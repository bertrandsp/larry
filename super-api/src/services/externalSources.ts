import axios from 'axios';

export interface ExternalTerm {
  term: string;
  definition: string;
  examples: string[];
  source: string;
  sourceUrl?: string;
  confidence: number;
  category?: string;
  etymology?: string;
  synonyms?: string[];
  antonyms?: string[];
}

export interface SourceResult {
  terms: ExternalTerm[];
  totalFound: number;
  sources: string[];
}

// Wikipedia API
export async function fetchFromWikipedia(topic: string, limit: number = 20): Promise<ExternalTerm[]> {
  try {
    const searchResponse = await axios.get('https://en.wikipedia.org/api/rest_v1/page/summary/' + encodeURIComponent(topic));
    
    if (searchResponse.data.extract) {
      // Extract key terms from the summary
      const extract = searchResponse.data.extract;
      const terms = extractTermsFromText(extract, topic);
      
      return terms.slice(0, limit).map(term => ({
        term: term,
        definition: `Definition related to ${topic} from Wikipedia`,
        examples: [`Example usage of ${term} in the context of ${topic}`],
        source: 'Wikipedia',
        sourceUrl: searchResponse.data.content_urls?.desktop?.page,
        confidence: 0.8,
        category: 'encyclopedic'
      }));
    }
    
    return [];
  } catch (error) {
    console.error('Wikipedia API error:', error);
    return [];
  }
}

// Merriam-Webster API (requires API key)
export async function fetchFromMerriamWebster(term: string): Promise<ExternalTerm | null> {
  try {
    const apiKey = process.env.MERRIAM_WEBSTER_API_KEY;
    if (!apiKey) {
      console.warn('Merriam-Webster API key not found');
      return null;
    }

    const response = await axios.get(`https://www.dictionaryapi.com/api/v3/references/collegiate/json/${encodeURIComponent(term)}`, {
      params: { key: apiKey }
    });

    if (response.data && response.data.length > 0) {
      const entry = response.data[0];
      if (typeof entry === 'object' && entry.shortdef) {
        return {
          term: entry.hwi?.hw || term,
          definition: entry.shortdef[0] || `Definition for ${term}`,
          examples: entry.shortdef.slice(1, 3) || [`Example usage of ${term}`],
          source: 'Merriam-Webster',
          sourceUrl: `https://www.merriam-webster.com/dictionary/${encodeURIComponent(term)}`,
          confidence: 0.9,
          category: 'dictionary',
          etymology: entry.et?.[0]?.[1]?.[0] || undefined,
          synonyms: entry.syns?.[0]?.map((syn: any) => syn.wd) || undefined
        };
      }
    }
    
    return null;
  } catch (error) {
    console.error('Merriam-Webster API error:', error);
    return null;
  }
}

// Urban Dictionary API (unofficial)
export async function fetchFromUrbanDictionary(term: string): Promise<ExternalTerm | null> {
  try {
    const response = await axios.get(`https://api.urbandictionary.com/v0/define`, {
      params: { term: term }
    });

    if (response.data && response.data.list && response.data.list.length > 0) {
      const entry = response.data.list[0];
      const definition = cleanWikiMarkup(entry.definition);
      const examples = [entry.example].filter(Boolean).map(ex => cleanWikiMarkup(ex));
      
      // Validate content quality (Urban Dictionary often has inappropriate content)
      if (!validateContentQuality(entry.word, definition, examples)) {
        console.warn(`Content quality validation failed for Urban Dictionary term: ${entry.word}`);
        return null;
      }
      
      return {
        term: entry.word,
        definition: definition,
        examples: examples,
        source: 'Urban Dictionary',
        sourceUrl: entry.permalink,
        confidence: 0.6, // Lower confidence for slang/colloquial terms
        category: 'slang'
      };
    }
    
    return null;
  } catch (error) {
    console.error('Urban Dictionary API error:', error);
    return null;
  }
}

