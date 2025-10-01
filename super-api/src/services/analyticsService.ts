import { supabase } from '../config/supabase';

/**
 * Educational Analytics Service
 * Provides privacy-safe insights into learning patterns and topic preferences
 */

export interface TopicAnalytics {
  topic: string;
  totalUsers: number;
  avgMasteryRate: number;
  avgLearningSpeed: number;
  demographicBreakdown: {
    [ageBracket: string]: number;
  };
  skillLevelBreakdown: {
    [level: string]: number;
  };
}

export interface LearningPatternAnalytics {
  pattern: string;
  userCount: number;
  avgTermsMastered: number;
  avgEngagementDuration: number;
  effectivenessScore: number;
}

export interface CohortAnalytics {
  cohortGroup: string;
  totalUsers: number;
  topTopics: Array<{
    topic: string;
    userCount: number;
  }>;
  avgLearningEfficiency: number;
  trendDirection: 'up' | 'down' | 'stable';
}

/**
 * Get most popular topics with learning effectiveness metrics
 */
export async function getTopicPopularityAnalytics(): Promise<TopicAnalytics[]> {
  try {
    const { data, error } = await supabase
      .from('AnonymizedLearningData')
      .select(`
        topic_preferences,
        user_age_bracket,
        learning_level,
        terms_mastered,
        total_terms_learned,
        average_learning_speed,
        success_metrics
      `);

    if (error) throw error;

    // Process the data to create topic analytics
    const topicMap = new Map<string, {
      users: Set<string>;
      masteryRates: number[];
      learningSpeeds: number[];
      demographics: Map<string, number>;
      skillLevels: Map<string, number>;
    }>();

    data?.forEach((record, index) => {
      const userId = `user_${index}`; // Create anonymous user identifier
      
      record.topic_preferences?.forEach((topic: string) => {
        if (!topicMap.has(topic)) {
          topicMap.set(topic, {
            users: new Set(),
            masteryRates: [],
            learningSpeeds: [],
            demographics: new Map(),
            skillLevels: new Map(),
          });
        }

        const topicData = topicMap.get(topic)!;
        topicData.users.add(userId);
        
        const masteryRate = record.total_terms_learned > 0 
          ? record.terms_mastered / record.total_terms_learned 
          : 0;
        topicData.masteryRates.push(masteryRate);
        topicData.learningSpeeds.push(record.average_learning_speed || 0);

        // Demographics
        const ageBracket = record.user_age_bracket || 'unknown';
        topicData.demographics.set(ageBracket, (topicData.demographics.get(ageBracket) || 0) + 1);

        // Skill levels
        const skillLevel = record.learning_level || 'unknown';
        topicData.skillLevels.set(skillLevel, (topicData.skillLevels.get(skillLevel) || 0) + 1);
      });
    });

    // Convert to analytics format
    const analytics: TopicAnalytics[] = Array.from(topicMap.entries()).map(([topic, data]) => ({
      topic,
      totalUsers: data.users.size,
      avgMasteryRate: data.masteryRates.reduce((a, b) => a + b, 0) / data.masteryRates.length || 0,
      avgLearningSpeed: data.learningSpeeds.reduce((a, b) => a + b, 0) / data.learningSpeeds.length || 0,
      demographicBreakdown: Object.fromEntries(data.demographics),
      skillLevelBreakdown: Object.fromEntries(data.skillLevels),
    }));

    return analytics.sort((a, b) => b.totalUsers - a.totalUsers);
  } catch (error) {
    console.error('Error getting topic popularity analytics:', error);
    throw error;
  }
}

/**
 * Analyze learning pattern effectiveness
 */
export async function getLearningPatternAnalytics(): Promise<LearningPatternAnalytics[]> {
  try {
    const { data, error } = await supabase
      .from('AnonymizedLearningData')
      .select(`
        learning_pattern,
        terms_mastered,
        days_active,
        success_metrics
      `);

    if (error) throw error;

    const patternMap = new Map<string, {
      userCount: number;
      termsMastered: number[];
      engagementDurations: number[];
      efficiencyScores: number[];
    }>();

    data?.forEach((record) => {
      const pattern = record.learning_pattern || 'unknown';
      
      if (!patternMap.has(pattern)) {
        patternMap.set(pattern, {
          userCount: 0,
          termsMastered: [],
          engagementDurations: [],
          efficiencyScores: [],
        });
      }

      const patternData = patternMap.get(pattern)!;
      patternData.userCount++;
      patternData.termsMastered.push(record.terms_mastered || 0);
      patternData.engagementDurations.push(record.days_active || 0);
      
      const efficiency = record.success_metrics?.learning_efficiency || 0;
      patternData.efficiencyScores.push(efficiency);
    });

    const analytics: LearningPatternAnalytics[] = Array.from(patternMap.entries()).map(([pattern, data]) => ({
      pattern,
      userCount: data.userCount,
      avgTermsMastered: data.termsMastered.reduce((a, b) => a + b, 0) / data.termsMastered.length || 0,
      avgEngagementDuration: data.engagementDurations.reduce((a, b) => a + b, 0) / data.engagementDurations.length || 0,
      effectivenessScore: data.efficiencyScores.reduce((a, b) => a + b, 0) / data.efficiencyScores.length || 0,
    }));

    return analytics.sort((a, b) => b.effectivenessScore - a.effectivenessScore);
  } catch (error) {
    console.error('Error getting learning pattern analytics:', error);
    throw error;
  }
}

/**
 * Analyze cohort trends and topic evolution
 */
