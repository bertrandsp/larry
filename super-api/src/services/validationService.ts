import { ExternalTerm } from './externalSources';
import { VocabularyResponse } from '../promptBuilder';

export interface ValidatedTerm {
  term: string;
  definition: string;
  examples: string[];
  source: string;
  sourceUrl?: string;
  verified: boolean;
  gptGenerated: boolean;
  confidenceScore: number;
  category: string;
  complexityLevel: 'beginner' | 'intermediate' | 'advanced';
  tags: string[];
  synonyms?: string[];
  antonyms?: string[];
  relatedTerms?: string[];
  etymology?: string;
  analogy?: string;
}

export interface ValidationResult {
  terms: ValidatedTerm[];
  duplicatesRemoved: number;
  lowConfidenceTerms: number;
  totalProcessed: number;
}

// Main validation function
export function validateTerms(
  terms: (ExternalTerm | any)[],
  topic: string,
  gptGenerated: boolean = false,
  definitionComplexityLevel: 'beginner' | 'intermediate' | 'advanced' = 'intermediate',
  termSelectionLevel?: 'beginner' | 'intermediate' | 'advanced'
): ValidationResult {
  console.log(`🔍 validateTerms called with ${terms.length} terms, topic: ${topic}, termSelectionLevel: ${termSelectionLevel}`);
  const validatedTerms: ValidatedTerm[] = [];
  const seenTerms = new Set<string>();
  let duplicatesRemoved = 0;
  let lowConfidenceTerms = 0;

  for (const term of terms) {
    const validatedTerm = validateSingleTerm(term, topic, gptGenerated, definitionComplexityLevel);
    
    // Check for duplicates (case-insensitive)
    const normalizedTerm = validatedTerm.term.toLowerCase().trim();
    if (seenTerms.has(normalizedTerm)) {
      duplicatesRemoved++;
      continue;
    }
    
    // Additional content quality checks
    if (!isContentQualityAcceptable(validatedTerm)) {
      console.warn(`Content quality check failed for term: ${validatedTerm.term}`);
      continue;
    }
    
    // Term selection level validation
    if (termSelectionLevel && !isTermSelectionLevelAppropriate(validatedTerm.term, termSelectionLevel, topic)) {
      console.warn(`❌ Term selection level check failed for term: ${validatedTerm.term} (requested: ${termSelectionLevel})`);
      continue;
    }
    
    seenTerms.add(normalizedTerm);
    
    if (validatedTerm.confidenceScore < 0.5) {
      lowConfidenceTerms++;
    }
    
    validatedTerms.push(validatedTerm);
  }

  return {
    terms: validatedTerms,
    duplicatesRemoved,
    lowConfidenceTerms,
    totalProcessed: terms.length
  };
}

// Validate a single term
function validateSingleTerm(
  term: ExternalTerm | any,
  topic: string,
  gptGenerated: boolean = false,
  definitionComplexityLevel: 'beginner' | 'intermediate' | 'advanced' = 'intermediate'
): ValidatedTerm {
  // Normalize the term
  const normalizedTerm = normalizeTerm(term.term || term.word || '');
  
  // Calculate confidence score
  const confidenceScore = calculateConfidenceScore(term, gptGenerated);
  
  // Determine complexity level based on definition complexity level
  const complexityLevel = determineComplexityLevel(term, topic, definitionComplexityLevel);
  
  // Generate tags
  const tags = generateTags(term, topic, definitionComplexityLevel);
  
  // Determine category
  const category = determineCategory(term, topic);

  return {
    term: normalizedTerm,
    definition: sanitizeDefinition(term.definition || ''),
    examples: sanitizeExamples(term.examples || []),
    source: term.source || 'Unknown',
    sourceUrl: term.sourceUrl,
    verified: !gptGenerated && confidenceScore > 0.7,
    gptGenerated,
    confidenceScore,
    category,
    complexityLevel,
    tags,
    synonyms: term.synonyms || undefined,
    antonyms: term.antonyms || undefined,
    relatedTerms: term.relatedTerms || undefined,
    etymology: term.etymology || undefined,
    analogy: term.analogy || undefined
  };
}

// Normalize term text
function normalizeTerm(term: string): string {
  return term
    .trim()
    .replace(/\s+/g, ' ')
    .replace(/[^\w\s-]/g, '') // Remove special characters except hyphens
    .split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join(' ');
}

// Calculate confidence score based on various factors
function calculateConfidenceScore(term: any, gptGenerated: boolean): number {
  let score = 0.5; // Base score

  // Source-based scoring
  if (term.source) {
    switch (term.source.toLowerCase()) {
      case 'merriam-webster':
        score += 0.3;
        break;
      case 'wikipedia':
        score += 0.2;
        break;
      case 'wiktionary':
        score += 0.2;
        break;
      case 'urban dictionary':
        score += 0.1;
        break;
      case 'ai generated':
        score += 0.1;
        break;
    }
  }

  // Content quality scoring
  if (term.definition && term.definition.length > 20) {
    score += 0.1;
  }
  
  if (term.examples && term.examples.length > 0) {
    score += 0.1;
  }
  
  if (term.etymology) {
    score += 0.1;
  }

  // GPT-generated terms get lower base confidence
  if (gptGenerated) {
    score -= 0.2;
  }

  // Ensure score is between 0 and 1
  return Math.max(0, Math.min(1, score));
}

