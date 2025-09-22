/**
 * Evidence-Aware AI Refiner
 * 
 * Provides optional AI-powered definition refinement with strict word limits,
 * context provenance, and confidence scoring. Ensures all refined definitions
 * comply with the 30-word rule and maintain traceability to source material.
 */

/**
 * Configuration for AI refinement
 */
export interface RefineConfig {
  /** Maximum words allowed in refined definitions (default: 30) */
  maxDefinitionWords?: number;
  /** Whether AI refinement is enabled (default: false) */
  enabled?: boolean;
  /** Minimum confidence score to use AI refinement (default: 0.7) */
  minConfidence?: number;
  /** Context window size in sentences (default: 2 = ±2 sentences) */
  contextWindow?: number;
}

/**
 * Context snippet with provenance information
 */
export interface ContextEvidence {
  /** The target sentence containing the term */
  targetSentence: string;
  /** Surrounding sentences for context (±2 by default) */
  contextSentences: string[];
  /** Full context snippet */
  fullContext: string;
  /** Position of target sentence in the context */
  targetPosition: number;
}

/**
 * Result of AI refinement with confidence and provenance
 */
export interface RefinementResult {
  /** Refined definition (≤30 words) */
  refinedDefinition: string;
  /** Original extracted definition for comparison */
  originalDefinition: string;
  /** AI confidence score (0-1) */
  confidenceScore: number;
  /** Context evidence used for refinement */
  evidence: ContextEvidence;
  /** Whether the definition was actually refined or kept original */
  wasRefined: boolean;
  /** Word count of refined definition */
  wordCount: number;
  /** Any warnings or issues during refinement */
  warnings: string[];
}

/**
 * Default configuration
 */
const DEFAULT_CONFIG: Required<RefineConfig> = {
  maxDefinitionWords: Number(process.env.MAX_DEF_WORDS) || 30,
  enabled: process.env.AI_REFINE_ENABLED === 'true',
  minConfidence: Number(process.env.MIN_AI_CONFIDENCE) || 0.7,
  contextWindow: 2,
};

/**
 * Extract context evidence around a term occurrence
 * 
 * @param text - Full source text
 * @param term - Target term to find context for
 * @param config - Configuration options
 * @returns Context evidence with surrounding sentences
 */
export function extractContextEvidence(
  text: string,
  term: string,
  config: Partial<RefineConfig> = {}
): ContextEvidence {
  const cfg = { ...DEFAULT_CONFIG, ...config };
  
  // Split text into sentences
  const sentences = text
    .split(/[.!?]+/)
    .map(s => s.trim())
    .filter(s => s.length > 5);
  
  // Find the sentence containing the term
  const termLower = term.toLowerCase();
  const targetIndex = sentences.findIndex(sentence => 
    sentence.toLowerCase().includes(termLower)
  );
  
  if (targetIndex === -1) {
    // Fallback: use the first sentence as target
    return {
      targetSentence: sentences[0] || '',
      contextSentences: sentences.slice(0, Math.min(5, sentences.length)),
      fullContext: sentences.slice(0, Math.min(5, sentences.length)).join('. '),
      targetPosition: 0,
    };
  }
  
  // Extract context window around target
  const windowStart = Math.max(0, targetIndex - cfg.contextWindow);
  const windowEnd = Math.min(sentences.length, targetIndex + cfg.contextWindow + 1);
  const contextSentences = sentences.slice(windowStart, windowEnd);
  
  return {
    targetSentence: sentences[targetIndex],
    contextSentences,
    fullContext: contextSentences.join('. '),
    targetPosition: targetIndex - windowStart,
  };
}

/**
 * Refine a definition using AI with strict word limits and context
 * 
 * @param term - The term to define
 * @param originalDefinition - Original extracted definition
 * @param evidence - Context evidence from source text
 * @param config - Refinement configuration
 * @returns Refinement result with confidence and compliance
 */
