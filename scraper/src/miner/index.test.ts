import { describe, it, expect } from 'vitest';

import type { MinerCandidate } from '../types/miner';

import { cValue, pmi, tfidf } from './stats';
import { rankCandidates, explainScore } from './rank';
import { extractCandidates, analyzePatterns } from './extract';

describe('Mining Stats Functions', () => {
  describe('cValue', () => {
    it('should calculate C-value correctly for simple cases', () => {
      // Single word, no longer terms
      expect(cValue('data', 5, 0, 0)).toBe(0); // log2(1) * (5 - 0) = 0

      // Two-word phrase, no longer terms
      expect(cValue('data mining', 3, 0, 0)).toBe(3); // log2(2) * (3 - 0) = 1 * 3 = 3

      // Two-word phrase with longer containing terms
      expect(cValue('data mining', 5, 2, 6)).toBe(2); // log2(2) * (5 - 6/2) = 1 * (5 - 3) = 2
    });

    it('should favor longer terms', () => {
      const short = cValue('data', 5, 0, 0);
      const long = cValue('data mining algorithm', 5, 0, 0);
      expect(long).toBeGreaterThan(short);
    });
  });

  describe('pmi', () => {
    it('should calculate PMI correctly', () => {
      // Perfect association
      const perfectPmi = pmi(10, 10, 10, 100);
      expect(perfectPmi).toBeGreaterThan(0);

      // No association
      const zeroPmi = pmi(1, 10, 10, 100);
      expect(zeroPmi).toBeLessThan(perfectPmi);
    });

    it('should handle edge cases with small epsilon', () => {
      expect(() => pmi(0, 0, 0, 100)).not.toThrow();
    });
  });

  describe('tfidf', () => {
    it('should calculate TF-IDF correctly', () => {
      const score = tfidf(5, 2, 100);
      expect(score).toBeGreaterThan(0);

      // More frequent term should have higher TF component
      const moreFrequent = tfidf(10, 2, 100);
      expect(moreFrequent).toBeGreaterThan(score);
    });
  });
});

describe('Pattern Analysis', () => {
  it('should detect "is/are" patterns', () => {
    const score1 = analyzePatterns(
      'Machine learning is a subset of artificial intelligence.',
      'machine learning'
    );
    expect(score1).toBeGreaterThan(0.4);

    const score2 = analyzePatterns(
      'Neural networks are computational models inspired by biological neurons.',
      'neural networks'
    );
    expect(score2).toBeGreaterThan(0.4);
  });

  it('should detect apposition patterns', () => {
    const score = analyzePatterns(
      'Python, a high-level programming language, is widely used.',
      'python'
    );
    expect(score).toBeGreaterThan(0.3);
  });

  it('should detect "called/known as" patterns', () => {
    const score = analyzePatterns(
      'This technique is commonly called reinforcement learning.',
      'reinforcement learning'
    );
    expect(score).toBeGreaterThan(0.3);
  });

  it('should return low scores for non-definition contexts', () => {
    const score = analyzePatterns(
      'The cat sat on the mat yesterday.',
      'cat'
    );
    expect(score).toBeLessThan(0.2);
  });
});

describe('Candidate Extraction', () => {
  it('should extract candidates from text', () => {
    const text = `
      Machine learning is a subset of artificial intelligence that focuses on algorithms.
      Deep learning, a specialized form of machine learning, uses neural networks.
      These algorithms can learn patterns from data automatically.
    `;

    const candidates = extractCandidates(text);

    expect(candidates.length).toBeGreaterThan(0);
    
    // Should find "machine learning"
    const mlCandidate = candidates.find(c => c.phrase === 'machine learning');
    expect(mlCandidate).toBeDefined();
    expect(mlCandidate?.scores.freq).toBeGreaterThan(1); // Appears twice
    expect(mlCandidate?.scores.pattern).toBeGreaterThan(0); // Has definition pattern
  });

  it('should filter out invalid n-grams', () => {
    const text = 'The quick brown fox jumps over the lazy dog.';
    const candidates = extractCandidates(text);

    // Should not include n-grams that are all stop words
    const allStopWords = candidates.find(c => c.phrase === 'the of and');
    expect(allStopWords).toBeUndefined();
    
    // Should include n-grams with meaningful content
    const meaningfulNgram = candidates.find(c => c.phrase === 'quick brown fox');
    expect(meaningfulNgram).toBeDefined();
  });
});

