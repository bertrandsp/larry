import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { generateTermsAndFactsWithDualPipeline, quickGenerate, getUserPreferredPipeline, DualPipelineParams } from '../services/dualPipelineTermService';
import { VocabularyParams, getDefaultParams, validateParams } from '../promptBuilder';
import { logMetric } from '../metrics/logEvents';

const router = Router();

// Request validation schema
const GenerateRequestSchema = z.object({
  topic: z.string().min(1).max(100),
  openAiFirst: z.boolean().optional(),
  numTerms: z.number().min(1).max(100).optional(),
  definitionStyle: z.enum(['casual', 'formal', 'technical', 'academic']).optional(),
  sentenceRange: z.string().optional(),
  numExamples: z.number().min(1).max(5).optional(),
  numFacts: z.number().min(1).max(20).optional(),
  termSelectionLevel: z.enum(['beginner', 'intermediate', 'advanced']).optional(),
  definitionComplexityLevel: z.enum(['beginner', 'intermediate', 'advanced']).optional(),
  domainContext: z.string().optional(),
  language: z.string().optional(),
  useAnalogy: z.boolean().optional(),
  includeSynonyms: z.boolean().optional(),
  includeAntonyms: z.boolean().optional(),
  includeRelatedTerms: z.boolean().optional(),
  includeEtymology: z.boolean().optional(),
  highlightRootWords: z.boolean().optional(),
  userId: z.string().uuid().optional(),
  topicId: z.string().uuid().optional(),
  userTier: z.enum(['free', 'premium', 'pro']).optional()
});

// Quick generation schema (minimal parameters)
const QuickGenerateSchema = z.object({
  topic: z.string().min(1).max(100),
  numTerms: z.number().min(1).max(50).optional(),
  openAiFirst: z.boolean().optional(),
  userId: z.string().uuid().optional(),
  topicId: z.string().uuid().optional()
});

