import { ValidatedTerm } from './validationService';
import { fetchSingleFromExternalSources, ExternalTerm } from './externalSources';
import { rateLimiter } from './externalSources';

export interface EnrichmentResult {
  enrichedTerms: ValidatedTerm[];
  enrichmentStats: {
    totalTerms: number;
    successfullyEnriched: number;
    enrichmentRate: number;
    sourcesUsed: string[];
    averageConfidenceImprovement: number;
  };
}

export async function enrichWithExternalSources(
  terms: ValidatedTerm[],
  topic: string,
  maxConcurrent: number = 3
): Promise<EnrichmentResult> {
  const startTime = Date.now();
  const enrichedTerms: ValidatedTerm[] = [];
  const sourcesUsed = new Set<string>();
  let successfullyEnriched = 0;
  let totalConfidenceImprovement = 0;

  console.log(`🔍 Starting enrichment of ${terms.length} terms for topic: ${topic}`);

  // Process terms in batches to respect rate limits
  const batchSize = maxConcurrent;
  const batches = [];
  
  for (let i = 0; i < terms.length; i += batchSize) {
    batches.push(terms.slice(i, i + batchSize));
  }

  for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
    const batch = batches[batchIndex];
    console.log(`📦 Processing batch ${batchIndex + 1}/${batches.length} (${batch.length} terms)`);

    // Process batch concurrently
    const batchPromises = batch.map(async (term) => {
      return await enrichSingleTerm(term, topic);
    });

    const batchResults = await Promise.all(batchPromises);
    
    for (const result of batchResults) {
      enrichedTerms.push(result.enrichedTerm);
      
      if (result.wasEnriched) {
        successfullyEnriched++;
        sourcesUsed.add(result.source);
        totalConfidenceImprovement += result.confidenceImprovement;
      }
    }

    // Add delay between batches to respect rate limits
    if (batchIndex < batches.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }

  const enrichmentRate = terms.length > 0 ? (successfullyEnriched / terms.length) * 100 : 0;
  const averageConfidenceImprovement = successfullyEnriched > 0 
    ? totalConfidenceImprovement / successfullyEnriched 
    : 0;

  const result: EnrichmentResult = {
    enrichedTerms,
    enrichmentStats: {
      totalTerms: terms.length,
      successfullyEnriched,
      enrichmentRate,
      sourcesUsed: Array.from(sourcesUsed),
      averageConfidenceImprovement
    }
  };

  const duration = Date.now() - startTime;
  console.log(`✅ Enrichment completed in ${duration}ms:`);
  console.log(`   - ${successfullyEnriched}/${terms.length} terms enriched (${enrichmentRate.toFixed(1)}%)`);
  console.log(`   - Sources used: ${result.enrichmentStats.sourcesUsed.join(', ')}`);
  console.log(`   - Average confidence improvement: ${averageConfidenceImprovement.toFixed(2)}`);

  return result;
}

interface SingleTermEnrichmentResult {
  enrichedTerm: ValidatedTerm;
  wasEnriched: boolean;
  source: string;
  confidenceImprovement: number;
}

async function enrichSingleTerm(
  term: ValidatedTerm,
  topic: string
): Promise<SingleTermEnrichmentResult> {
  const originalConfidence = term.confidenceScore;
  
  try {
    // Check rate limits before making request
    if (!rateLimiter.canMakeRequest('external-sources', 10, 60000)) { // 10 requests per minute
      console.warn(`Rate limit reached for term: ${term.term}`);
      return {
        enrichedTerm: term,
        wasEnriched: false,
        source: 'rate-limited',
        confidenceImprovement: 0
      };
    }

    // Try to get external definition
    const externalTerm = await fetchSingleFromExternalSources(term.term);
    
    if (externalTerm && shouldUseExternalTerm(term, externalTerm)) {
      const enrichedTerm = mergeTermData(term, externalTerm);
      const confidenceImprovement = enrichedTerm.confidenceScore - originalConfidence;
      
      return {
        enrichedTerm,
        wasEnriched: true,
        source: externalTerm.source,
        confidenceImprovement
      };
    } else {
      return {
        enrichedTerm: term,
        wasEnriched: false,
        source: 'no-external-data',
        confidenceImprovement: 0
      };
    }
  } catch (error) {
    console.error(`Error enriching term ${term.term}:`, error);
    return {
      enrichedTerm: term,
      wasEnriched: false,
      source: 'error',
      confidenceImprovement: 0
    };
  }
}