// Determine complexity level based on definition complexity level
function determineComplexityLevel(term: any, topic: string, definitionComplexityLevel: 'beginner' | 'intermediate' | 'advanced'): 'beginner' | 'intermediate' | 'advanced' {
  const definition = term.definition || '';
  const termText = term.term || '';
  
  // For definition complexity-based complexity, we primarily use the definition complexity level
  // but can adjust based on content analysis
  const wordCount = definition.split(' ').length;
  const hasComplexWords = /(technical|sophisticated|advanced|complex|intricate|algorithm|methodology|implementation)/i.test(definition);
  const isLongTerm = termText.length > 15;
  
  // Base complexity on definition complexity level, with some content-based adjustments
  if (definitionComplexityLevel === 'beginner') {
    // For beginners, keep it simple unless content is clearly advanced
    if (hasComplexWords && wordCount > 20) {
      return 'intermediate'; // Upgrade if content is too complex
    }
    return 'beginner';
  } else if (definitionComplexityLevel === 'intermediate') {
    // For intermediate, use content analysis
    if (hasComplexWords || isLongTerm || wordCount > 30) {
      return 'advanced';
    } else if (wordCount < 10) {
      return 'beginner';
    }
    return 'intermediate';
  } else {
    // For advanced, use content analysis but lean toward advanced
    if (wordCount < 15 && !hasComplexWords) {
      return 'intermediate'; // Downgrade if content is too simple
    }
    return 'advanced';
  }
}

// Generate relevant tags
function generateTags(term: any, topic: string, definitionComplexityLevel: 'beginner' | 'intermediate' | 'advanced' = 'intermediate'): string[] {
  const tags: string[] = [];
  
  // Topic-based tags
  tags.push(topic.toLowerCase());
  
  // Source-based tags
  if (term.source) {
    tags.push(term.source.toLowerCase().replace(' ', '-'));
  }
  
  // Category-based tags
  if (term.category) {
    tags.push(term.category.toLowerCase());
  }
  
  // Content-based tags
  if (term.etymology) {
    tags.push('etymology');
  }
  
  if (term.synonyms && term.synonyms.length > 0) {
    tags.push('synonyms');
  }
  
  if (term.analogy) {
    tags.push('analogy');
  }
  
  // Complexity tags
  const complexity = determineComplexityLevel(term, topic, definitionComplexityLevel);
  tags.push(complexity);
  
  return [...new Set(tags)]; // Remove duplicates
}

// Determine category
function determineCategory(term: any, topic: string): string {
  if (term.category) {
    return term.category;
  }
  
  // Default categories based on topic
  const topicLower = topic.toLowerCase();
  
  if (topicLower.includes('tech') || topicLower.includes('programming') || topicLower.includes('software')) {
    return 'technology';
  } else if (topicLower.includes('art') || topicLower.includes('design') || topicLower.includes('creative')) {
    return 'arts';
  } else if (topicLower.includes('science') || topicLower.includes('biology') || topicLower.includes('chemistry')) {
    return 'science';
  } else if (topicLower.includes('business') || topicLower.includes('finance') || topicLower.includes('economics')) {
    return 'business';
  } else if (topicLower.includes('health') || topicLower.includes('medical') || topicLower.includes('medicine')) {
    return 'health';
  } else {
    return 'general';
  }
}

// Sanitize definition text
function sanitizeDefinition(definition: string): string {
  return definition
    .trim()
    .replace(/\s+/g, ' ')
    .replace(/[^\w\s.,!?;:-]/g, '') // Keep basic punctuation
    .substring(0, 500); // Limit length
}

// Sanitize examples array
function sanitizeExamples(examples: string[]): string[] {
  return examples
    .filter(example => example && typeof example === 'string')
    .map(example => example.trim().substring(0, 200)) // Limit length
    .filter(example => example.length > 10) // Remove very short examples
    .slice(0, 3); // Limit to 3 examples
}

// Post-process validation (remove low-quality terms, sort by confidence)
export function postProcessValidation(
  result: ValidationResult,
  minConfidence: number = 0.3,
  maxTerms: number = 50
): ValidationResult {
  const filteredTerms = result.terms
    .filter(term => term.confidenceScore >= minConfidence)
    .sort((a, b) => b.confidenceScore - a.confidenceScore) // Sort by confidence
    .slice(0, maxTerms);

  return {
    ...result,
    terms: filteredTerms,
    lowConfidenceTerms: result.terms.length - filteredTerms.length
  };
}

