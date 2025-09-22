/**
 * Advanced ranking system for term candidates using C-value, PMI, and pattern scoring
 */

import type {
  MinerCandidate,
  RankingConfig,
  CandidateScores,
} from '../types/miner';

import { cValue } from './stats';
import { scoreWithRecency, type RecencyMetadata } from '../scoring/recency';

/**
 * Default ranking configuration
 */
const DEFAULT_CONFIG: Required<RankingConfig> = {
  freqWeight: 0.4,
  cValueWeight: 0.3,
  pmiWeight: 0.2,
  patternWeight: 0.1,
  maxCandidates: 200,
  minFreq: 2,
  minNgramLen: 1,
  maxNgramLen: 5,
};

/**
 * Rank candidates using a blended scoring approach
 * Combines frequency, C-value, PMI, pattern-based scores, and recency
 *
 * @param cands - Array of candidate terms to rank
 * @param config - Optional ranking configuration
 * @param metadata - Optional recency metadata for fresh content boost
 * @param topic - Topic for breaking news detection
 * @returns Ranked candidates sorted by final score (highest first)
 */
export function rankCandidates(
  cands: MinerCandidate[],
  config: Partial<RankingConfig> = {},
  metadata?: RecencyMetadata,
  topic?: string
): MinerCandidate[] {
  const cfg = { ...DEFAULT_CONFIG, ...config };

  // Filter candidates by basic criteria
  const filtered = cands.filter(
    (c) =>
      (c.scores.freq || 0) >= cfg.minFreq &&
      c.ngramLen >= cfg.minNgramLen &&
      c.ngramLen <= cfg.maxNgramLen
  );

  // Calculate corpus statistics for normalization
  const corpusStats = calculateCorpusStats(filtered);

  // Score each candidate with recency boost
  const scored = filtered.map((candidate) => {
    const baseScores = calculateBlendedScore(candidate, corpusStats, cfg);
    
    // Apply recency scoring if metadata is available
    let finalScore = baseScores.final || 0;
    let recencyMultiplier = 1.0;
    let isBreaking = false;
    let trendingScore = 0;
    
    if (metadata && topic) {
      const recencyResult = scoreWithRecency(
        finalScore,
        candidate.phrase,
        metadata,
        topic
      );
      
      finalScore = recencyResult.finalScore;
      recencyMultiplier = recencyResult.recencyMultiplier;
      isBreaking = recencyResult.isBreaking;
      trendingScore = recencyResult.trendingScore;
    }
    
    return {
      ...candidate,
      scores: { 
        ...candidate.scores, 
        ...baseScores,
        final: finalScore,
        recencyMultiplier,
        trending: trendingScore,
        breaking: isBreaking,
      },
    };
  });

  // Sort by final score and return top candidates
  return scored
    .sort((a, b) => (b.scores.final || 0) - (a.scores.final || 0))
    .slice(0, cfg.maxCandidates);
}

/**
 * Calculate blended score for a single candidate
 */
function calculateBlendedScore(
  candidate: MinerCandidate,
  corpusStats: CorpusStats,
  config: Required<RankingConfig>
): Partial<CandidateScores> {
  const freq = candidate.scores.freq || 0;

  // Calculate C-value score
  const longerTerms = findLongerTerms(candidate, corpusStats.allCandidates);
  const cval = cValue(
    candidate.phrase,
    freq,
    longerTerms.count,
    longerTerms.freqSum
  );

  // Normalize PMI score (cap at 5 for stability)
  const pmiScore = Math.min(5, candidate.scores.pmi || 0);

  // Pattern score from definition contexts
  const pattern = candidate.scores.pattern || 0;

  // Calculate final blended score
  const finalScore =
    config.freqWeight * normalizeFreq(freq, corpusStats.maxFreq) +
    config.cValueWeight * normalizeCValue(cval, corpusStats.maxCValue) +
    config.pmiWeight * (pmiScore / 5) + // PMI already capped at 5
    config.patternWeight * pattern;

  return {
    cValue: cval,
    final: finalScore,
  };
}

/**
 * Calculate corpus-wide statistics for normalization
 */
interface CorpusStats {
  maxFreq: number;
  maxCValue: number;
  totalTerms: number;
  allCandidates: MinerCandidate[];
}

function calculateCorpusStats(candidates: MinerCandidate[]): CorpusStats {
  const maxFreq = Math.max(...candidates.map((c) => c.scores.freq || 0));

  // Calculate C-values for normalization
  const cValues = candidates.map((c) => {
    const freq = c.scores.freq || 0;
    const longerTerms = findLongerTerms(c, candidates);
    return cValue(c.phrase, freq, longerTerms.count, longerTerms.freqSum);
  });

  const maxCValue = Math.max(...cValues);

  return {
    maxFreq,
    maxCValue,
    totalTerms: candidates.length,
    allCandidates: candidates,
  };
}

/**
 * Find longer terms that contain the given candidate
 */
function findLongerTerms(
  candidate: MinerCandidate,
  allCandidates: MinerCandidate[]
): { count: number; freqSum: number } {
  const longerTerms = allCandidates.filter(
    (other) =>
      other.ngramLen > candidate.ngramLen &&
      other.phrase.includes(candidate.phrase)
  );

  return {
    count: longerTerms.length,
    freqSum: longerTerms.reduce((sum, term) => sum + (term.scores.freq || 0), 0),
  };
}

/**
 * Normalize frequency score to 0-1 range
 */
function normalizeFreq(freq: number, maxFreq: number): number {
  if (maxFreq <= 0) return 0;
  return Math.sqrt(freq / maxFreq); // Square root to reduce dominance of high-frequency terms
}

/**
 * Normalize C-value score to 0-1 range
 */
function normalizeCValue(cval: number, maxCValue: number): number {
  if (maxCValue <= 0) return 0;
  return Math.max(0, cval / maxCValue);
}

/**
 * Debug function to explain scoring for a candidate
 */
export function explainScore(
  candidate: MinerCandidate,
  config: Partial<RankingConfig> = {}
): string {
  const cfg = { ...DEFAULT_CONFIG, ...config };
  const scores = candidate.scores;

  return `
Scoring for: "${candidate.phrase}"
- Frequency: ${scores.freq} (weight: ${cfg.freqWeight})
- C-value: ${scores.cValue?.toFixed(3)} (weight: ${cfg.cValueWeight})
- PMI: ${scores.pmi?.toFixed(3)} (weight: ${cfg.pmiWeight})
- Pattern: ${scores.pattern} (weight: ${cfg.patternWeight})
- Final Score: ${scores.final?.toFixed(4)}
  `.trim();
}
