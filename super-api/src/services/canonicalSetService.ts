import { prisma } from '../utils/prisma';
import { topicPipelineQueue } from '../queues/topicPipelineQueue';

export interface CanonicalSetCreationParams {
  topicName: string;
  userId?: string; // Optional: user who triggered creation
}

export interface CanonicalSetResult {
  id: string;
  topicName: string;
  wasCreated: boolean;
  existingTopicId?: string;
}

/**
 * Get or create a canonical set for a topic
 * This prevents duplication of processing and allows shared term sets across users
 */
export async function getOrCreateCanonicalSetForTopic(
  topicName: string
): Promise<CanonicalSetResult> {
  try {
    console.log(`🔍 Checking for existing canonical set for topic: ${topicName}`);
    
    // Normalize topic name (lowercase, remove punctuation)
    const normalizedName = topicName.trim().toLowerCase();
    
    // Check for existing topic with canonical set
    const existingTopic = await prisma.topic.findFirst({
      where: { 
        name: { equals: normalizedName, mode: 'insensitive' },
        canonicalSetId: { not: null }
      },
      include: { canonicalSet: true }
    });
    
    if (existingTopic?.canonicalSet) {
      console.log(`✅ Found existing canonical set for topic: ${topicName}`);
      return {
        id: existingTopic.canonicalSet.id,
        topicName: existingTopic.name,
        wasCreated: false,
        existingTopicId: existingTopic.id
      };
    }
    
    // Check for existing topic without canonical set
    const topicWithoutCanonical = await prisma.topic.findFirst({
      where: { 
        name: { equals: normalizedName, mode: 'insensitive' },
        canonicalSetId: null
      }
    });
    
    if (topicWithoutCanonical) {
      console.log(`📝 Found existing topic without canonical set: ${topicName}, creating one...`);
      return await createCanonicalSetForExistingTopic(topicWithoutCanonical.id, topicName);
    }
    
    // Create new topic and canonical set
    console.log(`🆕 Creating new topic and canonical set for: ${topicName}`);
    return await createNewTopicWithCanonicalSet(topicName);
    
  } catch (error) {
    console.error(`❌ Error in getOrCreateCanonicalSetForTopic:`, error);
    throw error;
  }
}

/**
 * Create a canonical set for an existing topic
 */
async function createCanonicalSetForExistingTopic(
  topicId: string, 
  topicName: string
): Promise<CanonicalSetResult> {
  try {
    // Create new canonical set
    const canonicalSet = await prisma.canonicalSet.create({
      data: {}
    });
    
    // Update existing topic to link to canonical set
    await prisma.topic.update({
      where: { id: topicId },
      data: { canonicalSetId: canonicalSet.id }
    });
    
    // Move existing terms to canonical set
    await prisma.term.updateMany({
      where: { topicId },
      data: { canonicalSetId: canonicalSet.id }
    });
    
    // Move existing facts to canonical set (if facts table supports it)
    // Note: Current schema doesn't have canonicalSetId for facts
    
    console.log(`✅ Created canonical set for existing topic: ${topicName}`);
    
    return {
      id: canonicalSet.id,
      topicName,
      wasCreated: true,
      existingTopicId: topicId
    };
    
  } catch (error) {
    console.error(`❌ Error creating canonical set for existing topic:`, error);
    throw error;
  }
}

/**
 * Create a new topic with canonical set
 */
async function createNewTopicWithCanonicalSet(
  topicName: string
): Promise<CanonicalSetResult> {
  try {
    // Create canonical set first
    const canonicalSet = await prisma.canonicalSet.create({
      data: {}
    });
    
    // Create new topic linked to canonical set
    const newTopic = await prisma.topic.create({
      data: {
        name: topicName,
        canonicalSetId: canonicalSet.id
      }
    });
    
    console.log(`✅ Created new topic with canonical set: ${topicName}`);
    
    return {
      id: canonicalSet.id,
      topicName,
      wasCreated: true
    };
    
  } catch (error) {
    console.error(`❌ Error creating new topic with canonical set:`, error);
    throw error;
  }
}

/**
 * Create a canonical set with initial content
 * This is called when a new topic is submitted and needs terms/facts generated
 */
export async function createCanonicalSetWithContent(
  params: CanonicalSetCreationParams
): Promise<CanonicalSetResult> {
  try {
    const { topicName, userId } = params;
    
    // Get or create canonical set
    const canonicalSetResult = await getOrCreateCanonicalSetForTopic(topicName);
    
    // If this is a new canonical set, queue content generation
    if (canonicalSetResult.wasCreated) {
      console.log(`🚀 Queuing content generation for new canonical set: ${topicName}`);
      
      // Find the topic ID (either existing or newly created)
      const topic = await prisma.topic.findFirst({
        where: { 
          name: { equals: topicName, mode: 'insensitive' },
          canonicalSetId: canonicalSetResult.id
        }
      });
      
      if (topic && userId) {
        // Queue the generation job
        await topicPipelineQueue.add('generate', {
          userId,
          topicId: topic.id,
          topicName: topic.name,
          userTier: 'free', // Default tier for canonical set generation
          isCanonicalSet: true
        });
        
        console.log(`📋 Queued canonical set generation for topic: ${topicName}`);
      }
    }
    
    return canonicalSetResult;
    
  } catch (error) {
    console.error(`❌ Error creating canonical set with content:`, error);
    throw error;
  }
}

/**
 * Get canonical set statistics
 */
export async function getCanonicalSetStats(canonicalSetId: string) {
  try {
    const [termCount, topicCount, userCount] = await Promise.all([
      prisma.term.count({ where: { canonicalSetId } }),
      prisma.topic.count({ where: { canonicalSetId } }),
      prisma.userTopic.count({
        where: {
          topic: { canonicalSetId }
        }
      })
    ]);
    
    return {
      termCount,
      topicCount,
      userCount,
      efficiency: topicCount > 0 ? termCount / topicCount : 0
    };
    
  } catch (error) {
    console.error(`❌ Error getting canonical set stats:`, error);
    throw error;
  }
}

/**
 * Clean up orphaned canonical sets (topics with no users)
 */
export async function cleanupOrphanedCanonicalSets() {
  try {
    const orphanedSets = await prisma.canonicalSet.findMany({
      where: {
        topics: {
          none: {
            userTopics: {
              some: {}
            }
          }
        }
      }
    });
    
    console.log(`🧹 Found ${orphanedSets.length} orphaned canonical sets`);
    
    for (const set of orphanedSets) {
      // Delete terms first
      await prisma.term.deleteMany({
        where: { canonicalSetId: set.id }
      });
      
      // Delete the canonical set
      await prisma.canonicalSet.delete({
        where: { id: set.id }
      });
      
      console.log(`🗑️ Cleaned up orphaned canonical set: ${set.id}`);
    }
    
    return { cleanedCount: orphanedSets.length };
    
  } catch (error) {
    console.error(`❌ Error cleaning up orphaned canonical sets:`, error);
    throw error;
  }
}
