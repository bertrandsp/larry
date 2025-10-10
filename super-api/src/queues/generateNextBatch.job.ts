import { prisma } from "../utils/prisma"; // Use pooled connection for workers
import { generateVocabulary } from "../services/openAiService";
import { addDeliveryToQueue, getQueuedDeliveriesCount } from "../api/daily/preload-service";

export async function generateNextBatchJob({ userId }: { userId: string }) {
  console.log(`🔄 Generating next batch for user: ${userId}`);
  
  const user = await prisma.user.findUnique({ 
    where: { id: userId }, 
    include: { 
      topics: {
        include: {
          topic: true
        }
      }
    } 
  });
  
  if (!user) {
    console.log(`❌ User not found: ${userId}`);
    return;
  }

  if (!user.topics || user.topics.length === 0) {
    console.log(`❌ No topics found for user: ${userId}`);
    return;
  }

  // Check if enough undelivered words exist
  const queued = await getQueuedDeliveriesCount(userId);
  console.log(`📊 Current queued deliveries: ${queued}`);

  if (queued >= 5) {
    console.log(`✅ Sufficient cache exists for user: ${userId} (${queued} words queued)`);
    return; // already have enough cache
  }

  const needed = 5 - queued;
  console.log(`🎯 Need to generate ${needed} new words for user: ${userId}`);

  try {
    // Select a random topic from user's topics
    const userTopic = user.topics[Math.floor(Math.random() * user.topics.length)];
    const topicName = userTopic.topic.name;
    
    console.log(`🎲 Selected topic: ${topicName} for batch generation`);
    
    // Fetch existing terms for this topic to avoid duplicates
    const existingTerms = await prisma.term.findMany({
      where: {
        topicId: userTopic.topicId
      },
      select: {
        term: true
      },
      take: 200 // Limit to recent 200 terms
    });
    
    const existingTermsList = existingTerms.map(t => t.term);
    console.log(`📋 Found ${existingTermsList.length} existing terms for topic ${topicName}`);
    
    // Generate vocabulary for the selected topic
    const result = await generateVocabulary({
      topic: topicName,
      numTerms: needed,
      termSelectionLevel: user.preferredDifficulty as any || 'intermediate',
      definitionComplexityLevel: user.preferredDifficulty as any || 'intermediate',
      existingTerms: existingTermsList, // Pass existing terms to avoid duplicates
    });

    if (!result || !result.response || !result.response.terms || result.response.terms.length === 0) {
      console.error(`❌ No terms generated for topic: ${topicName}`);
      return;
    }

    console.log(`✅ Generated ${result.response.terms.length} terms for topic: ${topicName}`);

    // Save each term and add to delivery queue
    let successCount = 0;
    for (const termData of result.response.terms) {
      try {
        // Use upsert to handle duplicates gracefully
        const term = await prisma.term.upsert({
          where: {
            topicId_term: {
              topicId: userTopic.topicId,
              term: termData.term
            }
          },
          create: {
            topicId: userTopic.topicId,
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
          },
          update: {
            // If term exists, optionally update the definition if it's better
            // For now, we'll just keep the existing one
          }
        });

        // Check if user has already seen this term
        const existingDelivery = await prisma.delivery.findFirst({
          where: {
            userId: userId,
            termId: term.id
          }
        });

        // Only add to queue if user hasn't seen it
        if (!existingDelivery) {
          await addDeliveryToQueue(userId, term.id);
          successCount++;
          console.log(`📦 Queued new term: ${term.term} (ID: ${term.id})`);
        } else {
          console.log(`⏭️  Skipping already seen term: ${term.term}`);
        }
      } catch (termError) {
        console.error(`❌ Error processing term "${termData.term}":`, termError);
        // Continue with next term instead of failing entire batch
      }
    }

    console.log(`✅ Successfully queued ${successCount} new words for user: ${userId}`);
  } catch (error) {
    console.error(`❌ Error generating batch for user ${userId}:`, error);
    throw error;
  }
}
