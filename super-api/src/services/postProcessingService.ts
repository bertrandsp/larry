import { 
  normalizeTerm, 
  deduplicateTermsWithConfidence, 
  deduplicateFactsWithConfidence 
} from '../utils/cleanAndDedupe';

export interface Term {
  term: string;
  definition: string;
  example?: string;
  source?: string;
  sourceUrl?: string;
  gptGenerated?: boolean;
  confidenceScore?: number;
  complexityLevel?: string;
  category?: string;
  topicId?: string;
}

export interface PostProcessedTerm extends Term {
  term: string;
  definition: string;
  example: string;
  source: string;
  sourceUrl?: string;
  verified: boolean;
  gptGenerated: boolean;
  confidenceScore: number;
  category: string;
  complexityLevel: string;
  topicId: string;
}

export interface PostProcessingResult {
  terms: PostProcessedTerm[];
  stats: {
    originalCount: number;
    normalizedCount: number;
    deduplicatedCount: number;
    enrichedCount: number;
    duplicatesRemoved: number;
    confidenceImproved: number;
  };
}

/**
 * Complete post-processing pipeline for vocabulary terms
 * Normalizes, deduplicates, and enriches terms with metadata
 */
export async function postProcessTerms(
  rawTerms: Term[], 
  topicName: string
): Promise<PostProcessingResult> {
  console.log(`🔄 Starting post-processing for ${rawTerms.length} terms`);
  
  try {
    // Step 1: Normalize terms
    const normalized = rawTerms.map(term => ({
      ...term,
      term: normalizeTerm(term.term),
    }));
    
    console.log(`📝 Normalized ${normalized.length} terms`);
    
    // Step 2: Deduplicate with confidence scoring
    const deduped = deduplicateTermsWithConfidence(normalized);
    const duplicatesRemoved = normalized.length - deduped.length;
    
    console.log(`🧹 Deduplicated: ${deduped.length} terms (removed ${duplicatesRemoved} duplicates)`);
    
    // Step 3: Enrich with metadata
    const enriched = await Promise.all(deduped.map(async term => ({
      term: term.term,
      definition: term.definition,
      example: term.example || '',
      source: term.source || 'AI Generated',
      sourceUrl: term.sourceUrl,
      confidenceScore: assignConfidence(term),
      complexityLevel: estimateComplexity(term.definition),
      category: await categorizeTerm(term.term, term.definition, topicName),
      gptGenerated: !term.sourceUrl,
      verified: Boolean(term.sourceUrl),
      topicId: term.topicId || '',
    })));
    
    console.log(`✨ Enriched ${enriched.length} terms with metadata`);
    
    // Step 4: Calculate improvement statistics
    const confidenceImproved = enriched.filter(term => 
      term.confidenceScore > (term.confidenceScore || 0)
    ).length;
    
    const result: PostProcessingResult = {
      terms: enriched,
      stats: {
        originalCount: rawTerms.length,
        normalizedCount: normalized.length,
        deduplicatedCount: deduped.length,
        enrichedCount: enriched.length,
        duplicatesRemoved: duplicatesRemoved,
        confidenceImproved: confidenceImproved,
      }
    };
    
    console.log(`✅ Post-processing complete:`, result.stats);
    return result;
    
  } catch (error) {
    console.error(`❌ Error in post-processing pipeline:`, error);
    throw error;
  }
}

/**
 * Assign confidence score based on source and validation
 */
function assignConfidence(term: Term): number {
  // +0.9 if definition sourced from known APIs (MW, Wikipedia)
  if (term.sourceUrl) {
    if (term.sourceUrl.includes('wikipedia.org')) return 0.9;
    if (term.sourceUrl.includes('merriam-webster.com')) return 0.95;
    if (term.sourceUrl.includes('wiktionary.org')) return 0.9;
    return 0.85; // Other verified sources
  }
  
  // 0.6–0.8 if GPT generated but validated by fallback logic
  if (term.gptGenerated) {
    if (term.example && term.example.length > 10) return 0.75;
    return 0.6;
  }
  
  // <0.5 if no source and GPT fallback
  return 0.4;
}

/**
 * Estimate complexity level using advanced heuristics
 */
function estimateComplexity(definition: string): 'beginner' | 'intermediate' | 'advanced' {
  const words = definition.split(' ').filter(word => word.length > 0);
  const wordCount = words.length;
  
  // Calculate average word length
  const totalLength = words.reduce((sum, word) => sum + word.length, 0);
  const avgWordLength = wordCount > 0 ? totalLength / wordCount : 0;
  
  // Check for complex vocabulary patterns
  const complexPatterns = [
    /algorithm|methodology|framework|paradigm|infrastructure/i,
    /quantum|neural|synthetic|molecular|theoretical/i,
    /optimization|implementation|deployment|orchestration/i
  ];
  
  const hasComplexPatterns = complexPatterns.some(pattern => pattern.test(definition));
  
  // Advanced heuristics
  if (wordCount > 25 || avgWordLength > 8 || hasComplexPatterns) return 'advanced';
  if (wordCount > 15 || avgWordLength > 6) return 'intermediate';
  return 'beginner';
}