// Wiktionary API
export async function fetchFromWiktionary(term: string): Promise<ExternalTerm | null> {
  try {
    const response = await axios.get(`https://en.wiktionary.org/api/rest_v1/page/definition/${encodeURIComponent(term)}`);
    
    if (response.data && response.data.en && response.data.en.length > 0) {
      const entry = response.data.en[0];
      if (entry.definitions && entry.definitions.length > 0) {
        const definition = entry.definitions[0];
        const rawDefinition = definition.definition || `Definition for ${term}`;
        
        const cleanedDefinition = cleanWikiMarkup(rawDefinition);
        const cleanedExamples = definition.examples?.map((ex: any) => cleanWikiMarkup(ex.text)) || [`Example usage of ${term}`];
        
        // Validate content quality
        if (!validateContentQuality(term, cleanedDefinition, cleanedExamples)) {
          console.warn(`Content quality validation failed for term: ${term}`);
          return null;
        }
        
        return {
          term: term,
          definition: cleanedDefinition,
          examples: cleanedExamples,
          source: 'Wiktionary',
          sourceUrl: `https://en.wiktionary.org/wiki/${encodeURIComponent(term)}`,
          confidence: 0.7,
          category: 'dictionary',
          etymology: definition.etymology ? cleanWikiMarkup(definition.etymology) : undefined
        };
      }
    }
    
    return null;
  } catch (error) {
    console.error('Wiktionary API error:', error);
    return null;
  }
}

// Main function to fetch from all external sources
export async function fetchFromExternalSources(
  topic: string, 
  limit: number = 50
): Promise<SourceResult> {
  const allTerms: ExternalTerm[] = [];
  const sources: string[] = [];

  try {
    // Fetch from Wikipedia
    const wikiTerms = await fetchFromWikipedia(topic, Math.ceil(limit * 0.4));
    allTerms.push(...wikiTerms);
    if (wikiTerms.length > 0) sources.push('Wikipedia');

    // For each term found, try to get detailed definitions
    const detailedTerms: ExternalTerm[] = [];
    
    for (const term of allTerms.slice(0, 10)) { // Limit to avoid rate limits
      try {
        // Try Merriam-Webster first (highest quality)
        const mwTerm = await fetchFromMerriamWebster(term.term);
        if (mwTerm) {
          detailedTerms.push(mwTerm);
          continue;
        }

        // Fallback to Wiktionary
        const wkTerm = await fetchFromWiktionary(term.term);
        if (wkTerm) {
          detailedTerms.push(wkTerm);
          continue;
        }

        // Keep original Wikipedia term if no detailed definition found
        detailedTerms.push(term);
      } catch (error) {
        console.error(`Error fetching detailed definition for ${term.term}:`, error);
        detailedTerms.push(term);
      }
    }

    return {
      terms: detailedTerms.slice(0, limit),
      totalFound: detailedTerms.length,
      sources
    };
  } catch (error) {
    console.error('Error fetching from external sources:', error);
    return {
      terms: [],
      totalFound: 0,
      sources: []
    };
  }
}

// Fetch single term from external sources
export async function fetchSingleFromExternalSources(term: string): Promise<ExternalTerm | null> {
  try {
    // Try sources in order of preference
    const mwTerm = await fetchFromMerriamWebster(term);
    if (mwTerm) return mwTerm;

    const wkTerm = await fetchFromWiktionary(term);
    if (wkTerm) return wkTerm;

    const udTerm = await fetchFromUrbanDictionary(term);
    if (udTerm) return udTerm;

    return null;
  } catch (error) {
    console.error(`Error fetching single term ${term}:`, error);
    return null;
  }
}

