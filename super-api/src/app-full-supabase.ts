import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Import Supabase versions of API routes
import authRoutes from './api/auth-supabase';
import userRoutes from './api/users-supabase';
import onboardingRoutes from './api/onboarding-supabase';

// Import shared Supabase client to initialize it
import './config/supabase';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4001;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    features: ['supabase-integration', 'full-backend', 'auth', 'users', 'onboarding']
  });
});

// Root endpoint
app.get('/', (_, res) => res.send('Larry Backend Service (Full Supabase) is up 🚀'));

// API routes
app.use('/', authRoutes);
app.use('/', userRoutes);
app.use('/', onboardingRoutes);

// Additional endpoints that will be added later
app.get('/topics', (req, res) => {
  res.status(501).json({
    message: 'Topics endpoint coming soon with Supabase integration'
  });
});

app.get('/terms', (req, res) => {
  res.status(501).json({
    message: 'Terms endpoint coming soon with Supabase integration'
  });
});

app.post('/generate', (req, res) => {
  res.status(501).json({
    message: 'Generate endpoint coming soon with OpenAI + Supabase integration'
  });
});

app.get('/admin', (req, res) => {
  res.status(501).json({
    message: 'Admin endpoints coming soon with Supabase integration'
  });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('❌ Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl,
    method: req.method
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Larry Backend Service (Full Supabase) running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 API base: http://localhost:${PORT}`);
  console.log(`🗄️  Database: Supabase`);
  console.log(`✨ Features: Auth, Users, Onboarding (More coming soon)`);
});

export default app;
