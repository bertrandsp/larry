import { database } from '../utils/prisma';
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
      try {
        await database.topics.getById(topicId);
        console.log(`✅ Topic found for metric logging: ${topicId}`);
      } catch (error) {
        console.log(`⚠️ Topic not found for metric logging: ${topicId}`);
        logger.warn('Topic not found for metric logging', { topicId, type, message });
        // Log without topicId to avoid foreign key constraint error
        topicId = undefined;
      }
    }

    const result = await database.metrics.create({
      type,
      topic_id: topicId,
      term_id: termId,
      fact_id: factId,
      message,
      metadata
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
      database.metrics.getGroupedMetrics({
        type: 'openai',
        createdAt: { gte: since }
      }),

      // Most common fallback reasons
      database.metrics.getGroupedMetrics({
        type: 'fallback',
        createdAt: { gte: since },
        limit: 10
      }),

      // Moderation actions
      database.metrics.getGroupedMetrics({
        type: 'moderation',
        createdAt: { gte: since }
      }),

      // Pipeline outcomes
      database.metrics.getGroupedMetrics({
        type: 'pipeline',
        createdAt: { gte: since }
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
    // Get moderation metrics
    const flaggedMetrics = await database.metrics.getAll({
      type: 'moderation'
    });

    // Filter for rejected terms and group by term_id
    const flaggedTerms = flaggedMetrics.filter((metric: any) => 
      metric.metadata && metric.metadata.action === 'reject' && metric.term_id
    );

    // Group by term_id and count
    const grouped: any = {};
    flaggedTerms.forEach((metric: any) => {
      const termId = metric.term_id;
      if (!grouped[termId]) {
        grouped[termId] = {
          termId,
          metadata: metric.metadata,
          flagCount: 0
        };
      }
      grouped[termId].flagCount++;
    });

    // Sort by flag count and take top results
    const sortedFlagged = Object.values(grouped)
      .sort((a: any, b: any) => b.flagCount - a.flagCount)
      .slice(0, limit);

    // Get term details
    const termIds = sortedFlagged.map((f: any) => f.termId);
    const terms = await database.terms.getAll({ ids: termIds });

    return sortedFlagged.map((flagged: any) => {
      const term = terms.find((t: any) => t.id === flagged.termId);
      return {
        termId: flagged.termId,
        term: term?.term,
        definition: term?.definition,
        topicId: term?.topic_id,
        flagCount: flagged.flagCount,
        metadata: flagged.metadata
      };
    });
  } catch (error: any) {
    logger.error('Failed to get most flagged terms', { error: error.message });
    throw error;
  }
}
