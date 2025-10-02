import express from 'express';
import { prisma } from '../utils/prisma';
import { topicPipelineQueue } from '../queues/topicPipelineQueue';
import { quotaService } from '../services/quotaService';
import { createCanonicalSetWithContent } from '../services/canonicalSetService';
import { z } from 'zod';

const router = express.Router();

const createTopicSchema = z.object({
  userId: z.string().uuid(),
  topicName: z.string().min(1),
  weight: z.number().min(0).max(100).default(100),
});

// POST /user/topics → Accept topic input, queue job
router.post('/user/topics', async (req, res) => {
  try {
    const { userId, topicName, weight } = createTopicSchema.parse(req.body);

    // Step 1: Ensure user exists
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Step 1.5: Check quota before processing
    const quotaCheck = await quotaService.checkQuota(userId);
    if (!quotaCheck.allowed) {
      return res.status(429).json({ 
        error: 'Quota exceeded',
        message: quotaCheck.message,
        quota: quotaCheck.usage
      });
    }

    // Step 2: Check if topic already exists (case-insensitive match)
    const existingTopic = await prisma.topic.findFirst({
      where: { name: { equals: topicName, mode: 'insensitive' } },
      include: { canonicalSet: true }
    });

    let topic;
    let canonicalSetResult;

    if (existingTopic) {
      // Use existing topic
      topic = existingTopic;
      
      // If topic doesn't have a canonical set, create one
      if (!existingTopic.canonicalSet) {
        canonicalSetResult = await createCanonicalSetWithContent({
          topicName: existingTopic.name,
          userId
        });
      }
      
      console.log(`✅ Reusing existing topic: ${topicName}`);
    } else {
      // Create new topic with canonical set
      canonicalSetResult = await createCanonicalSetWithContent({
        topicName,
        userId
      });
      
      // Find the newly created topic
      topic = await prisma.topic.findFirst({
        where: { 
          name: { equals: topicName, mode: 'insensitive' },
          canonicalSetId: canonicalSetResult.id
        }
      });
      
      if (!topic) {
        throw new Error('Failed to create topic with canonical set');
      }
      
      console.log(`🆕 Created new topic with canonical set: ${topicName}`);
    }

    // Step 3: Link topic to user
    const userTopic = await prisma.userTopic.create({
      data: {
        userId,
        topicId: topic.id,
        weight,
      },
    });

    // Step 4: Queue job for term + fact generation (with tier info)
    // Only queue if this is a new canonical set or if the topic doesn't have terms yet
    const hasTerms = await prisma.term.count({ where: { topicId: topic.id } }) > 0;
    
    if (!hasTerms || canonicalSetResult?.wasCreated) {
      await topicPipelineQueue.add('generate', {
        userId,
        topicId: topic.id,
        topicName: topic.name,
        userTier: user.subscription, // Pass user's tier for generation limits
        isCanonicalSet: Boolean(canonicalSetResult?.wasCreated)
      });
      
      console.log(`📋 Queued generation job for topic: ${topicName}`);
    } else {
      console.log(`ℹ️ Topic ${topicName} already has terms, skipping generation`);
    }

    // Step 5: Increment quota usage
    await quotaService.incrementUsage(userId);

    res.status(201).json({
      message: existingTopic && !canonicalSetResult?.wasCreated 
        ? 'Topic linked to user (existing content available).'
        : 'Topic submitted and queued for generation.',
      userTopicId: userTopic.id,
      topicId: topic.id,
      canonicalSetId: topic.canonicalSetId,
      hasExistingContent: hasTerms,
      quota: quotaCheck.usage
    });
  } catch (err: any) {
    console.error('POST /user/topics error:', err);
    if (err instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: err.issues });
    }
    res.status(400).json({ error: 'Invalid request', detail: err.message });
  }
});

