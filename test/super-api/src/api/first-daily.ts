import * as express from 'express';
import { database } from '../utils/prisma';
import { getNextDailyWord, createDelivery, addToWordbank } from '../services/deliveryService';

const router = express.Router();

/**
 * Get first daily word for user (immediately after onboarding)
 */
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    console.log(`🎯 Getting first daily word for user ${userId}`);
    
    // Check if user exists and has completed onboarding
    const user = await database.users.getById(userId);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    if (!user.onboarding_completed) {
      return res.status(400).json({ error: 'User must complete onboarding first' });
    }
    
    // If first vocab already generated, get the existing delivery
    if (user.first_vocab_generated) {
      console.log(`✅ First vocab already generated, returning existing delivery`);
      
      // Get the most recent delivery for this user
      const deliveries = await database.deliveries.getAll({ userId });
      const latestDelivery = deliveries.sort((a, b) => 
        new Date(b.delivered_at).getTime() - new Date(a.delivered_at).getTime()
      )[0];
      
      if (latestDelivery) {
        const term = await database.terms.getById(latestDelivery.term_id);
        
        if (term) {
          return res.json({
            success: true,
            isFirstWord: true,
            word: {
              deliveryId: latestDelivery.id,
              termId: term.id,
              term: term.term,
              definition: term.definition,
              example: term.example,
              category: term.category,
              complexityLevel: term.complexity_level,
              topicId: term.topic_id,
              deliveredAt: latestDelivery.delivered_at,
              openedAt: latestDelivery.opened_at,
              action: latestDelivery.action
            }
          });
        }
      }
    }
    
    // First vocab not generated yet, generate it now
    console.log(`🚀 Generating first vocabulary for user ${userId}`);
    
    const wordSelection = await getNextDailyWord(userId);
    
    if (!wordSelection) {
      return res.status(500).json({ 
        error: 'Failed to generate first vocabulary',
        message: 'Please try again in a few moments'
      });
    }
    
    // Create delivery record
    const delivery = await createDelivery(userId, wordSelection.termId);
    
    // Add to wordbank for spaced repetition
    await addToWordbank(userId, wordSelection.termId, 1);
    
    // Update user to mark first vocab as generated
    await database.users.update(userId, {
      first_vocab_generated: true,
      last_daily_word_date: new Date().toISOString(),
      daily_word_streak: 1
    });
    
    console.log(`✅ First daily word delivered: ${wordSelection.term}`);
    
    res.json({
      success: true,
      isFirstWord: true,
      word: {
        deliveryId: delivery.id,
        termId: wordSelection.termId,
        term: wordSelection.term,
        definition: wordSelection.definition,
        example: wordSelection.example,
        category: wordSelection.category,
        complexityLevel: wordSelection.complexityLevel,
        topicId: wordSelection.topicId,
        deliveredAt: delivery.delivered_at,
        openedAt: delivery.opened_at,
        action: delivery.action
      }
    });
    
  } catch (error: any) {
    console.error('❌ Get first daily word error:', error);
    res.status(500).json({ 
      error: 'Failed to get first daily word',
      details: error.message 
    });
  }
});

/**
 * Get regular daily word (for returning users)
 */
router.get('/daily/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    console.log(`📅 Getting daily word for user ${userId}`);
    
    // Check if user exists and has completed onboarding
    const user = await database.users.getById(userId);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    if (!user.onboarding_completed) {
      return res.status(400).json({ error: 'User must complete onboarding first' });
    }
    
    // Get next daily word using spaced repetition
    const wordSelection = await getNextDailyWord(userId);
    
    if (!wordSelection) {
      return res.status(500).json({ 
        error: 'No vocabulary available',
        message: 'Please add more topics to your interests'
      });
    }
    
    // Create delivery record
    const delivery = await createDelivery(userId, wordSelection.termId);
    
    // Update user's daily streak
    const today = new Date().toDateString();
    const lastWordDate = user.last_daily_word_date ? new Date(user.last_daily_word_date).toDateString() : null;
    
    let newStreak = user.daily_word_streak;
    if (lastWordDate !== today) {
      // Check if it's consecutive day
      if (lastWordDate && new Date(today).getTime() - new Date(lastWordDate).getTime() === 24 * 60 * 60 * 1000) {
        newStreak += 1;
      } else {
        newStreak = 1; // Reset streak if not consecutive
      }
    }
    
    await database.users.update(userId, {
      last_daily_word_date: new Date().toISOString(),
      daily_word_streak: newStreak
    });
    
    console.log(`✅ Daily word delivered: ${wordSelection.term} (streak: ${newStreak})`);
    
    res.json({
      success: true,
      isFirstWord: false,
      word: {
        deliveryId: delivery.id,
        termId: wordSelection.termId,
        term: wordSelection.term,
        definition: wordSelection.definition,
        example: wordSelection.example,
        category: wordSelection.category,
        complexityLevel: wordSelection.complexityLevel,
        topicId: wordSelection.topicId,
        deliveredAt: delivery.delivered_at,
        openedAt: delivery.opened_at,
        action: delivery.action
      },
      streak: newStreak
    });
    
  } catch (error: any) {
    console.error('❌ Get daily word error:', error);
    res.status(500).json({ 
      error: 'Failed to get daily word',
      details: error.message 
    });
  }
});

export default router;
