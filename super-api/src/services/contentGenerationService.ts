import { Queue } from 'bullmq';
import Redis from 'ioredis';

// Redis connection
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: null
});

// Create the content generation queue
const contentGenerationQueue = new Queue('content-generation', {
  connection: redis,
  defaultJobOptions: {
    removeOnComplete: 10,
    removeOnFail: 5,
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
  },
});

export const contentGenerationService = {
  /**
   * Generate content for a specific topic
   */
  async generateContentForTopic(userId: string, topicName: string) {
    console.log(`🚀 Queuing content generation for topic: ${topicName} (User: ${userId})`);
    
    // Create a unique job ID
    const jobId = `manual-gen-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    // Add job to the queue
    const job = await contentGenerationQueue.add(
      'generate-content',
      {
        userId,
        topicName,
        jobId,
        timestamp: new Date().toISOString(),
      },
      {
        jobId,
        priority: 1, // High priority for manual generation
      }
    );
    
    console.log(`📋 Queued content generation job: ${jobId}`);
    
    return {
      jobId,
      status: 'queued',
      estimatedTime: '2-5 minutes',
    };
  },

  /**
   * Get job status
   */
  async getJobStatus(jobId: string) {
    const job = await contentGenerationQueue.getJob(jobId);
    
    if (!job) {
      return { status: 'not_found' };
    }
    
    const state = await job.getState();
    
    return {
      jobId,
      status: state,
      progress: job.progress,
      data: job.data,
      result: job.returnvalue,
      error: job.failedReason,
    };
  },

  /**
   * Get queue statistics
   */
  async getQueueStats() {
    const waiting = await contentGenerationQueue.getWaiting();
    const active = await contentGenerationQueue.getActive();
    const completed = await contentGenerationQueue.getCompleted();
    const failed = await contentGenerationQueue.getFailed();
    
    return {
      waiting: waiting.length,
      active: active.length,
      completed: completed.length,
      failed: failed.length,
      total: waiting.length + active.length + completed.length + failed.length,
    };
  },
};