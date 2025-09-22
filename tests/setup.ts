/**
 * Test setup file for acceptance tests
 */

import { beforeAll, afterAll } from 'vitest';

beforeAll(async () => {
  // Global test setup
  console.log('🧪 Setting up acceptance test environment...');
  
  // Set test environment variables
  process.env.NODE_ENV = 'test';
  process.env.ADMIN_SIGNING_KEY = 'test_admin_key_12345';
  
  // Wait for any services to be ready
  await new Promise(resolve => setTimeout(resolve, 2000));
});

afterAll(async () => {
  // Global test cleanup
  console.log('🧹 Cleaning up acceptance test environment...');
  
  // Any global cleanup goes here
});
