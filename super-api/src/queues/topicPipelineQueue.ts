import { Queue } from 'bullmq';
import Redis from 'ioredis';

// Create Redis connection options for Redis 8.x compatibility
const redisOptions = {
  host: 'localhost',
  port: 6379,
  maxRetriesPerRequest: null, // Required for BullMQ with Redis 8.x
  enableReadyCheck: false,
  retryStrategy(times: number) {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
};

// Topic processing queue with enhanced configuration
export const topicPipelineQueue = new Queue('generate-topic-pipeline', {
  connection: redisOptions,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
    removeOnComplete: 100,
    removeOnFail: 50,
  },
});

// Daily word pre-generation queue - separate connection
export const generateNextBatchQueue = new Queue('generate-next-batch', {
  connection: redisOptions,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
    removeOnComplete: 50,
    removeOnFail: 25,
  },
});

// Job types
export interface TopicGenerationJob {
  userId: string;
  topicId: string;
  topicName: string;
  userTier?: string;
}

// Queue event handlers
topicPipelineQueue.on('error', (err: any) => {
  console.error('❌ Topic pipeline queue error:', err);
});

generateNextBatchQueue.on('error', (err: any) => {
  console.error('❌ Generate next batch queue error:', err);
});

export default topicPipelineQueue;
