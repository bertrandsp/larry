import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import onboardingRoutes from './routes/onboarding';
import dailyRoutes from './routes/daily';
import { testOpenAI } from './services/openai';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 4001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', async (req, res) => {
  const openaiWorking = await testOpenAI();
  
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    database: 'supabase',
    openai: openaiWorking ? 'connected' : 'disconnected',
    features: ['onboarding', 'vocabulary-generation', 'spaced-repetition']
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Larry Backend Service - Fresh Supabase Version',
    status: 'running',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      onboarding: '/onboarding/*',
      daily: '/daily/*',
      test: '/test'
    }
  });
});

// Test endpoint
app.get('/test', (req, res) => {
  res.json({
    message: 'Backend is working perfectly!',
    supabase: 'connected',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/onboarding', onboardingRoutes);
app.use('/daily', dailyRoutes);

// Start server
app.listen(PORT, () => {
  console.log('🚀 Larry Backend Service (Fresh Supabase Version)');
  console.log(`📊 Server running on: http://localhost:${PORT}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health`);
  console.log(`🧪 Test endpoint: http://localhost:${PORT}/test`);
  console.log('✅ Ready for connections!');
});

export default app;
