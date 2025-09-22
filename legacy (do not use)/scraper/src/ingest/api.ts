import fetch from 'node-fetch';

import type { IngestResult } from './types';

/**
 * Wiktionary API configuration
 */
const WIKTIONARY_API_BASE = 'https://en.wiktionary.org/w/api.php';
const USER_AGENT = 'LarryVocabApp/1.0 (https://larry-vocab.com; contact@larry-vocab.com)';

/**
 * Wikipedia API configuration  
 */
const WIKIPEDIA_API_BASE = 'https://en.wikipedia.org/w/api.php';

/**
 * Enhanced API fetcher with specialized handlers for known sources
 */
export async function fetchApi(url: string): Promise<IngestResult> {
  try {
    // Detect source type and use specialized handler
    if (isWiktionaryUrl(url)) {
      return fetchWiktionaryEntry(url);
    } else if (isWikipediaUrl(url)) {
      return fetchWikipediaArticle(url);
    } else {
      // Generic API endpoint
      return fetchGenericApi(url);
    }
  } catch (error) {
    console.error(`[API] Failed to fetch ${url}:`, error);
    return {
      text: `Error fetching ${url}: ${error instanceof Error ? error.message : 'Unknown error'}`,
      title: 'Fetch Error',
    };
  }
}

/**
 * Fetch a Wiktionary entry using the MediaWiki API
 */
async function fetchWiktionaryEntry(url: string): Promise<IngestResult> {
  const term = extractTermFromWiktionaryUrl(url);
  
  console.log(`[WIKTIONARY] Fetching definition for: ${term}`);
  
  // Use MediaWiki API to get page content
  const apiUrl = new URL(WIKTIONARY_API_BASE);
  apiUrl.searchParams.set('action', 'query');
  apiUrl.searchParams.set('format', 'json');
  apiUrl.searchParams.set('titles', term);
  apiUrl.searchParams.set('prop', 'revisions|extracts');
  apiUrl.searchParams.set('rvprop', 'content');
  apiUrl.searchParams.set('exintro', '1');
  apiUrl.searchParams.set('explaintext', '1');
  apiUrl.searchParams.set('exsectionformat', 'plain');
  
  const response = await fetch(apiUrl.toString(), {
    headers: { 'User-Agent': USER_AGENT },
  });
  
  const data = await response.json();
  const pages = data.query?.pages || {};
  const page = Object.values(pages)[0] as any;
  
  if (!page || page.missing) {
    return {
      text: `No Wiktionary entry found for "${term}"`,
      title: `${term} (not found)`,
    };
  }
  
  // Extract content
  const wikitext = page.revisions?.[0]?.['*'] || '';
  const extract = page.extract || '';
  
  // Parse wikitext for definitions
  const definitions = parseWiktionaryContent(wikitext, term);
  
  // Combine extract and parsed definitions
  const text = [
    extract,
    ...definitions,
  ].filter(Boolean).join('\n\n');
  
  console.log(`[WIKTIONARY] ✅ Extracted ${definitions.length} definitions for: ${term}`);
  
  return {
    text: text || `Wiktionary entry for ${term} (no content extracted)`,
    title: `${term} (Wiktionary)`,
    author: 'Wiktionary contributors',
  };
}

/**
 * Fetch a Wikipedia article using the MediaWiki API
 */
async function fetchWikipediaArticle(url: string): Promise<IngestResult> {
  const title = extractTitleFromWikipediaUrl(url);
  
  console.log(`[WIKIPEDIA] Fetching article: ${title}`);
  
  const apiUrl = new URL(WIKIPEDIA_API_BASE);
  apiUrl.searchParams.set('action', 'query');
  apiUrl.searchParams.set('format', 'json');
  apiUrl.searchParams.set('titles', title);
  apiUrl.searchParams.set('prop', 'extracts');
  apiUrl.searchParams.set('exintro', '1');
  apiUrl.searchParams.set('explaintext', '1');
  apiUrl.searchParams.set('exsectionformat', 'plain');
  
  const response = await fetch(apiUrl.toString(), {
    headers: { 'User-Agent': USER_AGENT },
  });
  
  const data = await response.json();
  const pages = data.query?.pages || {};
  const page = Object.values(pages)[0] as any;
  
  if (!page || page.missing) {
    return {
      text: `No Wikipedia article found for "${title}"`,
      title: `${title} (not found)`,
    };
  }
  
  const extract = page.extract || '';
  
  console.log(`[WIKIPEDIA] ✅ Extracted article: ${title} (${extract.length} chars)`);
  
  return {
    text: extract || `Wikipedia article for ${title} (no content extracted)`,
    title: `${title} (Wikipedia)`,
    author: 'Wikipedia contributors',
  };
}

