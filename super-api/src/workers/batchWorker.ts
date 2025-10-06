import { Worker } from 'bullmq';
import Redis from 'ioredis';
import { generateNextBatchJob } from '../queues/generateNextBatch.job';

// Redis connection
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

// Create worker for batch generation
const batchWorker = new Worker('generate-next-batch', async (job) => {
  console.log(`🔄 Processing batch generation job for user: ${job.data.userId}`);
  await generateNextBatchJob(job.data);
}, {
  connection: redis,
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