// POST /generate - Full parameter generation
router.post('/generate', async (req: Request, res: Response) => {
  try {
    // Validate request body
    const validatedBody = GenerateRequestSchema.parse(req.body);
    
    // Generate job ID
    const jobId = `gen-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    // Use user's preferred pipeline if not specified
    let openAiFirst = validatedBody.openAiFirst;
    if (openAiFirst === undefined && validatedBody.userId) {
      openAiFirst = await getUserPreferredPipeline(validatedBody.userId);
    }
    
    // Build parameters with defaults
    const params: DualPipelineParams = {
      ...validatedBody,
      openAiFirst: openAiFirst || false,
      jobId,
      numTerms: validatedBody.numTerms || 20,
      numExamples: validatedBody.numExamples || 2,
      numFacts: validatedBody.numFacts || 5,
      definitionStyle: validatedBody.definitionStyle || 'formal' as const,
      sentenceRange: validatedBody.sentenceRange || '2-3',
      domainContext: validatedBody.domainContext || 'general',
      language: validatedBody.language || 'English',
      useAnalogy: validatedBody.useAnalogy ?? true,
      includeSynonyms: validatedBody.includeSynonyms ?? true,
      includeAntonyms: validatedBody.includeAntonyms ?? true,
      includeRelatedTerms: validatedBody.includeRelatedTerms ?? true,
      includeEtymology: validatedBody.includeEtymology ?? false,
      highlightRootWords: validatedBody.highlightRootWords ?? false,
      termSelectionLevel: validatedBody.termSelectionLevel || 'intermediate' as const,
      definitionComplexityLevel: validatedBody.definitionComplexityLevel || 'intermediate' as const
    };
    
    console.log(`🚀 Starting generation request:`, {
      topic: params.topic,
      pipeline: params.openAiFirst ? 'OpenAI-first' : 'Source-first',
      numTerms: params.numTerms,
      userId: params.userId
    });
    
    // Generate terms and facts
    const result = await generateTermsAndFactsWithDualPipeline(params);
    
    // Log successful generation
    if (params.userId) {
      await logMetric({
        type: 'content_generation',
        topicId: params.topicId,
        message: `Generated ${result.stats.termsGenerated} terms for topic: ${params.topic}`,
        metadata: {
          userId: params.userId,
          topic: params.topic,
          pipeline: result.pipeline,
          termsGenerated: result.stats.termsGenerated,
          factsGenerated: result.stats.factsGenerated,
          processingTime: result.stats.processingTime,
          success: result.success
        }
      });
    }
    
    // Return response
    res.json({
      success: result.success,
      data: {
        topic: params.topic,
        pipeline: result.pipeline,
        terms: result.terms,
        facts: result.facts,
        stats: result.stats,
        sourceStats: result.sourceStats,
        enrichmentStats: result.enrichmentStats
      },
      jobId,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Generation endpoint error:', error);
    
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request parameters',
        details: error.issues
      });
    }
    
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// POST /generate/quick - Quick generation with minimal parameters
router.post('/generate/quick', async (req: Request, res: Response) => {
  try {
    // Validate request body
    const validatedBody = QuickGenerateSchema.parse(req.body);
    
    console.log(`⚡ Quick generation request:`, {
      topic: validatedBody.topic,
      numTerms: validatedBody.numTerms || 20,
      openAiFirst: validatedBody.openAiFirst || false
    });
    
    // Generate terms and facts
    const result = await quickGenerate(
      validatedBody.topic,
      validatedBody.numTerms || 20,
      validatedBody.openAiFirst || false,
      validatedBody.userId,
      validatedBody.topicId
    );
    
    // Log successful generation
    if (validatedBody.userId) {
      await logMetric({
        type: 'content_generation',
        topicId: validatedBody.topicId,
        message: `Quick generated ${result.stats.termsGenerated} terms for topic: ${validatedBody.topic}`,
        metadata: {
          userId: validatedBody.userId,
          topic: validatedBody.topic,
          pipeline: result.pipeline,
          termsGenerated: result.stats.termsGenerated,
          factsGenerated: result.stats.factsGenerated,
          processingTime: result.stats.processingTime,
          success: result.success,
          quickGeneration: true
        }
      });
    }
    
    // Return response
    res.json({
      success: result.success,
      data: {
        topic: validatedBody.topic,
        pipeline: result.pipeline,
        terms: result.terms,
        facts: result.facts,
        stats: result.stats
      },
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Quick generation endpoint error:', error);
    
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request parameters',
        details: error.issues
      });
    }
    
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /generate/defaults - Get default parameters for a topic
router.get('/generate/defaults', (req: Request, res: Response) => {
  try {
    const topic = req.query.topic as string || 'general';
    const defaults = getDefaultParams(topic);
    
    res.json({
      success: true,
      data: {
        topic,
        defaults
      }
    });
  } catch (error) {
    console.error('Defaults endpoint error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /generate/pipelines - Get available pipelines and their descriptions
router.get('/generate/pipelines', (req: Request, res: Response) => {
  res.json({
    success: true,
    data: {
      pipelines: [
        {
          id: 'source-first',
          name: 'Source-First Pipeline',
          description: 'Fetches terms from external sources (Wikipedia, Merriam-Webster, etc.) first, then uses OpenAI as fallback',
          advantages: [
            'Higher accuracy from verified sources',
            'Lower cost (fewer OpenAI API calls)',
            'More reliable definitions',
            'Better for established topics'
          ],
          disadvantages: [
            'May miss newer or niche terms',
            'Slower for topics with limited external sources',
            'Less creative or contextual definitions'
          ],
          bestFor: ['Established topics', 'Academic subjects', 'Technical terms', 'Cost-conscious usage']
        },
        {
          id: 'openai-first',
          name: 'OpenAI-First Pipeline',
          description: 'Generates terms with OpenAI first, then enriches with external sources for verification',
          advantages: [
            'More creative and contextual definitions',
            'Better for niche or new topics',
            'Consistent style and format',
            'Faster initial generation'
          ],
          disadvantages: [
            'Higher cost (more OpenAI API calls)',
            'May include less accurate information',
            'Requires external source enrichment for verification'
          ],
          bestFor: ['Niche topics', 'Creative subjects', 'New or emerging concepts', 'Style consistency']
        }
      ]
    }
  });
});

// POST /generate/test - Test endpoint for development
router.post('/generate/test', async (req: Request, res: Response) => {
  try {
    const { topic, pipeline, termSelectionLevel, definitionComplexityLevel, numTerms } = req.body;
    
    if (!topic) {
      return res.status(400).json({
        success: false,
        error: 'Topic is required'
      });
    }
    
    console.log(`🧪 Test generation: ${topic} (${pipeline || 'default'}) - Term Level: ${termSelectionLevel || 'intermediate'}, Def Level: ${definitionComplexityLevel || 'intermediate'}`);
    
    const result = await quickGenerate(
      topic,
      numTerms || 5, // Small number for testing
      pipeline === 'openai-first',
      undefined,
      undefined,
      termSelectionLevel,
      definitionComplexityLevel
    );
    
    // Filter terms based on selection level as a fallback
    let filteredTerms = result.terms;
    if (termSelectionLevel === 'beginner') {
      // Topic-agnostic advanced indicators that should be filtered out for beginner level
      const advancedIndicators = [
        // Technical/scientific terms
        'algorithm', 'methodology', 'implementation', 'optimization', 'configuration', 'parameter', 'variable',
        'synthesis', 'analysis', 'hypothesis', 'theory', 'paradigm', 'framework', 'architecture', 'infrastructure',
        'quantum', 'nuclear', 'molecular', 'atomic', 'genetic', 'biochemical', 'neurochemical', 'pharmacological',
        'thermodynamic', 'electromagnetic', 'electrochemical', 'photochemical', 'catalytic', 'enzymatic',
        
        // Professional/abstract terms
        'executive', 'director', 'manager', 'supervisor', 'coordinator', 'specialist', 'expert', 'consultant',
        'analyst', 'engineer', 'architect', 'developer', 'designer', 'researcher', 'scientist', 'professor',
        'philosophy', 'metaphysics', 'epistemology', 'ontology', 'phenomenology', 'hermeneutics', 'dialectics',
        
        // Foreign language terms (common ones)
        'savoir', 'faire', 'avoir', 'être', 'c\'est', 'très', 'beaucoup', 'comment', 'pourquoi', 'parce que',
        'bonjour', 'merci', 'au revoir', 'excusez', 'pardon', 's\'il vous plaît', 'de rien', 'bienvenue',
        
        // Advanced cooking terms (only if topic is cooking-related)
        ...(topic.toLowerCase().includes('cook') || topic.toLowerCase().includes('food') || topic.toLowerCase().includes('chef') || topic.toLowerCase().includes('kitchen') ? 
          ['sauté', 'saut', 'julienne', 'al dente', 'confit', 'brunoise', 'mirepoix', 'gastrique', 'braise', 'emulsify', 'caramelize', 'sous vide'] : [])
      ];
      
      filteredTerms = result.terms.filter(term => 
        !advancedIndicators.some(indicator => 
          term.term.toLowerCase().includes(indicator.toLowerCase())
        )
      );
      console.log(`🔍 Filtered ${result.terms.length - filteredTerms.length} inappropriate terms for beginner level`);
    }

    res.json({
      success: true,
      data: {
        topic,
        pipeline: result.pipeline,
        terms: filteredTerms.slice(0, 3), // Return only first 3 terms for testing
        facts: result.facts.slice(0, 2), // Return only first 2 facts for testing
        stats: result.stats
      },
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Test generation endpoint error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;


