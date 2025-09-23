import { database } from '../utils/prisma';
import { generateVocabulary } from './openAiService';

export interface DeliveryAction {
  type: 'FAVORITE' | 'LEARN_AGAIN' | 'MASTERED' | 'NONE';
  deliveryId: string;
}

export interface WordSelection {
  termId: string;
  term: string;
  definition: string;
  example: string;
  category: string;
  complexityLevel: string;
  topicId: string;
}

/**
 * Create a delivery record for a word
 */
export async function createDelivery(userId: string, termId: string): Promise<any> {
  console.log(`📦 Creating delivery for user ${userId}, term ${termId}`);
  
  const delivery = await database.deliveries.create({
    user_id: userId,
    term_id: termId,
    delivered_at: new Date().toISOString(),
    action: 'NONE'
  });
  
  console.log(`✅ Delivery created: ${delivery.id}`);
  return delivery;
}

/**
 * Update delivery action when user interacts with a word
 */
export async function updateDeliveryAction(deliveryId: string, action: string): Promise<any> {
  console.log(`🔄 Updating delivery ${deliveryId} action to ${action}`);
  
  const updateData: any = { action };
  
  // If opening for the first time, set opened_at
  if (action !== 'NONE') {
    updateData.opened_at = new Date().toISOString();
  }
  
  const delivery = await database.deliveries.update(deliveryId, updateData);
  
  console.log(`✅ Delivery updated: ${delivery.id}`);
  return delivery;
}

/**
 * Add a word to user's wordbank for spaced repetition
 */
export async function addToWordbank(userId: string, termId: string, bucket: number = 1): Promise<any> {
  console.log(`📚 Adding term ${termId} to wordbank for user ${userId} (bucket ${bucket})`);
  
  // Check if already exists
  const existing = await database.wordbank.getByUserAndTerm(userId, termId);
  if (existing) {
    console.log(`⚠️ Term already in wordbank, updating bucket`);
    return await database.wordbank.update(existing.id, { bucket });
  }
  
  // Calculate next review date based on bucket (spaced repetition)
  const nextReview = calculateNextReview(bucket);
  
  const wordbankEntry = await database.wordbank.create({
    user_id: userId,
    term_id: termId,
    status: 'LEARNING',
    bucket,
    last_reviewed: new Date().toISOString(),
    next_review: nextReview,
    review_count: 0
  });
  
  console.log(`✅ Added to wordbank: ${wordbankEntry.id}, next review: ${nextReview}`);
  return wordbankEntry;
}

/**
 * Get next daily word for user using spaced repetition
 */
export async function getNextDailyWord(userId: string): Promise<WordSelection | null> {
  console.log(`🎯 Getting next daily word for user ${userId}`);
  
  // First, check for words due for review
  const reviewWords = await database.wordbank.getNextReviewWords(userId);
  
  if (reviewWords && reviewWords.length > 0) {
    // Return the most overdue word
    const wordToReview = reviewWords[0];
    const term = await database.terms.getById(wordToReview.term_id);
    
    if (term) {
      console.log(`📖 Returning review word: ${term.term}`);
      return {
        termId: term.id,
        term: term.term,
        definition: term.definition,
        example: term.example,
        category: term.category,
        complexityLevel: term.complexity_level,
        topicId: term.topic_id
      };
    }
  }
  
  // No words to review, check if user has topics
  const userTopics = await database.userTopics.getAll({ userId });
  
  if (!userTopics || userTopics.length === 0) {
    console.log(`⚠️ No topics found for user ${userId}`);
    return null;
  }
  
  // Get a random topic for new word generation
  const randomTopic = userTopics[Math.floor(Math.random() * userTopics.length)];
  const topic = await database.topics.getById(randomTopic.topic_id);
  
  if (!topic) {
    console.log(`⚠️ Topic not found: ${randomTopic.topic_id}`);
    return null;
  }
  
  // Generate new vocabulary for this topic
  console.log(`🚀 Generating new vocabulary for topic: ${topic.name}`);
  
  try {
    const result = await generateVocabulary({
      topic: topic.name,
      termSelectionLevel: 'intermediate',
      definitionComplexityLevel: 'intermediate',
      numTerms: 1
    });
    
    if (result && result.terms && result.terms.length > 0) {
      const newTerm = result.terms[0];
      
      // Save the term to database
      const savedTerm = await database.terms.create({
        topic_id: topic.id,
        term: newTerm.term,
        definition: newTerm.definition,
        example: newTerm.example,
        source: 'OpenAI',
        verified: false,
        gpt_generated: true,
        confidence_score: 0.9,
        category: newTerm.category || 'general',
        complexity_level: newTerm.complexityLevel || 'intermediate'
      });
      
      console.log(`✅ Generated new term: ${savedTerm.term}`);
      
      return {
        termId: savedTerm.id,
        term: savedTerm.term,
        definition: savedTerm.definition,
        example: savedTerm.example,
        category: savedTerm.category,
        complexityLevel: savedTerm.complexity_level,
        topicId: savedTerm.topic_id
      };
    }
  } catch (error) {
    console.error(`❌ Error generating vocabulary:`, error);
  }
  
  return null;
}

/**
 * Handle user action on a delivered word
 */
export async function handleWordAction(userId: string, deliveryId: string, action: string): Promise<any> {
  console.log(`🎬 Handling word action: ${action} for delivery ${deliveryId}`);
  
  // Update delivery action
  await updateDeliveryAction(deliveryId, action);
  
  // Get the delivery to find the term
  const delivery = await database.deliveries.getById(deliveryId);
  
  if (!delivery) {
    throw new Error(`Delivery not found: ${deliveryId}`);
  }
  
  // Handle different actions
  switch (action) {
    case 'FAVORITE':
      // Keep in current bucket but mark as favorite
      console.log(`❤️ Word favorited: ${delivery.term_id}`);
      break;
      
    case 'LEARN_AGAIN':
      // Move to bucket 1 for faster review
      await addToWordbank(userId, delivery.term_id, 1);
      console.log(`🔄 Word marked for learning again: ${delivery.term_id}`);
      break;
      
    case 'MASTERED':
      // Move to mastered status
      const wordbankEntry = await database.wordbank.getByUserAndTerm(userId, delivery.term_id);
      if (wordbankEntry) {
        await database.wordbank.update(wordbankEntry.id, { status: 'MASTERED' });
      }
      console.log(`🎓 Word mastered: ${delivery.term_id}`);
      break;
  }
  
  return { success: true, action };
}

/**
 * Calculate next review date based on bucket (Leitner system)
 */
function calculateNextReview(bucket: number): string {
  const now = new Date();
  let daysToAdd = 1; // Default to 1 day
  
  switch (bucket) {
    case 1: daysToAdd = 1; break;    // Review tomorrow
    case 2: daysToAdd = 3; break;    // Review in 3 days
    case 3: daysToAdd = 7; break;    // Review in 1 week
    case 4: daysToAdd = 14; break;   // Review in 2 weeks
    case 5: daysToAdd = 30; break;   // Review in 1 month
    default: daysToAdd = 1;
  }
  
  const nextReview = new Date(now.getTime() + (daysToAdd * 24 * 60 * 60 * 1000));
  return nextReview.toISOString();
}
