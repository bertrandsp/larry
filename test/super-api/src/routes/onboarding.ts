import express from 'express';
import { db } from '../lib/supabase';
import { deliveryService } from '../services/delivery';

const router = express.Router();

// POST /onboarding/complete
router.post('/complete', async (req, res) => {
  try {
    const { userId, topics } = req.body;

    if (!userId || !topics || !Array.isArray(topics)) {
      return res.status(400).json({
        error: 'Missing required fields: userId, topics (array)'
      });
    }

    console.log(`🎯 Completing onboarding for user: ${userId} with ${topics.length} topics`);

    // Create or update user
    let user;
    try {
      user = await db.getUser(userId);
    } catch (error) {
      // User doesn't exist, create them
      user = await db.createUser({
        id: userId,
        onboarding_completed: false,
        first_vocab_generated: false,
        created_at: new Date().toISOString()
      });
    }

    // Add user topics
    for (const topicId of topics) {
      try {
        await db.createUserTopic(userId, topicId, 10); // Equal weight for all topics
      } catch (error) {
        console.log(`⚠️ Topic ${topicId} already exists for user ${userId}`);
      }
    }

    // Generate first vocabulary
    const firstVocab = await deliveryService.generateFirstVocabulary(userId);

    res.json({
      success: true,
      message: 'Onboarding completed successfully',
      user: user,
      first_vocabulary: firstVocab,
      topics_added: topics.length
    });

  } catch (error) {
    console.error('❌ Onboarding completion failed:', error);
    res.status(500).json({
      error: 'Failed to complete onboarding',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /onboarding/status/:userId
router.get('/status/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await db.getUser(userId);
    const userTopics = await db.getUserTopics(userId);

    res.json({
      success: true,
      user: {
        id: user.id,
        onboarding_completed: user.onboarding_completed,
        first_vocab_generated: user.first_vocab_generated,
        created_at: user.created_at
      },
      topics: userTopics,
      topics_count: userTopics.length
    });

  } catch (error) {
    console.error('❌ Failed to get onboarding status:', error);
    res.status(500).json({
      error: 'Failed to get onboarding status',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /onboarding/topics - Get available topics
router.get('/topics', async (req, res) => {
  try {
    const topics = await db.getAllTopics();

    res.json({
      success: true,
      topics: topics,
      count: topics.length
    });

  } catch (error) {
    console.error('❌ Failed to get topics:', error);
    res.status(500).json({
      error: 'Failed to get topics',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;
