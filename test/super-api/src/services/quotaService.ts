import { prisma } from '../utils/prisma';
import { getTierConfig } from '../config/tiers';
import { logMetric } from '../metrics/logEvents';

export interface QuotaUsage {
  userId: string;
  tier: string;
  currentUsage: number;
  maxRequests: number;
  resetPeriod: string;
  nextReset: Date;
  isQuotaExceeded: boolean;
  remainingRequests: number;
}

export interface QuotaCheckResult {
  allowed: boolean;
  usage: QuotaUsage;
  message?: string;
}

export class QuotaService {
  /**
   * Check if user can make a request based on their tier quota
   */
  async checkQuota(userId: string): Promise<QuotaCheckResult> {
    try {
      // Get user and their tier
      const user = await prisma.user.findUnique({
        where: { id: userId }
      });

      if (!user) {
        throw new Error('User not found');
      }

      const tierConfig = getTierConfig(user.subscription);
      
      // Get or create quota tracking record
      let quotaRecord = await prisma.userQuota.findUnique({
        where: { userId }
      });

      const now = new Date();
      
      if (!quotaRecord) {
        // First time user, create quota record
        quotaRecord = await prisma.userQuota.create({
          data: {
            userId,
            currentUsage: 0,
            periodStart: now,
            lastReset: now
          }
        });
      }

      // Check if we need to reset the quota
      const shouldReset = this.shouldResetQuota(
        quotaRecord.lastReset,
        tierConfig.resetPeriod,
        now
      );

      if (shouldReset) {
        // Reset quota for new period
        quotaRecord = await prisma.userQuota.update({
          where: { userId },
          data: {
            currentUsage: 0,
            periodStart: now,
            lastReset: now
          }
        });
      }

      // Check if quota is exceeded
      const isQuotaExceeded = quotaRecord.currentUsage >= tierConfig.maxRequestsPerPeriod;
      const remainingRequests = Math.max(0, tierConfig.maxRequestsPerPeriod - quotaRecord.currentUsage);

      // Calculate next reset time
      const nextReset = this.calculateNextReset(quotaRecord.lastReset, tierConfig.resetPeriod);

      const usage: QuotaUsage = {
        userId,
        tier: user.subscription,
        currentUsage: quotaRecord.currentUsage,
        maxRequests: tierConfig.maxRequestsPerPeriod,
        resetPeriod: tierConfig.resetPeriod,
        nextReset,
        isQuotaExceeded,
        remainingRequests
      };

      return {
        allowed: !isQuotaExceeded,
        usage,
        message: isQuotaExceeded 
          ? `Quota exceeded. ${tierConfig.resetPeriod} limit: ${tierConfig.maxRequestsPerPeriod} requests. Next reset: ${nextReset.toLocaleDateString()}`
          : `Quota available: ${remainingRequests} requests remaining`
      };

    } catch (error) {
      console.error('Quota check error:', error);
      throw error;
    }
  }

  /**
   * Increment user's quota usage after successful request
   */
  async incrementUsage(userId: string): Promise<void> {
    try {
      const updatedQuota = await prisma.userQuota.update({
        where: { userId },
        data: {
          currentUsage: {
            increment: 1
          }
        }
      });

      // Log quota usage
      await logMetric({
        type: 'quota_usage',
        message: `Quota usage incremented for user`,
        metadata: {
          userId,
          currentUsage: updatedQuota.currentUsage,
          periodStart: updatedQuota.periodStart,
          lastReset: updatedQuota.lastReset
        }
      });
    } catch (error) {
      console.error('Failed to increment quota usage:', error);
      // Don't throw error as this shouldn't break the main flow
    }
  }

  /**
   * Check if quota should be reset based on reset period
   */
  private shouldResetQuota(lastReset: Date, resetPeriod: string, now: Date): boolean {
    const lastResetTime = new Date(lastReset).getTime();
    const currentTime = now.getTime();
    
    switch (resetPeriod) {
      case 'daily':
        // Reset if it's a new day
        const lastDay = new Date(lastResetTime).getDate();
        const currentDay = new Date(currentTime).getDate();
        return lastDay !== currentDay;
        
      case 'weekly':
        // Reset if it's been 7 days or more
        const weekInMs = 7 * 24 * 60 * 60 * 1000;
        return (currentTime - lastResetTime) >= weekInMs;
        
      case 'monthly':
        // Reset if it's a new month
        const lastMonth = new Date(lastResetTime).getMonth();
        const currentMonth = new Date(currentTime).getMonth();
        const lastYear = new Date(lastResetTime).getFullYear();
        const currentYear = new Date(currentTime).getFullYear();
        return lastMonth !== currentMonth || lastYear !== currentYear;
        
      case 'never':
        return false;
        
      default:
        return false;
    }
  }

  /**
   * Calculate next reset time based on reset period
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
        // Set to far future
        resetDate.setFullYear(9999);
        break;
    }
    
    return resetDate;
  }

  /**
   * Get quota status for a user
   */
  async getQuotaStatus(userId: string): Promise<QuotaUsage | null> {
    try {
      const result = await this.checkQuota(userId);
      return result.usage;
    } catch (error) {
      console.error('Failed to get quota status:', error);
      return null;
    }
  }

  /**
   * Reset quota manually (admin function)
   */
  async resetQuota(userId: string): Promise<void> {
    try {
      const now = new Date();
      await prisma.userQuota.update({
        where: { userId },
        data: {
          currentUsage: 0,
          periodStart: now,
          lastReset: now
        }
      });
    } catch (error) {
      console.error('Failed to reset quota:', error);
      throw error;
    }
  }
}

export const quotaService = new QuotaService();