export async function refineDefinition(
  term: string,
  originalDefinition: string,
  evidence: ContextEvidence,
  config: Partial<RefineConfig> = {}
): Promise<RefinementResult> {
  const cfg = { ...DEFAULT_CONFIG, ...config };
  const warnings: string[] = [];
  
  // If AI refinement is disabled, return original with metadata
  if (!cfg.enabled) {
    const wordCount = countWords(originalDefinition);
    return {
      refinedDefinition: originalDefinition,
      originalDefinition,
      confidenceScore: 0.5, // Neutral confidence for non-AI definitions
      evidence,
      wasRefined: false,
      wordCount,
      warnings: wordCount > cfg.maxDefinitionWords 
        ? [`Definition exceeds ${cfg.maxDefinitionWords} words (${wordCount} words)`]
        : [],
    };
  }
  
  try {
    // Prepare AI prompt with strict constraints
    const prompt = buildRefinementPrompt(term, originalDefinition, evidence, cfg);
    
    // Call AI service (placeholder - would use actual OpenAI/Claude API)
    const aiResponse = await callAIService(prompt);
    
    // Parse and validate AI response
    const parsed = parseAIResponse(aiResponse);
    
    // Enforce word limit strictly
    const wordCount = countWords(parsed.definition);
    let finalDefinition = parsed.definition;
    
    if (wordCount > cfg.maxDefinitionWords) {
      finalDefinition = truncateToWordLimit(parsed.definition, cfg.maxDefinitionWords);
      warnings.push(`AI definition truncated from ${wordCount} to ${cfg.maxDefinitionWords} words`);
    }
    
    // Validate confidence threshold
    if (parsed.confidence < cfg.minConfidence) {
      warnings.push(`AI confidence ${parsed.confidence} below threshold ${cfg.minConfidence}, using original`);
      return {
        refinedDefinition: originalDefinition,
        originalDefinition,
        confidenceScore: parsed.confidence,
        evidence,
        wasRefined: false,
        wordCount: countWords(originalDefinition),
        warnings,
      };
    }
    
    return {
      refinedDefinition: finalDefinition,
      originalDefinition,
      confidenceScore: parsed.confidence,
      evidence,
      wasRefined: true,
      wordCount: countWords(finalDefinition),
      warnings,
    };
    
  } catch (error) {
    warnings.push(`AI refinement failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    
    return {
      refinedDefinition: originalDefinition,
      originalDefinition,
      confidenceScore: 0.0,
      evidence,
      wasRefined: false,
      wordCount: countWords(originalDefinition),
      warnings,
    };
  }
}

/**
 * Complete refinement pipeline for a term
 * 
 * @param term - Target term
 * @param originalDefinition - Extracted definition
 * @param sourceText - Full source text for context
 * @param config - Configuration options
 * @returns Complete refinement result
 */
export async function refineTermDefinition(
  term: string,
  originalDefinition: string,
  sourceText: string,
  config: Partial<RefineConfig> = {}
): Promise<RefinementResult> {
  // Extract context evidence
  const evidence = extractContextEvidence(sourceText, term, config);
  
  // Refine with AI
  return refineDefinition(term, originalDefinition, evidence, config);
}

/**
 * Build AI prompt with context and constraints
 */
function buildRefinementPrompt(
  term: string,
  originalDefinition: string,
  evidence: ContextEvidence,
  config: Required<RefineConfig>
): string {
  return `You are a vocabulary expert tasked with refining definitions for educational use.

TERM: "${term}"
ORIGINAL DEFINITION: "${originalDefinition}"

CONTEXT FROM SOURCE:
${evidence.fullContext}

TARGET SENTENCE: "${evidence.targetSentence}"

CONSTRAINTS:
- Maximum ${config.maxDefinitionWords} words STRICTLY ENFORCED
- Keep definition accurate and clear
- Use context to improve precision
- Respond only with JSON format shown below

REQUIRED RESPONSE FORMAT:
{
  "definition": "your refined definition here",
  "confidence": 0.85,
  "reasoning": "brief explanation of changes made"
}

Refine the definition to be clearer and more precise while staying under ${config.maxDefinitionWords} words:`;
}

/**
 * Call AI service (placeholder implementation)
 */
async function callAIService(prompt: string): Promise<string> {
  // In a real implementation, this would call OpenAI, Claude, etc.
  // For now, return a mock response that demonstrates the functionality
  
  const mockResponse = {
    definition: "A computational approach that enables systems to learn and improve from data without explicit programming",
    confidence: 0.87,
    reasoning: "Simplified technical language while maintaining accuracy",
  };
  
  return JSON.stringify(mockResponse);
}

/**
 * Parse AI response and validate format
 */
interface AIResponse {
  definition: string;
  confidence: number;
  reasoning?: string;
}

function parseAIResponse(response: string): AIResponse {
  try {
    const parsed = JSON.parse(response);
    
    if (!parsed.definition || typeof parsed.definition !== 'string') {
      throw new Error('Missing or invalid definition field');
    }
    
    if (typeof parsed.confidence !== 'number' || parsed.confidence < 0 || parsed.confidence > 1) {
      throw new Error('Missing or invalid confidence field');
    }
    
    return {
      definition: parsed.definition.trim(),
      confidence: parsed.confidence,
      reasoning: parsed.reasoning || '',
    };
  } catch (error) {
    throw new Error(`Failed to parse AI response: ${error instanceof Error ? error.message : 'Invalid JSON'}`);
  }
}

/**
 * Count words in a text string
 */
function countWords(text: string): number {
  return text.trim().split(/\s+/).filter(word => word.length > 0).length;
}

/**
 * Truncate text to specified word limit
 */
function truncateToWordLimit(text: string, maxWords: number): string {
  const words = text.trim().split(/\s+/);
  if (words.length <= maxWords) {
    return text;
  }
  
  return words.slice(0, maxWords).join(' ');
}

/**
 * Validate that a definition meets quality standards
 * 
 * @param definition - Definition to validate
 * @param config - Configuration with limits
 * @returns Validation result with specific issues
 */
export function validateDefinition(
  definition: string,
  config: Partial<RefineConfig> = {}
): { isValid: boolean; issues: string[] } {
  const cfg = { ...DEFAULT_CONFIG, ...config };
  const issues: string[] = [];
  
  // Check word count
  const wordCount = countWords(definition);
  if (wordCount > cfg.maxDefinitionWords) {
    issues.push(`Exceeds word limit: ${wordCount}/${cfg.maxDefinitionWords} words`);
  }
  
  // Check minimum length
  if (wordCount < 3) {
    issues.push('Definition too short (minimum 3 words)');
  }
  
  // Check for empty or whitespace-only
  if (!definition.trim()) {
    issues.push('Definition is empty');
  }
  
  // Check for common issues
  if (definition.includes('undefined') || definition.includes('null')) {
    issues.push('Contains invalid placeholder text');
  }
  
  // Check for circular definitions (this logic was too strict, removing it)
  // Circular definition detection needs term context which we don't have here
  
  return {
    isValid: issues.length === 0,
    issues,
  };
}
