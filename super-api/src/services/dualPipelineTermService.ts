import { VocabularyParams, validateParams } from '../promptBuilder';
import { runSourceFirstPipeline, SourceFirstResult } from './pipeline/sourceFirst';
import { runOpenAiFirstPipeline, OpenAiFirstResult } from './pipeline/openAiFirst';
import { logContentGeneration, logPipelineEvent } from '../metrics/logEvents';
import { prisma } from '../utils/prisma';

export interface DualPipelineParams extends VocabularyParams {
  userId?: string;
  topicId?: string;
  jobId?: string;
  userTier?: string;
}

export interface DualPipelineResult {
  success: boolean;
  pipeline: 'source-first' | 'openai-first';
  terms: any[];
  facts: string[];
  stats: {
    termsGenerated: number;
    factsGenerated: number;
    duplicatesRemoved: number;
    lowConfidenceTerms: number;
    processingTime: number;
  };
  sourceStats?: any;
  enrichmentStats?: any;
  error?: string;
}

export async function generateTermsAndFactsWithDualPipeline(
  params: DualPipelineParams
): Promise<DualPipelineResult> {
  const startTime = Date.now();
  
  console.log(`🔍 Raw params received:`, {
    topic: params.topic,
    termSelectionLevel: params.termSelectionLevel,
    definitionComplexityLevel: params.definitionComplexityLevel,
    numTerms: params.numTerms
  });
  
  const validatedParams = validateParams(params);
  
  console.log(`🔍 Validated params:`, {
    topic: validatedParams.topic,
    termSelectionLevel: validatedParams.termSelectionLevel,
    definitionComplexityLevel: validatedParams.definitionComplexityLevel,
    numTerms: validatedParams.numTerms
  });
  
  console.log(`🚀 Starting dual-pipeline generation for topic: ${validatedParams.topic}`);
  console.log(`📋 Pipeline: ${validatedParams.openAiFirst ? 'OpenAI-first' : 'Source-first'}`);
  console.log(`📊 Parameters: ${validatedParams.numTerms} terms, ${validatedParams.numFacts} facts`);

  // Log content generation start
  if (params.jobId) {
    await logContentGeneration('started', params.topicId || 'unknown', 'started', {
      userId: params.userId,
      topicName: validatedParams.topic,
      userTier: params.userTier || 'free',
      pipeline: validatedParams.openAiFirst ? 'openai-first' : 'source-first',
      numTerms: validatedParams.numTerms,
      numFacts: validatedParams.numFacts
    });
  }

  try {
    let result: SourceFirstResult | OpenAiFirstResult;
    
    if (validatedParams.openAiFirst) {
      // Run OpenAI-first pipeline
      result = await runOpenAiFirstPipeline(
        validatedParams,
        params.jobId,
        params.userId,
        params.topicId
      );
    } else {
      // Run source-first pipeline
      result = await runSourceFirstPipeline(
        validatedParams,
        params.jobId,
        params.userId,
        params.topicId
      );
    }

    // Convert to database format
    const dbTerms = await convertToDatabaseFormat(result.terms, params.topicId);
    
    // Save to database if topicId is provided
    if (params.topicId && dbTerms.length > 0) {
      await saveTermsToDatabase(dbTerms, params.topicId);
    }

    const processingTime = Date.now() - startTime;
    
    const dualPipelineResult: DualPipelineResult = {
      success: true,
      pipeline: result.pipeline,
      terms: result.terms,
      facts: result.facts,
      stats: {
        termsGenerated: result.terms.length,
        factsGenerated: result.facts.length,
        duplicatesRemoved: result.pipeline === 'source-first' 
          ? result.sourceStats.duplicatesRemoved 
          : result.enrichmentStats.duplicatesRemoved,
        lowConfidenceTerms: result.pipeline === 'source-first'
          ? result.sourceStats.lowConfidenceTerms
          : result.enrichmentStats.lowConfidenceTerms,
        processingTime
      },
      sourceStats: result.pipeline === 'source-first' ? result.sourceStats : undefined,
      enrichmentStats: result.pipeline === 'openai-first' ? result.enrichmentStats : undefined
    };

    // Log successful completion
    if (params.jobId) {
      await logContentGeneration('completed', params.topicId || 'unknown', 'completed', {
        userId: params.userId,
        topicName: validatedParams.topic,
        userTier: params.userTier || 'free',
        pipeline: result.pipeline,
        termsGenerated: result.terms.length,
        factsGenerated: result.facts.length,
        processingTime,
        stats: dualPipelineResult.stats
      });
    }

    console.log(`✅ Dual-pipeline generation completed successfully:`);
    console.log(`   - Pipeline: ${result.pipeline}`);
    console.log(`   - Terms: ${result.terms.length}`);
    console.log(`   - Facts: ${result.facts.length}`);
    console.log(`   - Processing time: ${processingTime}ms`);

    return dualPipelineResult;

  } catch (error) {
    const processingTime = Date.now() - startTime;
    console.error(`❌ Dual-pipeline generation failed:`, error);
    
    // Log failure
    if (params.jobId) {
      await logContentGeneration('failed', params.topicId || 'unknown', 'failed', {
        userId: params.userId,
        topicName: validatedParams.topic,
        userTier: params.userTier || 'free',
        pipeline: validatedParams.openAiFirst ? 'openai-first' : 'source-first',
        error: error instanceof Error ? error.message : 'Unknown error',
        processingTime
      });
    }
    
    return {
      success: false,
      pipeline: validatedParams.openAiFirst ? 'openai-first' : 'source-first',
      terms: [],
      facts: [],
      stats: {
        termsGenerated: 0,
        factsGenerated: 0,
        duplicatesRemoved: 0,
        lowConfidenceTerms: 0,
        processingTime
      },
      error: error instanceof Error ? error.message : 'Unknown error'
    };
  }
}

