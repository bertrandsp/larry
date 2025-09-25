import { prisma } from '../utils/prisma';
import { getTierConfig, TIER_CONFIGS } from '../config/tiers';

export interface QuotaAnalytics {
  totalUsers: number;
  tierDistribution: Record<string, number>;
  averageUsagePerTier: Record<string, number>;
  quotaExceededUsers: number;
  systemHealth: {
    totalRequests: number;
    averageRequestsPerUser: number;
    mostActiveUsers: Array<{ userId: string; usage: number; tier: string }>;
  };
  resetSchedule: {
    nextDailyReset: Date;
    nextWeeklyReset: Date;
    nextMonthlyReset: Date;
  };
}

export interface UserQuotaAnalytics {
  userId: string;
  email: string;
  tier: string;
  currentUsage: number;
  maxRequests: number;
  usagePercentage: number;
  resetPeriod: string;
  nextReset: Date;
  isQuotaExceeded: boolean;
  lastActivity: Date;
}

export class QuotaAnalyticsService {
  /**
   * Get comprehensive system-wide quota analytics
   */
  async getSystemAnalytics(): Promise<QuotaAnalytics> {
    try {
      // Get all users with their quota information
      const users = await prisma.user.findMany({
        include: {
          quota: true
        }
      });

      // Calculate tier distribution
      const tierDistribution: Record<string, number> = {};
      const tierUsage: Record<string, number[]> = {};
      
      users.forEach(user => {
        const tier = user.subscription;
        tierDistribution[tier] = (tierDistribution[tier] || 0) + 1;
        
        if (!tierUsage[tier]) tierUsage[tier] = [];
        if (user.quota) {
          tierUsage[tier].push(user.quota.currentUsage);
        }
      });

      // Calculate average usage per tier
      const averageUsagePerTier: Record<string, number> = {};
      Object.keys(tierUsage).forEach(tier => {
        const usages = tierUsage[tier];
        averageUsagePerTier[tier] = usages.length > 0 
          ? usages.reduce((sum, usage) => sum + usage, 0) / usages.length 
          : 0;
      });

      // Count quota exceeded users
      const quotaExceededUsers = users.filter(user => 
        user.quota && user.quota.currentUsage >= getTierConfig(user.subscription).maxRequestsPerPeriod
      ).length;

      // Get most active users
      const mostActiveUsers = users
        .filter(user => user.quota)
        .map(user => ({
          userId: user.id,
          usage: user.quota!.currentUsage,
          tier: user.subscription
        }))
        .sort((a, b) => b.usage - a.usage)
        .slice(0, 10);

      // Calculate total system requests
      const totalRequests = users.reduce((sum, user) => 
        sum + (user.quota?.currentUsage || 0), 0
      );

      // Calculate reset schedule
      const now = new Date();
      const nextDailyReset = new Date(now);
      nextDailyReset.setDate(nextDailyReset.getDate() + 1);
      nextDailyReset.setHours(0, 0, 0, 0);

      const nextWeeklyReset = new Date(now);
      nextWeeklyReset.setDate(nextWeeklyReset.getDate() + 7);
      nextWeeklyReset.setHours(0, 0, 0, 0);

      const nextMonthlyReset = new Date(now);
      nextMonthlyReset.setMonth(nextMonthlyReset.getMonth() + 1);
      nextMonthlyReset.setDate(1);
      nextMonthlyReset.setHours(0, 0, 0, 0);

      return {
        totalUsers: users.length,
        tierDistribution,
        averageUsagePerTier,
        quotaExceededUsers,
        systemHealth: {
          totalRequests,
          averageRequestsPerUser: users.length > 0 ? totalRequests / users.length : 0,
          mostActiveUsers
        },
        resetSchedule: {
          nextDailyReset,
          nextWeeklyReset,
          nextMonthlyReset
        }
      };

    } catch (error) {
      console.error('Failed to get system analytics:', error);
      throw error;
    }
  }

  /**
   * Get analytics for a specific user
   */
  async getUserAnalytics(userId: string): Promise<UserQuotaAnalytics | null> {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: { quota: true }
      });

      if (!user) return null;

      const tierConfig = getTierConfig(user.subscription);
      const usagePercentage = user.quota 
        ? (user.quota.currentUsage / tierConfig.maxRequestsPerPeriod) * 100 
        : 0;

      return {
        userId: user.id,
        email: user.email,
        tier: user.subscription,
        currentUsage: user.quota?.currentUsage || 0,
        maxRequests: tierConfig.maxRequestsPerPeriod,
        usagePercentage: Math.round(usagePercentage * 100) / 100,
        resetPeriod: tierConfig.resetPeriod,
        nextReset: user.quota ? this.calculateNextReset(user.quota.lastReset, tierConfig.resetPeriod) : new Date(),
        isQuotaExceeded: user.quota ? user.quota.currentUsage >= tierConfig.maxRequestsPerPeriod : false,
        lastActivity: user.quota?.updatedAt || user.createdAt
      };

    } catch (error) {
      console.error('Failed to get user analytics:', error);
      return null;
    }
  }

  /**
   * Get tier performance metrics
   */
  async getTierPerformance(): Promise<Record<string, any>> {
    try {
      const users = await prisma.user.findMany({
        include: { quota: true }
      });

      const tierMetrics: Record<string, any> = {};
      
      Object.keys(TIER_CONFIGS).forEach(tier => {
        const tierUsers = users.filter(user => user.subscription === tier);
        const activeUsers = tierUsers.filter(user => user.quota && user.quota.currentUsage > 0);
        
        tierMetrics[tier] = {
          totalUsers: tierUsers.length,
          activeUsers: activeUsers.length,
          averageUsage: activeUsers.length > 0 
            ? activeUsers.reduce((sum, user) => sum + (user.quota?.currentUsage || 0), 0) / activeUsers.length
            : 0,
          maxRequests: TIER_CONFIGS[tier].maxRequestsPerPeriod,
          resetPeriod: TIER_CONFIGS[tier].resetPeriod,
          features: TIER_CONFIGS[tier].features
        };
      });

      return tierMetrics;

    } catch (error) {
      console.error('Failed to get tier performance:', error);
      throw error;
    }
  }

  /**
   * Calculate next reset time (helper method)
   */
  private calculateNextReset(lastReset: Date, resetPeriod: string): Date {
    const resetDate = new Date(lastReset);
    
    switch (resetPeriod) {
      case 'daily':
        resetDate.setDate(resetDate.getDate() + 1);
        resetDate.setHours(0, 0, 0, 0);
        break;
      case 'weekly':
        resetDate.setDate(resetDate.getDate() + 7);
        resetDate.setHours(0, 0, 0, 0);
        break;
      case 'monthly':
        resetDate.setMonth(resetDate.getMonth() + 1);
        resetDate.setDate(1);
        resetDate.setHours(0, 0, 0, 0);
        break;
      case 'never':
        resetDate.setFullYear(9999);
        break;
    }
    
    return resetDate;
  }
}

export const quotaAnalyticsService = new QuotaAnalyticsService();
