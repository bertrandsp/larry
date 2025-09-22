/**
 * Text extraction and pattern detection for term mining
 */

import type { MinerCandidate } from '../types/miner';

/**
 * Extract candidates from text with pattern-based scoring
 *
 * @param text - Input text to process
 * @param options - Extraction options
 * @returns Array of candidate terms with initial scoring
 */
export function extractCandidates(
  text: string,
  options: ExtractOptions = {}
): MinerCandidate[] {
  const opts = { ...DEFAULT_OPTIONS, ...options };

  // Split into sentences for pattern analysis
  const sentences = splitIntoSentences(text);

  // Extract n-grams and analyze patterns
  const candidateMap = new Map<string, MinerCandidate>();

  sentences.forEach((sentence) => {
    const ngrams = extractNgrams(sentence, opts.maxNgramLen);

    ngrams.forEach((ngram) => {
      const phrase = ngram.tokens.join(' ');
      const existing = candidateMap.get(phrase);

      if (existing) {
        // Update frequency and add context
        existing.scores.freq = (existing.scores.freq || 0) + 1;
        existing.contexts?.push(sentence);
        existing.positions?.push({
          start: ngram.start,
          end: ngram.end,
          sentence,
        });
      } else {
        // Create new candidate
        const candidate: MinerCandidate = {
          phrase,
          ngramLen: ngram.tokens.length,
          scores: {
            freq: 1,
            pattern: analyzePatterns(sentence, phrase),
          },
          contexts: [sentence],
          positions: [
            {
              start: ngram.start,
              end: ngram.end,
              sentence,
            },
          ],
        };

        candidateMap.set(phrase, candidate);
      }
    });
  });

  return Array.from(candidateMap.values());
}

/**
 * Analyze definition patterns in a sentence containing the target phrase
 *
 * @param sentence - The sentence to analyze
 * @param phrase - The target phrase to score
 * @returns Pattern score (0-1)
 */
export function analyzePatterns(sentence: string, phrase: string): number {
  const normalized = sentence.toLowerCase();
  const phraseNorm = phrase.toLowerCase();

  let score = 0;

  // Pattern 1: "X is/are/was/were [definition]"
  const isPattern = new RegExp(
    `\\b${escapeRegex(phraseNorm)}\\s+(?:is|are|was|were)\\s+(?:a|an|the|[^.!?]+)`,
    'i'
  );
  if (isPattern.test(normalized)) {
    score += 0.5;
  }

  // Pattern 2: "X, [definition]," (apposition)
  const appositionPattern = new RegExp(
    `\\b${escapeRegex(phraseNorm)},\\s*(?:a|an|the)?\\s*[^,]+,`,
    'i'
  );
  if (appositionPattern.test(normalized)) {
    score += 0.4;
  }

  // Pattern 3: "[definition] called/known as X"
  const calledPattern = new RegExp(
    `[^.!?]+(?:called|known as|termed|referred to as)\\s+${escapeRegex(
      phraseNorm
    )}`,
    'i'
  );
  if (calledPattern.test(normalized)) {
    score += 0.4;
  }

  // Pattern 4: "X (definition)" or "X - definition"
  const parentheticalPattern = new RegExp(
    `\\b${escapeRegex(phraseNorm)}\\s*[\\(\\-]\\s*[^\\)\\-]{5,}[\\)\\-]?`,
    'i'
  );
  if (parentheticalPattern.test(normalized)) {
    score += 0.3;
  }

  // Pattern 5: Definition indicators
  const definitionWords = [
    'define',
    'definition',
    'means',
    'refers to',
    'describes',
    'denotes',
    'indicates',
  ];
  for (const defWord of definitionWords) {
    if (normalized.includes(defWord) && normalized.includes(phraseNorm)) {
      score += 0.2;
      break;
    }
  }

  // Pattern 6: Technical/academic contexts
  const technicalIndicators = [
    'algorithm',
    'method',
    'technique',
    'approach',
    'framework',
    'model',
    'theory',
    'concept',
  ];
  for (const indicator of technicalIndicators) {
    if (normalized.includes(indicator)) {
      score += 0.1;
      break;
    }
  }

  // Cap the score at 1.0
  return Math.min(1.0, score);
}

/**
 * Split text into sentences using basic rules
 */
function splitIntoSentences(text: string): string[] {
  return text
    .split(/[.!?]+/)
    .map((s) => s.trim())
    .filter((s) => s.length > 10); // Filter out very short fragments
}

/**
 * Extract n-grams from a sentence
 */
interface Ngram {
  tokens: string[];
  start: number;
  end: number;
}

function extractNgrams(sentence: string, maxLen: number): Ngram[] {
  const tokens = tokenize(sentence);
  const ngrams: Ngram[] = [];

  for (let len = 1; len <= Math.min(maxLen, tokens.length); len++) {
    for (let i = 0; i <= tokens.length - len; i++) {
      const ngramTokens = tokens.slice(i, i + len);

      // Filter out n-grams with too many stop words or punctuation
      if (isValidNgram(ngramTokens)) {
        ngrams.push({
          tokens: ngramTokens,
          start: i,
          end: i + len - 1,
        });
      }
    }
  }

  return ngrams;
}

/**
 * Simple tokenization (split on whitespace and basic punctuation)
 */
function tokenize(text: string): string[] {
  return text
    .toLowerCase()
    .replace(/[^\w\s]/g, ' ') // Replace punctuation with spaces
    .split(/\s+/)
    .filter((token) => token.length > 0);
}

/**
 * Check if an n-gram is valid for term extraction
 */
function isValidNgram(tokens: string[]): boolean {
  // Reject n-grams that are mostly stop words
  const stopWords = new Set([
    'the',
    'a',
    'an',
    'and',
    'or',
    'but',
    'in',
    'on',
    'at',
    'to',
    'for',
    'of',
    'with',
    'by',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'have',
    'has',
    'had',
    'will',
    'would',
    'could',
    'should',
    'this',
    'that',
    'these',
    'those',
  ]);

  // For 3+ word phrases, be more strict about stop words
  if (tokens.length >= 3) {
    const stopWordCount = tokens.filter((token) => stopWords.has(token)).length;
    return stopWordCount <= 1; // Allow at most 1 stop word in longer phrases
  }

  const nonStopWords = tokens.filter((token) => !stopWords.has(token));
  return nonStopWords.length >= Math.ceil(tokens.length / 2);
}

/**
 * Escape special regex characters
 */
function escapeRegex(string: string): string {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/**
 * Options for candidate extraction
 */
interface ExtractOptions {
  maxNgramLen?: number;
  minFreq?: number;
  includePositions?: boolean;
}

const DEFAULT_OPTIONS: Required<ExtractOptions> = {
  maxNgramLen: 5,
  minFreq: 1,
  includePositions: true,
};
