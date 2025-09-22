import { PrismaClient } from '@prisma/client';
import { interestsRouter } from '../src/routes/interests';
import request from 'supertest';
import express from 'express';

const prisma = new PrismaClient();

// Create a test Express app
const app = express();
app.use(express.json());
app.use('/', interestsRouter);

const TEST_USER_ID = 'test-user-interests-simple';

describe('Interests API', () => {
  beforeAll(async () => {
    // Create test user to avoid foreign key constraint issues
    await prisma.user.upsert({
      where: { id: TEST_USER_ID },
      update: {},
      create: {
        id: TEST_USER_ID,
        email: 'test-interests@example.com',
        name: 'Test User Interests'
      }
    });

    // Clean up any existing test data
    await prisma.userInterest.deleteMany({
      where: { userId: TEST_USER_ID }
    });
  });

  afterAll(async () => {
    // Clean up test data
    await prisma.userInterest.deleteMany({
      where: { userId: TEST_USER_ID }
    });
    await prisma.user.deleteMany({
      where: { id: TEST_USER_ID }
    });
    await prisma.$disconnect();
  });

  describe('GET /interests', () => {
    it('should return a list of preset interests', async () => {
      const response = await request(app)
        .get('/interests')
        .expect(200);

      expect(response.body).toHaveProperty('items');
      expect(Array.isArray(response.body.items)).toBe(true);
      expect(response.body.items.length).toBeGreaterThan(0);

      // Check structure of returned items
      const firstItem = response.body.items[0];
      expect(firstItem).toHaveProperty('id');
      expect(firstItem).toHaveProperty('slug');
      expect(firstItem).toHaveProperty('name');
      expect(firstItem).toHaveProperty('locale');
      expect(firstItem.locale).toBe('en');
    });

    it('should return up to 20 interests', async () => {
      const response = await request(app)
        .get('/interests')
        .expect(200);

      expect(response.body.items.length).toBeLessThanOrEqual(20);
    });

    it('should return interests sorted alphabetically', async () => {
      const response = await request(app)
        .get('/interests')
        .expect(200);

      const names = response.body.items.map((item: any) => item.name);
      const sortedNames = [...names].sort();
      expect(names).toEqual(sortedNames);
    });
  });

  describe('POST /user/interests', () => {
    it('should create custom interests and distribute scores evenly', async () => {
      const response = await request(app)
        .post('/user/interests')
        .set('x-user-id', TEST_USER_ID)
        .send({
          presetIds: [],
          customNames: ['Test Interest 1', 'Test Interest 2']
        })
        .expect(200);

      expect(response.body).toHaveProperty('userInterests');
      expect(response.body).toHaveProperty('totalScore');
      expect(response.body.totalScore).toBe(100);
      expect(response.body.userInterests).toHaveLength(2);

      // Check that scores are distributed evenly (50/50 for 2 items)
      const scores = response.body.userInterests.map((ui: any) => ui.overlapScore).sort();
      expect(scores).toEqual([50, 50]);
    });

    it('should handle preset interests correctly', async () => {
      // First get available interests
      const interestsResponse = await request(app)
        .get('/interests')
        .expect(200);

      const firstInterest = interestsResponse.body.items[0];

      const response = await request(app)
        .post('/user/interests')
        .set('x-user-id', TEST_USER_ID)
        .send({
          presetIds: [firstInterest.id],
          customNames: []
        })
        .expect(200);

      expect(response.body.totalScore).toBe(100);
      expect(response.body.userInterests).toHaveLength(1);
      expect(response.body.userInterests[0].interestId).toBe(firstInterest.id);
      expect(response.body.userInterests[0].overlapScore).toBe(100);
    });

    it('should deduplicate custom interests case-insensitively', async () => {
      const response = await request(app)
        .post('/user/interests')
        .set('x-user-id', TEST_USER_ID)
        .send({
          presetIds: [],
          customNames: ['React Native', 'react native', 'REACT NATIVE']
        })
        .expect(200);

      expect(response.body.userInterests).toHaveLength(1);
      expect(response.body.totalScore).toBe(100);
    });

    it('should return 400 for empty selection', async () => {
      const response = await request(app)
        .post('/user/interests')
        .set('x-user-id', TEST_USER_ID)
        .send({
          presetIds: [],
          customNames: []
        })
        .expect(400);

      expect(response.body.error).toBe('At least one interest is required.');
    });

    it('should return 401 for unauthorized requests', async () => {
      const response = await request(app)
        .post('/user/interests')
        .send({
          presetIds: [],
          customNames: ['Test']
        })
        .expect(401);

      expect(response.body.error).toBe('unauthorized');
    });

    it('should validate input with Zod', async () => {
      const response = await request(app)
        .post('/user/interests')
        .set('x-user-id', TEST_USER_ID)
        .send({
          presetIds: 'invalid', // Should be array
          customNames: 123 // Should be array
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toHaveProperty('fieldErrors');
    });
  });
});
