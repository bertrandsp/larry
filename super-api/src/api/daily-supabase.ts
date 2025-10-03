import express from 'express';
import { getNextDailyWord, getNextUnseenWord, recordDailyWordAction } from '../services/dailySupabase';

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

    // Convert to iOS app expected format
    const iosDailyWord = {
      id: dailyWord.id,
      user_id: userId, // Extract from token
      term: {
        id: dailyWord.id,
        term: dailyWord.term,
        definition: dailyWord.definition,
        example: dailyWord.example,
        pronunciation: dailyWord.pronunciation || null,
        partOfSpeech: dailyWord.partOfSpeech || null,
        difficulty: dailyWord.difficulty || null,
        etymology: dailyWord.etymology || null,
        synonyms: dailyWord.synonyms || [],
        antonyms: dailyWord.antonyms || [],
        relatedTerms: (dailyWord.relatedTerms || []).map((rt: any) => ({
          term: rt.term,
          difference: rt.difference
        })),
        tags: dailyWord.tags || [],
        category: dailyWord.category || null,
        complexityLevel: dailyWord.complexityLevel || null,
        source: dailyWord.source || null,
        confidenceScore: dailyWord.confidenceScore || null,
        topicId: dailyWord.topic || null, // Use topic name as topicId for now
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        userProgress: null
      },
      delivery_date: new Date(dailyWord.delivery.deliveredAt).toISOString(),
      is_review: dailyWord.isReview,
      spaced_repetition_bucket: dailyWord.wordbank.bucket,
      ai_explanation: `This ${dailyWord.complexityLevel.toLowerCase()} vocabulary word from ${dailyWord.topic} will help expand your professional vocabulary.`,
      contextual_example: dailyWord.example,
      created_at: new Date().toISOString(),
      user_interaction: null
    };

    const iosResponse = {
      success: true,
      words: [iosDailyWord],
      total_count: 1,
      remaining_today: 2,
      next_delivery_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      streak_count: 1
    };

    res.json(iosResponse);

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
 * GET /daily/next - Get next unseen word for user (for swipe functionality)
 */
router.get('/daily/next', async (req, res) => {
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
    
    console.log('🎯 Getting next unseen word for user:', userId);

    const dailyWord = await getNextUnseenWord(userId);

    if (!dailyWord) {
      return res.status(400).json({ 
        error: 'Unable to get next unseen word',
        message: 'Please check that you have topics selected and onboarding is completed'
      });
    }

    // Convert to iOS app expected format
    const iosDailyWord = {
      id: dailyWord.id,
      user_id: userId,
      term: {
        id: dailyWord.id,
        term: dailyWord.term,
        definition: dailyWord.definition,
        example: dailyWord.example,
        pronunciation: dailyWord.pronunciation || null,
        partOfSpeech: dailyWord.partOfSpeech || null,
        difficulty: dailyWord.difficulty || null,
        etymology: dailyWord.etymology || null,
        synonyms: dailyWord.synonyms || [],
        antonyms: dailyWord.antonyms || [],
        relatedTerms: (dailyWord.relatedTerms || []).map((rt: any) => ({
          term: rt.term,
          difference: rt.difference
        })),
        tags: dailyWord.tags || [],
        category: dailyWord.category || null,
        complexityLevel: dailyWord.complexityLevel || null,
        source: dailyWord.source || null,
        confidenceScore: dailyWord.confidenceScore || null,
        topicId: dailyWord.topic || null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        userProgress: null
      },
      delivery_date: new Date(dailyWord.delivery.deliveredAt).toISOString(),
      is_review: dailyWord.isReview,
      spaced_repetition_bucket: dailyWord.wordbank.bucket,
      ai_explanation: `This ${dailyWord.complexityLevel.toLowerCase()} vocabulary word from ${dailyWord.topic} will help expand your professional vocabulary.`,
      contextual_example: dailyWord.example,
      created_at: new Date().toISOString(),
      user_interaction: null
    };

    const iosResponse = {
      success: true,
      words: [iosDailyWord],
      total_count: 1,
      remaining_today: 999, // Indicate unlimited for swipe functionality
      next_delivery_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      streak_count: 1
    };

    res.json(iosResponse);

  } catch (error: any) {
    console.error('❌ Error getting next unseen word:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get next unseen word',
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
