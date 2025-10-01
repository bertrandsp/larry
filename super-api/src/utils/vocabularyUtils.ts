/**
 * Utility functions for processing rich vocabulary data
 */

/**
 * Extract part of speech from a definition using common patterns
 */
export function extractPartOfSpeech(definition: string): string | undefined {
  if (!definition) return undefined;
  
  const lowerDef = definition.toLowerCase();
  
  // Common patterns for part of speech detection
  if (lowerDef.includes('verb') || lowerDef.match(/\b(to|ing|ed)\b/)) {
    return 'verb';
  }
  if (lowerDef.includes('noun') || lowerDef.match(/\b(a|an|the)\s+\w+/)) {
    return 'noun';
  }
  if (lowerDef.includes('adjective') || lowerDef.match(/\bdescrib(es|ing)\b/)) {
    return 'adjective';
  }
  if (lowerDef.includes('adverb') || lowerDef.match(/\bly\b/)) {
    return 'adverb';
  }
  
  // Default based on common sentence patterns
  if (lowerDef.startsWith('a ') || lowerDef.startsWith('an ')) {
    return 'noun';
  }
  if (lowerDef.startsWith('to ')) {
    return 'verb';
  }
  
  return undefined;
}

/**
 * Estimate difficulty level based on definition complexity and topic
 */
export function estimateDifficulty(definition: string, topicName: string): number {
  if (!definition) return 1;
  
  let difficulty = 1; // Base difficulty
  
  // Length-based complexity
  if (definition.length > 100) difficulty += 1;
  if (definition.length > 200) difficulty += 1;
  
  // Word complexity indicators
  const complexWords = [
    'sophisticated', 'comprehensive', 'methodology', 'paradigm',
    'infrastructure', 'implementation', 'optimization', 'architecture'
  ];
  
  const hasComplexWords = complexWords.some(word => 
    definition.toLowerCase().includes(word)
  );
  if (hasComplexWords) difficulty += 1;
  
  // Technical topic adjustment
  const technicalTopics = [
    'software engineering', 'data science', 'machine learning',
    'cybersecurity', 'blockchain', 'artificial intelligence'
  ];
  
  const isTechnical = technicalTopics.some(topic => 
    topicName.toLowerCase().includes(topic.toLowerCase())
  );
  if (isTechnical) difficulty += 1;
  
  // Cap at 5
  return Math.min(difficulty, 5);
}

/**
 * Process OpenAI card data into structured vocabulary fields
 */
export function processVocabularyCard(card: any, topicName: string) {
  return {
    synonyms: JSON.stringify(card.synonyms || []),
    antonyms: JSON.stringify(card.antonyms || []),
    relatedTerms: JSON.stringify(card.similar_terms?.map((st: any) => ({
      term: st.term,
      difference: st.difference
    })) || []),
    partOfSpeech: extractPartOfSpeech(card.definition),
    difficulty: estimateDifficulty(card.definition, topicName),
    tags: JSON.stringify([topicName, "AI Generated"]),
    etymology: card.etymology || undefined,
    pronunciation: card.pronunciation || undefined,
  };
}

/**
 * Parse JSON fields safely for database retrieval
 */
export function parseVocabularyFields(term: any) {
  return {
    ...term,
    synonyms: safeJsonParse(term.synonyms, []),
    antonyms: safeJsonParse(term.antonyms, []),
    relatedTerms: safeJsonParse(term.relatedTerms, []),
    tags: safeJsonParse(term.tags, []),
  };
}

/**
 * Safely parse JSON with fallback
 */
function safeJsonParse(jsonString: string | null | undefined, fallback: any = null) {
  if (!jsonString) return fallback;
  
  // Handle empty string or whitespace-only strings
  const trimmed = jsonString.trim();
  if (!trimmed) return fallback;
  
  // Handle empty array string specifically
  if (trimmed === '[]') return [];
  if (trimmed === '{}') return {};
  
  try {
    return JSON.parse(trimmed);
  } catch (error) {
    console.warn('Failed to parse JSON:', jsonString, error);
    return fallback;
  }
}