// GET /user/:userId/topics → List user topics
router.get('/user/:userId/topics', async (req, res) => {
  const { userId } = req.params;

  try {
    // Check if user exists
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Get all userTopic entries with joined topic name
    const topics = await prisma.userTopic.findMany({
      where: { userId },
      include: {
        topic: {
          include: {
            terms: true,
            facts: true
          }
        }
      }
    });

    const result = topics.map((ut) => ({
      id: ut.id,
      topicId: ut.topicId,
      name: ut.topic.name,
      weight: ut.weight,
      termCount: ut.topic.terms.length,
      factCount: ut.topic.facts.length,
    }));

    res.json(result);
  } catch (err: any) {
    console.error('GET /user/:userId/topics error:', err);
    res.status(500).json({ error: 'Failed to fetch topics' });
  }
});

// GET /user/:userId/quota → Get user's quota status
router.get('/user/:userId/quota', async (req, res) => {
  const { userId } = req.params;

  try {
    // Check if user exists
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Get quota status
    const quotaStatus = await quotaService.getQuotaStatus(userId);
    if (!quotaStatus) {
      return res.status(500).json({ error: 'Failed to get quota status' });
    }

    res.json({
      userId,
      tier: user.subscription,
      quota: quotaStatus
    });
  } catch (err: any) {
    console.error('GET /user/:userId/quota error:', err);
    res.status(500).json({ error: 'Failed to fetch quota status' });
  }
});

