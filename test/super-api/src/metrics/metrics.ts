import client from 'prom-client';

// Create a Registry to hold all metrics
export const register = new client.Registry();

// Add default metrics (CPU, memory, etc.)
client.collectDefaultMetrics({ register });

// OpenAI Usage Metrics
export const openAiRequests = new client.Counter({
  name: 'openai_requests_total',
  help: 'Total number of OpenAI API requests',
  labelNames: ['prompt_type', 'model', 'status'],
  registers: [register]
});

export const openAiTokens = new client.Counter({
  name: 'openai_tokens_total',
  help: 'Total number of OpenAI tokens used',
  labelNames: ['prompt_type', 'model', 'token_type'], // token_type: 'input' or 'output'
  registers: [register]
});

export const openAiRequestDuration = new client.Histogram({
  name: 'openai_request_duration_seconds',
  help: 'Duration of OpenAI API requests in seconds',
  labelNames: ['prompt_type', 'model'],
  buckets: [0.1, 0.5, 1, 2, 5, 10, 30],
  registers: [register]
});

// Pipeline Processing Metrics
export const pipelineProcessingOutcomes = new client.Counter({
  name: 'pipeline_processing_outcomes_total',
  help: 'Total number of pipeline processing outcomes',
  labelNames: ['status', 'stage'], // status: 'success', 'failure', 'partial'
  registers: [register]
});

export const pipelineProcessingDuration = new client.Histogram({
  name: 'pipeline_processing_duration_seconds',
  help: 'Duration of pipeline processing in seconds',
  labelNames: ['stage'],
  buckets: [1, 5, 10, 30, 60, 120, 300],
  registers: [register]
});

// GPT Fallback Usage Metrics
export const gptFallbackUsage = new client.Counter({
  name: 'gpt_fallback_used_total',
  help: 'Total number of GPT fallback usages',
  labelNames: ['reason', 'term_type'],
  registers: [register]
});

// Term Moderation Metrics
export const termModerationActions = new client.Counter({
  name: 'term_moderation_actions_total',
  help: 'Total number of term moderation actions',
  labelNames: ['action', 'status'], // action: 'approve', 'reject', 'flag'
  registers: [register]
});

export const termModerationQueue = new client.Gauge({
  name: 'term_moderation_queue_size',
  help: 'Current number of terms pending moderation',
  registers: [register]
});

// Content Generation Metrics
export const contentGenerationJobs = new client.Counter({
  name: 'content_generation_jobs_total',
  help: 'Total number of content generation jobs',
  labelNames: ['status', 'topic_type'],
  registers: [register]
});

export const contentGenerationQueue = new client.Gauge({
  name: 'content_generation_queue_size',
  help: 'Current number of jobs in content generation queue',
  registers: [register]
});

// Database Metrics
export const databaseOperations = new client.Counter({
  name: 'database_operations_total',
  help: 'Total number of database operations',
  labelNames: ['operation', 'table', 'status'],
  registers: [register]
});

export const databaseOperationDuration = new client.Histogram({
  name: 'database_operation_duration_seconds',
  help: 'Duration of database operations in seconds',
  labelNames: ['operation', 'table'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1],
  registers: [register]
});

// System Health Metrics
export const systemHealth = new client.Gauge({
  name: 'system_health_status',
  help: 'System health status (1 = healthy, 0 = unhealthy)',
  labelNames: ['component'],
  registers: [register]
});

export const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
  labelNames: ['type'],
  registers: [register]
});

// Helper functions for common metric operations
export const incrementOpenAiRequest = (promptType: string, model: string, status: 'success' | 'failure') => {
  openAiRequests.inc({ prompt_type: promptType, model, status });
};

export const recordOpenAiTokens = (promptType: string, model: string, tokenType: 'input' | 'output', count: number) => {
  openAiTokens.inc({ prompt_type: promptType, model, token_type: tokenType }, count);
};

export const recordOpenAiDuration = (promptType: string, model: string, duration: number) => {
  openAiRequestDuration.observe({ prompt_type: promptType, model }, duration);
};

export const incrementPipelineOutcome = (status: 'success' | 'failure' | 'partial', stage: string) => {
  pipelineProcessingOutcomes.inc({ status, stage });
};

export const recordPipelineDuration = (stage: string, duration: number) => {
  pipelineProcessingDuration.observe({ stage }, duration);
};

export const incrementFallbackUsage = (reason: string, termType: string = 'unknown') => {
  gptFallbackUsage.inc({ reason, term_type: termType });
};

export const incrementModerationAction = (action: 'approve' | 'reject' | 'flag', status: 'success' | 'failure') => {
  termModerationActions.inc({ action, status });
};

export const setModerationQueueSize = (size: number) => {
  termModerationQueue.set(size);
};

export const incrementContentGenerationJob = (status: 'started' | 'completed' | 'failed', topicType: string = 'unknown') => {
  contentGenerationJobs.inc({ status, topic_type: topicType });
};

export const setContentGenerationQueueSize = (size: number) => {
  contentGenerationQueue.set(size);
};

export const incrementDatabaseOperation = (operation: string, table: string, status: 'success' | 'failure') => {
  databaseOperations.inc({ operation, table, status });
};

export const recordDatabaseDuration = (operation: string, table: string, duration: number) => {
  databaseOperationDuration.observe({ operation, table }, duration);
};

export const setSystemHealth = (component: string, healthy: boolean) => {
  systemHealth.set({ component }, healthy ? 1 : 0);
};

export const setActiveConnections = (type: string, count: number) => {
  activeConnections.set({ type }, count);
};

// Export metrics endpoint handler
export const getMetrics = async (): Promise<string> => {
  return register.metrics();
};




