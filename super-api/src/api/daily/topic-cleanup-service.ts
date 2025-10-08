import { prisma } from "../../utils/prisma"; // Use pooled connection for all operations

/**
 * Clean up deliveries for topics that user no longer has enabled
 * Uses regular prisma (pooled) since this is called from API endpoints
 */
export async function cleanupStaleDeliveries(userId: string): Promise<number> {
  console.log(`🧹 Cleaning up stale deliveries for user: ${userId}`);
  
  try {
    // Get user's current active topic IDs
    const userTopics = await prisma.userTopic.findMany({
      where: {
        userId,
        enabled: true
      },
      select: {
        topicId: true
      }
    });

    const activeTopicIds = userTopics.map(ut => ut.topicId);
    
    if (activeTopicIds.length === 0) {
      console.log('⚠️ User has no active topics, keeping deliveries for potential re-enable');
      return 0;
    }

    // Find deliveries for terms that are NOT from user's current topics
    const staleDeliveries = await prisma.delivery.findMany({
      where: {
        userId,
        openedAt: null, // Only undelivered words
        term: {
          topicId: {
            notIn: activeTopicIds
          }
        }
      },
      select: {
        id: true,
        term: {
          select: {
            term: true,
            topic: {
              select: {
                name: true
              }
            }
          }
        }
      }
    });

    if (staleDeliveries.length === 0) {
      console.log('✅ No stale deliveries found');
      return 0;
    }

    console.log(`🗑️ Found ${staleDeliveries.length} stale deliveries to remove:`);
    staleDeliveries.slice(0, 5).forEach(d => {
      console.log(`   - ${d.term.term} (from ${d.term.topic?.name})`);
    });
    if (staleDeliveries.length > 5) {
      console.log(`   ... and ${staleDeliveries.length - 5} more`);
    }

    // Delete stale deliveries
    const deleteResult = await prisma.delivery.deleteMany({
      where: {
        id: {
          in: staleDeliveries.map(d => d.id)
        }
      }
    });

    console.log(`✅ Removed ${deleteResult.count} stale deliveries`);
    return deleteResult.count;

  } catch (error) {
    console.error('❌ Error cleaning up stale deliveries:', error);
    // Don't throw - allow request to continue even if cleanup fails
    return 0;
  }
}

/**
 * Get queue-aware delivery that respects user's current topics
 * Uses regular prisma (pooled) since this is called from API endpoints
 */
export async function getNextQueuedDeliveryForActiveTopics(userId: string) {
  try {
    // Get user's current active topic IDs
    const userTopics = await prisma.userTopic.findMany({
      where: {
        userId,
        enabled: true
      },
      select: {
        topicId: true
      }
    });

    const activeTopicIds = userTopics.map(ut => ut.topicId);
    
    if (activeTopicIds.length === 0) {
      console.log('⚠️ User has no active topics');
      return null;
    }

    // Find delivery for a term from user's CURRENT active topics only
    return await prisma.delivery.findFirst({
      where: {
        userId,
        openedAt: null,
        term: {
          topicId: {
            in: activeTopicIds
          }
        }
      },
      include: {
        term: {
          include: {
            topic: true
          }
        }
      },
      orderBy: {
        createdAt: "asc"
      },
    });
  } catch (error) {
    console.error('❌ Error getting queued delivery for active topics:', error);
    return null;
  }
}

/**
 * Trigger immediate generation for a newly added topic
 * Uses pooled connection (safe for background operations with reasonable concurrency)
 */
export async function generateForNewTopic(userId: string, topicId: string, topicName: string): Promise<void> {
  console.log(`🆕 Generating initial words for new topic: ${topicName}`);
  
  try {
    const { generateVocabulary } = await import('../../services/openAiService');
    
    // Get user preferences using pooled connection
    const user = await prisma.user.findUnique({
      where: { id: userId }
    });

    // Generate initial batch of 3 words for immediate use
    const result = await generateVocabulary({
      topic: topicName,
      numTerms: 3,
      termSelectionLevel: user?.preferredDifficulty as any || 'intermediate',
      definitionComplexityLevel: user?.preferredDifficulty as any || 'intermediate',
    });

    if (!result || !result.terms || result.terms.length === 0) {
      console.error(`❌ No terms generated for topic: ${topicName}`);
      return;
    }

    console.log(`✅ Generated ${result.terms.length} terms for new topic: ${topicName}`);

    // Save each term and add to delivery queue using pooled connection
    for (const termData of result.terms) {
      const term = await prisma.term.create({
        data: {
          topicId,
          term: termData.term,
          definition: termData.definition,
          example: termData.example || termData.definition,
          category: 'Vocabulary',
          complexityLevel: termData.complexityLevel || 'Intermediate',
          source: 'AI Generated',
          confidenceScore: 0.8,
          moderationStatus: 'approved',
          gptGenerated: true,
          verified: true,
        }
      });

      // Add to delivery queue
      await prisma.delivery.create({
        data: {
          userId,
          termId: term.id
        }
      });

      console.log(`📦 Queued new term: ${term.term}`);
    }

    console.log(`✅ New topic ready with ${result.terms.length} words queued`);
  } catch (error) {
    console.error(`❌ Error generating for new topic ${topicName}:`, error);
    // Don't throw - this runs in background
  }
}
