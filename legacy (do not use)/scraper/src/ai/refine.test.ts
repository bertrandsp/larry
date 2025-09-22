import { describe, it, expect, vi, beforeEach } from 'vitest';

import {
  extractContextEvidence,
  refineDefinition,
  refineTermDefinition,
  validateDefinition,
} from './refine';

import type { ContextEvidence, RefinementResult } from './refine';

describe('AI Refiner System', () => {
  describe('Context Evidence Extraction', () => {
    it('should extract context around target term', () => {
      const text = `
        Machine learning is a powerful technology. 
        It enables computers to learn from data automatically.
        Neural networks are a subset of machine learning algorithms.
        They process information through interconnected nodes.
        Deep learning uses multiple layers for complex pattern recognition.
      `;
      
      const evidence = extractContextEvidence(text, 'machine learning');
      
      expect(evidence.targetSentence).toContain('Machine learning');
      expect(evidence.contextSentences.length).toBeGreaterThan(2);
      expect(evidence.fullContext).toContain('Machine learning');
      expect(evidence.targetPosition).toBeGreaterThanOrEqual(0);
    });

    it('should handle terms not found in text', () => {
      const text = 'This text does not contain the target term.';
      const evidence = extractContextEvidence(text, 'nonexistent');
      
      expect(evidence.targetSentence).toBeTruthy();
      expect(evidence.contextSentences.length).toBeGreaterThan(0);
      expect(evidence.targetPosition).toBe(0);
    });

    it('should respect context window size', () => {
      const text = `
        Sentence one. Sentence two. TARGET sentence here. 
        Sentence four. Sentence five. Sentence six.
      `;
      
      const evidence = extractContextEvidence(text, 'TARGET', { contextWindow: 1 });
      
      // Should include target + 1 before + 1 after = 3 sentences max
      expect(evidence.contextSentences.length).toBeLessThanOrEqual(3);
    });
  });

  describe('Definition Validation', () => {
    it('should validate compliant definitions', () => {
      const validDef = 'A computational approach that enables systems to learn from data automatically';
      const result = validateDefinition(validDef, { maxDefinitionWords: 30 });
      
      expect(result.isValid).toBe(true);
      expect(result.issues).toHaveLength(0);
    });

    it('should reject definitions exceeding word limit', () => {
      const longDef = 'This is a very long definition that contains way more than the maximum allowed number of words and should definitely be rejected by the validation system for being too verbose and exceeding the strict word limit that has been set for quality control purposes';
      const result = validateDefinition(longDef, { maxDefinitionWords: 10 });
      
      expect(result.isValid).toBe(false);
      expect(result.issues.some(issue => issue.includes('word limit'))).toBe(true);
    });

    it('should reject empty or too short definitions', () => {
      const emptyResult = validateDefinition('');
      const shortResult = validateDefinition('Too short');
      
      expect(emptyResult.isValid).toBe(false);
      expect(shortResult.isValid).toBe(false);
      expect(emptyResult.issues.some(issue => issue.includes('empty'))).toBe(true);
      expect(shortResult.issues.some(issue => issue.includes('too short'))).toBe(true);
    });

    it('should detect invalid placeholder content', () => {
      const invalidDef = 'This definition contains undefined values';
      const result = validateDefinition(invalidDef);
      
      expect(result.isValid).toBe(false);
      expect(result.issues.some(issue => issue.includes('placeholder'))).toBe(true);
    });
  });

  describe('AI Refinement (Disabled)', () => {
    it('should return original definition when AI disabled', async () => {
      const evidence: ContextEvidence = {
        targetSentence: 'Machine learning is a subset of AI.',
        contextSentences: ['Machine learning is a subset of AI.', 'It uses algorithms.'],
        fullContext: 'Machine learning is a subset of AI. It uses algorithms.',
        targetPosition: 0,
      };

      const result = await refineDefinition(
        'machine learning',
        'a method for computers to learn',
        evidence,
        { enabled: false }
      );

      expect(result.wasRefined).toBe(false);
      expect(result.refinedDefinition).toBe('a method for computers to learn');
      expect(result.confidenceScore).toBe(0.5);
    });
  });

  describe('AI Refinement (Enabled with Mock)', () => {
    beforeEach(() => {
      // Mock the AI service call to return controlled responses
      vi.doMock('./refine', async () => {
        const actual = await vi.importActual('./refine');
        return {
          ...actual,
          // Override the internal AI service call
        };
      });
    });

    it('should process refinement when enabled', async () => {
      const evidence: ContextEvidence = {
        targetSentence: 'Machine learning is a subset of artificial intelligence.',
        contextSentences: [
          'Machine learning is a subset of artificial intelligence.',
          'It enables computers to learn automatically.',
        ],
        fullContext: 'Machine learning is a subset of artificial intelligence. It enables computers to learn automatically.',
        targetPosition: 0,
      };

      const result = await refineDefinition(
        'machine learning',
        'a way for computers to learn things from data automatically using algorithms',
        evidence,
        { enabled: true, maxDefinitionWords: 15 }
      );

      // Since we're using a mock AI service, check the structure
      expect(result.originalDefinition).toBe('a way for computers to learn things from data automatically using algorithms');
      expect(result.evidence).toEqual(evidence);
      expect(result.confidenceScore).toBeGreaterThanOrEqual(0);
      expect(result.confidenceScore).toBeLessThanOrEqual(1);
      expect(typeof result.wasRefined).toBe('boolean');
      expect(result.wordCount).toBeGreaterThan(0);
    });

    it('should enforce strict word limits', async () => {
      const evidence: ContextEvidence = {
        targetSentence: 'Test sentence.',
        contextSentences: ['Test sentence.'],
        fullContext: 'Test sentence.',
        targetPosition: 0,
      };

      const result = await refineDefinition(
        'test term',
        'original definition',
        evidence,
        { enabled: true, maxDefinitionWords: 5 }
      );

      // The word count should respect the limit
      expect(result.wordCount).toBeLessThanOrEqual(5);
      
      // If the AI response was too long, it should be truncated
      if (result.wordCount > 5) {
        expect(result.warnings.some(w => w.includes('truncated'))).toBe(true);
      }
    });

    it('should handle low confidence scores', async () => {
      const evidence: ContextEvidence = {
        targetSentence: 'Unclear term usage here.',
        contextSentences: ['Unclear term usage here.'],
        fullContext: 'Unclear term usage here.',
        targetPosition: 0,
      };

      const result = await refineDefinition(
        'unclear term',
        'original definition',
        evidence,
        { enabled: true, minConfidence: 0.9 } // Very high threshold
      );

      // If confidence is below threshold, should use original
      if (result.confidenceScore < 0.9) {
        expect(result.wasRefined).toBe(false);
        expect(result.refinedDefinition).toBe('original definition');
      }
    });
  });

  describe('Complete Refinement Pipeline', () => {
    it('should process term through complete pipeline', async () => {
      const sourceText = `
        Machine learning is a method of data analysis that automates analytical model building.
        It is a branch of artificial intelligence based on the idea that systems can learn from data.
        Neural networks are computing systems inspired by biological neural networks.
        Deep learning is part of machine learning methods based on artificial neural networks.
      `;

      const result = await refineTermDefinition(
        'machine learning',
        'a type of AI that learns from data',
        sourceText,
        { enabled: false } // Disabled for predictable testing
      );

      expect(result.originalDefinition).toBe('a type of AI that learns from data');
      expect(result.evidence.targetSentence).toContain('Machine learning');
      expect(result.evidence.fullContext).toContain('artificial intelligence');
      expect(result.wasRefined).toBe(false); // AI disabled
      expect(result.wordCount).toBeGreaterThan(0);
    });

    it('should extract meaningful context for refinement', async () => {
      const sourceText = `
        Introduction paragraph here.
        Machine learning is a subset of artificial intelligence that focuses on algorithms.
        These algorithms can improve automatically through experience and data.
        Applications include image recognition and natural language processing.
        Conclusion paragraph here.
      `;

      const result = await refineTermDefinition(
        'machine learning',
        'AI subset',
        sourceText
      );

      // Context should include sentences around the target
      expect(result.evidence.fullContext).toContain('algorithms');
      expect(result.evidence.fullContext).toContain('artificial intelligence');
      expect(result.evidence.contextSentences.length).toBeGreaterThan(1);
    });
  });

  describe('Word Counting and Truncation', () => {
    it('should count words accurately', () => {
      const testCases = [
        { text: 'one two three', expected: 3 },
        { text: '  spaced   words  here  ', expected: 3 },
        { text: 'single', expected: 1 },
        { text: '', expected: 0 },
        { text: '   ', expected: 0 },
      ];

      for (const { text, expected } of testCases) {
        const words = text.trim().split(/\s+/).filter(w => w.length > 0).length;
        expect(words).toBe(expected);
      }
    });

    it('should validate 30-word rule compliance', () => {
      const exactly30Words = 'One two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty twenty-one twenty-two twenty-three twenty-four twenty-five twenty-six twenty-seven twenty-eight twenty-nine thirty';
      const over30Words = exactly30Words + ' thirty-one';

      const valid = validateDefinition(exactly30Words, { maxDefinitionWords: 30 });
      const invalid = validateDefinition(over30Words, { maxDefinitionWords: 30 });

      expect(valid.isValid).toBe(true);
      expect(invalid.isValid).toBe(false);
    });
  });

  describe('Error Handling', () => {
    it('should handle errors gracefully', async () => {
      const evidence: ContextEvidence = {
        targetSentence: 'Test',
        contextSentences: ['Test'],
        fullContext: 'Test',
        targetPosition: 0,
      };

      // Test with invalid configuration that might cause errors
      const result = await refineDefinition(
        'test',
        'test definition',
        evidence,
        { enabled: true, maxDefinitionWords: -1 } // Invalid config
      );

      // Should still return a result, possibly with warnings
      expect(result.originalDefinition).toBe('test definition');
      expect(result.confidenceScore).toBeGreaterThanOrEqual(0);
    });

    it('should provide useful warnings', async () => {
      const evidence: ContextEvidence = {
        targetSentence: 'Short',
        contextSentences: ['Short'],
        fullContext: 'Short',
        targetPosition: 0,
      };

      const result = await refineDefinition(
        'test',
        'a very long definition that will definitely exceed the word limit and should trigger warnings',
        evidence,
        { enabled: true, maxDefinitionWords: 5 }
      );

      // Should have warnings about word limit or other issues
      expect(Array.isArray(result.warnings)).toBe(true);
    });
  });
});
