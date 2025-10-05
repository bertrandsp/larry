import { logMetric } from '../metrics/logEvents';

export interface CostAlert {
  type: 'daily_limit' | 'hourly_spike' | 'anomaly';
  message: string;
  cost: number;
  threshold: number;
  timestamp: Date;
}

export class CostMonitor {
  private dailySpend: number = 0;
  private hourlySpend: number = 0;
  private lastReset: Date = new Date();
  private alerts: CostAlert[] = [];

  // Cost thresholds
  private readonly DAILY_LIMIT = 10.00; // $10 per day
  private readonly HOURLY_LIMIT = 2.00; // $2 per hour
  private readonly SPIKE_THRESHOLD = 1.00; // $1 spike in 10 minutes

  async trackCost(model: string, inputTokens: number, outputTokens: number, userId?: string): Promise<void> {
    const cost = this.calculateCost(model, inputTokens, outputTokens);
    
    this.dailySpend += cost;
    this.hourlySpend += cost;

    // Reset counters if needed
    this.resetIfNeeded();

    // Check for alerts
    await this.checkAlerts(cost, userId);

    // Log the cost
    await logMetric({
      type: 'cost_tracking',
      message: `Cost tracked: $${cost.toFixed(4)}`,
      metadata: {
        model,
        inputTokens,
        outputTokens,
        cost,
        dailySpend: this.dailySpend,
        hourlySpend: this.hourlySpend,
        userId
      }
    });
  }

  private calculateCost(model: string, inputTokens: number, outputTokens: number): number {
    const pricing = {
      "gpt-4o": { input: 0.005, output: 0.015 },
      "gpt-4o-mini": { input: 0.00015, output: 0.0006 }
    };

    const modelPricing = pricing[model as keyof typeof pricing] || pricing["gpt-4o-mini"];
    return (inputTokens / 1000) * modelPricing.input + (outputTokens / 1000) * modelPricing.output;
  }

  private resetIfNeeded(): void {
    const now = new Date();
    const hoursSinceReset = (now.getTime() - this.lastReset.getTime()) / (1000 * 60 * 60);

    if (hoursSinceReset >= 1) {
      this.hourlySpend = 0;
    }

    if (hoursSinceReset >= 24) {
      this.dailySpend = 0;
      this.lastReset = now;
    }
  }

  private async checkAlerts(currentCost: number, userId?: string): Promise<void> {
    const now = new Date();

    // Daily limit alert
    if (this.dailySpend > this.DAILY_LIMIT) {
      const alert: CostAlert = {
        type: 'daily_limit',
        message: `Daily spending limit exceeded: $${this.dailySpend.toFixed(2)} / $${this.DAILY_LIMIT}`,
        cost: this.dailySpend,
        threshold: this.DAILY_LIMIT,
        timestamp: now
      };
      
      this.alerts.push(alert);
      await this.sendAlert(alert);
    }

    // Hourly limit alert
    if (this.hourlySpend > this.HOURLY_LIMIT) {
      const alert: CostAlert = {
        type: 'hourly_spike',
        message: `Hourly spending spike: $${this.hourlySpend.toFixed(2)} / $${this.HOURLY_LIMIT}`,
        cost: this.hourlySpend,
        threshold: this.HOURLY_LIMIT,
        timestamp: now
      };
      
      this.alerts.push(alert);
      await this.sendAlert(alert);
    }

    // Large single request alert
    if (currentCost > this.SPIKE_THRESHOLD) {
      const alert: CostAlert = {
        type: 'anomaly',
        message: `Large single request detected: $${currentCost.toFixed(4)}`,
        cost: currentCost,
        threshold: this.SPIKE_THRESHOLD,
        timestamp: now
      };
      
      this.alerts.push(alert);
      await this.sendAlert(alert);
    }
  }

  private async sendAlert(alert: CostAlert): Promise<void> {
    console.warn(`🚨 COST ALERT: ${alert.message}`);
    
    await logMetric({
      type: 'cost_alert',
      message: alert.message,
      metadata: {
        alertType: alert.type,
        cost: alert.cost,
        threshold: alert.threshold,
        timestamp: alert.timestamp.toISOString()
      }
    });

    // In production, you might send this to Slack, email, etc.
    // await sendSlackAlert(alert);
    // await sendEmailAlert(alert);
  }

  getDailySpend(): number {
    this.resetIfNeeded();
    return this.dailySpend;
  }

  getHourlySpend(): number {
    this.resetIfNeeded();
    return this.hourlySpend;
  }

  getAlerts(): CostAlert[] {
    return this.alerts.slice(-50); // Return last 50 alerts
  }

  async getCostSummary(): Promise<any> {
    this.resetIfNeeded();
    
    return {
      dailySpend: this.dailySpend,
      hourlySpend: this.hourlySpend,
      dailyLimit: this.DAILY_LIMIT,
      hourlyLimit: this.HOURLY_LIMIT,
      dailyRemaining: Math.max(0, this.DAILY_LIMIT - this.dailySpend),
      hourlyRemaining: Math.max(0, this.HOURLY_LIMIT - this.hourlySpend),
      recentAlerts: this.alerts.slice(-10),
      recommendations: this.getRecommendations()
    };
  }

  private getRecommendations(): string[] {
    const recommendations = [];

    if (this.dailySpend > this.DAILY_LIMIT * 0.8) {
      recommendations.push('Consider implementing stricter rate limits');
    }

    if (this.hourlySpend > this.HOURLY_LIMIT * 0.8) {
      recommendations.push('Add request queuing to smooth out spikes');
    }

    if (this.alerts.length > 10) {
      recommendations.push('Review and optimize prompt lengths');
      recommendations.push('Implement more aggressive caching');
    }

    if (this.dailySpend > 5) {
      recommendations.push('Consider switching to gpt-4o-mini for non-critical requests');
    }

    return recommendations;
  }
}

// Singleton instance
export const costMonitor = new CostMonitor();
