import { db } from '../lib/supabase';
import { generateVocabulary } from './openai';

export enum DeliveryAction {
  NONE = 'none',
  OPENED = 'opened',
  FAVORITED = 'favorited',
  LEARN_AGAIN = 'learn_again',
  MASTERED = 'mastered'
}

export enum WordStatus {
  LEARNING = 'learning',
  REVIEWING = 'reviewing',
  MASTERED = 'mastered',
  ARCHIVED = 'archived'
}

// Spaced repetition intervals (in days)
const INTERVALS = {
  learning: [1, 3, 7, 14, 30],  // Leitner system buckets
  reviewing: [7, 14, 30, 90],
  mastered: [180, 365]
};

export class DeliveryService {
  // Create a delivery record
  async createDelivery(userId: string, termId: string, action: DeliveryAction = DeliveryAction.NONE) {
    const delivery = await db.createDelivery({
      user_id: userId,
      term_id: termId,
      action: action,
      delivered_at: new Date().toISOString(),
      opened_at: action === DeliveryAction.OPENED ? new Date().toISOString() : null
    });

    console.log(`📬 Created delivery: ${delivery.id} for user ${userId}`);
    return delivery;
  }

  // Update delivery action
  async updateDeliveryAction(deliveryId: string, action: DeliveryAction) {
    const updates: any = { action };
    
    if (action === DeliveryAction.OPENED && !updates.opened_at) {
      updates.opened_at = new Date().toISOString();
    }

    const delivery = await db.updateDelivery(deliveryId, updates);
    console.log(`📝 Updated delivery ${deliveryId} with action: ${action}`);
    return delivery;
  }

  // Add word to user's wordbank
  async addToWordbank(userId: string, termId: string, initialStatus: WordStatus = WordStatus.LEARNING) {
    const wordbankEntry = await db.createWordbankEntry({
      user_id: userId,
      term_id: termId,
      status: initialStatus,
      bucket: 0, // Start in bucket 0 (most frequent review)
      review_count: 0,
      last_reviewed: null,
      next_review: new Date().toISOString(), // Available immediately
      ease_factor: 2.5, // Standard ease factor for spaced repetition
      streak: 0
    });

    console.log(`📚 Added to wordbank: ${wordbankEntry.id} for user ${userId}`);
    return wordbankEntry;
  }

  // Get next daily word for user
  async getNextDailyWord(userId: string) {
    console.log(`🎯 Getting next daily word for user: ${userId}`);

    // First, check if user has words due for review
    const wordsForReview = await db.getWordsForReview(userId, 1);
    
    if (wordsForReview && wordsForReview.length > 0) {
      const word = wordsForReview[0];
      console.log(`🔄 Returning word for review: ${word.terms.term}`);
      
      // Create delivery record
      const delivery = await this.createDelivery(userId, word.term_id);
      
      return {
        term: word.terms,
        delivery: delivery,
        type: 'review',
        wordbank_entry: word
      };
    }

    // If no words for review, generate a new word
    console.log(`🆕 No words for review, generating new word`);
    return await this.generateNewWord(userId);
  }

  // Generate new vocabulary word for user
  async generateNewWord(userId: string) {
    // Get user's topics
    const userTopics = await db.getUserTopics(userId);
    
    if (!userTopics || userTopics.length === 0) {
      throw new Error('User has no topics configured');
    }

    // Select topic based on weights (simple random for now)
    const randomTopic = userTopics[Math.floor(Math.random() * userTopics.length)];
    const topic = randomTopic.topics;

    console.log(`🎲 Selected topic: ${topic.name} for vocabulary generation`);

    // Generate vocabulary
    const vocabResult = await generateVocabulary(topic.name, 1, 'intermediate');
    
    if (!vocabResult.terms || vocabResult.terms.length === 0) {
      throw new Error('No vocabulary generated');
    }

    const newTerm = vocabResult.terms[0];

    // Save term to database
    const savedTerm = await db.createTerm({
      topic_id: topic.id,
      term: newTerm.term,
      definition: newTerm.definition,
      example: newTerm.examples && newTerm.examples.length > 0 ? newTerm.examples[0] : '',
      pronunciation: newTerm.pronunciation || '',
      etymology: newTerm.etymology || '',
      category: newTerm.category || 'general',
      complexity_level: newTerm.difficulty || 'intermediate',
      source: 'OpenAI',
      verified: false,
      gpt_generated: true,
      confidence_score: 0.9
    });

    console.log(`✅ Generated new term: ${savedTerm.term}`);

    // Create delivery record
    const delivery = await this.createDelivery(userId, savedTerm.id);

    // Add to wordbank
    const wordbankEntry = await this.addToWordbank(userId, savedTerm.id);

    return {
      term: savedTerm,
      delivery: delivery,
      type: 'new',
      wordbank_entry: wordbankEntry
    };
  }

