import { Router } from 'express';
import { z } from 'zod';
import { generateWithCache, checkRateLimit } from '../services/openAiOptimized';
import { logMetric } from '../metrics/logEvents';

const router = Router();

// Optimized request schema
const OptimizedGenerateRequestSchema = z.object({
  topic: z.string().min(1).max(100),
  numTerms: z.number().min(1).max(10).optional(),
  complexity: z.enum(['basic', 'intermediate', 'advanced']).optional(),
  userId: z.string().optional(),
  topicId: z.string().uuid().optional()
});

// POST /generate-optimized - Cost-optimized generation
router.post('/generate-optimized', async (req, res) => {
  try {
    const validatedBody = OptimizedGenerateRequestSchema.parse(req.body);
    const {
      topic,
      numTerms = 5,
      complexity = 'basic',
      userId,
      topicId
    } = validatedBody;

    // Rate limiting check
    if (userId && !checkRateLimit(userId, 'free')) {
      return res.status(429).json({
        error: 'Rate limit exceeded',
        message: 'Too many requests. Please try again later.',
        retryAfter: 3600 // 1 hour
      });
    }

    console.log(`🚀 Optimized generation request:`, {
      topic,
      numTerms,
      complexity,
      userId: userId ? 'provided' : 'anonymous'
    });

    const jobId = `opt-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    // Generate with caching and optimization
    const result = await generateWithCache(
      topic,
      numTerms,
      complexity,
      'free', // Default to free tier for cost control
      jobId
    );

    // Log metrics
    await logMetric({
      type: 'optimized_generation',
      topicId,
      message: `Generated ${result.response.terms?.length || 0} terms for ${topic}`,
      metadata: {
        jobId,
        complexity,
        numTerms,
        cached: result.cached,
        cost: result.usage.cost,
        tokens: result.usage.totalTokens,
        model: result.usage.model
      }
    });

    res.json({
      success: true,
      data: {
        terms: result.response.terms || [],
        facts: [], // Simplified - no facts to reduce costs
        metadata: {
          jobId,
          complexity,
          cached: result.cached,
          cost: result.usage.cost,
          tokens: result.usage.totalTokens,
          model: result.usage.model
        }
      }
    });

  } catch (error) {
    console.error('Optimized generation error:', error);
    
    res.status(500).json({
      error: 'Generation failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /cost-analysis - Analyze current costs
router.get('/cost-analysis', async (req, res) => {
  try {
    // This would typically query your metrics database
    // For now, return estimated savings
    const analysis = {
      currentModel: 'gpt-4o',
      optimizedModel: 'gpt-4o-mini',
      estimatedSavings: {
        inputTokens: '90%', // Much shorter prompts
        outputTokens: '70%', // Optimized responses
        totalCost: '85%', // Overall savings
        modelCost: '90%' // gpt-4o-mini vs gpt-4o
      },
      recommendations: [
        'Switch to gpt-4o-mini for 90% cost reduction',
        'Implement caching for repeated requests',
        'Reduce prompt complexity by 80%',
        'Add rate limiting per user tier',
        'Batch similar requests together'
      ]
    };

    res.json(analysis);
  } catch (error) {
    res.status(500).json({ error: 'Analysis failed' });
  }
});

export default router;
