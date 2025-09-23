import express from 'express';
import { handleWordAction } from '../services/deliveryService';

const router = express.Router();

/**
 * Handle user action on a delivered word
 */
router.post('/action', async (req, res) => {
  try {
    const { userId, deliveryId, action } = req.body;
    
    if (!userId || !deliveryId || !action) {
      return res.status(400).json({ 
        error: 'Missing required fields',
        required: ['userId', 'deliveryId', 'action']
      });
    }
    
    // Validate action
    const validActions = ['FAVORITE', 'LEARN_AGAIN', 'MASTERED', 'NONE'];
    if (!validActions.includes(action)) {
      return res.status(400).json({ 
        error: 'Invalid action',
        validActions 
      });
    }
    
    console.log(`🎬 Processing word action: ${action} for delivery ${deliveryId}`);
    
    const result = await handleWordAction(userId, deliveryId, action);
    
    res.json({
      success: true,
      message: `Word action ${action} processed successfully`,
      action: result.action,
      deliveryId
    });
    
  } catch (error: any) {
    console.error('❌ Word action error:', error);
    res.status(500).json({ 
      error: 'Failed to process word action',
      details: error.message 
    });
  }
});

/**
 * Mark word as opened (when user views the word)
 */
router.post('/open', async (req, res) => {
  try {
    const { deliveryId } = req.body;
    
    if (!deliveryId) {
      return res.status(400).json({ error: 'Delivery ID is required' });
    }
    
    console.log(`👀 Marking word as opened: ${deliveryId}`);
    
    // Import database to update delivery
    const { database } = await import('../utils/prisma');
    
    const delivery = await database.deliveries.update(deliveryId, {
      opened_at: new Date().toISOString()
    });
    
    res.json({
      success: true,
      message: 'Word marked as opened',
      deliveryId,
      openedAt: delivery.opened_at
    });
    
  } catch (error: any) {
    console.error('❌ Mark word as opened error:', error);
    res.status(500).json({ 
      error: 'Failed to mark word as opened',
      details: error.message 
    });
  }
});

export default router;
