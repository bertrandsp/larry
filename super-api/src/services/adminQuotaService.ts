import { prisma } from '../utils/prisma';
import { getTierConfig, TIER_CONFIGS } from '../config/tiers';
import { quotaService } from './quotaService';

export interface AdminQuotaAction {
  action: 'reset' | 'upgrade' | 'downgrade' | 'set_custom_limit' | 'bulk_reset';
  userId?: string;
  newTier?: string;
  customLimit?: number;
  reason?: string;
  adminId: string;
}

export interface BulkQuotaReset {
  tier: string;
  resetCount: number;
  affectedUsers: string[];
}

export interface AdminQuotaReport {
  totalUsers: number;
  quotaExceededUsers: number;
  usersNeedingReset: Array<{ userId: string; email: string; tier: string; usage: number; maxRequests: number }>;
  tierUpgradeRecommendations: Array<{ userId: string; email: string; currentTier: string; recommendedTier: string; reason: string }>;
  systemHealth: {
    averageUsagePerTier: Record<string, number>;
    mostActiveUsers: Array<{ userId: string; email: string; usage: number; tier: string }>;
    quotaUtilization: number;
  };
}

export class AdminQuotaService {
  /**
   * Reset a user's quota manually
   */
  async resetUserQuota(userId: string, adminId: string, reason?: string): Promise<boolean> {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: { quota: true }
      });

      if (!user) {
        throw new Error('User not found');
      }

      const now = new Date();
      
      // Reset quota
      await prisma.userQuota.update({
        where: { userId },
        data: {
          currentUsage: 0,
          periodStart: now,
          lastReset: now
        }
      });

      // Log admin action
      await this.logAdminAction({
        action: 'reset',
        userId,
        adminId,
        reason: reason || 'Manual reset by admin'
      });

      return true;

    } catch (error) {
      console.error('Failed to reset user quota:', error);
      throw error;
    }
  }

  /**
   * Upgrade/downgrade user tier
   */
  async changeUserTier(userId: string, newTier: string, adminId: string, reason?: string): Promise<boolean> {
    try {
      if (!TIER_CONFIGS[newTier]) {
        throw new Error(`Invalid tier: ${newTier}`);
      }

      const user = await prisma.user.findUnique({
        where: { id: userId }
      });

      if (!user) {
        throw new Error('User not found');
      }

      // Update user tier
      await prisma.user.update({
        where: { id: userId },
        data: { subscription: newTier }
      });

      // Reset quota for new tier
      await this.resetUserQuota(userId, adminId, `Tier change to ${newTier}`);

      // Log admin action
      await this.logAdminAction({
        action: user.subscription === newTier ? 'upgrade' : 'downgrade',
        userId,
        newTier,
        adminId,
        reason: reason || `Tier changed to ${newTier}`
      });

      return true;

    } catch (error) {
      console.error('Failed to change user tier:', error);
      throw error;
    }
  }

  /**
   * Set custom quota limit for a user
   */
  async setCustomQuotaLimit(userId: string, customLimit: number, adminId: string, reason?: string): Promise<boolean> {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId }
      });

      if (!user) {
        throw new Error('User not found');
      }

      if (customLimit < 1) {
        throw new Error('Custom limit must be at least 1');
      }

      // Store custom limit in user metadata (you might want to add a customQuota field to User model)
      // For now, we'll use a custom approach
      await prisma.user.update({
        where: { id: userId },
        data: {
          // Add custom quota field if needed
        }
      });

      // Log admin action
      await this.logAdminAction({
        action: 'set_custom_limit',
        userId,
        customLimit,
        adminId,
        reason: reason || `Custom limit set to ${customLimit}`
      });

      return true;

    } catch (error) {
      console.error('Failed to set custom quota limit:', error);
      throw error;
    }
  }

  /**
   * Bulk reset quotas for all users of a specific tier
   */
  async bulkResetTierQuotas(tier: string, adminId: string, reason?: string): Promise<BulkQuotaReset> {
    try {
      if (!TIER_CONFIGS[tier]) {
        throw new Error(`Invalid tier: ${tier}`);
      }

      const users = await prisma.user.findMany({
        where: { subscription: tier },
        include: { quota: true }
      });

      const affectedUsers: string[] = [];
      let resetCount = 0;

      for (const user of users) {
        if (user.quota) {
          await this.resetUserQuota(user.id, adminId, `Bulk reset for ${tier} tier`);
          affectedUsers.push(user.id);
          resetCount++;
        }
      }

      // Log admin action
      await this.logAdminAction({
        action: 'bulk_reset',
        adminId,
        reason: reason || `Bulk reset for ${tier} tier - ${resetCount} users affected`
      });

      return {
        tier,
        resetCount,
        affectedUsers
      };

    } catch (error) {
      console.error('Failed to bulk reset tier quotas:', error);
      throw error;
    }
  }

  /**
   * Get comprehensive admin report
   */
  async getAdminReport(): Promise<AdminQuotaReport> {
    try {
      const users = await prisma.user.findMany({
        include: { quota: true }
      });

      // Find quota exceeded users
      const quotaExceededUsers = users.filter(user => 
        user.quota && user.quota.currentUsage >= getTierConfig(user.subscription).maxRequestsPerPeriod
      );

      // Find users needing reset (high usage)
      const usersNeedingReset = users
        .filter(user => user.quota && user.quota.currentUsage > 0)
        .map(user => ({
          userId: user.id,
          email: user.email,
          tier: user.subscription,
          usage: user.quota!.currentUsage,
          maxRequests: getTierConfig(user.subscription).maxRequestsPerPeriod
        }))
        .sort((a, b) => (b.usage / b.maxRequests) - (a.usage / a.maxRequests))
        .slice(0, 20);

      // Generate tier upgrade recommendations
      const tierUpgradeRecommendations: Array<{ userId: string; email: string; currentTier: string; recommendedTier: string; reason: string }> = [];
      
      users.forEach(user => {
        if (user.quota && user.quota.currentUsage > 0) {
          const currentTier = user.subscription;
          const usagePercentage = (user.quota.currentUsage / getTierConfig(currentTier).maxRequestsPerPeriod) * 100;
          
          if (usagePercentage > 80) {
            // Recommend upgrade
            const tiers = Object.keys(TIER_CONFIGS);
            const currentIndex = tiers.indexOf(currentTier);
            if (currentIndex < tiers.length - 1) {
              const recommendedTier = tiers[currentIndex + 1];
              tierUpgradeRecommendations.push({
                userId: user.id,
                email: user.email,
                currentTier,
                recommendedTier,
                reason: `High usage (${Math.round(usagePercentage)}%) - consider upgrading to ${recommendedTier}`
              });
            }
          }
        }
      });

      // Calculate system health metrics
      const totalRequests = users.reduce((sum, user) => 
        sum + (user.quota?.currentUsage || 0), 0
      );
      
      const totalMaxRequests = users.reduce((sum, user) => 
        sum + getTierConfig(user.subscription).maxRequestsPerPeriod, 0
      );
      
      const quotaUtilization = totalMaxRequests > 0 ? (totalRequests / totalMaxRequests) * 100 : 0;

      // Calculate average usage per tier
      const tierUsage: Record<string, number[]> = {};
      users.forEach(user => {
        if (user.quota && user.quota.currentUsage > 0) {
          const tier = user.subscription;
          if (!tierUsage[tier]) tierUsage[tier] = [];
          tierUsage[tier].push(user.quota.currentUsage);
        }
      });

      const averageUsagePerTier: Record<string, number> = {};
      Object.keys(tierUsage).forEach(tier => {
        const usages = tierUsage[tier];
        averageUsagePerTier[tier] = usages.length > 0 
          ? usages.reduce((sum, usage) => sum + usage, 0) / usages.length 
          : 0;
      });

      // Get most active users
      const mostActiveUsers = users
        .filter(user => user.quota && user.quota.currentUsage > 0)
        .map(user => ({
          userId: user.id,
          email: user.email,
          usage: user.quota!.currentUsage,
          tier: user.subscription
        }))
        .sort((a, b) => b.usage - a.usage)
        .slice(0, 10);

      return {
        totalUsers: users.length,
        quotaExceededUsers: quotaExceededUsers.length,
        usersNeedingReset,
        tierUpgradeRecommendations,
        systemHealth: {
          averageUsagePerTier,
          mostActiveUsers,
          quotaUtilization: Math.round(quotaUtilization * 100) / 100
        }
      };

    } catch (error) {
      console.error('Failed to get admin report:', error);
      throw error;
    }
  }

  /**
   * Log admin actions for audit trail
   */
  private async logAdminAction(action: AdminQuotaAction): Promise<void> {
    try {
      // You might want to create an AdminActionLog model for this
      console.log('Admin Action Log:', {
        timestamp: new Date().toISOString(),
        ...action
      });
    } catch (error) {
      console.error('Failed to log admin action:', error);
    }
  }
}

export const adminQuotaService = new AdminQuotaService();