/**
 * Generic API endpoint handler
 */
async function fetchGenericApi(url: string): Promise<IngestResult> {
  console.log(`[API] Fetching generic endpoint: ${url}`);
  
  const response = await fetch(url, {
    headers: { 'User-Agent': USER_AGENT },
  });
  
  const data = await response.json().catch(() => ({}));
  const text = typeof data === 'string' ? data : JSON.stringify(data, null, 2);
  
  return {
    text,
    title: `API Response from ${new URL(url).hostname}`,
  };
}

/**
 * Parse Wiktionary wikitext to extract definitions
 */
function parseWiktionaryContent(wikitext: string, term: string): string[] {
  const definitions: string[] = [];
  
  if (!wikitext) return definitions;
  
  // Split into sections
  const lines = wikitext.split('\n');
  let inEnglishSection = false;
  let currentSection = '';
  
  for (const line of lines) {
    // Check for language section headers
    if (line.match(/^==[^=].*English.*[^=]==$/) || line.match(/^==[^=].*english.*[^=]==$/i)) {
      inEnglishSection = true;
      currentSection = 'English';
      continue;
    }
    
    // Check for other language sections (exit English)
    if (line.match(/^==[^=].*[^=]==$/) && !line.includes('English')) {
      inEnglishSection = false;
      continue;
    }
    
    // Skip if not in English section
    if (!inEnglishSection) continue;
    
    // Extract definitions (lines starting with # in definition contexts)
    if (line.match(/^#+\s+/)) {
      const definition = line
        .replace(/^#+\s+/, '') // Remove # markers
        .replace(/\{\{[^}]*\}\}/g, '') // Remove templates
        .replace(/\[\[([^|\]]*)\|?[^\]]*\]\]/g, '$1') // Convert wiki links
        .replace(/'''([^']*)'''/g, '$1') // Remove bold formatting
        .replace(/''([^']*)'/g, '$1') // Remove italic formatting
        .trim();
      
      if (definition && definition.length > 10) {
        definitions.push(`${term} definition: ${definition}`);
      }
    }
    
    // Extract example sentences (lines with quotes or example indicators)
    if (line.match(/:+\s*['"""]/)) {
      const example = line
        .replace(/^:+\s*/, '') // Remove colons
        .replace(/['"""]([^'"""]*)['""]/, '$1') // Extract quoted content
        .trim();
      
      if (example && example.length > 10) {
        definitions.push(`Example: ${example}`);
      }
    }
  }
  
  return definitions;
}

/**
 * URL detection and parsing helpers
 */
function isWiktionaryUrl(url: string): boolean {
  return url.includes('wiktionary.org');
}

function isWikipediaUrl(url: string): boolean {
  return url.includes('wikipedia.org');
}

function extractTermFromWiktionaryUrl(url: string): string {
  const match = url.match(/\/wiki\/([^/?#]+)/);
  if (match) {
    return decodeURIComponent(match[1].replace(/_/g, ' '));
  }
  
  // Fallback: extract from URL structure
  const urlObj = new URL(url);
  const pathParts = urlObj.pathname.split('/');
  return pathParts[pathParts.length - 1].replace(/_/g, ' ');
}

function extractTitleFromWikipediaUrl(url: string): string {
  const match = url.match(/\/wiki\/([^/?#]+)/);
  if (match) {
    return decodeURIComponent(match[1].replace(/_/g, ' '));
  }
  
  // Fallback: extract from URL structure
  const urlObj = new URL(url);
  const pathParts = urlObj.pathname.split('/');
  return pathParts[pathParts.length - 1].replace(/_/g, ' ');
}
