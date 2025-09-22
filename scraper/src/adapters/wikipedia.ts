import { SourceAdapter, Doc } from '../types/base';
import { SourceMetadata } from '../types/miner';
import { backoffRetry } from '../utils/backoff';
import { normalizeText } from '../utils/normalize';

interface WikipediaSearchResult {
  query: {
    search: Array<{
      pageid: number;
      title: string;
      snippet: string;
    }>;
  };
}

interface WikipediaPageResult {
  query: {
    pages: {
      [key: string]: {
        pageid: number;
        title: string;
        extract: string;
        categories?: Array<{
          title: string;
        }>;
      };
    };
  };
}

interface WiktionaryParseResult {
  parse: {
    title: string;
    pageid: number;
    text: {
      '*': string;
    };
    categories: Array<{
      '*': string;
    }>;
  };
}

/**
 * Wikipedia API Adapter
 * Uses the official Wikipedia REST API for content discovery and fetching
 */
export class WikipediaAdapter implements SourceAdapter {
  private readonly baseUrl = 'https://en.wikipedia.org/api/rest_v1';
  private readonly apiUrl = 'https://en.wikipedia.org/w/api.php';
  private readonly userAgent = 'Larry-VocabApp/1.0 (https://github.com/your-org/larry)';

  async discover(topic: string, maxResults = 10): Promise<SourceMetadata[]> {
    try {
      console.log(`[WIKIPEDIA] Discovering content for topic: ${topic}`);
      
      const searchUrl = new URL(this.apiUrl);
      searchUrl.searchParams.set('action', 'query');
      searchUrl.searchParams.set('list', 'search');
      searchUrl.searchParams.set('srsearch', topic);
      searchUrl.searchParams.set('srlimit', maxResults.toString());
      searchUrl.searchParams.set('format', 'json');
      searchUrl.searchParams.set('origin', '*');

      const response = await backoffRetry(async () => {
        const res = await fetch(searchUrl.toString(), {
          headers: {
            'User-Agent': this.userAgent,
            'Accept': 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Wikipedia API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<WikipediaSearchResult>;
      });

      const sources: SourceMetadata[] = response.query.search.map(page => ({
        url: `https://en.wikipedia.org/wiki/${encodeURIComponent(page.title.replace(/ /g, '_'))}`,
        title: page.title,
        snippet: page.snippet.replace(/<[^>]*>/g, ''), // Remove HTML tags
        publishedAt: undefined, // Wikipedia doesn't provide creation dates in search
        source: 'wikipedia',
        type: 'html' as const,
        reliability: 0.9, // Wikipedia is generally reliable
        industry: this.categorizeIndustry(page.title, page.snippet),
        metadata: {
          pageId: page.pageid.toString(),
          wordCount: this.estimateWordCount(page.snippet),
        },
      }));

      console.log(`[WIKIPEDIA] Found ${sources.length} sources for topic: ${topic}`);
      return sources;
    } catch (error) {
      console.error(`[WIKIPEDIA] Discovery failed for topic "${topic}":`, error);
      return [];
    }
  }

  async fetch(url: string, context?: string): Promise<Doc | null> {
    try {
      console.log(`[WIKIPEDIA] Fetching content from: ${url}`);
      
      // Extract page title from URL
      const urlObj = new URL(url);
      const title = decodeURIComponent(urlObj.pathname.split('/wiki/')[1]?.replace(/_/g, ' ') || '');
      
      if (!title) {
        throw new Error('Could not extract page title from URL');
      }

      // Use Wikipedia API to get clean extract
      const apiUrl = new URL(this.apiUrl);
      apiUrl.searchParams.set('action', 'query');
      apiUrl.searchParams.set('prop', 'extracts|categories');
      apiUrl.searchParams.set('titles', title);
      apiUrl.searchParams.set('exintro', '0'); // Get full content, not just intro
      apiUrl.searchParams.set('explaintext', '1'); // Plain text, no HTML
      apiUrl.searchParams.set('exsectionformat', 'wiki'); // Include section headers
      apiUrl.searchParams.set('format', 'json');
      apiUrl.searchParams.set('origin', '*');

      const response = await backoffRetry(async () => {
        const res = await fetch(apiUrl.toString(), {
          headers: {
            'User-Agent': this.userAgent,
            'Accept': 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Wikipedia API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<WikipediaPageResult>;
      });

      const pages = response.query.pages;
      const page = Object.values(pages)[0];

      if (!page || !page.extract) {
        console.warn(`[WIKIPEDIA] No content found for: ${title}`);
        return null;
      }

      // Extract categories for additional metadata
      const categories = page.categories?.map(cat => cat.title.replace('Category:', '')) || [];
      const industry = this.categorizeIndustry(page.title, page.extract, categories);

      const doc: Doc = {
        url,
        title: page.title,
        content: normalizeText(page.extract),
        contentHash: this.generateContentHash(page.extract),
        source: 'wikipedia',
        sourceReliability: 0.9,
        sourceIndustry: industry,
        extractedAt: new Date(),
        metadata: {
          pageId: page.pageid.toString(),
          categories: categories.slice(0, 10), // Limit categories
          wordCount: this.estimateWordCount(page.extract),
          language: 'en',
        },
      };

      console.log(`[WIKIPEDIA] Successfully fetched: ${page.title} (${doc.metadata.wordCount} words)`);
      return doc;
    } catch (error) {
      console.error(`[WIKIPEDIA] Fetch failed for URL "${url}":`, error);
      return null;
    }
  }

  private categorizeIndustry(title: string, content: string, categories?: string[]): string {
    const text = `${title} ${content} ${categories?.join(' ') || ''}`.toLowerCase();
    
    // Industry classification based on content analysis
    const industries = {
      'technology': ['technology', 'computer', 'software', 'programming', 'algorithm', 'artificial intelligence', 'machine learning'],
      'science': ['science', 'physics', 'chemistry', 'biology', 'research', 'scientific', 'laboratory'],
      'medicine': ['medicine', 'medical', 'health', 'disease', 'treatment', 'hospital', 'patient'],
      'finance': ['finance', 'economics', 'banking', 'investment', 'money', 'financial', 'market'],
      'education': ['education', 'school', 'university', 'learning', 'academic', 'student', 'teaching'],
      'arts': ['art', 'music', 'literature', 'painting', 'culture', 'creative', 'artistic'],
      'history': ['history', 'historical', 'ancient', 'war', 'empire', 'civilization'],
      'geography': ['geography', 'country', 'city', 'mountain', 'river', 'continent'],
      'sports': ['sport', 'game', 'team', 'player', 'competition', 'athletic'],
    };

    for (const [industry, keywords] of Object.entries(industries)) {
      if (keywords.some(keyword => text.includes(keyword))) {
        return industry;
      }
    }

    return 'general';
  }

  private estimateWordCount(text: string): number {
    return text.split(/\s+/).filter(word => word.length > 0).length;
  }

  private generateContentHash(content: string): string {
    // Simple hash function for content deduplication
    let hash = 0;
    for (let i = 0; i < content.length; i++) {
      const char = content.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash).toString(36);
  }
}

/**
 * Wiktionary API Adapter
 * Specialized for dictionary and etymology content
 */
export class WiktionaryAdapter implements SourceAdapter {
  private readonly apiUrl = 'https://en.wiktionary.org/w/api.php';
  private readonly userAgent = 'Larry-VocabApp/1.0 (https://github.com/your-org/larry)';

  async discover(topic: string, maxResults = 10): Promise<SourceMetadata[]> {
    try {
      console.log(`[WIKTIONARY] Discovering definitions for topic: ${topic}`);
      
      // Search for terms related to the topic
      const searchUrl = new URL(this.apiUrl);
      searchUrl.searchParams.set('action', 'query');
      searchUrl.searchParams.set('list', 'search');
      searchUrl.searchParams.set('srsearch', `${topic} OR "${topic}"`);
      searchUrl.searchParams.set('srlimit', maxResults.toString());
      searchUrl.searchParams.set('srnamespace', '0'); // Main namespace only
      searchUrl.searchParams.set('format', 'json');
      searchUrl.searchParams.set('origin', '*');

      const response = await backoffRetry(async () => {
        const res = await fetch(searchUrl.toString(), {
          headers: {
            'User-Agent': this.userAgent,
            'Accept': 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Wiktionary API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<WikipediaSearchResult>;
      });

      const sources: SourceMetadata[] = response.query.search.map(page => ({
        url: `https://en.wiktionary.org/wiki/${encodeURIComponent(page.title.replace(/ /g, '_'))}`,
        title: page.title,
        snippet: page.snippet.replace(/<[^>]*>/g, ''),
        publishedAt: undefined,
        source: 'wiktionary',
        type: 'html' as const,
        reliability: 0.95, // Wiktionary is very reliable for definitions
        industry: 'language',
        metadata: {
          pageId: page.pageid.toString(),
          isDefinition: true,
          wordCount: this.estimateWordCount(page.snippet),
        },
      }));

      console.log(`[WIKTIONARY] Found ${sources.length} definitions for topic: ${topic}`);
      return sources;
    } catch (error) {
      console.error(`[WIKTIONARY] Discovery failed for topic "${topic}":`, error);
      return [];
    }
  }

  async fetch(url: string, context?: string): Promise<Doc | null> {
    try {
      console.log(`[WIKTIONARY] Fetching definition from: ${url}`);
      
      // Extract page title from URL
      const urlObj = new URL(url);
      const title = decodeURIComponent(urlObj.pathname.split('/wiki/')[1]?.replace(/_/g, ' ') || '');
      
      if (!title) {
        throw new Error('Could not extract page title from URL');
      }

      // Use Wiktionary API to get parsed content
      const apiUrl = new URL(this.apiUrl);
      apiUrl.searchParams.set('action', 'parse');
      apiUrl.searchParams.set('page', title);
      apiUrl.searchParams.set('prop', 'text|categories');
      apiUrl.searchParams.set('format', 'json');
      apiUrl.searchParams.set('origin', '*');
      apiUrl.searchParams.set('disablelimitreport', '1');

      const response = await backoffRetry(async () => {
        const res = await fetch(apiUrl.toString(), {
          headers: {
            'User-Agent': this.userAgent,
            'Accept': 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Wiktionary API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<WiktionaryParseResult>;
      });

      if (!response.parse || !response.parse.text) {
        console.warn(`[WIKTIONARY] No content found for: ${title}`);
        return null;
      }

      // Extract plain text from HTML (Wiktionary returns HTML)
      const htmlContent = response.parse.text['*'];
      const plainText = this.extractTextFromWiktionaryHTML(htmlContent);

      if (!plainText || plainText.length < 50) {
        console.warn(`[WIKTIONARY] Insufficient content for: ${title}`);
        return null;
      }

      const doc: Doc = {
        url,
        title: response.parse.title,
        content: normalizeText(plainText),
        contentHash: this.generateContentHash(plainText),
        source: 'wiktionary',
        sourceReliability: 0.95,
        sourceIndustry: 'language',
        extractedAt: new Date(),
        metadata: {
          pageId: response.parse.pageid.toString(),
          categories: response.parse.categories?.map(cat => cat['*']) || [],
          wordCount: this.estimateWordCount(plainText),
          language: 'en',
          isDefinition: true,
        },
      };

      console.log(`[WIKTIONARY] Successfully fetched: ${response.parse.title} (${doc.metadata.wordCount} words)`);
      return doc;
    } catch (error) {
      console.error(`[WIKTIONARY] Fetch failed for URL "${url}":`, error);
      return null;
    }
  }

  private extractTextFromWiktionaryHTML(html: string): string {
    // Remove HTML tags and extract meaningful content
    // This is a simplified version - in production, you might want to use a proper HTML parser
    return html
      .replace(/<script[^>]*>.*?<\/script>/gis, '') // Remove scripts
      .replace(/<style[^>]*>.*?<\/style>/gis, '') // Remove styles
      .replace(/<[^>]*>/g, ' ') // Remove all HTML tags
      .replace(/&[^;]+;/g, ' ') // Remove HTML entities
      .replace(/\s+/g, ' ') // Normalize whitespace
      .trim();
  }

  private estimateWordCount(text: string): number {
    return text.split(/\s+/).filter(word => word.length > 0).length;
  }

  private generateContentHash(content: string): string {
    let hash = 0;
    for (let i = 0; i < content.length; i++) {
      const char = content.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(36);
  }
}

// Factory function for easy instantiation
export function createWikipediaAdapter(): WikipediaAdapter {
  return new WikipediaAdapter();
}

export function createWiktionaryAdapter(): WiktionaryAdapter {
  return new WiktionaryAdapter();
}