// Convert validated terms to database format
async function convertToDatabaseFormat(terms: any[], topicId?: string): Promise<any[]> {
  return terms.map(term => ({
    topicId: topicId || null,
    term: term.term,
    definition: term.definition,
    example: term.examples?.[0] || '',
    source: term.source,
    sourceUrl: term.sourceUrl,
    verified: term.verified,
    gptGenerated: term.gptGenerated,
    confidenceScore: term.confidenceScore,
    category: term.category,
    complexityLevel: term.complexityLevel,
    // Add moderation fields
    moderationStatus: 'pending' as const,
    moderationNote: null,
    updatedByAdmin: false,
    updatedAt: new Date()
  }));
}

// Save terms to database
async function saveTermsToDatabase(terms: any[], topicId: string): Promise<void> {
  try {
    // Save terms one by one since Supabase doesn't have createMany with skipDuplicates
    for (const term of terms) {
      try {
        await prisma.term.create({
          ...term,
          topic_id: topicId
        });
      } catch (error: any) {
        // Skip if duplicate (unique constraint on topicId + term)
        if (error.code === '23505') {
          console.log(`⚠️ Skipping duplicate term: ${term.term}`);
          continue;
        }
        throw error;
      }
    }
    console.log(`💾 Saved ${terms.length} terms to database for topic: ${topicId}`);
  } catch (error) {
    console.error(`❌ Error saving terms to database:`, error);
    throw error;
  }
}

// Get user's preferred pipeline setting
export async function getUserPreferredPipeline(userId: string): Promise<boolean> {
  try {
    const user = await prisma.user.getById(userId);
    
    return user?.open_ai_first_preferred || false;
  } catch (error) {
    console.error('Error fetching user pipeline preference:', error);
    return false; // Default to source-first
  }
}

// Set user's preferred pipeline setting
export async function setUserPreferredPipeline(userId: string, openAiFirst: boolean): Promise<void> {
  try {
    await prisma.user.update(userId, {
      open_ai_first_preferred: openAiFirst
    });
    console.log(`✅ Updated user ${userId} pipeline preference to: ${openAiFirst ? 'OpenAI-first' : 'Source-first'}`);
  } catch (error) {
    console.error('Error updating user pipeline preference:', error);
    throw error;
  }
}

// Generate with user's preferred pipeline
export async function generateWithUserPreference(
  params: Omit<DualPipelineParams, 'openAiFirst'>,
  userId: string
): Promise<DualPipelineResult> {
  const userPreference = await getUserPreferredPipeline(userId);
  
  return generateTermsAndFactsWithDualPipeline({
    ...params,
    openAiFirst: userPreference
  });
}

// Quick generation with minimal parameters
export async function quickGenerate(
  topic: string,
  numTerms: number = 20,
  openAiFirst: boolean = false,
  userId?: string,
  topicId?: string,
  termSelectionLevel?: 'beginner' | 'intermediate' | 'advanced',
  definitionComplexityLevel?: 'beginner' | 'intermediate' | 'advanced'
): Promise<DualPipelineResult> {
  const params: DualPipelineParams = {
    topic,
    numTerms,
    openAiFirst,
    userId,
    topicId,
    termSelectionLevel: termSelectionLevel || 'intermediate',
    definitionComplexityLevel: definitionComplexityLevel || 'intermediate',
    jobId: `quick-gen-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
    definitionStyle: 'formal',
    sentenceRange: '2-3',
    numExamples: 2,
    numFacts: 5,
    domainContext: 'general',
    language: 'English',
    useAnalogy: true,
    includeSynonyms: true,
    includeAntonyms: true,
    includeRelatedTerms: true,
    includeEtymology: false,
    highlightRootWords: false
  };

  return generateTermsAndFactsWithDualPipeline(params);
}