// Helper function to extract terms from text
function extractTermsFromText(text: string, topic: string): string[] {
  // Simple term extraction - in practice you'd use NLP libraries
  const words = text.toLowerCase()
    .replace(/[^\w\s]/g, ' ')
    .split(/\s+/)
    .filter(word => word.length > 3 && word !== topic.toLowerCase());
  
  // Remove common words and get unique terms
  const commonWords = new Set(['the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 'her', 'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his', 'how', 'its', 'may', 'new', 'now', 'old', 'see', 'two', 'way', 'who', 'boy', 'did', 'man', 'oil', 'sit', 'try', 'use', 'very', 'want', 'with', 'been', 'good', 'have', 'just', 'like', 'long', 'make', 'many', 'over', 'such', 'take', 'than', 'them', 'well', 'were', 'what', 'when', 'will', 'your', 'about', 'after', 'again', 'being', 'every', 'great', 'might', 'shall', 'still', 'their', 'there', 'these', 'think', 'those', 'under', 'where', 'which', 'while', 'would', 'years', 'before', 'could', 'first', 'never', 'other', 'right', 'should', 'through', 'without', 'another', 'because', 'between', 'during', 'however', 'nothing', 'something', 'together', 'without']);
  
  const uniqueTerms = [...new Set(words.filter(word => !commonWords.has(word)))];
  
  return uniqueTerms.slice(0, 20); // Return top 20 terms
}

// Rate limiting helper
class RateLimiter {
  private requests: Map<string, number[]> = new Map();
  
  canMakeRequest(source: string, maxRequests: number, windowMs: number): boolean {
    const now = Date.now();
    const requests = this.requests.get(source) || [];
    
    // Remove old requests outside the window
    const validRequests = requests.filter(time => now - time < windowMs);
    
    if (validRequests.length >= maxRequests) {
      return false;
    }
    
    validRequests.push(now);
    this.requests.set(source, validRequests);
    return true;
  }
}

export const rateLimiter = new RateLimiter();

// Function to clean wiki markup from text
function cleanWikiMarkup(text: string): string {
  if (!text) return '';
  
  // Remove wiki markup patterns
  let cleaned = text
    // Remove wiki links like [[term|display text]] or [[term]]
    .replace(/\[\[([^\]]+)\]\]/g, (match, content) => {
      const parts = content.split('|');
      return parts[parts.length - 1]; // Use display text or fallback to term
    })
    // Remove wiki interwiki links like [[w:term]]
    .replace(/\[\[w:([^\]]+)\]\]/g, '$1')
    // Remove relmw:WikiLink patterns
    .replace(/relmw:WikiLink[^>]*>([^<]+)<\/a>/g, '$1')
    .replace(/relmw:WikiLink[^>]*href[^>]*title[^>]*>([^<]+)<\/a>/g, '$1')
    // Remove other wiki markup
    .replace(/{{[^}]+}}/g, '') // Remove templates
    .replace(/'{2,3}([^']*)'{2,3}/g, '$1') // Remove bold/italic markup
    .replace(/<[^>]+>/g, '') // Remove HTML tags
    .replace(/&[a-zA-Z0-9#]+;/g, '') // Remove HTML entities
    // Clean up extra whitespace
    .replace(/\s+/g, ' ')
    .trim();
  
  return cleaned;
}

// Function to validate content quality
function validateContentQuality(term: string, definition: string, examples: string[]): boolean {
  // Check for inappropriate content
  const inappropriateWords = ['crap', 'bull-dike', 'troll', 'tears', 'shame', 'grave'];
  const textToCheck = `${term} ${definition} ${examples.join(' ')}`.toLowerCase();
  
  if (inappropriateWords.some(word => textToCheck.includes(word))) {
    console.warn(`Inappropriate content detected for term: ${term}`);
    return false;
  }
  
  // Check for wiki markup pollution
  if (definition.includes('relmw:') || definition.includes('href') || definition.includes('titlew:')) {
    console.warn(`Wiki markup pollution detected for term: ${term}`);
    return false;
  }
  
  // Check for reasonable definition length
  if (definition.length < 10 || definition.length > 1000) {
    console.warn(`Invalid definition length for term: ${term}`);
    return false;
  }
  
  // Check for relevance (basic check)
  if (definition.toLowerCase().includes('world war') && !term.toLowerCase().includes('war')) {
    console.warn(`Irrelevant content detected for term: ${term}`);
    return false;
  }
  
  return true;
}

