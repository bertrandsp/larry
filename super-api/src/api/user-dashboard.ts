import express from 'express';
import { supabase } from '../config/supabase';

// Auth helper functions
function extractUserIdFromToken(authHeader: string | undefined): string | null {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  
  const token = authHeader.substring(7);
  const userIdMatch = token.match(/access_([^_]+)_/);
  
  return userIdMatch ? userIdMatch[1] : null;
}

async function setUserContext(userId: string): Promise<void> {
  if (supabase) {
    await supabase.rpc('set_current_user_id', { user_id: userId });
  }
}

const router = express.Router();

/**
 * GET /user/dashboard - Get comprehensive user dashboard data
 * Returns: subscribed topics, wordbank, delivery history, and statistics
 */
router.get('/user/dashboard', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    await setUserContext(userId);

    // Get user with all related data
    const { data: user, error: userError } = await supabase
      ?.from('User')
      .select(`
        *,
        topics:UserTopic(
          *,
          topic:Topic(*)
        ),
        wordbank:Wordbank(
          *,
          term:Term(*)
        ),
        deliveries:Delivery(
          *,
          term:Term(*)
        )
      `)
      .eq('id', userId)
      .single() || { data: null, error: null };

    if (userError || !user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    // Process the data into a dashboard format
    const dashboard = {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        onboardingCompleted: user.onboardingCompleted,
        dailyWordGoal: user.dailyWordGoal,
        dailyWordStreak: user.dailyWordStreak,
        lastDailyWordDate: user.lastDailyWordDate
      },
      
      subscribedTopics: user.topics?.map((ut: any) => ({
        id: ut.topic.id,
        name: ut.topic.name,
        description: ut.topic.description,
        weight: ut.weight,
        isCustom: ut.topic.isCustom,
        usageCount: ut.topic.usageCount,
        subscribedAt: ut.createdAt || null
      })) || [],
      
      wordbank: {
        total: user.wordbank?.length || 0,
        learning: user.wordbank?.filter((w: any) => w.status === 'LEARNING').length || 0,
        reviewing: user.wordbank?.filter((w: any) => w.status === 'REVIEWING').length || 0,
        mastered: user.wordbank?.filter((w: any) => w.status === 'MASTERED').length || 0,
        archived: user.wordbank?.filter((w: any) => w.status === 'ARCHIVED').length || 0,
        words: user.wordbank?.map((w: any) => ({
          id: w.id,
          termId: w.termId,
          term: w.term?.term,
          definition: w.term?.definition,
          status: w.status,
          bucket: w.bucket,
          reviewCount: w.reviewCount,
          lastReviewed: w.lastReviewed,
          nextReview: w.nextReview,
          addedAt: w.createdAt
        })) || []
      },
      
      deliveryHistory: {
        total: user.deliveries?.length || 0,
        opened: user.deliveries?.filter((d: any) => d.openedAt).length || 0,
        favorited: user.deliveries?.filter((d: any) => d.action === 'FAVORITE').length || 0,
        learnAgain: user.deliveries?.filter((d: any) => d.action === 'LEARN_AGAIN').length || 0,
        mastered: user.deliveries?.filter((d: any) => d.action === 'MASTERED').length || 0,
        recent: user.deliveries?.slice(0, 10).map((d: any) => ({
          id: d.id,
          termId: d.termId,
          term: d.term?.term,
          deliveredAt: d.deliveredAt,
          openedAt: d.openedAt,
          action: d.action
        })) || []
      },
      
      statistics: {
        totalWordsLearned: user.wordbank?.filter((w: any) => w.status === 'MASTERED').length || 0,
        averageReviewCount: user.wordbank?.length > 0 
          ? Math.round(user.wordbank.reduce((sum: number, w: any) => sum + (w.reviewCount || 0), 0) / user.wordbank.length)
          : 0,
        completionRate: user.deliveries?.length > 0 
          ? Math.round((user.deliveries.filter((d: any) => d.openedAt).length / user.deliveries.length) * 100)
          : 0
      }
    };

    res.json({
      success: true,
      dashboard
    });

  } catch (error: any) {
    console.error('❌ Error fetching user dashboard:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user dashboard',
      message: error.message
    });
  }
});

/**
 * DELETE /user/topics/:topicId - Unsubscribe from a topic
 */
router.delete('/user/topics/:topicId', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { topicId } = req.params;

    await setUserContext(userId);

    // Remove the UserTopic relationship
    const { error: deleteError } = await supabase
      ?.from('UserTopic')
      .delete()
      .eq('userId', userId)
      .eq('topicId', topicId) || { error: null };

    if (deleteError) {
      console.error('❌ Error unsubscribing from topic:', deleteError);
      return res.status(500).json({
        success: false,
        error: 'Failed to unsubscribe from topic',
        message: deleteError.message
      });
    }

    // Get the topic name for logging
    const { data: topic } = await supabase
      ?.from('Topic')
      .select('name')
      .eq('id', topicId)
      .single() || { data: null };

    console.log(`✅ User ${userId} unsubscribed from topic: ${topic?.name || topicId}`);

    res.json({
      success: true,
      message: `Successfully unsubscribed from ${topic?.name || 'topic'}`
    });

  } catch (error: any) {
    console.error('❌ Error unsubscribing from topic:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to unsubscribe from topic',
      message: error.message
    });
  }
});

