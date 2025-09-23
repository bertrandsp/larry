export function cleanAndDedupe(items: string[]): string[] {
  const cleaned = items
    .map(item => item.trim().toLowerCase())
    .filter(item => item.length > 0);
  
  return Array.from(new Set(cleaned));
}

export function cleanAndDedupeTerms<T extends { term: string }>(terms: T[]): T[] {
  const seen = new Set<string>();
  return terms.filter(term => {
    const normalized = term.term.trim().toLowerCase();
    if (seen.has(normalized)) {
      return false;
    }
    seen.add(normalized);
    return true;
  });
}

export function cleanAndDedupeFacts<T extends { fact: string }>(facts: T[]): T[] {
  const seen = new Set<string>();
  return facts.filter(fact => {
    const normalized = fact.fact.trim().toLowerCase();
    if (seen.has(normalized)) {
      return false;
    }
    seen.add(normalized);
    return true;
  });
}

/**
 * Advanced term normalization with sophisticated cleaning
 */
export function normalizeTerm(term: string): string {
  return term
    .trim()
    .toLowerCase()
    .replace(/[.!?]+$/, '') // Remove trailing punctuation
    .replace(/\s+/g, ' ') // Normalize whitespace
    .replace(/['"]/g, '') // Remove quotes
    .replace(/[^\w\s-]/g, '') // Remove special characters except hyphens
    .trim();
}

/**
 * Advanced deduplication with confidence score-based logic
 * Keeps the term with the highest confidence score when duplicates exist
 */
export function deduplicateTermsWithConfidence<T extends { 
  term: string; 
  confidenceScore?: number;
  gptGenerated?: boolean;
  example?: string;
  sourceUrl?: string;
}>(terms: T[]): T[] {
  const termMap = new Map<string, T>();
  
  terms.forEach(term => {
    const normalized = normalizeTerm(term.term);
    const existing = termMap.get(normalized);
    
    if (!existing) {
      termMap.set(normalized, term);
      return;
    }
    
    // If duplicates exist, keep the one with the highest confidence score
    const existingScore = existing.confidenceScore || 0;
    const newScore = term.confidenceScore || 0;
    
    if (newScore > existingScore) {
      termMap.set(normalized, term);
      return;
    }
    
    // If confidence scores are equal, prefer verified sources over GPT-generated
    if (newScore === existingScore) {
      if (term.sourceUrl && !existing.sourceUrl) {
        termMap.set(normalized, term);
        return;
      }
      
      // If both are GPT-generated, prefer the one with an example sentence
      if (term.gptGenerated && existing.gptGenerated) {
        if (term.example && !existing.example) {
          termMap.set(normalized, term);
          return;
        }
      }
    }
  });
  
  return Array.from(termMap.values());
}

/**
 * Advanced fact deduplication with confidence scoring
 */
export function deduplicateFactsWithConfidence<T extends { 
  fact: string; 
  gptGenerated?: boolean;
  sourceUrl?: string;
}>(facts: T[]): T[] {
  const factMap = new Map<string, T>();
  
  facts.forEach(fact => {
    const normalized = normalizeTerm(fact.fact);
    const existing = factMap.get(normalized);
    
    if (!existing) {
      factMap.set(normalized, fact);
      return;
    }
    
    // Prefer verified sources over GPT-generated facts
    if (fact.sourceUrl && !existing.sourceUrl) {
      factMap.set(normalized, fact);
    }
  });
  
  return Array.from(factMap.values());
}

