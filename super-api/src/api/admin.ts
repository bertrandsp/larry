import express from 'express';
import { z } from 'zod';
import { quotaAnalyticsService } from '../services/quotaAnalyticsService';
import { adminQuotaService } from '../services/adminQuotaService';
import { isAdmin } from '../middleware/isAdmin';
import { 
  getFlaggedTerms, 
  getAllTerms, 
  updateTermModeration, 
  getModerationStats, 
  bulkModerateTerms 
} from '../services/adminService';
import { getMetrics } from '../metrics/metrics';
import { getMetricsSummary, getMostFlaggedTerms } from '../metrics/logEvents';

const router = express.Router();

// POST /admin/generate-content → Generate content for a topic (public for GUI)
router.post('/generate-content', async (req, res) => {
  try {
    const { userId, topicName } = req.body;
    
    if (!userId || !topicName) {
      return res.status(400).json({ error: 'userId and topicName are required' });
    }

    // Import the content generation service
    const { contentGenerationService } = await import('../services/contentGenerationService');
    
    const result = await contentGenerationService.generateContentForTopic(userId, topicName);
    
    res.json({
      message: 'Content generation started successfully',
      topicName,
      userId,
      jobId: result.jobId,
      estimatedTime: '2-5 minutes'
    });
  } catch (error: any) {
    console.error('POST /admin/generate-content error:', error);
    res.status(500).json({ error: 'Failed to start content generation' });
  }
});

// ===== MODERATION ROUTES (using new admin middleware) =====
// These routes use the new Bearer token authentication

// GET /admin/terms/flagged → Get flagged terms for review
router.get('/terms/flagged', isAdmin, getFlaggedTerms);

// GET /admin/terms/all → Get all terms with pagination
router.get('/terms/all', isAdmin, getAllTerms);

// POST /admin/terms/:id/moderate → Moderate a single term
router.post('/terms/:id/moderate', isAdmin, updateTermModeration);

// POST /admin/terms/bulk-moderate → Bulk moderate multiple terms
router.post('/terms/bulk-moderate', isAdmin, bulkModerateTerms);

// GET /admin/moderation/stats → Get moderation statistics
router.get('/moderation/stats', isAdmin, getModerationStats);

// GET /admin/metrics → Get Prometheus metrics
router.get('/metrics', isAdmin, async (req, res) => {
  try {
    const metrics = await getMetrics();
    res.set('Content-Type', 'text/plain');
    res.send(metrics);
  } catch (error: any) {
    res.status(500).json({ error: 'Failed to get metrics' });
  }
});

// GET /admin/metrics/summary → Get metrics summary for dashboard
router.get('/metrics/summary', isAdmin, async (req, res) => {
  try {
    const { days = 7 } = req.query;
    const summary = await getMetricsSummary(Number(days));
    res.json(summary);
  } catch (error: any) {
    res.status(500).json({ error: 'Failed to get metrics summary' });
  }
});

// GET /admin/metrics/flagged-terms → Get most flagged terms
router.get('/metrics/flagged-terms', isAdmin, async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const flaggedTerms = await getMostFlaggedTerms(Number(limit));
    res.json(flaggedTerms);
  } catch (error: any) {
    res.status(500).json({ error: 'Failed to get flagged terms' });
  }
});

// ===== EXISTING ADMIN ROUTES (using old x-admin-key auth) =====
// Simple admin authentication (you might want to implement proper JWT admin auth)
const adminAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const adminKey = req.headers['x-admin-key'];
  if (adminKey !== process.env.ADMIN_KEY) {
    return res.status(401).json({ error: 'Unauthorized - Admin access required' });
  }
  next();
};

// Apply admin auth to all remaining routes
router.use(adminAuth);

// GET /admin/analytics → Get system-wide quota analytics
router.get('/analytics', async (req, res) => {
  try {
    const analytics = await quotaAnalyticsService.getSystemAnalytics();
    res.json(analytics);
  } catch (error: any) {
    console.error('GET /admin/analytics error:', error);
    res.status(500).json({ error: 'Failed to get analytics' });
  }
});

// GET /admin/analytics/tier-performance → Get tier performance metrics
router.get('/analytics/tier-performance', async (req, res) => {
  try {
    const performance = await quotaAnalyticsService.getTierPerformance();
    res.json(performance);
  } catch (error: any) {
    console.error('GET /admin/analytics/tier-performance error:', error);
    res.status(500).json({ error: 'Failed to get tier performance' });
  }
});