// Validate OpenAI response format
export function validateOpenAiResponse(response: any): VocabularyResponse | null {
  try {
    if (!response || typeof response !== 'object') {
      return null;
    }

    if (!response.terms || !Array.isArray(response.terms)) {
      return null;
    }

    if (!response.facts || !Array.isArray(response.facts)) {
      return null;
    }

    // Validate each term
    const validTerms = response.terms.filter((term: any) => 
      term && 
      typeof term.term === 'string' && 
      term.term.trim().length > 0 &&
      typeof term.definition === 'string' &&
      term.definition.trim().length > 0
    );

    // Validate facts
    const validFacts = response.facts.filter((fact: any) => 
      typeof fact === 'string' && 
      fact.trim().length > 0
    );

    return {
      terms: validTerms,
      facts: validFacts
    };
  } catch (error) {
    console.error('Error validating OpenAI response:', error);
    return null;
  }
}

// Function to check if content quality is acceptable
function isContentQualityAcceptable(term: ValidatedTerm): boolean {
  const textToCheck = `${term.term} ${term.definition} ${term.examples.join(' ')}`.toLowerCase();
  
  // Check for inappropriate content
  const inappropriateWords = [
    'crap', 'bull-dike', 'troll', 'tears', 'shame', 'grave', 'rolling',
    'teeny-bopper', 'crappy', 'would ring', 'youre', 'walts'
  ];
  
  if (inappropriateWords.some(word => textToCheck.includes(word))) {
    return false;
  }
  
  // Check for wiki markup pollution
  if (term.definition.includes('relmw:') || 
      term.definition.includes('href') || 
      term.definition.includes('titlew:') ||
      term.definition.includes('WikiLink')) {
    return false;
  }
  
  // Check for reasonable definition length and content
  if (term.definition.length < 10 || term.definition.length > 1000) {
    return false;
  }
  
  // Check for relevance issues (e.g., WWII content for non-war terms)
  if (term.definition.toLowerCase().includes('world war') && 
      !term.term.toLowerCase().includes('war') &&
      !term.term.toLowerCase().includes('magic')) {
    return false;
  }
  
  // Check for grammatical issues
  if (term.definition.includes(' is draw') || 
      term.definition.includes('invented a wonderful characters')) {
    return false;
  }
  
  // Check for offensive or derogatory content
  if (textToCheck.includes('bulldike') || 
      textToCheck.includes('bull-dike') ||
      textToCheck.includes('pseudo-adams')) {
    return false;
  }
  
  return true;
}

// Function to validate if a term matches the requested selection level
function isTermSelectionLevelAppropriate(term: string, selectionLevel: 'beginner' | 'intermediate' | 'advanced', topic: string): boolean {
  console.log(`🔍 Validating term "${term}" for ${selectionLevel} level`);
  const termLower = term.toLowerCase();
  const topicLower = topic.toLowerCase();
  
  // Define general complexity indicators
  const advancedIndicators = [
    // Technical/scientific terms
    'algorithm', 'methodology', 'implementation', 'optimization', 'configuration', 'parameter', 'variable',
    'synthesis', 'analysis', 'hypothesis', 'theory', 'paradigm', 'framework', 'architecture', 'infrastructure',
    'quantum', 'nuclear', 'molecular', 'atomic', 'genetic', 'biochemical', 'neurochemical', 'pharmacological',
    'thermodynamic', 'electromagnetic', 'electrochemical', 'photochemical', 'catalytic', 'enzymatic',
    
    // Professional/abstract terms
    'executive', 'director', 'manager', 'supervisor', 'coordinator', 'specialist', 'expert', 'consultant',
    'analyst', 'engineer', 'architect', 'developer', 'designer', 'researcher', 'scientist', 'professor',
    'philosophy', 'metaphysics', 'epistemology', 'ontology', 'phenomenology', 'hermeneutics', 'dialectics',
    
    // Foreign language terms (common ones)
    'savoir', 'faire', 'avoir', 'être', 'c\'est', 'très', 'beaucoup', 'comment', 'pourquoi', 'parce que',
    'bonjour', 'merci', 'au revoir', 'excusez', 'pardon', 's\'il vous plaît', 'de rien', 'bienvenue'
  ];
  
  const intermediateIndicators = [
    // Somewhat specialized terms
    'technique', 'method', 'approach', 'strategy', 'tactic', 'process', 'system', 'protocol',
    'standard', 'guideline', 'procedure', 'workflow', 'pipeline', 'framework'
  ];
  
  // Check if term contains advanced indicators
  const hasAdvancedIndicators = advancedIndicators.some(indicator => 
    termLower.includes(indicator.toLowerCase())
  );
  
  const hasIntermediateIndicators = intermediateIndicators.some(indicator => 
    termLower.includes(indicator.toLowerCase())
  );
  
  // Simple validation logic based on complexity indicators
  switch (selectionLevel) {
    case 'beginner':
      // For beginner, reject terms with advanced indicators
      if (hasAdvancedIndicators) {
        console.log(`❌ Term "${term}" rejected for beginner level - contains advanced indicators`);
        return false;
      }
      return true;
      
    case 'intermediate':
      // For intermediate, reject terms that are too advanced
      if (hasAdvancedIndicators) {
        console.log(`❌ Term "${term}" rejected for intermediate level - contains advanced indicators`);
        return false;
      }
      return true;
      
    case 'advanced':
      // For advanced, allow all terms (no restrictions)
      return true;
      
    default:
      return true;
  }
}

