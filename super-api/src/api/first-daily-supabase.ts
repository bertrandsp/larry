import express from 'express';
import { getFirstDailyWord, recordFirstDailyWordAction } from '../services/firstDailySupabase';

const router = express.Router();

/**
 * GET /first-daily - Get the first vocabulary word after onboarding
 */
router.get('/first-daily', async (req, res) => {
  try {
    const userId = req.query.userId as string || req.headers['x-user-id'] as string;
    
    console.log('🎯 Getting first daily word for user:', userId);
    
    if (!userId) {
      return res.status(400).json({ 
        error: 'User ID required',
        message: 'Please provide userId in query params or x-user-id header'
      });
    }

    const firstDailyWord = await getFirstDailyWord(userId);

    if (!firstDailyWord) {
      return res.status(400).json({ 
        error: 'Unable to generate first daily word',
        message: 'Please check that onboarding is completed and user has selected topics'
      });
    }

    res.json({
      success: true,
      firstVocabGenerated: true,
      dailyWord: firstDailyWord,
      userProgress: {
        wordsLearned: 1,
        streak: 1,
        level: 'Beginner'
      },
      message: 'Welcome to your vocabulary journey!'
    });

  } catch (error: any) {
    console.error('❌ Error getting first daily word:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get first daily word',
      message: error.message,
      generating: false
    });
  }
});

/**
 * POST /first-daily/action - Track user action on their first daily word
 */
router.post('/first-daily/action', async (req, res) => {
  try {
    const { deliveryId, action, wordbankId } = req.body;

    if (!deliveryId || !action) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'deliveryId and action are required'
      });
    }

    if (!['FAVORITE', 'LEARN_AGAIN', 'MASTERED'].includes(action)) {
      return res.status(400).json({
        error: 'Invalid action',
        message: 'Action must be FAVORITE, LEARN_AGAIN, or MASTERED'
      });
    }

    const success = await recordFirstDailyWordAction(deliveryId, action, wordbankId);

    if (!success) {
      return res.status(500).json({
        error: 'Failed to record action',
        message: 'Unable to update delivery and wordbank records'
      });
    }

    res.json({
      success: true,
      message: 'Action recorded successfully'
    });

  } catch (error: any) {
    console.error('❌ Error recording first daily word action:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to record action',
      message: error.message
    });
  }
});

export default router;
