import express from 'express';
import {
  getTopicPopularityAnalytics,
  getLearningPatternAnalytics,
  getCohortAnalytics,
  getTopicDifficultyAnalytics,
  getDemographicAnalytics,
} from '../services/analyticsService';

const router = express.Router();

/**
 * GET /analytics/topics/popularity
 * Get most popular topics with learning effectiveness metrics
 */
router.get('/analytics/topics/popularity', async (req, res) => {
  try {
    const analytics = await getTopicPopularityAnalytics();
    
    res.json({
      success: true,
      data: analytics,
      insights: {
        mostPopularTopic: analytics[0]?.topic || 'No data',
        totalTopics: analytics.length,
        avgMasteryRate: analytics.reduce((sum, t) => sum + t.avgMasteryRate, 0) / analytics.length || 0,
      }
    });
  } catch (error: any) {
    console.error('Error fetching topic popularity analytics:', error);
    res.status(500).json({ 
      error: 'Failed to fetch topic analytics',
      details: error.message 
    });
  }
});

/**
 * GET /analytics/learning-patterns
 * Analyze learning pattern effectiveness
 */
router.get('/analytics/learning-patterns', async (req, res) => {
  try {
    const analytics = await getLearningPatternAnalytics();
    
    res.json({
      success: true,
      data: analytics,
      insights: {
        mostEffectivePattern: analytics[0]?.pattern || 'No data',
        totalPatterns: analytics.length,
        avgEffectiveness: analytics.reduce((sum, p) => sum + p.effectivenessScore, 0) / analytics.length || 0,
      }
    });
  } catch (error: any) {
    console.error('Error fetching learning pattern analytics:', error);
    res.status(500).json({ 
      error: 'Failed to fetch learning pattern analytics',
      details: error.message 
    });
  }
});

/**
 * GET /analytics/cohorts
 * Analyze cohort trends and topic evolution
 */
router.get('/analytics/cohorts', async (req, res) => {
  try {
    const analytics = await getCohortAnalytics();
    
    res.json({
      success: true,
      data: analytics,
      insights: {
        totalCohorts: analytics.length,
        largestCohort: analytics.reduce((max, c) => c.totalUsers > max.totalUsers ? c : max, analytics[0] || { totalUsers: 0 }),
        avgEfficiency: analytics.reduce((sum, c) => sum + c.avgLearningEfficiency, 0) / analytics.length || 0,
      }
    });
  } catch (error: any) {
    console.error('Error fetching cohort analytics:', error);
    res.status(500).json({ 
      error: 'Failed to fetch cohort analytics',
      details: error.message 
    });
  }
});

/**
 * GET /analytics/topics/difficulty
 * Get topic difficulty analysis
 */
router.get('/analytics/topics/difficulty', async (req, res) => {
  try {
    const analytics = await getTopicDifficultyAnalytics();
    
    res.json({
      success: true,
      data: analytics,
      insights: {
        hardestTopic: analytics[0]?.topic || 'No data',
        easiestTopic: analytics[analytics.length - 1]?.topic || 'No data',
        avgDifficulty: analytics.reduce((sum, t) => sum + t.avgDifficultyScore, 0) / analytics.length || 0,
      }
    });
  } catch (error: any) {
    console.error('Error fetching topic difficulty analytics:', error);
    res.status(500).json({ 
      error: 'Failed to fetch topic difficulty analytics',
      details: error.message 
    });
  }
});

/**
 * GET /analytics/demographics
 * Get demographic learning insights
 */
router.get('/analytics/demographics', async (req, res) => {
  try {
    const analytics = await getDemographicAnalytics();
    
    res.json({
      success: true,
      data: analytics,
      insights: {
        totalDemographics: analytics.length,
        mostEngagedGroup: analytics.reduce((max, d) => d.avgEngagementDays > max.avgEngagementDays ? d : max, analytics[0] || { avgEngagementDays: 0 }),
        avgEfficiency: analytics.reduce((sum, d) => sum + d.avgEfficiency, 0) / analytics.length || 0,
      }
    });
  } catch (error: any) {
    console.error('Error fetching demographic analytics:', error);
    res.status(500).json({ 
      error: 'Failed to fetch demographic analytics',
      details: error.message 
    });
  }
});

/**
 * GET /analytics/dashboard
 * Get comprehensive analytics dashboard data
 */
router.get('/analytics/dashboard', async (req, res) => {
  try {
    const [
      topicAnalytics,
      patternAnalytics,
      cohortAnalytics,
      difficultyAnalytics,
      demographicAnalytics
    ] = await Promise.all([
      getTopicPopularityAnalytics(),
      getLearningPatternAnalytics(),
      getCohortAnalytics(),
      getTopicDifficultyAnalytics(),
      getDemographicAnalytics(),
    ]);

    res.json({
      success: true,
      data: {
        topics: {
          popularity: topicAnalytics.slice(0, 10), // Top 10
          difficulty: difficultyAnalytics.slice(0, 10), // Top 10 hardest
        },
        learningPatterns: patternAnalytics,
        cohorts: cohortAnalytics,
        demographics: demographicAnalytics.slice(0, 10), // Top 10
      },
      summary: {
        totalTopics: topicAnalytics.length,
        totalUsers: demographicAnalytics.reduce((sum, d) => sum + d.userCount, 0),
        avgMasteryRate: topicAnalytics.reduce((sum, t) => sum + t.avgMasteryRate, 0) / topicAnalytics.length || 0,
        mostEffectivePattern: patternAnalytics[0]?.pattern || 'No data',
        hardestTopic: difficultyAnalytics[0]?.topic || 'No data',
      }
    });
  } catch (error: any) {
    console.error('Error fetching dashboard analytics:', error);
    res.status(500).json({ 
      error: 'Failed to fetch dashboard analytics',
      details: error.message 
    });
  }
});

export default router;
