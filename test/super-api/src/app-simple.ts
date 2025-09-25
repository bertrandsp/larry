import * as express from 'express';
import * as cors from 'cors';
import * as dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4001;

// Middleware
app.use(cors());
app.use(express.json());

// Simple health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    features: ['basic-health-check']
  });
});

// Simple test endpoint
app.get('/test', (req, res) => {
  res.json({
    message: 'Backend is working!',
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Simple Larry Backend running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🧪 Test endpoint: http://localhost:${PORT}/test`);
});
