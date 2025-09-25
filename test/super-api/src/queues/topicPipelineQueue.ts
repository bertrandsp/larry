import { Queue } from 'bullmq';
import Redis from 'ioredis';

// Redis connection
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

// Topic processing queue with enhanced configuration
export const topicPipelineQueue = new Queue('generate-topic-pipeline', {
  connection: redis,
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

// Job types
export interface TopicGenerationJob {
  userId: string;
  topicId: string;
  topicName: string;
  userTier?: string;
}

// Queue event handlers - commented out due to TypeScript issues
// topicPipelineQueue.on('completed', (job: any) => {
//   console.log(`✅ Topic generation completed for job ${job.id}: ${job.data.topicName}`);
// });

// topicPipelineQueue.on('failed', (job: any, err: any) => {
//   console.error(`❌ Topic generation failed for job ${job.id}:`, err.message);
// });

// topicPipelineQueue.on('error', (err: any) => {
//   console.error('❌ Topic pipeline queue error:', err);
// });

export default topicPipelineQueue;
