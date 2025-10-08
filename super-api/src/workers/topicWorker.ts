import { Worker } from 'bullmq';
import { prisma } from '../utils/prisma';
import { TopicGenerationJob } from '../queues/topicPipelineQueue';
import { generateTermsAndFacts } from '../services/termService';

// Redis connection options for Redis 8.x compatibility
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

// Topic generation worker with enhanced pipeline
const topicWorker = new Worker(
  'generate-topic-pipeline',
  async (job) => {
    const { userId, topicId, topicName, userTier } = job.data as TopicGenerationJob;
    
    console.log(`🔄 Processing topic generation for: ${topicName} (Tier: ${userTier || 'free'})`);
    
    try {
      // Use the new term generation pipeline with tier limits
      const result = await generateTermsAndFacts({ userId, topicId, topicName, userTier });
      
      console.log(`✅ Generated ${result.termsGenerated} terms and ${result.factsGenerated} facts for topic: ${topicName}`);
      
      return result;
      
    } catch (error) {
      console.error(`❌ Error processing topic generation for ${topicName}:`, error);
      throw error;
    }
  },
  {
    connection: redisOptions,
    concurrency: 3, // Process up to 3 jobs concurrently (reduced for API rate limits)
  }
);

// Worker event handlers
topicWorker.on('completed', (job) => {
  console.log(`✅ Job ${job.id} completed successfully`);
});

topicWorker.on('failed', (job, err) => {
  console.error(`❌ Job ${job?.id || 'unknown'} failed:`, err.message);
});

topicWorker.on('error', (err) => {
  console.error('❌ Topic worker error:', err);
});

export default topicWorker;