export async function getCohortAnalytics(): Promise<CohortAnalytics[]> {
  try {
    const { data, error } = await supabase
      .from('AnonymizedLearningData')
      .select(`
        cohort_group,
        topic_preferences,
        success_metrics
      `)
      .order('cohort_group', { ascending: true });

    if (error) throw error;

    const cohortMap = new Map<string, {
      users: Set<string>;
      topics: Map<string, number>;
      efficiencyScores: number[];
    }>();

    data?.forEach((record, index) => {
      const userId = `user_${index}`;
      const cohort = record.cohort_group || 'unknown';
      
      if (!cohortMap.has(cohort)) {
        cohortMap.set(cohort, {
          users: new Set(),
          topics: new Map(),
          efficiencyScores: [],
        });
      }

      const cohortData = cohortMap.get(cohort)!;
      cohortData.users.add(userId);
      cohortData.efficiencyScores.push(record.success_metrics?.learning_efficiency || 0);

      record.topic_preferences?.forEach((topic: string) => {
        cohortData.topics.set(topic, (cohortData.topics.get(topic) || 0) + 1);
      });
    });

    const analytics: CohortAnalytics[] = Array.from(cohortMap.entries()).map(([cohort, data]) => {
      const topTopics = Array.from(data.topics.entries())
        .map(([topic, count]) => ({ topic, userCount: count }))
        .sort((a, b) => b.userCount - a.userCount)
        .slice(0, 5);

      const avgEfficiency = data.efficiencyScores.reduce((a, b) => a + b, 0) / data.efficiencyScores.length || 0;

      return {
        cohortGroup: cohort,
        totalUsers: data.users.size,
        topTopics,
        avgLearningEfficiency: avgEfficiency,
        trendDirection: 'stable' as const, // Could be enhanced with historical data
      };
    });

    return analytics.sort((a, b) => a.cohortGroup.localeCompare(b.cohortGroup));
  } catch (error) {
    console.error('Error getting cohort analytics:', error);
    throw error;
  }
}

/**
 * Get topic difficulty analysis
 */
export async function getTopicDifficultyAnalytics() {
  try {
    const { data, error } = await supabase
      .from('AnonymizedLearningData')
      .select(`
        topic_preferences,
        terms_struggled_with,
        total_terms_learned,
        learning_level
      `);

    if (error) throw error;

    const topicDifficultyMap = new Map<string, {
      totalAttempts: number;
      struggles: number;
      difficultyByLevel: Map<string, number>;
    }>();

    data?.forEach((record) => {
      const struggleRate = record.total_terms_learned > 0 
        ? record.terms_struggled_with / record.total_terms_learned 
        : 0;

      record.topic_preferences?.forEach((topic: string) => {
        if (!topicDifficultyMap.has(topic)) {
          topicDifficultyMap.set(topic, {
            totalAttempts: 0,
            struggles: 0,
            difficultyByLevel: new Map(),
          });
        }

        const topicData = topicDifficultyMap.get(topic)!;
        topicData.totalAttempts++;
        topicData.struggles += struggleRate;

        const level = record.learning_level || 'unknown';
        topicData.difficultyByLevel.set(level, (topicData.difficultyByLevel.get(level) || 0) + struggleRate);
      });
    });

    return Array.from(topicDifficultyMap.entries()).map(([topic, data]) => ({
      topic,
      avgDifficultyScore: data.struggles / data.totalAttempts || 0,
      totalUsers: data.totalAttempts,
      difficultyByLevel: Object.fromEntries(data.difficultyByLevel),
    })).sort((a, b) => b.avgDifficultyScore - a.avgDifficultyScore);
  } catch (error) {
    console.error('Error getting topic difficulty analytics:', error);
    throw error;
  }
}

/**
 * Get demographic learning insights
 */
export async function getDemographicAnalytics() {
  try {
    const { data, error } = await supabase
      .from('AnonymizedLearningData')
      .select(`
        user_age_bracket,
        learning_level,
        terms_mastered,
        days_active,
        learning_pattern,
        success_metrics
      `);

    if (error) throw error;

    const demographicMap = new Map<string, {
      userCount: number;
      avgTermsMastered: number;
      avgEngagement: number;
      commonPatterns: Map<string, number>;
      efficiencyScores: number[];
    }>();

    data?.forEach((record) => {
      const demographic = `${record.user_age_bracket}_${record.learning_level}` || 'unknown';
      
      if (!demographicMap.has(demographic)) {
        demographicMap.set(demographic, {
          userCount: 0,
          avgTermsMastered: 0,
          avgEngagement: 0,
          commonPatterns: new Map(),
          efficiencyScores: [],
        });
      }

      const demoData = demographicMap.get(demographic)!;
      demoData.userCount++;
      demoData.avgTermsMastered += record.terms_mastered || 0;
      demoData.avgEngagement += record.days_active || 0;
      demoData.efficiencyScores.push(record.success_metrics?.learning_efficiency || 0);

      const pattern = record.learning_pattern || 'unknown';
      demoData.commonPatterns.set(pattern, (demoData.commonPatterns.get(pattern) || 0) + 1);
    });

    return Array.from(demographicMap.entries()).map(([demographic, data]) => ({
      demographic,
      userCount: data.userCount,
      avgTermsMastered: data.avgTermsMastered / data.userCount || 0,
      avgEngagementDays: data.avgEngagement / data.userCount || 0,
      avgEfficiency: data.efficiencyScores.reduce((a, b) => a + b, 0) / data.efficiencyScores.length || 0,
      mostCommonPattern: Array.from(data.commonPatterns.entries())
        .sort((a, b) => b[1] - a[1])[0]?.[0] || 'unknown',
    })).sort((a, b) => b.userCount - a.userCount);
  } catch (error) {
    console.error('Error getting demographic analytics:', error);
    throw error;
  }
}
