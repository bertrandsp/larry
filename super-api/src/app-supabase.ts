import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import authRoutes from './api/auth-supabase';
import userRoutes from './api/users-supabase';
import onboardingRoutes from './api/onboarding-supabase';
import onboardingStepsRoutes from './api/onboarding-steps-supabase';
import firstDailyRoutes from './api/first-daily-supabase';
import userDashboardRoutes from './api/user-dashboard';
import analyticsRoutes from './api/analytics';
import topicsRoutes from './api/topics-supabase';

dotenv.config();

const app = express();
const PORT = 4001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    features: ['supabase-integration', 'auth-only']
  });
});

// Routes
app.use('/user', userRoutes);
app.use('/', authRoutes);
app.use('/', onboardingRoutes);
app.use('/', onboardingStepsRoutes);
app.use('/', firstDailyRoutes);
app.use('/', userDashboardRoutes);
app.use('/', analyticsRoutes);
app.use('/', topicsRoutes);

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Larry Backend Service running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 API base: http://localhost:${PORT}/user`);
  console.log(`🍎 Supabase integration active`);
});

export default app;