/**
 * Categorize term using keyword heuristics and topic context
 */
async function categorizeTerm(
  term: string, 
  definition: string, 
  topicName: string
): Promise<string> {
  const termLower = term.toLowerCase();
  const definitionLower = definition.toLowerCase();
  const topicLower = topicName.toLowerCase();
  
  // Technical categories
  if (termLower.includes('algorithm') || definitionLower.includes('algorithm')) return 'algorithm';
  if (termLower.includes('method') || definitionLower.includes('method')) return 'method';
  if (termLower.includes('technique') || definitionLower.includes('technique')) return 'technique';
  if (termLower.includes('approach') || definitionLower.includes('approach')) return 'approach';
  if (termLower.includes('framework') || definitionLower.includes('framework')) return 'framework';
  if (termLower.includes('model') || definitionLower.includes('model')) return 'model';
  if (termLower.includes('theory') || definitionLower.includes('theory')) return 'theory';
  if (termLower.includes('concept') || definitionLower.includes('concept')) return 'concept';
  
  // Tool and software categories
  if (termLower.includes('tool') || definitionLower.includes('software')) return 'tool';
  if (termLower.includes('platform') || definitionLower.includes('platform')) return 'platform';
  if (termLower.includes('system') || definitionLower.includes('system')) return 'system';
  if (termLower.includes('api') || definitionLower.includes('api')) return 'api';
  
  // Business and strategy categories
  if (termLower.includes('strategy') || definitionLower.includes('strategy')) return 'strategy';
  if (termLower.includes('process') || definitionLower.includes('process')) return 'process';
  if (termLower.includes('workflow') || definitionLower.includes('workflow')) return 'workflow';
  if (termLower.includes('methodology') || definitionLower.includes('methodology')) return 'methodology';
  
  // Language and communication categories
  if (termLower.includes('slang') || definitionLower.includes('slang')) return 'slang';
  if (termLower.includes('jargon') || definitionLower.includes('jargon')) return 'jargon';
  if (termLower.includes('terminology') || definitionLower.includes('terminology')) return 'terminology';
  
  // Topic-specific categorization
  if (topicLower.includes('technology') || topicLower.includes('tech')) {
    if (termLower.includes('ai') || termLower.includes('machine learning')) return 'ai-ml';
    if (termLower.includes('blockchain') || termLower.includes('crypto')) return 'blockchain';
    if (termLower.includes('cloud') || termLower.includes('saas')) return 'cloud-computing';
  }
  
  if (topicLower.includes('business') || topicLower.includes('management')) {
    if (termLower.includes('leadership') || termLower.includes('management')) return 'leadership';
    if (termLower.includes('strategy') || termLower.includes('planning')) return 'strategy';
    if (termLower.includes('operations') || termLower.includes('process')) return 'operations';
  }
  
  if (topicLower.includes('science') || topicLower.includes('research')) {
    if (termLower.includes('experiment') || termLower.includes('research')) return 'research';
    if (termLower.includes('hypothesis') || termLower.includes('theory')) return 'theory';
    if (termLower.includes('analysis') || termLower.includes('data')) return 'analysis';
  }
  
  // Default category based on word characteristics
  if (term.split(' ').length > 2) return 'multi-word-concept';
  if (term.length > 12) return 'long-term';
  
  return 'general';
}

/**
 * Post-process facts with similar logic
 */
export async function postProcessFacts(
  rawFacts: Array<{ fact: string; source?: string; sourceUrl?: string }>,
  topicName: string
): Promise<Array<{ fact: string; source: string; sourceUrl?: string; gptGenerated: boolean; category: string }>> {
  try {
    // Normalize facts
    const normalized = rawFacts.map(fact => ({
      ...fact,
      fact: normalizeTerm(fact.fact),
    }));
    
    // Deduplicate facts
    const deduped = deduplicateFactsWithConfidence(normalized);
    
    // Enrich with metadata
    const enriched = deduped.map(fact => ({
      fact: fact.fact,
      source: fact.source || 'AI Generated',
      sourceUrl: fact.sourceUrl,
      gptGenerated: !fact.sourceUrl,
      category: categorizeFact(fact.fact, topicName),
    }));
    
    return enriched;
    
  } catch (error) {
    console.error(`❌ Error in fact post-processing:`, error);
    throw error;
  }
}

/**
 * Categorize facts based on content
 */
function categorizeFact(fact: string, topicName: string): string {
  const factLower = fact.toLowerCase();
  const topicLower = topicName.toLowerCase();
  
  if (factLower.includes('history') || factLower.includes('founded')) return 'history';
  if (factLower.includes('statistics') || factLower.includes('data')) return 'statistics';
  if (factLower.includes('example') || factLower.includes('case study')) return 'example';
  if (factLower.includes('benefit') || factLower.includes('advantage')) return 'benefit';
  if (factLower.includes('challenge') || factLower.includes('problem')) return 'challenge';
  
  // Topic-specific categorization
  if (topicLower.includes('technology')) return 'tech-fact';
  if (topicLower.includes('business')) return 'business-fact';
  if (topicLower.includes('science')) return 'science-fact';
  
  return 'general';
}
