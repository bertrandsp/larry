import { VocabularyParams, VocabularyResponse } from '../../promptBuilder';
import { fetchFromExternalSources, ExternalTerm } from '../externalSources';
import { generateVocabulary } from '../openAiService';
import { validateTerms, postProcessValidation, validateOpenAiResponse, ValidatedTerm } from '../validationService';
import { logPipelineEvent, logContentGeneration } from '../../metrics/logEvents';

export interface SourceFirstResult {
  terms: ValidatedTerm[];
  facts: string[];
  pipeline: 'source-first';
  sourceStats: {
    externalTermsFound: number;
    openAiFallbackUsed: boolean;
    totalTermsGenerated: number;
    duplicatesRemoved: number;
    lowConfidenceTerms: number;
  };
}

export async function runSourceFirstPipeline(
  params: VocabularyParams,
  jobId?: string,
  userId?: string,
  topicId?: string
): Promise<SourceFirstResult> {
  const startTime = Date.now();
  
  try {
    // Log pipeline start
    if (jobId) {
      await logPipelineEvent('source_first_started', topicId || '', 'success', {
        jobId,
        topic: params.topic,
        numTerms: params.numTerms,
        userId
      });
    }

    // Step 1: Fetch from external sources first
    console.log(`🔍 Fetching terms from external sources for topic: ${params.topic}`);
    const externalResult = await fetchFromExternalSources(params.topic, params.numTerms);
    
    let validatedTerms: ValidatedTerm[] = [];
    let facts: string[] = [];
    let openAiFallbackUsed = false;

    if (externalResult.terms.length > 0) {
      console.log(`✅ Found ${externalResult.terms.length} terms from external sources`);
      
      // Step 2: Validate external terms
      const validationResult = validateTerms(externalResult.terms, params.topic, false, params.definitionComplexityLevel, params.termSelectionLevel);
      validatedTerms = postProcessValidation(validationResult, 0.3, params.numTerms).terms;
      
      // Step 3: If we don't have enough terms, use OpenAI to fill the gap
      if (validatedTerms.length < params.numTerms * 0.7) { // If less than 70% of requested terms
        console.log(`⚠️ Only found ${validatedTerms.length} terms, using OpenAI to fill the gap`);
        openAiFallbackUsed = true;
        
        const remainingTerms = params.numTerms - validatedTerms.length;
        const fallbackParams = {
          ...params,
          numTerms: remainingTerms
        };
        
        const openAiResult = await generateVocabulary(fallbackParams, jobId);
        const validatedOpenAiResponse = validateOpenAiResponse(openAiResult.response);
        
        if (validatedOpenAiResponse) {
          const openAiValidation = validateTerms(
            validatedOpenAiResponse.terms.map(term => ({
              term: term.term,
              definition: term.definition,
              examples: term.examples,
              source: 'AI Generated',
              confidence: 0.6
            })),
            params.topic,
            true,
            params.definitionComplexityLevel,
            params.termSelectionLevel
          );
          
          const openAiTerms = postProcessValidation(openAiValidation, 0.3, remainingTerms).terms;
          validatedTerms = [...validatedTerms, ...openAiTerms];
          facts = [...facts, ...validatedOpenAiResponse.facts];
        }
      }
    } else {
      // Step 4: No external terms found, fallback to OpenAI entirely
      console.log(`❌ No external terms found, falling back to OpenAI entirely`);
      openAiFallbackUsed = true;
      
      const openAiResult = await generateVocabulary(params, jobId);
      const validatedOpenAiResponse = validateOpenAiResponse(openAiResult.response);
      
      if (validatedOpenAiResponse) {
        const openAiValidation = validateTerms(
          validatedOpenAiResponse.terms.map(term => ({
            term: term.term,
            definition: term.definition,
            examples: term.examples,
            source: 'AI Generated',
            confidence: 0.6
          })),
          params.topic,
          true,
          params.definitionComplexityLevel,
          params.termSelectionLevel
        );
        
        validatedTerms = postProcessValidation(openAiValidation, 0.3, params.numTerms).terms;
        facts = validatedOpenAiResponse.facts;
      }
    }

    // Step 5: Final validation and deduplication
    const finalValidation = validateTerms(validatedTerms, params.topic, false, params.definitionComplexityLevel, params.termSelectionLevel);
    const finalResult = postProcessValidation(finalValidation, 0.3, params.numTerms);

    const result: SourceFirstResult = {
      terms: finalResult.terms,
      facts: facts.slice(0, params.numFacts),
      pipeline: 'source-first',
      sourceStats: {
        externalTermsFound: externalResult.terms.length,
        openAiFallbackUsed,
        totalTermsGenerated: finalResult.terms.length,
        duplicatesRemoved: finalResult.duplicatesRemoved,
        lowConfidenceTerms: finalResult.lowConfidenceTerms
      }
    };

    // Log pipeline completion
    if (jobId) {
      await logPipelineEvent('source_first_completed', topicId || '', 'success', {
        jobId,
        topic: params.topic,
        termsGenerated: result.terms.length,
        factsGenerated: result.facts.length,
        externalTermsFound: result.sourceStats.externalTermsFound,
        openAiFallbackUsed: result.sourceStats.openAiFallbackUsed,
        duration: Date.now() - startTime,
        userId
      });
    }

    console.log(`✅ Source-first pipeline completed: ${result.terms.length} terms, ${result.facts.length} facts`);
    return result;

  } catch (error) {
    console.error('Source-first pipeline failed:', error);
    
    // Log pipeline failure
    if (jobId) {
      await logPipelineEvent('source_first_failed', topicId || '', 'failure', {
        jobId,
        topic: params.topic,
        error: error instanceof Error ? error.message : 'Unknown error',
        duration: Date.now() - startTime,
        userId
      });
    }
    
    throw error;
  }
}

// Helper function to tag terms with metadata
function tagTerms(terms: ValidatedTerm[], metadata: { gptGenerated: boolean }): ValidatedTerm[] {
  return terms.map(term => ({
    ...term,
    gptGenerated: metadata.gptGenerated,
    verified: !metadata.gptGenerated && term.confidenceScore > 0.7
  }));
}

// Helper function to check if we have enough quality terms
function hasEnoughQualityTerms(terms: ValidatedTerm[], minCount: number, minConfidence: number = 0.5): boolean {
  const qualityTerms = terms.filter(term => term.confidenceScore >= minConfidence);
  return qualityTerms.length >= minCount;
}

// Helper function to merge terms from different sources
function mergeTerms(externalTerms: ValidatedTerm[], openAiTerms: ValidatedTerm[]): ValidatedTerm[] {
  const allTerms = [...externalTerms, ...openAiTerms];
  
  // Remove duplicates based on normalized term names
  const seen = new Set<string>();
  const uniqueTerms: ValidatedTerm[] = [];
  
  for (const term of allTerms) {
    const normalized = term.term.toLowerCase().trim();
    if (!seen.has(normalized)) {
      seen.add(normalized);
      uniqueTerms.push(term);
    }
  }
  
  // Sort by confidence score (highest first)
  return uniqueTerms.sort((a, b) => b.confidenceScore - a.confidenceScore);
}

