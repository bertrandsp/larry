import express from 'express';
import { deliveryService, DeliveryAction } from '../services/delivery';
import { db } from '../lib/supabase';

const router = express.Router();

// GET /daily/:userId - Get daily word
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    console.log(`📱 Getting daily word for user: ${userId}`);

    const dailyWord = await deliveryService.getNextDailyWord(userId);

    res.json({
      success: true,
      daily_word: {
        term: dailyWord.term,
        delivery_id: dailyWord.delivery.id,
        type: dailyWord.type, // 'new' or 'review'
        wordbank_entry: dailyWord.wordbank_entry
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Failed to get daily word:', error);
    res.status(500).json({
      error: 'Failed to get daily word',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /daily/:userId/history - Get delivery history
router.get('/:userId/history', async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;

    const deliveries = await db.getUserDeliveries(userId);

    res.json({
      success: true,
      deliveries: deliveries.slice(0, limit),
      total: deliveries.length
    });

  } catch (error) {
    console.error('❌ Failed to get delivery history:', error);
    res.status(500).json({
      error: 'Failed to get delivery history',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// POST /daily/action - Handle word action
router.post('/action', async (req, res) => {
  try {
    const { userId, termId, deliveryId, action } = req.body;

    if (!userId || !termId || !deliveryId || !action) {
      return res.status(400).json({
        error: 'Missing required fields: userId, termId, deliveryId, action'
      });
    }

    if (!Object.values(DeliveryAction).includes(action)) {
      return res.status(400).json({
        error: 'Invalid action. Must be one of: ' + Object.values(DeliveryAction).join(', ')
      });
    }

    console.log(`🎬 Processing word action: ${action} for user ${userId}`);

    const result = await deliveryService.handleWordAction(userId, termId, deliveryId, action);

    res.json({
      success: true,
      message: `Action '${action}' processed successfully`,
      result: result
    });

  } catch (error) {
    console.error('❌ Failed to process word action:', error);
    res.status(500).json({
      error: 'Failed to process word action',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /daily/:userId/wordbank - Get user's wordbank
router.get('/:userId/wordbank', async (req, res) => {
  try {
    const { userId } = req.params;

    const wordbank = await db.getUserWordbank(userId);

    res.json({
      success: true,
      wordbank: wordbank,
      total: wordbank.length,
      by_status: {
        learning: wordbank.filter(w => w.status === 'learning').length,
        reviewing: wordbank.filter(w => w.status === 'reviewing').length,
        mastered: wordbank.filter(w => w.status === 'mastered').length,
        archived: wordbank.filter(w => w.status === 'archived').length
      }
    });

  } catch (error) {
    console.error('❌ Failed to get wordbank:', error);
    res.status(500).json({
      error: 'Failed to get wordbank',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;
