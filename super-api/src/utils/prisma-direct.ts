import { PrismaClient } from '@prisma/client';

/**
 * Direct Prisma client for workers
 * Uses direct database connection (not pooled) to avoid connection limits
 * 
 * Use this in:
 * - Background workers
 * - Batch jobs
 * - Long-running processes
 * 
 * Do NOT use in API endpoints (use regular prisma client instead)
 */
export const prismaDirect = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DIRECT_URL || process.env.DATABASE_URL
    }
  },
  log: process.env.NODE_ENV === 'development' ? ['error', 'warn'] : ['error'],
});

// Handle graceful shutdown
process.on('beforeExit', async () => {
  await prismaDirect.$disconnect();
});

process.on('SIGINT', async () => {
  await prismaDirect.$disconnect();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await prismaDirect.$disconnect();
  process.exit(0);
});

export default prismaDirect;