  // Handle word action (favorite, learn again, mastered)
  async handleWordAction(userId: string, termId: string, deliveryId: string, action: DeliveryAction) {
    console.log(`🎬 Handling word action: ${action} for user ${userId}, term ${termId}`);

    // Update delivery
    await this.updateDeliveryAction(deliveryId, action);

    // Update wordbank based on action
    await this.updateWordbankForAction(userId, termId, action);

    return { success: true, action };
  }

  // Update wordbank entry based on user action
  async updateWordbankForAction(userId: string, termId: string, action: DeliveryAction) {
    const wordbank = await db.getUserWordbank(userId);
    const entry = wordbank.find(w => w.term_id === termId);

    if (!entry) {
      console.log(`⚠️ No wordbank entry found for term ${termId}`);
      return;
    }

    const updates: any = {
      last_reviewed: new Date().toISOString(),
      review_count: entry.review_count + 1
    };

    switch (action) {
      case DeliveryAction.LEARN_AGAIN:
        // Move back to bucket 0 (more frequent review)
        updates.bucket = 0;
        updates.next_review = this.calculateNextReview(0, WordStatus.LEARNING);
        updates.streak = 0;
        updates.status = WordStatus.LEARNING;
        break;

      case DeliveryAction.MASTERED:
        // Move to mastered status
        updates.status = WordStatus.MASTERED;
        updates.next_review = this.calculateNextReview(0, WordStatus.MASTERED);
        updates.streak = entry.streak + 1;
        break;

      case DeliveryAction.FAVORITED:
        // Keep current schedule but mark as favorite
        updates.favorited = true;
        break;

      default:
        // Normal progression - move to next bucket
        const newBucket = Math.min(entry.bucket + 1, INTERVALS.learning.length - 1);
        updates.bucket = newBucket;
        updates.next_review = this.calculateNextReview(newBucket, entry.status);
        updates.streak = entry.streak + 1;
        
        // Graduate to reviewing status if in higher buckets
        if (newBucket >= 3 && entry.status === WordStatus.LEARNING) {
          updates.status = WordStatus.REVIEWING;
        }
        break;
    }

    await db.updateWordbankEntry(userId, termId, updates);
    console.log(`📝 Updated wordbank entry for term ${termId}, bucket: ${updates.bucket}`);
  }

  // Calculate next review date based on bucket and status
  calculateNextReview(bucket: number, status: WordStatus): string {
    let days: number;

    switch (status) {
      case WordStatus.LEARNING:
        days = INTERVALS.learning[bucket] || 1;
        break;
      case WordStatus.REVIEWING:
        days = INTERVALS.reviewing[Math.min(bucket, INTERVALS.reviewing.length - 1)] || 7;
        break;
      case WordStatus.MASTERED:
        days = INTERVALS.mastered[Math.min(bucket, INTERVALS.mastered.length - 1)] || 180;
        break;
      default:
        days = 1;
    }

    const nextReview = new Date();
    nextReview.setDate(nextReview.getDate() + days);
    return nextReview.toISOString();
  }

  // Generate first vocabulary after onboarding
  async generateFirstVocabulary(userId: string) {
    console.log(`🎉 Generating first vocabulary for user: ${userId}`);
    
    try {
      const result = await this.generateNewWord(userId);
      
      // Mark user as having first vocab generated
      await db.updateUser(userId, {
        first_vocab_generated: true,
        onboarding_completed: true
      });

      console.log(`✅ First vocabulary generated successfully for user: ${userId}`);
      return result;
    } catch (error) {
      console.error(`❌ Failed to generate first vocabulary for user ${userId}:`, error);
      throw error;
    }
  }
}

export const deliveryService = new DeliveryService();
