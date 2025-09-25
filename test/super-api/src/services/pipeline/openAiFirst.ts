import { VocabularyParams, VocabularyResponse } from '../../promptBuilder';
import { generateVocabulary } from '../openAiService';
import { fetchSingleFromExternalSources } from '../externalSources';
import { validateTerms, postProcessValidation, validateOpenAiResponse, ValidatedTerm } from '../validationService';
import { logPipelineEvent, logContentGeneration } from '../../metrics/logEvents';

export interface OpenAiFirstResult {
  terms: ValidatedTerm[];
  facts: string[];
  pipeline: 'openai-first';
  enrichmentStats: {
    openAiTermsGenerated: number;
    termsEnriched: number;
    enrichmentSuccessRate: number;
    totalTermsGenerated: number;
    duplicatesRemoved: number;
    lowConfidenceTerms: number;
  };
}

export async function runOpenAiFirstPipeline(
  params: VocabularyParams,
  jobId?: string,
  userId?: string,
  topicId?: string
): Promise<OpenAiFirstResult> {
  const startTime = Date.now();
  
  try {
    // Log pipeline start
    if (jobId) {
      await logPipelineEvent('openai_first_started', topicId, 'success', {
        jobId,
        topic: params.topic,
        numTerms: params.numTerms,
        userId,
        topicId
      });
    }

    // Step 1: Generate terms using OpenAI first
    console.log(`🤖 Generating terms with OpenAI for topic: ${params.topic}`);
    const openAiResult = await generateVocabulary(params, jobId);
    const validatedOpenAiResponse = validateOpenAiResponse(openAiResult.response);
    
    if (!validatedOpenAiResponse) {
      throw new Error('Invalid response from OpenAI');
    }

    console.log(`✅ Generated ${validatedOpenAiResponse.terms.length} terms with OpenAI`);

    // Step 2: Convert OpenAI terms to ValidatedTerm format
    const openAiTerms: ValidatedTerm[] = validatedOpenAiResponse.terms.map(term => ({
      term: term.term,
      definition: term.definition,
      examples: term.examples,
      source: 'AI Generated',
      verified: false,
      gptGenerated: true,
      confidenceScore: 0.6, // Base confidence for AI-generated terms
      category: 'general',
      complexityLevel: 'beginner' as const,
      tags: [params.topic.toLowerCase(), 'ai-generated'],
      synonyms: term.synonyms,
      antonyms: term.antonyms,
      relatedTerms: term.relatedTerms,
      etymology: term.etymology,
      analogy: term.analogy
    }));

    // Step 3: Enrich terms with external sources
    console.log(`🔍 Enriching terms with external sources...`);
    const enrichedTerms = await enrichWithExternalSources(openAiTerms, params.topic);
    
    // Step 4: Validate and post-process
    const validationResult = validateTerms(enrichedTerms, params.topic, false, params.definitionComplexityLevel, params.termSelectionLevel);
    const finalResult = postProcessValidation(validationResult, 0.3, params.numTerms);

    // Calculate enrichment statistics
    const termsEnriched = enrichedTerms.filter(term => 
      term.source !== 'AI Generated' && term.confidenceScore > 0.6
    ).length;
    
    const enrichmentSuccessRate = openAiTerms.length > 0 
      ? (termsEnriched / openAiTerms.length) * 100 
      : 0;

    const result: OpenAiFirstResult = {
      terms: finalResult.terms,
      facts: validatedOpenAiResponse.facts.slice(0, params.numFacts),
      pipeline: 'openai-first',
      enrichmentStats: {
        openAiTermsGenerated: openAiTerms.length,
        termsEnriched,
        enrichmentSuccessRate,
        totalTermsGenerated: finalResult.terms.length,
        duplicatesRemoved: finalResult.duplicatesRemoved,
        lowConfidenceTerms: finalResult.lowConfidenceTerms
      }
    };

    // Log pipeline completion
    if (jobId) {
      await logPipelineEvent('openai_first_completed', topicId, 'success', {
        jobId,
        topic: params.topic,
        termsGenerated: result.terms.length,
        factsGenerated: result.facts.length,
        openAiTermsGenerated: result.enrichmentStats.openAiTermsGenerated,
        termsEnriched: result.enrichmentStats.termsEnriched,
        enrichmentSuccessRate: result.enrichmentStats.enrichmentSuccessRate,
        duration: Date.now() - startTime,
        userId,
        topicId
      });
    }

    console.log(`✅ OpenAI-first pipeline completed: ${result.terms.length} terms, ${result.facts.length} facts`);
    console.log(`📊 Enrichment stats: ${termsEnriched}/${openAiTerms.length} terms enriched (${enrichmentSuccessRate.toFixed(1)}%)`);
    
    return result;

  } catch (error) {
    console.error('OpenAI-first pipeline failed:', error);
    
    // Log pipeline failure
    if (jobId) {
      await logPipelineEvent('openai_first_failed', topicId, 'failure', {
        jobId,
        topic: params.topic,
        error: error instanceof Error ? error.message : 'Unknown error',
        duration: Date.now() - startTime,
        userId,
        topicId
      });
    }
    
    throw error;
  }
}

