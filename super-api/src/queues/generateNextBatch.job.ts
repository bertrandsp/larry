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
  const requestCount = Math.ceil(needed * 2); // Request 2x to account for ~40% duplicate rate
  console.log(`🎯 Need to generate ${needed} new words for user: ${userId} (requesting ${requestCount} to account for duplicates)`);

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
      numTerms: requestCount,
      definitionStyle: 'formal',
      sentenceRange: '2-3',
      numExamples: 1,
      numFacts: 0,
      termSelectionLevel: user.preferredDifficulty as any || 'intermediate',
      definitionComplexityLevel: user.preferredDifficulty as any || 'intermediate',
      domainContext: topicName,
      language: 'en',
      useAnalogy: false,
      includeSynonyms: true,
      includeAntonyms: false,
      includeRelatedTerms: true,
      includeEtymology: false,
      highlightRootWords: false,
      openAiFirst: true,
      existingTerms: existingTermsList, // Pass existing terms to avoid duplicates
    });

    if (!result || !result.response || !result.response.terms || result.response.terms.length === 0) {
      console.error(`❌ No terms generated for topic: ${topicName}`);
      return;
    }

    console.log(`✅ Generated ${result.response.terms.length} terms for topic: ${topicName}` + 
      ` (requested ${requestCount}, need to successfully queue ${needed})`);

    // Filter out duplicates BEFORE processing to avoid wasted database operations
    const uniqueTerms = result.response.terms.filter(termData => {
      const termLower = termData.term.toLowerCase().trim();
      return !existingTermsList.some(existing => 
        existing.toLowerCase().trim() === termLower
      );
    });
    
    const duplicateCount = result.response.terms.length - uniqueTerms.length;
    if (duplicateCount > 0) {
      console.log(`🔍 Filtered out ${duplicateCount} duplicate terms before processing`);
    }

    // Save each unique term and add to delivery queue
    let successCount = 0;
    for (const termData of uniqueTerms) {
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
            example: termData.examples?.[0] || termData.definition,
            category: 'Vocabulary',
            complexityLevel: 'Intermediate',
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
    
    // Retry logic if we didn't queue enough terms
    if (successCount < needed) {
      const remaining = needed - successCount;
      console.log(`⚠️ Only queued ${successCount}/${needed} terms, retrying for ${remaining} more...`);
      
      try {
        // Retry with a different topic to increase chances of new terms
        const alternativeTopic = user.topics[Math.floor(Math.random() * user.topics.length)];
        const alternativeTopicName = alternativeTopic.topic.name;
        
        console.log(`🔄 Retry: Selected alternative topic: ${alternativeTopicName}`);
        
        // Fetch existing terms for the alternative topic
        const altExistingTerms = await prisma.term.findMany({
          where: {
            topicId: alternativeTopic.topicId
          },
          select: {
            term: true
          },
          take: 200
        });
        
        const altExistingTermsList = altExistingTerms.map(t => t.term);
        
        // Generate additional vocabulary
        const retryResult = await generateVocabulary({
          topic: alternativeTopicName,
          numTerms: remaining * 2, // Request 2x remaining to account for duplicates
          definitionStyle: 'formal',
          sentenceRange: '2-3',
          numExamples: 1,
          numFacts: 0,
          termSelectionLevel: user.preferredDifficulty as any || 'intermediate',
          definitionComplexityLevel: user.preferredDifficulty as any || 'intermediate',
          domainContext: alternativeTopicName,
          language: 'en',
          useAnalogy: false,
          includeSynonyms: true,
          includeAntonyms: false,
          includeRelatedTerms: true,
          includeEtymology: false,
          highlightRootWords: false,
          openAiFirst: true,
          existingTerms: altExistingTermsList,
        });
        
        if (retryResult && retryResult.response && retryResult.response.terms) {
          console.log(`🔄 Retry generated ${retryResult.response.terms.length} additional terms`);
          
          // Filter out duplicates from retry results
          const uniqueRetryTerms = retryResult.response.terms.filter(termData => {
            const termLower = termData.term.toLowerCase().trim();
            return !altExistingTermsList.some(existing => 
              existing.toLowerCase().trim() === termLower
            );
          });
          
          const retryDuplicateCount = retryResult.response.terms.length - uniqueRetryTerms.length;
          if (retryDuplicateCount > 0) {
            console.log(`🔍 Retry: Filtered out ${retryDuplicateCount} duplicate terms before processing`);
          }
          
          for (const termData of uniqueRetryTerms) {
            try {
              const term = await prisma.term.upsert({
                where: {
                  topicId_term: {
                    topicId: alternativeTopic.topicId,
                    term: termData.term
                  }
                },
                create: {
                  topicId: alternativeTopic.topicId,
                  term: termData.term,
                  definition: termData.definition,
                  example: termData.examples?.[0] || termData.definition,
                  category: 'Vocabulary',
                  complexityLevel: 'Intermediate',
                  source: 'AI Generated',
                  confidenceScore: 0.8,
                  moderationStatus: 'approved',
                  gptGenerated: true,
                  verified: true,
                },
                update: {}
              });

              const existingDelivery = await prisma.delivery.findFirst({
                where: {
                  userId: userId,
                  termId: term.id
                }
              });

              if (!existingDelivery) {
                await addDeliveryToQueue(userId, term.id);
                successCount++;
                console.log(`📦 Retry: Queued new term: ${term.term}`);
                
                // Stop if we've reached the target
                if (successCount >= needed) {
                  break;
                }
              }
            } catch (termError) {
              console.error(`❌ Retry: Error processing term "${termData.term}":`, termError);
            }
          }
          
          console.log(`✅ After retry: Successfully queued ${successCount}/${needed} total words`);
        }
      } catch (retryError) {
        console.error(`❌ Error in retry logic:`, retryError);
        // Don't throw - we've already queued some terms
      }
    }
  } catch (error) {
    console.error(`❌ Error generating batch for user ${userId}:`, error);
    throw error;
  }
}
