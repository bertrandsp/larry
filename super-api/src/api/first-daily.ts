import express from 'express';
import { PrismaClient } from '@prisma/client';
import { createDelivery, addToWordbank } from '../services/deliveryService';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * GET /first-daily
 * Get the first vocabulary word immediately after onboarding
 * This endpoint handles first-time users who just completed onboarding
 */
router.get('/first-daily', async (req, res) => {
  try {
    const userId = req.query.userId || req.headers['x-user-id'];
    
    console.log('🎯 Getting first daily word for user:', userId);
    
    if (!userId) {
      return res.status(400).json({ 
        error: 'User ID required',
        message: 'Please provide userId in query params or x-user-id header'
      });
    }

    // Get user with topics
    const user = await prisma.user.findUnique({
      where: { id: userId as string },
      include: {
        topics: {
          include: {
            topic: true
          }
        }
      }
    });

    if (!user) {
      return res.status(404).json({ 
        error: 'User not found',
        message: `User ${userId} does not exist`
      });
    }

    if (!user.onboardingCompleted) {
      return res.status(400).json({ 
        error: 'Onboarding not completed',
        message: 'User must complete onboarding before getting daily words'
      });
    }

    // Check if user already has firstVocabGenerated
    if (user.firstVocabGenerated) {
      console.log('✅ User already has vocab generated, redirecting to regular daily endpoint');
      return res.status(200).json({
        success: true,
        message: 'First vocab already generated',
        redirect: '/daily',
        firstVocabGenerated: true
      });
    }

    // Check if user has topics
    if (user.topics.length === 0) {
      return res.status(400).json({ 
        error: 'No topics selected',
        message: 'User must select topics during onboarding'
      });
    }

    console.log(`📚 User has ${user.topics.length} topics, looking for terms...`);

    // Get terms from user's topics
    const topicIds = user.topics.map(ut => ut.topicId);
    const availableTerms = await prisma.term.findMany({
      where: {
        topicId: { in: topicIds },
        moderationStatus: 'APPROVED'
      },
      include: { 
        topic: true 
      },
      orderBy: { confidenceScore: 'desc' },
      take: 10
    });

    console.log(`📖 Found ${availableTerms.length} available terms`);

    // If no terms available, trigger generation and return loading state
    if (availableTerms.length === 0) {
      console.log('🚀 No terms available, triggering content generation...');
      
      // Trigger content generation for user's topics
      for (const userTopic of user.topics) {
        try {
          const generateResponse = await fetch('http://localhost:4001/generate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              topic: userTopic.topic.name,
              topicId: userTopic.topicId,
              userTier: user.subscription || 'free',
              priority: true // High priority for first-time users
            })
          });
          
          if (generateResponse.ok) {
            console.log('✅ Content generation started for:', userTopic.topic.name);
          }
        } catch (error) {
          console.error('❌ Failed to trigger generation for:', userTopic.topic.name, error);
        }
      }

      return res.status(202).json({
        success: false,
        generating: true,
        message: 'Generating your first vocabulary words...',
        estimatedTime: '30-60 seconds',
        retryAfter: 10 // Suggest retry after 10 seconds
      });
    }

    // Select first available term
    const selectedTerm = availableTerms[0];
    console.log(`🎯 Selected first term: ${selectedTerm.term} from topic: ${selectedTerm.topic.name}`);

    // Create delivery record
    const delivery = await createDelivery(userId as string, selectedTerm.id);

    // Add to wordbank
    const wordbankEntry = await addToWordbank(userId as string, selectedTerm.id);

    // Update user to mark first vocab as generated
    await prisma.user.update({
      where: { id: userId as string },
      data: {
        firstVocabGenerated: true,
        lastDailyWordDate: new Date(),
        dailyWordStreak: 1
      }
    });

    // Get related facts
    const facts = await prisma.fact.findMany({
      where: { topicId: selectedTerm.topicId },
      take: 3
    });

    const firstDailyWord = {
      id: selectedTerm.id,
      term: selectedTerm.term,
      definition: selectedTerm.definition,
      example: selectedTerm.example,
      category: selectedTerm.category || 'Vocabulary',
      complexityLevel: selectedTerm.complexityLevel || 'Intermediate',
      source: selectedTerm.source || 'AI Generated',
      sourceUrl: selectedTerm.sourceUrl,
      confidenceScore: selectedTerm.confidenceScore || 0.95,
      topic: selectedTerm.topic?.name || 'General Vocabulary',
      facts: facts.map(f => ({
        id: f.id,
        fact: f.fact,
        category: f.category || 'General'
      })),
      delivery: {
        id: delivery.id,
        deliveredAt: delivery.deliveredAt
      },
      wordbank: {
        id: wordbankEntry.id,
        bucket: wordbankEntry.bucket,
        status: wordbankEntry.status
      },
      isFirstWord: true
    };

    console.log('✅ First daily word delivered successfully');

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
      error: 'Failed to get first daily word',
      message: error.message,
      generating: false
    });
  }
});

/**
 * POST /first-daily/action
 * Track user action on their first daily word
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

    console.log(`🎬 Recording first daily word action: ${action} for delivery ${deliveryId}`);

    // Update delivery record
    await prisma.delivery.update({
      where: { id: deliveryId },
      data: { 
        action,
        openedAt: new Date()
      }
    });

    // Update wordbank if provided
    if (wordbankId) {
      const wordbank = await prisma.wordbank.findUnique({
        where: { id: wordbankId }
      });

      if (wordbank) {
        let updateData: any = {
          lastReviewed: new Date(),
          reviewCount: wordbank.reviewCount + 1
        };

        // Calculate next review based on action
        const nextReview = new Date();
        switch (action) {
          case 'LEARN_AGAIN':
            updateData.bucket = 1;
            nextReview.setDate(nextReview.getDate() + 1);
            updateData.nextReview = nextReview;
            break;
          case 'FAVORITE':
            nextReview.setDate(nextReview.getDate() + Math.pow(2, wordbank.bucket));
            updateData.nextReview = nextReview;
            break;
          case 'MASTERED':
            updateData.status = 'MASTERED';
            updateData.nextReview = null;
            break;
        }

        await prisma.wordbank.update({
          where: { id: wordbankId },
          data: updateData
        });
      }
    }

    console.log('✅ First daily word action recorded successfully');

    res.json({
      success: true,
      message: `Action ${action} recorded successfully`,
      action
    });

  } catch (error: any) {
    console.error('❌ Error recording first daily word action:', error);
    res.status(500).json({ 
      error: 'Failed to record action',
      message: error.message
    });
  }
});

export default router;
