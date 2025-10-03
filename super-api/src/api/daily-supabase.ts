import express from 'express';
import { getNextDailyWord, recordDailyWordAction } from '../services/dailySupabase';

const router = express.Router();

/**
 * GET /daily - Get next daily word for user based on spaced repetition
 */
router.get('/daily', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authorization header required' });
    }

    const token = authHeader.substring(7);
    const userIdMatch = token.match(/access_([^_]+)_/);
    
    if (!userIdMatch) {
      return res.status(401).json({ error: 'Invalid access token' });
    }

    const userId = userIdMatch[1];
    
    console.log('🎯 Getting daily word for user:', userId);

    const dailyWord = await getNextDailyWord(userId);

    if (!dailyWord) {
      return res.status(400).json({ 
        error: 'Unable to generate daily word',
        message: 'Please check that you have topics selected and onboarding is completed'
      });
    }

    res.json({
      success: true,
      dailyWord: dailyWord,
      userProgress: {
        wordsLearned: dailyWord.userProgress?.wordsLearned || 1,
        streak: dailyWord.userProgress?.streak || 1,
        level: dailyWord.userProgress?.level || 'Beginner'
      }
    });

  } catch (error: any) {
    console.error('❌ Error getting daily word:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get daily word',
      message: error.message
    });
  }
});

/**
 * POST /daily/action - Track user action on daily word
 */
router.post('/daily/action', async (req, res) => {
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

    const success = await recordDailyWordAction(deliveryId, action, wordbankId);

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
    console.error('❌ Error recording daily word action:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to record action',
      message: error.message
    });
  }
});

export default router;
