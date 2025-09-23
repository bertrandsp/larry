import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// import userRoutes from './api/users';
// import topicRoutes from './api/topics';
// import termRoutes from './api/terms';
// import adminRoutes from './api/admin';
import generateRoutes from './api/generate';
import onboardingRoutes from './api/onboarding';
import firstDailyRoutes from './api/first-daily';
import wordActionsRoutes from './api/word-actions';

dotenv.config();

const app = express();
const PORT = 4001; // Hardcoded for debugging

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    features: ['queue-integration', 'enhanced-validation', 'bullmq']
  });
});

// Root endpoint
app.get('/', (_, res) => res.send('Larry Backend Service is up 🚀'));

// API routes
// app.use('/', userRoutes);
// app.use('/', topicRoutes);
// app.use('/', termRoutes);
// app.use('/admin', adminRoutes);
app.use('/onboarding', onboardingRoutes);
app.use('/first-daily', firstDailyRoutes);
app.use('/word-actions', wordActionsRoutes);
app.use('/', generateRoutes);

// Real AI endpoints with simplified error handling
import { generateVocabulary } from './services/openAiService';

app.get('/generate/pipelines', (req, res) => {
  res.json({
    success: true,
    pipelines: ['openai-first', 'source-first'],
    default: 'openai-first',
    descriptions: {
      'openai-first': 'Generate content using OpenAI first, then enhance with external sources',
      'source-first': 'Fetch from external sources first, then use OpenAI as fallback'
    }
  });
});

app.post('/generate', async (req, res) => {
  try {
    const { 
      topic, 
      numTerms = 3, 
      definitionStyle = 'formal',
      sentenceRange = '2-3',
      numExamples = 2,
      numFacts = 3,
      termSelectionLevel = 'intermediate',
      definitionComplexityLevel = 'intermediate',
      domainContext = 'general',
      language = 'English',
      useAnalogy = true,
      includeSynonyms = true,
      includeAntonyms = true,
      includeRelatedTerms = true,
      includeEtymology = false,
      highlightRootWords = false
    } = req.body;
    
    if (!topic) {
      return res.status(400).json({
        success: false,
        error: 'Topic is required'
      });
    }

    console.log(`🚀 Generating vocabulary for topic: ${topic} with ${numTerms} terms`);

    // Use the real AI service
    const result = await generateVocabulary({
      topic,
      numTerms,
      definitionStyle,
      sentenceRange,
      numExamples,
      numFacts,
      termSelectionLevel,
      definitionComplexityLevel,
      domainContext,
      language,
      useAnalogy,
      includeSynonyms,
      includeAntonyms,
      includeRelatedTerms,
      includeEtymology,
      highlightRootWords,
      openAiFirst: true
    });

    console.log(`✅ Generated ${result.response.terms.length} terms and ${result.response.facts.length} facts`);

    res.json({
      success: true,
      data: {
        topic,
        pipeline: 'openai-first',
        terms: result.response.terms,
        facts: result.response.facts,
        stats: {
          termsGenerated: result.response.terms.length,
          factsGenerated: result.response.facts.length,
          duplicatesRemoved: 0,
          lowConfidenceTerms: 0,
          processingTime: 1500
        }
      }
    });
  } catch (error) {
    console.error('Generate endpoint error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate vocabulary',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// POST /generate/test - For "Generate More" functionality
app.post('/generate/test', async (req, res) => {
  try {
    const { 
      topic, 
      pipeline = 'openai-first',
      numTerms = 10, 
      definitionStyle = 'formal',
      sentenceRange = '2-3',
      numExamples = 2,
      numFacts = 5,
      termSelectionLevel = 'intermediate',
      definitionComplexityLevel = 'intermediate',
      domainContext = 'general',
      language = 'English',
      useAnalogy = true,
      includeSynonyms = true,
      includeAntonyms = true,
      includeRelatedTerms = true,
      includeEtymology = false,
      highlightRootWords = false
    } = req.body;
    
    if (!topic) {
      return res.status(400).json({
        success: false,
        error: 'Topic is required'
      });
    }

    console.log(`🚀 Generate More: Creating ${numTerms} additional terms for topic: ${topic}`);

    // Use the real AI service
    const result = await generateVocabulary({
      topic,
      numTerms,
      definitionStyle,
      sentenceRange,
      numExamples,
      numFacts,
      termSelectionLevel,
      definitionComplexityLevel,
      domainContext,
      language,
      useAnalogy,
      includeSynonyms,
      includeAntonyms,
      includeRelatedTerms,
      includeEtymology,
      highlightRootWords,
      openAiFirst: pipeline === 'openai-first'
    });

    console.log(`✅ Generate More: Created ${result.response.terms.length} additional terms and ${result.response.facts.length} additional facts`);

    res.json({
      success: true,
      data: {
        topic,
        pipeline,
        terms: result.response.terms,
        facts: result.response.facts,
        stats: {
          termsGenerated: result.response.terms.length,
          factsGenerated: result.response.facts.length,
          duplicatesRemoved: 0,
          lowConfidenceTerms: 0,
          processingTime: 1500
        }
      }
    });
  } catch (error) {
    console.error('Generate More endpoint error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate additional vocabulary',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});


// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Endpoint not found',
    path: req.originalUrl,
    method: req.method
  });
});

// Global error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Global error handler:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Larry Backend Service running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 API base: http://localhost:${PORT}/user`);
});

export default app;
