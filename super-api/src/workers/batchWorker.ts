import { Worker } from 'bullmq';
import { generateNextBatchJob } from '../queues/generateNextBatch.job';

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

// Create worker for batch generation
const batchWorker = new Worker('generate-next-batch', async (job) => {
  console.log(`🔄 Processing batch generation job for user: ${job.data.userId}`);
  await generateNextBatchJob(job.data);
}, {
  connection: redisOptions,
  concurrency: 5, // Process up to 5 batch generation jobs concurrently
});

// Event handlers
batchWorker.on('completed', (job) => {
  console.log(`✅ Batch generation completed for job ${job.id}: user ${job.data.userId}`);
});

batchWorker.on('failed', (job, err) => {
  console.error(`❌ Batch generation failed for job ${job?.id}:`, err.message);
});

batchWorker.on('error', (err) => {
  console.error('❌ Batch worker error:', err);
});

export default batchWorker;