describe('Ranking System', () => {
  it('should rank candidates by blended score', () => {
    const candidates: MinerCandidate[] = [
      {
        phrase: 'machine learning',
        ngramLen: 2,
        scores: { freq: 5, pmi: 3.2, pattern: 0.8 },
      },
      {
        phrase: 'algorithm',
        ngramLen: 1,
        scores: { freq: 10, pmi: 1.5, pattern: 0.1 },
      },
      {
        phrase: 'deep learning framework',
        ngramLen: 3,
        scores: { freq: 3, pmi: 4.1, pattern: 0.6 },
      },
    ];

    const ranked = rankCandidates(candidates);

    expect(ranked).toHaveLength(3);
    expect(ranked[0].scores.final).toBeDefined();
    expect(ranked[0].scores.final! >= ranked[1].scores.final!).toBe(true);
    expect(ranked[1].scores.final! >= ranked[2].scores.final!).toBe(true);
  });

  it('should respect minimum frequency filter', () => {
    const candidates: MinerCandidate[] = [
      {
        phrase: 'rare term',
        ngramLen: 2,
        scores: { freq: 1, pmi: 5.0, pattern: 1.0 },
      },
      {
        phrase: 'common term',
        ngramLen: 2,
        scores: { freq: 5, pmi: 2.0, pattern: 0.5 },
      },
    ];

    const ranked = rankCandidates(candidates, { minFreq: 3 });

    expect(ranked).toHaveLength(1);
    expect(ranked[0].phrase).toBe('common term');
  });

  it('should limit results to maxCandidates', () => {
    const candidates: MinerCandidate[] = Array.from({ length: 50 }, (_, i) => ({
      phrase: `term${i}`,
      ngramLen: 1,
      scores: { freq: 10, pmi: 1.0, pattern: 0.0 }, // All have same high frequency
    }));

    const ranked = rankCandidates(candidates, { maxCandidates: 10, minFreq: 1 });

    expect(ranked).toHaveLength(10);
  });
});

describe('Real-world Test Case', () => {
  it('should prioritize domain terms in a machine learning article', () => {
    const article = `
      Machine learning is a subset of artificial intelligence (AI) that focuses on the development of algorithms.
      Deep learning, a specialized subset of machine learning, uses artificial neural networks with multiple layers.
      These neural networks can automatically learn and improve from experience without being explicitly programmed.
      
      Supervised learning algorithms learn from labeled training data to make predictions on new data.
      Unsupervised learning, in contrast, finds hidden patterns in data without labeled examples.
      Reinforcement learning is a type of machine learning where agents learn through interaction with an environment.
      
      Popular algorithms include decision trees, random forests, support vector machines, and gradient boosting.
      Deep learning architectures such as convolutional neural networks (CNNs) are particularly effective for image recognition.
      Recurrent neural networks (RNNs) excel at processing sequential data like natural language.
    `;

    const candidates = extractCandidates(article);
    const ranked = rankCandidates(candidates, { maxCandidates: 20 });

    // Expected domain terms should rank highly
    const domainTerms = [
      'machine learning',
      'deep learning',
      'neural networks',
      'artificial intelligence',
      'supervised learning',
      'unsupervised learning',
      'reinforcement learning',
    ];

    const topPhrases = ranked.slice(0, 10).map(c => c.phrase);
    
    // At least half of the top 10 should be domain terms
    const domainTermsInTop = topPhrases.filter(phrase => 
      domainTerms.some(term => phrase.includes(term) || term.includes(phrase))
    );

    expect(domainTermsInTop.length).toBeGreaterThan(4);

    // Machine learning should rank very highly due to frequency and patterns
    const mlRank = ranked.findIndex(c => c.phrase === 'machine learning');
    expect(mlRank).toBeLessThan(5);
  });
});

describe('Score Explanation', () => {
  it('should provide readable score explanations', () => {
    const candidate: MinerCandidate = {
      phrase: 'machine learning',
      ngramLen: 2,
      scores: {
        freq: 5,
        cValue: 2.5,
        pmi: 3.2,
        pattern: 0.8,
        final: 0.75,
      },
    };

    const explanation = explainScore(candidate);
    expect(explanation).toContain('machine learning');
    expect(explanation).toContain('Frequency: 5');
    expect(explanation).toContain('C-value: 2.500');
    expect(explanation).toContain('Final Score: 0.7500');
  });
});