// Enrich OpenAI-generated terms with external sources
async function enrichWithExternalSources(
  openAiTerms: ValidatedTerm[],
  topic: string
): Promise<ValidatedTerm[]> {
  const enrichedTerms: ValidatedTerm[] = [];
  
  // Process terms in batches to avoid rate limits
  const batchSize = 5;
  const batches = [];
  
  for (let i = 0; i < openAiTerms.length; i += batchSize) {
    batches.push(openAiTerms.slice(i, i + batchSize));
  }
  
  for (const batch of batches) {
    const batchPromises = batch.map(async (term) => {
      try {
        // Try to get external definition for this term
        const externalTerm = await fetchSingleFromExternalSources(term.term);
        
        if (externalTerm) {
          // Only enrich if external source is high quality and from reputable source
          const isHighQualitySource = externalTerm.source === 'Merriam-Webster' || 
                                     (externalTerm.source === 'Wiktionary' && externalTerm.confidence > 0.8);
          
          if (isHighQualitySource) {
            // Merge external data with OpenAI data, but prioritize OpenAI definition
            return {
              ...term,
              definition: term.definition, // Keep OpenAI definition as primary
              examples: externalTerm.examples.length > 0 ? externalTerm.examples : term.examples,
              source: `${externalTerm.source} (Enhanced)`, // Mark as enhanced
              sourceUrl: externalTerm.sourceUrl,
              verified: true,
              gptGenerated: false,
              confidenceScore: Math.max(term.confidenceScore, externalTerm.confidence),
              etymology: externalTerm.etymology || term.etymology,
              synonyms: externalTerm.synonyms || term.synonyms,
              tags: [...term.tags, externalTerm.source.toLowerCase().replace(' ', '-')]
            };
          } else {
            // External source is low quality, keep OpenAI term but add source info
            return {
              ...term,
              source: `${term.source} (External verified)`,
              verified: true,
              tags: [...term.tags, 'external-verified']
            };
          }
        } else {
          // Keep original OpenAI term if no external source found
          return term;
        }
      } catch (error) {
        console.error(`Error enriching term ${term.term}:`, error);
        return term; // Return original term on error
      }
    });
    
    const batchResults = await Promise.all(batchPromises);
    enrichedTerms.push(...batchResults);
    
    // Add small delay between batches to respect rate limits
    if (batches.indexOf(batch) < batches.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
  
  return enrichedTerms;
}

// Helper function to prioritize external sources over AI-generated content
function prioritizeExternalSources(terms: ValidatedTerm[]): ValidatedTerm[] {
  return terms.sort((a, b) => {
    // Prioritize verified terms from external sources
    if (a.verified && !b.verified) return -1;
    if (!a.verified && b.verified) return 1;
    
    // Then sort by confidence score
    return b.confidenceScore - a.confidenceScore;
  });
}

// Helper function to merge similar terms from different sources
function mergeSimilarTerms(terms: ValidatedTerm[]): ValidatedTerm[] {
  const merged: ValidatedTerm[] = [];
  const seen = new Set<string>();
  
  for (const term of terms) {
    const normalized = term.term.toLowerCase().trim();
    
    if (!seen.has(normalized)) {
      seen.add(normalized);
      merged.push(term);
    } else {
      // Find existing term and merge if this one is better
      const existingIndex = merged.findIndex(t => t.term.toLowerCase().trim() === normalized);
      if (existingIndex !== -1) {
        const existing = merged[existingIndex];
        if (term.confidenceScore > existing.confidenceScore || 
            (term.verified && !existing.verified)) {
          merged[existingIndex] = term;
        }
      }
    }
  }
  
  return merged;
}

