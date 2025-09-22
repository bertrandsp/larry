/**
 * Term mining and ranking system
 * 
 * This module provides advanced term extraction and ranking capabilities using:
 * - C-value algorithm for nested term analysis
 * - Pointwise Mutual Information (PMI) for term association
 * - Pattern-based scoring for definition contexts
 * - Blended scoring for optimal term selection
 */

// Re-export types
export type {
  MinerCandidate,
  CandidateScores,
  RankingConfig,
  MiningResult,
} from '../types/miner';

// Import functions for internal use
import type { MinerCandidate } from '../types/miner';

import { extractCandidates } from './extract';
import { rankCandidates } from './rank';


// Re-export all functionality
export { cValue, pmi, tfidf, normalizePmi } from './stats';
export { rankCandidates, explainScore } from './rank';
export { extractCandidates, analyzePatterns } from './extract';

/**
 * Complete mining pipeline: extract candidates from text and rank them
 * 
 * @param text - Input text to mine for terms
 * @param config - Optional ranking configuration
 * @returns Top-ranked mining results
 */
export async function mineTerms(
  text: string,
  config?: {
    maxCandidates?: number;
    minFreq?: number;
    freqWeight?: number;
    cValueWeight?: number;
    pmiWeight?: number;
    patternWeight?: number;
  }
): Promise<MinerCandidate[]> {
  const startTime = Date.now();
  
  // Extract candidates with pattern scoring
  const candidates = extractCandidates(text);
  
  // Rank using blended algorithm
  const ranked = rankCandidates(candidates, config);
  
  const processingTime = Date.now() - startTime;
  console.log(`Mined ${ranked.length} terms from ${candidates.length} candidates in ${processingTime}ms`);
  
  return ranked;
}