/**
 * DELETE /user/wordbank/:wordbankId - Remove word from wordbank
 */
router.delete('/user/wordbank/:wordbankId', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { wordbankId } = req.params;

    await setUserContext(userId);

    // Get the wordbank entry first to verify ownership and get term info
    const { data: wordbankEntry, error: fetchError } = await supabase
      ?.from('Wordbank')
      .select(`
        *,
        term:Term(*)
      `)
      .eq('id', wordbankId)
      .eq('userId', userId)
      .single() || { data: null, error: null };

    if (fetchError || !wordbankEntry) {
      return res.status(404).json({
        success: false,
        error: 'Word not found in your wordbank'
      });
    }

    // Remove the wordbank entry
    const { error: deleteError } = await supabase
      ?.from('Wordbank')
      .delete()
      .eq('id', wordbankId)
      .eq('userId', userId) || { error: null };

    if (deleteError) {
      console.error('❌ Error removing word from wordbank:', deleteError);
      return res.status(500).json({
        success: false,
        error: 'Failed to remove word from wordbank',
        message: deleteError.message
      });
    }

    console.log(`✅ User ${userId} removed word from wordbank: ${wordbankEntry.term?.term || wordbankId}`);

    res.json({
      success: true,
      message: `Successfully removed "${wordbankEntry.term?.term || 'word'}" from your wordbank`
    });

  } catch (error: any) {
    console.error('❌ Error removing word from wordbank:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to remove word from wordbank',
      message: error.message
    });
  }
});

/**
 * PUT /user/topics/:topicId/weight - Update topic weight/preference
 */
router.put('/user/topics/:topicId/weight', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { topicId } = req.params;
    const { weight } = req.body;

    if (typeof weight !== 'number' || weight < 0 || weight > 100) {
      return res.status(400).json({
        success: false,
        error: 'Weight must be a number between 0 and 100'
      });
    }

    await setUserContext(userId);

    // Update the topic weight
    const { data: updatedUserTopic, error: updateError } = await supabase
      ?.from('UserTopic')
      .update({ weight })
      .eq('userId', userId)
      .eq('topicId', topicId)
      .select(`
        *,
        topic:Topic(*)
      `)
      .single() || { data: null, error: null };

    if (updateError) {
      console.error('❌ Error updating topic weight:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to update topic preference',
        message: updateError.message
      });
    }

    console.log(`✅ User ${userId} updated weight for topic: ${updatedUserTopic?.topic?.name || topicId} to ${weight}%`);

    res.json({
      success: true,
      message: `Updated preference for "${updatedUserTopic?.topic?.name || 'topic'}" to ${weight}%`,
      userTopic: updatedUserTopic
    });

  } catch (error: any) {
    console.error('❌ Error updating topic weight:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update topic preference',
      message: error.message
    });
  }
});

/**
 * PUT /user/wordbank/:wordbankId/status - Update word status (LEARNING, REVIEWING, MASTERED, ARCHIVED)
 */
router.put('/user/wordbank/:wordbankId/status', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { wordbankId } = req.params;
    const { status } = req.body;

    const validStatuses = ['LEARNING', 'REVIEWING', 'MASTERED', 'ARCHIVED'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: `Status must be one of: ${validStatuses.join(', ')}`
      });
    }

    await setUserContext(userId);

    // First, get the current wordbank entry to increment review count
    const { data: currentWordbank, error: fetchError } = await supabase
      ?.from('Wordbank')
      .select('reviewCount')
      .eq('id', wordbankId)
      .eq('userId', userId)
      .single() || { data: null, error: null };

    if (fetchError || !currentWordbank) {
      return res.status(404).json({
        success: false,
        error: 'Word not found in your wordbank'
      });
    }

    // Update the word status with incremented review count
    const { data: updatedWordbank, error: updateError } = await supabase
      ?.from('Wordbank')
      .update({ 
        status,
        lastReviewed: new Date().toISOString(),
        reviewCount: (currentWordbank.reviewCount || 0) + 1
      })
      .eq('id', wordbankId)
      .eq('userId', userId)
      .select(`
        *,
        term:Term(*)
      `)
      .single() || { data: null, error: null };

    if (updateError) {
      console.error('❌ Error updating word status:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to update word status',
        message: updateError.message
      });
    }

    console.log(`✅ User ${userId} updated word status: ${updatedWordbank?.term?.term || wordbankId} → ${status}`);

    res.json({
      success: true,
      message: `Updated "${updatedWordbank?.term?.term || 'word'}" status to ${status}`,
      wordbank: updatedWordbank
    });

  } catch (error: any) {
    console.error('❌ Error updating word status:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update word status',
      message: error.message
    });
  }
});

export default router;
