import express from 'express';
import { getNextDailyWord, getNextUnseenWord, recordDailyWordAction } from '../services/dailySupabase';
import { getNextQueuedDelivery, markDeliveryAsDelivered } from './daily/preload-service';
import { getNextQueuedDeliveryForActiveTopics, cleanupStaleDeliveries } from './daily/topic-cleanup-service';
import { generateNextBatchQueue } from '../queues/topicPipelineQueue';
import { prisma } from '../utils/prisma';

const router = express.Router();

/**
 * GET /daily - Get next daily word for user (instant fetch from pre-generated queue)
 */
router.get('/daily', async (req, res) => {
  const startTime = Date.now();
  
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


    // Clean up stale deliveries from disabled topics (non-blocking)
    cleanupStaleDeliveries(userId).catch(err => {
      console.error("Cleanup warning:", err.message);
    });
    // Try to get from pre-generated queue first (instant)
    const queuedDelivery = await getNextQueuedDeliveryForActiveTopics(userId);

    if (queuedDelivery) {
      console.log('✅ Found pre-generated word, delivering instantly');
      
      // Mark as delivered
      await markDeliveryAsDelivered(queuedDelivery.id);
      
      // Trigger background generation for next batch (non-blocking)
      generateNextBatchQueue.add("batch-gen", { userId: userId }, { delay: 1000 });
      
      const dailyWord = queuedDelivery;
      
      // Convert to iOS app expected format
      const iosDailyWord = {
        id: dailyWord.id,
        user_id: userId,
        term: {
          id: dailyWord.term.id,
          term: dailyWord.term.term,
          definition: dailyWord.term.definition,
          example: dailyWord.term.example,
          pronunciation: null,
          partOfSpeech: null,
          difficulty: dailyWord.term.complexityLevel,
          etymology: null,
          synonyms: [],
          antonyms: [],
          relatedTerms: [],
          tags: [],
          category: dailyWord.term.category,
          complexityLevel: dailyWord.term.complexityLevel,
          source: dailyWord.term.source,
          confidenceScore: dailyWord.term.confidenceScore,
          topicId: dailyWord.term.topicId,
          createdAt: dailyWord.createdAt.toISOString(),
          updatedAt: dailyWord.createdAt.toISOString(),
          userProgress: null
        },
        topic: {
          id: dailyWord.term.topic.id,
          name: dailyWord.term.topic.name,
          slug: dailyWord.term.topic.name.toLowerCase().replace(/\s+/g, '-')
        },
        delivery_date: new Date().toISOString(),
        is_review: false,
        spaced_repetition_bucket: 1,
        ai_explanation: `This ${dailyWord.term.complexityLevel.toLowerCase()} vocabulary word from ${dailyWord.term.topic.name} will help expand your professional vocabulary.`,
        contextual_example: dailyWord.term.example,
        created_at: dailyWord.createdAt.toISOString(),
        user_interaction: null
      };

      const iosResponse = {
        words: [iosDailyWord],
        total_count: 1,
        remaining_today: 2,
        next_delivery_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        streak_count: 1
      };

      // Log performance metrics
      const renderTime = Date.now() - startTime;
      console.log(`⚡ Daily word delivered in ${renderTime}ms`);
      
      // Store metrics in database
      try {
        await prisma.metricLog.create({
          data: {
            type: "daily_card_render_time",
            message: `Daily word delivered in ${renderTime}ms`,
            metadata: {
              userId: userId,
              renderTimeMs: renderTime,
              source: "pre_generated",
              timestamp: new Date().toISOString()
            }
          }
        });
      } catch (error) {
        console.error("Failed to log metrics:", error);
      }

      res.json(iosResponse);
    } else {
      // Fallback: trigger background generation but don't block
      console.log('⚠️ No pre-generated words available, triggering background generation');
      generateNextBatchQueue.add("batch-gen", { userId: userId }, { delay: 1000 });
      
      return res.json({ 
        words: [],
        total_count: 0,
        remaining_today: 0,
        next_delivery_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        streak_count: 0
      });
    }

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
 * OPTIMIZED: Uses preload queue instead of generating on-demand
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

    // Try to get from preload queue first (FAST)
    const queuedDelivery = await getNextQueuedDeliveryForActiveTopics(userId);
    
    let dailyWord;
    if (queuedDelivery) {
      console.log('✅ Found pre-generated word in queue, delivering instantly');
      
      // Mark as delivered
      await markDeliveryAsDelivered(queuedDelivery.id);
      
      // Trigger background generation to refill queue (non-blocking)
      generateNextBatchQueue.add("batch-gen", { userId: userId }, { delay: 1000 });
      
      dailyWord = queuedDelivery;
    } else {
      // Fallback to on-demand generation (SLOW)
      console.log('⚠️ No pre-generated words in queue, falling back to on-demand generation');
      dailyWord = await getNextUnseenWord(userId);
      
      // Mark on-demand word as delivered too (prevent duplicates)
      if (dailyWord && (dailyWord as any).delivery?.id) {
        await markDeliveryAsDelivered((dailyWord as any).delivery.id);
        console.log('✅ Marked on-demand word as delivered');
      }
    }

    if (!dailyWord) {
      return res.status(400).json({ 
        error: 'Unable to get next unseen word',
        message: 'Please check that you have topics selected and onboarding is completed'
      });
    }

    // Convert to iOS app expected format
    // Handle both queued delivery format (nested term object) and flat DailyWord format
    const isNestedFormat = dailyWord.term && typeof dailyWord.term === 'object';
    const term = isNestedFormat ? dailyWord.term : dailyWord;
    const topic = isNestedFormat ? dailyWord.term.topic : { name: (dailyWord as any).topic, id: (dailyWord as any).topicId };
    
    const iosDailyWord = {
      id: dailyWord.id,
      user_id: userId,
      term: {
        id: term.id || dailyWord.id,
        term: term.term || (dailyWord as any).term,
        definition: term.definition || (dailyWord as any).definition,
        example: term.example || (dailyWord as any).example,
        pronunciation: term.pronunciation || (dailyWord as any).pronunciation || null,
        partOfSpeech: term.partOfSpeech || (dailyWord as any).partOfSpeech || null,
        difficulty: term.difficulty || (dailyWord as any).difficulty || null,
        etymology: term.etymology || (dailyWord as any).etymology || null,
        synonyms: term.synonyms || (dailyWord as any).synonyms || [],
        antonyms: term.antonyms || (dailyWord as any).antonyms || [],
        relatedTerms: ((term.relatedTerms || (dailyWord as any).relatedTerms || []) as any[]).map((rt: any) => ({
          term: rt.term || "Related term",
          difference: rt.difference || "Related concept"
        })),
        tags: term.tags || (dailyWord as any).tags || [],
        category: term.category || (dailyWord as any).category || null,
        complexityLevel: term.complexityLevel || (dailyWord as any).complexityLevel || null,
        source: term.source || (dailyWord as any).source || null,
        confidenceScore: term.confidenceScore || (dailyWord as any).confidenceScore || null,
        topicId: term.topicId || (dailyWord as any).topicId || null,
        createdAt: term.createdAt || new Date().toISOString(),
        updatedAt: term.updatedAt || new Date().toISOString(),
        userProgress: null
      },
      topic: {
        id: topic?.id || (dailyWord as any).topicId || null,
        name: topic?.name || (dailyWord as any).topic || "General Vocabulary",
        slug: (topic?.name || (dailyWord as any).topic || (dailyWord as any).topicSlug) ? (topic?.name || (dailyWord as any).topic).toLowerCase().replace(/\s+/g, '-') : "general-vocabulary"
      },
      delivery_date: new Date().toISOString(),
      is_review: (dailyWord as any).isReview || false,
      spaced_repetition_bucket: 1,
      ai_explanation: `This ${((dailyWord as any).complexityLevel || 'intermediate').toLowerCase()} vocabulary word from ${topic?.name || (dailyWord as any).topic || 'General Vocabulary'} will help expand your professional vocabulary.`,
      contextual_example: term.example || (dailyWord as any).example,
      created_at: term.createdAt || new Date().toISOString(),
      user_interaction: null
    };

    const iosResponse = {
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