function shouldUseExternalTerm(originalTerm: ValidatedTerm, externalTerm: ExternalTerm): boolean {
  // Don't use external term if it's significantly worse
  if (externalTerm.confidence < originalTerm.confidenceScore - 0.2) {
    return false;
  }

  // Don't use external term if it's from a low-quality source and original is already good
  if (originalTerm.confidenceScore > 0.8 && externalTerm.source === 'Urban Dictionary') {
    return false;
  }

  // Use external term if it's from a high-quality source
  if (['Merriam-Webster', 'Wikipedia', 'Wiktionary'].includes(externalTerm.source)) {
    return true;
  }

  // Use external term if it has better content
  if (externalTerm.definition && externalTerm.definition.length > originalTerm.definition.length) {
    return true;
  }

  return false;
}

function mergeTermData(originalTerm: ValidatedTerm, externalTerm: ExternalTerm): ValidatedTerm {
  // Determine which definition to use
  const useExternalDefinition = shouldUseExternalDefinition(originalTerm, externalTerm);
  
  // Determine which examples to use
  const useExternalExamples = shouldUseExternalExamples(originalTerm, externalTerm);

  return {
    ...originalTerm,
    definition: useExternalDefinition ? externalTerm.definition : originalTerm.definition,
    examples: useExternalExamples ? externalTerm.examples : originalTerm.examples,
    source: externalTerm.source,
    sourceUrl: externalTerm.sourceUrl,
    verified: true,
    gptGenerated: false,
    confidenceScore: Math.max(originalTerm.confidenceScore, externalTerm.confidence),
    etymology: externalTerm.etymology || originalTerm.etymology,
    synonyms: externalTerm.synonyms || originalTerm.synonyms,
    tags: [...originalTerm.tags, externalTerm.source.toLowerCase().replace(' ', '-')]
  };
}

function shouldUseExternalDefinition(originalTerm: ValidatedTerm, externalTerm: ExternalTerm): boolean {
  // Use external definition if it's from a high-quality source
  if (['Merriam-Webster', 'Wikipedia'].includes(externalTerm.source)) {
    return true;
  }

  // Use external definition if it's significantly longer and more detailed
  if (externalTerm.definition.length > originalTerm.definition.length * 1.5) {
    return true;
  }

  // Use external definition if original is AI-generated and external is from a dictionary
  if (originalTerm.gptGenerated && externalTerm.source === 'Wiktionary') {
    return true;
  }

  return false;
}

function shouldUseExternalExamples(originalTerm: ValidatedTerm, externalTerm: ExternalTerm): boolean {
  // Use external examples if they exist and original doesn't have good examples
  if (externalTerm.examples.length > 0 && originalTerm.examples.length === 0) {
    return true;
  }

  // Use external examples if they're from a high-quality source
  if (['Merriam-Webster', 'Wikipedia'].includes(externalTerm.source)) {
    return true;
  }

  // Use external examples if they're more diverse
  if (externalTerm.examples.length > originalTerm.examples.length) {
    return true;
  }

  return false;
}

// Batch enrichment for better performance
export async function enrichTermsInBatches(
  terms: ValidatedTerm[],
  topic: string,
  batchSize: number = 5,
  delayBetweenBatches: number = 2000
): Promise<EnrichmentResult> {
  const enrichedTerms: ValidatedTerm[] = [];
  const sourcesUsed = new Set<string>();
  let successfullyEnriched = 0;
  let totalConfidenceImprovement = 0;

  const batches = [];
  for (let i = 0; i < terms.length; i += batchSize) {
    batches.push(terms.slice(i, i + batchSize));
  }

  for (let i = 0; i < batches.length; i++) {
    const batch = batches[i];
    console.log(`Processing batch ${i + 1}/${batches.length}`);

    const batchResults = await enrichWithExternalSources(batch, topic, batchSize);
    enrichedTerms.push(...batchResults.enrichedTerms);
    successfullyEnriched += batchResults.enrichmentStats.successfullyEnriched;
    batchResults.enrichmentStats.sourcesUsed.forEach(source => sourcesUsed.add(source));
    totalConfidenceImprovement += batchResults.enrichmentStats.averageConfidenceImprovement * batchResults.enrichmentStats.successfullyEnriched;

    // Delay between batches
    if (i < batches.length - 1) {
      await new Promise(resolve => setTimeout(resolve, delayBetweenBatches));
    }
  }

  const enrichmentRate = terms.length > 0 ? (successfullyEnriched / terms.length) * 100 : 0;
  const averageConfidenceImprovement = successfullyEnriched > 0 
    ? totalConfidenceImprovement / successfullyEnriched 
    : 0;

  return {
    enrichedTerms,
    enrichmentStats: {
      totalTerms: terms.length,
      successfullyEnriched,
      enrichmentRate,
      sourcesUsed: Array.from(sourcesUsed),
      averageConfidenceImprovement
    }
  };
}

