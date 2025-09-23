import 'dotenv/config';
import topicWorker from './topicWorker';

console.log('🚀 Starting Larry Backend Workers...');

// Check environment variables
if (!process.env.OPENAI_API_KEY) {
  console.error('❌ OPENAI_API_KEY environment variable is missing!');
  process.exit(1);
}

if (!process.env.DATABASE_URL) {
  console.error('❌ DATABASE_URL environment variable is missing!');
  process.exit(1);
}

// Initialize all workers with error handling
const workers = [topicWorker];

// Add error handling for uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  // Don't exit, let the worker handle it
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  // Don't exit, let the worker handle it
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Shutting down workers...');
  try {
    await Promise.all(workers.map(worker => worker.close()));
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
});

process.on('SIGINT', async () => {
  console.log('🛑 Shutting down workers...');
  try {
    await Promise.all(workers.map(worker => worker.close()));
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
});

console.log('✅ All workers started successfully');


