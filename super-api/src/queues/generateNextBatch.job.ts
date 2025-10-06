import { prisma } from "../utils/prisma";
import { generateVocabulary } from "../services/openAiService";
import { addDeliveryToQueue, getQueuedDeliveriesCount } from "../api/daily/preload-service";

export async function generateNextBatchJob({ userId }: { userId: string }) {
  console.log(`🔄 Generating next batch for user: ${userId}`);
  
  const user = await prisma.user.findUnique({ 
    where: { id: userId }, 
    include: { topics: true } 
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
    console.log(`✅ Sufficient cache exists for user: ${userId}`);
    return; // already have enough cache
  }

  const needed = 5 - queued;
  console.log(`🎯 Generating ${needed} new words for user: ${userId}`);

  try {
    // Select a random topic from user's topics
    const randomTopic = user.topics[Math.floor(Math.random() * user.topics.length)];
    
    const newWords = await generateVocabulary({
      topic: randomTopic.topicId,
      numTerms: needed,
    });

    console.log(`✅ Generated ${newWords.length} words for topic: ${randomTopic.topicId}`);

    // Add each word to the delivery queue
    for (const word of newWords) {
      await addDeliveryToQueue(userId, word.termId);
    }

    console.log(`✅ Successfully queued ${newWords.length} words for user: ${userId}`);
  } catch (error) {
    console.error(`❌ Error generating batch for user ${userId}:`, error);
    throw error;
  }
}