// GET /admin/analytics/user/:userId → Get specific user analytics
router.get('/analytics/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const analytics = await quotaAnalyticsService.getUserAnalytics(userId);
    
    if (!analytics) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(analytics);
  } catch (error: any) {
    console.error('GET /admin/analytics/user/:userId error:', error);
    res.status(500).json({ error: 'Failed to get user analytics' });
  }
});

// GET /admin/report → Get comprehensive admin report
router.get('/report', async (req, res) => {
  try {
    const report = await adminQuotaService.getAdminReport();
    res.json(report);
  } catch (error: any) {
    console.error('GET /admin/report error:', error);
    res.status(500).json({ error: 'Failed to get admin report' });
  }
});

// POST /admin/quota/reset → Reset user quota
router.post('/quota/reset', async (req, res) => {
  try {
    const { userId, reason } = z.object({
      userId: z.string().uuid(),
      reason: z.string().optional()
    }).parse(req.body);

    const adminId = req.headers['x-admin-id'] as string || 'system';
    const success = await adminQuotaService.resetUserQuota(userId, adminId, reason);
    
    if (success) {
      res.json({ message: 'User quota reset successfully', userId });
    } else {
      res.status(500).json({ error: 'Failed to reset quota' });
    }
  } catch (error: any) {
    console.error('POST /admin/quota/reset error:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    res.status(500).json({ error: 'Failed to reset quota' });
  }
});

// POST /admin/quota/change-tier → Change user tier
router.post('/quota/change-tier', async (req, res) => {
  try {
    const { userId, newTier, reason } = z.object({
      userId: z.string().uuid(),
      newTier: z.enum(['free', 'basic', 'premium', 'enterprise']),
      reason: z.string().optional()
    }).parse(req.body);

    const adminId = req.headers['x-admin-id'] as string || 'system';
    const success = await adminQuotaService.changeUserTier(userId, newTier, adminId, reason);
    
    if (success) {
      res.json({ message: 'User tier changed successfully', userId, newTier });
    } else {
      res.status(500).json({ error: 'Failed to change tier' });
    }
  } catch (error: any) {
    console.error('POST /admin/quota/change-tier error:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    res.status(500).json({ error: 'Failed to change tier' });
  }
});

// POST /admin/quota/bulk-reset → Bulk reset quotas for a tier
router.post('/quota/bulk-reset', async (req, res) => {
  try {
    const { tier, reason } = z.object({
      tier: z.enum(['free', 'basic', 'premium', 'enterprise']),
      reason: z.string().optional()
    }).parse(req.body);

    const adminId = req.headers['x-admin-id'] as string || 'system';
    const result = await adminQuotaService.bulkResetTierQuotas(tier, adminId, reason);
    
    res.json({ 
      message: `Bulk reset completed for ${tier} tier`, 
      ...result 
    });
  } catch (error: any) {
    console.error('POST /admin/quota/bulk-reset error:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    res.status(500).json({ error: 'Failed to bulk reset quotas' });
  }
});

// GET /admin/health → Get system health status
router.get('/health', async (req, res) => {
  try {
    const analytics = await quotaAnalyticsService.getSystemAnalytics();
    
    const healthStatus: {
      status: string;
      timestamp: string;
      metrics: any;
      alerts: Array<{ level: string; message: string }>;
    } = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      metrics: {
        totalUsers: analytics.totalUsers,
        quotaExceededUsers: analytics.quotaExceededUsers,
        totalRequests: analytics.systemHealth.totalRequests,
        averageRequestsPerUser: analytics.systemHealth.averageRequestsPerUser,
        tierDistribution: analytics.tierDistribution
      },
      alerts: []
    };

    // Add alerts for concerning metrics
    if (analytics.quotaExceededUsers > 0) {
      healthStatus.alerts.push({
        level: 'warning',
        message: `${analytics.quotaExceededUsers} users have exceeded their quota`
      });
    }

    if (analytics.systemHealth.averageRequestsPerUser > 10) {
      healthStatus.alerts.push({
        level: 'info',
        message: 'High average usage per user - consider tier optimization'
      });
    }

    res.json(healthStatus);
  } catch (error: any) {
    console.error('GET /admin/health error:', error);
    res.status(500).json({ 
      status: 'unhealthy',
      error: 'Failed to get health status',
      timestamp: new Date().toISOString()
    });
  }
});

export default router;
