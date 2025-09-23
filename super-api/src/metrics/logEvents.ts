import { prisma } from '../utils/prisma';
import logger from '../utils/logger';

export interface MetricLogData {
  type: string;
  topicId?: string;
  termId?: string;
  factId?: string;
  message: string;
  metadata?: any;
}

/**
 * Log a metric event to the database
 */
export async function logMetric({
  type,
  topicId,
  termId,
  factId,
  message,
  metadata = {}
}: MetricLogData): Promise<void> {
  console.log(`📊 Attempting to log metric: ${type} - ${message}`);
  
  try {
    // If topicId is provided, verify it exists to avoid foreign key constraint errors
    if (topicId) {
      const topicExists = await prisma.topic.findUnique({
        where: { id: topicId },
        select: { id: true }
      });
      
      if (!topicExists) {
        console.log(`⚠️ Topic not found for metric logging: ${topicId}`);
        logger.warn('Topic not found for metric logging', { topicId, type, message });
        // Log without topicId to avoid foreign key constraint error
        topicId = undefined;
      } else {
        console.log(`✅ Topic found for metric logging: ${topicId}`);
      }
    }

    const result = await prisma.metricLog.create({
      data: {
        type,
        topicId,
        termId,
        factId,
        message,
        metadata
      }
    });

    console.log(`✅ Metric logged successfully: ${result.id}`);

    // Also log to Winston for immediate visibility
    logger.info('Metric logged', {
      type,
      topicId,
      termId,
      factId,
      message,
      metadata
    });
  } catch (error: any) {
    console.error(`❌ Failed to log metric: ${error.message}`);
    logger.error('Failed to log metric', {
      type,
      topicId,
      termId,
      factId,
      message,
      error: error.message
    });
  }
}

/**
 * Log OpenAI usage metrics
 */
export async function logOpenAiUsage(
  promptType: string,
  model: string,
  inputTokens: number,
  outputTokens: number,
  topicId?: string,
  metadata: any = {}
): Promise<void> {
  await logMetric({
    type: 'openai',
    topicId,
    message: `OpenAI request: ${promptType} using ${model}`,
    metadata: {
      promptType,
      model,
      inputTokens,
      outputTokens,
      ...metadata
    }
  });
}

/**
 * Log pipeline processing events
 */
export async function logPipelineEvent(
  event: string,
  topicId: string,
  status: 'success' | 'failure' | 'partial',
  metadata: any = {}
): Promise<void> {
  await logMetric({
    type: 'pipeline',
    topicId,
    message: `Pipeline ${event}: ${status}`,
    metadata: {
      event,
      status,
      ...metadata
    }
  });
}

/**
 * Log GPT fallback usage
 */
export async function logFallbackUsage(
  reason: string,
  term: string,
  topicId?: string,
  termId?: string,
  metadata: any = {}
): Promise<void> {
  await logMetric({
    type: 'fallback',
    topicId,
    termId,
    message: `GPT fallback used: ${reason} for term "${term}"`,
    metadata: {
      reason,
      term,
      ...metadata
    }
  });
}

/**
 * Log term moderation events
 */
export async function logModerationEvent(
  action: string,
  termId: string,
  topicId?: string,
  metadata: any = {}
): Promise<void> {
  await logMetric({
    type: 'moderation',
    topicId,
    termId,
    message: `Moderation ${action} for term`,
    metadata: {
      action,
      ...metadata
    }
  });
}

/**
 * Log content generation events
 */
export async function logContentGeneration(
  event: string,
  topicId: string,
  status: 'started' | 'completed' | 'failed',
  metadata: any = {}
): Promise<void> {
  await logMetric({
    type: 'content_generation',
    topicId,
    message: `Content generation ${event}: ${status}`,
    metadata: {
      event,
      status,
      ...metadata
    }
  });
}

/**
 * Log database operation events
 */
export async function logDatabaseOperation(
  operation: string,
  table: string,
  status: 'success' | 'failure',
  duration?: number,
  metadata: any = {}
): Promise<void> {
  await logMetric({
    type: 'database',
    message: `Database ${operation} on ${table}: ${status}`,
    metadata: {
      operation,
      table,
      status,
      duration,
      ...metadata
    }
  });
}

/**
 * Get metrics summary for admin dashboard
 */
export async function getMetricsSummary(days: number = 7) {
  const since = new Date();
  since.setDate(since.getDate() - days);

  try {
    const [
      openAiMetrics,
      fallbackMetrics,
      moderationMetrics,
      pipelineMetrics
    ] = await Promise.all([
      // OpenAI usage by prompt type
      prisma.metricLog.groupBy({
        by: ['metadata'],
        where: {
          type: 'openai',
          createdAt: { gte: since }
        },
        _count: true
      }),

      // Most common fallback reasons
      prisma.metricLog.groupBy({
        by: ['metadata'],
        where: {
          type: 'fallback',
          createdAt: { gte: since }
        },
        _count: true,
        orderBy: { _count: { metadata: 'desc' } },
        take: 10
      }),

      // Moderation actions
      prisma.metricLog.groupBy({
        by: ['metadata'],
        where: {
          type: 'moderation',
          createdAt: { gte: since }
        },
        _count: true
      }),

      // Pipeline outcomes
      prisma.metricLog.groupBy({
        by: ['metadata'],
        where: {
          type: 'pipeline',
          createdAt: { gte: since }
        },
        _count: true
      })
    ]);

    return {
      openAiUsage: openAiMetrics,
      fallbackReasons: fallbackMetrics,
      moderationActions: moderationMetrics,
      pipelineOutcomes: pipelineMetrics,
      period: `${days} days`
    };
  } catch (error: any) {
    logger.error('Failed to get metrics summary', { error: error.message });
    throw error;
  }
}

/**
 * Get most flagged terms
 */
export async function getMostFlaggedTerms(limit: number = 10) {
  try {
    const flaggedTerms = await prisma.metricLog.groupBy({
      by: ['termId', 'metadata'],
      where: {
        type: 'moderation',
        metadata: {
          path: ['action'],
          equals: 'reject'
        }
      },
      _count: true,
      orderBy: { _count: { termId: 'desc' } },
      take: limit
    });

    // Get term details
    const termIds = flaggedTerms.map(f => f.termId).filter((id): id is string => id !== null);
    const terms = await prisma.term.findMany({
      where: { id: { in: termIds } },
      select: { id: true, term: true, definition: true, topicId: true }
    });

    return flaggedTerms.map(flagged => {
      const term = terms.find(t => t.id === flagged.termId);
      return {
        termId: flagged.termId,
        term: term?.term,
        definition: term?.definition,
        topicId: term?.topicId,
        flagCount: (flagged._count as any).termId || 0,
        metadata: flagged.metadata
      };
    });
  } catch (error: any) {
    logger.error('Failed to get most flagged terms', { error: error.message });
    throw error;
  }
}
