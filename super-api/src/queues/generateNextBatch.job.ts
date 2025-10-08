import { prisma } from "../utils/prisma";
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
    
    // Generate vocabulary for the selected topic
    const result = await generateVocabulary({
      topic: topicName,
      numTerms: needed,
      termSelectionLevel: user.preferredDifficulty as any || 'intermediate',
      definitionComplexityLevel: user.preferredDifficulty as any || 'intermediate',
    });

    if (!result || !result.terms || result.terms.length === 0) {
      console.error(`❌ No terms generated for topic: ${topicName}`);
      return;
    }

    console.log(`✅ Generated ${result.terms.length} terms for topic: ${topicName}`);

    // Save each term and add to delivery queue
    for (const termData of result.terms) {
      // Create term in database
      const term = await prisma.term.create({
        data: {
          topicId: userTopic.topicId,
          term: termData.term,
          definition: termData.definition,
          example: termData.example || termData.definition,
          category: 'Vocabulary',
          complexityLevel: termData.complexityLevel || 'Intermediate',
          source: 'AI Generated',
          confidenceScore: 0.8,
          moderationStatus: 'approved', // Auto-approve generated terms
          gptGenerated: true,
          verified: true,
        }
      });

      // Add to delivery queue
      await addDeliveryToQueue(userId, term.id);
      
      console.log(`📦 Queued term: ${term.term} (ID: ${term.id})`);
    }

    console.log(`✅ Successfully queued ${result.terms.length} words for user: ${userId}`);
  } catch (error) {
    console.error(`❌ Error generating batch for user ${userId}:`, error);
    throw error;
  }
}