// PUT /user/topics/:userTopicId - Update topic weight
router.put('/user/topics/:userTopicId', async (req, res) => {
  try {
    const { userTopicId } = req.params;
    const { weight } = req.body;

    if (weight === undefined || weight < 0 || weight > 100) {
      return res.status(400).json({ error: 'Weight must be between 0 and 100' });
    }

    const userTopic = await prisma.userTopic.update({
      where: { id: userTopicId },
      data: { weight },
      include: {
        topic: true
      }
    });

    res.json(userTopic);
  } catch (error: any) {
    console.error('Error updating topic weight:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /user/topics/:userTopicId - Remove topic from user
router.delete('/user/topics/:userTopicId', async (req, res) => {
  try {
    const { userTopicId } = req.params;

    await prisma.userTopic.delete({
      where: { id: userTopicId }
    });

    res.status(204).send();
  } catch (error: any) {
    console.error('Error deleting user topic:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /canonical-sets/:canonicalSetId/stats - Get canonical set statistics
router.get('/canonical-sets/:canonicalSetId/stats', async (req, res) => {
  try {
    const { canonicalSetId } = req.params;
    
    // Import the service dynamically to avoid circular dependencies
    const { getCanonicalSetStats } = await import('../services/canonicalSetService');
    
    const stats = await getCanonicalSetStats(canonicalSetId);
    
    res.json({
      success: true,
      canonicalSetId,
      stats
    });
  } catch (error: any) {
    console.error('Error getting canonical set stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /canonical-sets/:canonicalSetId/terms - Get all terms in a canonical set
router.get('/canonical-sets/:canonicalSetId/terms', async (req, res) => {
  try {
    const { canonicalSetId } = req.params;
    
    const terms = await prisma.term.findMany({
      where: { canonicalSetId },
      include: {
        topic: {
          select: { name: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
    
    res.json({
      success: true,
      canonicalSetId,
      terms: terms.map(term => ({
        id: term.id,
        term: term.term,
        definition: term.definition,
        example: term.example,
        source: term.source,
        sourceUrl: term.sourceUrl,
        verified: term.verified,
        gptGenerated: term.gptGenerated,
        confidenceScore: term.confidenceScore,
        category: term.category,
        complexityLevel: term.complexityLevel,
        topicName: term.topic.name,
        createdAt: term.createdAt
      }))
    });
  } catch (error: any) {
    console.error('Error getting canonical set terms:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /admin/canonical-sets/cleanup - Clean up orphaned canonical sets (admin only)
router.post('/admin/canonical-sets/cleanup', async (req, res) => {
  try {
    // Simple admin check (in production, use proper middleware)
    const adminKey = req.headers['x-admin-key'];
    if (adminKey !== process.env.ADMIN_KEY) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Import the service dynamically to avoid circular dependencies
    const { cleanupOrphanedCanonicalSets } = await import('../services/canonicalSetService');
    
    const result = await cleanupOrphanedCanonicalSets();
    
    res.json({
      success: true,
      message: `Cleaned up ${result.cleanedCount} orphaned canonical sets`,
      result
    });
  } catch (error: any) {
    console.error('Error cleaning up canonical sets:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /topics/available - Get all available topics that users can add
router.get('/topics/available', async (req, res) => {
  try {
    const { userId } = req.query;
    
    // Get all active topics
    const allTopics = await prisma.topic.findMany({
      where: {
        isActive: true
      },
      include: {
        terms: true,
        _count: {
          select: {
            userTopics: true, // Count how many users have this topic
            terms: true
          }
        }
      },
      orderBy: [
        { _count: { userTopics: 'desc' } }, // Popular topics first
        { name: 'asc' }
      ]
    });

    // If userId provided, exclude topics user already has
    let availableTopics = allTopics;
    if (userId) {
      const userTopics = await prisma.userTopic.findMany({
        where: { userId: userId as string },
        select: { topicId: true }
      });
      const userTopicIds = new Set(userTopics.map(ut => ut.topicId));
      
      availableTopics = allTopics.filter(topic => !userTopicIds.has(topic.id));
    }

    const result = availableTopics.map(topic => ({
      id: topic.id,
      name: topic.name,
      description: topic.description,
      category: topic.category,
      isActive: topic.isActive,
      termCount: topic._count.terms,
      userCount: topic._count.userTopics,
      isPopular: topic._count.userTopics > 10, // Mark as popular if >10 users
      createdAt: topic.createdAt,
      updatedAt: topic.updatedAt
    }));

    res.json({
      success: true,
      topics: result,
      totalCount: result.length
    });
  } catch (error: any) {
    console.error('Error fetching available topics:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /user/:userId/topics/add - Add existing topic to user (simpler version)
router.post('/user/:userId/topics/add', async (req, res) => {
  try {
    const { userId } = req.params;
    const { topicId, weight = 50 } = req.body;

    // Validate input
    if (!topicId) {
      return res.status(400).json({ error: 'topicId is required' });
    }
    if (weight < 0 || weight > 100) {
      return res.status(400).json({ error: 'Weight must be between 0 and 100' });
    }

    // Check if user exists
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if topic exists
    const topic = await prisma.topic.findUnique({ where: { id: topicId } });
    if (!topic) {
      return res.status(404).json({ error: 'Topic not found' });
    }

    // Check if user already has this topic
    const existingUserTopic = await prisma.userTopic.findFirst({
      where: { userId, topicId }
    });
    if (existingUserTopic) {
      return res.status(409).json({ error: 'User already has this topic' });
    }

    // Add topic to user
    const userTopic = await prisma.userTopic.create({
      data: {
        userId,
        topicId,
        weight
      },
      include: {
        topic: {
          include: {
            terms: true,
            _count: {
              select: { terms: true }
            }
          }
        }
      }
    });

    res.status(201).json({
      success: true,
      userTopic: {
        id: userTopic.id,
        topicId: userTopic.topicId,
        userId: userTopic.userId,
        weight: userTopic.weight,
        topic: {
          id: userTopic.topic.id,
          name: userTopic.topic.name,
          description: userTopic.topic.description,
          category: userTopic.topic.category,
          termCount: userTopic.topic._count.terms
        },
        createdAt: userTopic.createdAt,
        updatedAt: userTopic.updatedAt
      }
    });
  } catch (error: any) {
    console.error('Error adding topic to user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});



export default router;
