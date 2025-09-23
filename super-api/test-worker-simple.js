const Redis = require('ioredis');
const { Worker } = require('bullmq');

console.log('🧪 Testing simple worker setup...');

// Test Redis connection
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6380', {
  maxRetriesPerRequest: null
});

redis.on('connect', () => {
  console.log('✅ Redis connected successfully');
});

redis.on('error', (err) => {
  console.error('❌ Redis connection error:', err);
});

// Test simple worker
const testWorker = new Worker(
  'test-queue',
  async (job) => {
    console.log('🔄 Processing test job:', job.data);
    return { success: true, message: 'Test job processed' };
  },
  {
    connection: redis,
    concurrency: 1,
  }
);

testWorker.on('completed', (job) => {
  console.log('✅ Test job completed:', job.id);
});

testWorker.on('failed', (job, err) => {
  console.error('❌ Test job failed:', job?.id, err.message);
});

testWorker.on('error', (err) => {
  console.error('❌ Test worker error:', err);
});

console.log('🚀 Simple test worker started');

// Keep the process alive
setTimeout(() => {
  console.log('⏰ Test completed, shutting down...');
  process.exit(0);
}, 10000);
