import { SourceAdapter, Doc } from '../types/base';
import { SourceMetadata } from '../types/miner';
import { backoffRetry } from '../utils/backoff';
import { normalizeText } from '../utils/normalize';

interface UrbanDictionaryResponse {
  list: Array<{
    definition: string;
    permalink: string;
    thumbs_up: number;
    author: string;
    word: string;
    defid: number;
    current_vote: string;
    written_on: string;
    example: string;
    thumbs_down: number;
  }>;
}

/**
 * Urban Dictionary API Adapter
 * Uses Urban Dictionary API for slang and informal language definitions
 * 
 * Note: Use this adapter carefully as Urban Dictionary contains user-generated
 * content that may not be suitable for all audiences or professional contexts
 */
export class UrbanDictionaryAdapter implements SourceAdapter {
  private readonly baseUrl = 'https://api.urbandictionary.com/v0';
  private readonly minUpvotes = 5; // Minimum upvotes for quality filtering
  private readonly maxResults = 10;

  async discover(topic: string, maxResults = 5): Promise<SourceMetadata[]> {
    try {
      console.log(`[URBANDICTIONARY] Discovering definitions for topic: ${topic}`);
      
      const searchUrl = new URL(`${this.baseUrl}/define`);
      searchUrl.searchParams.set('term', topic);

      const response = await backoffRetry(async () => {
        const res = await fetch(searchUrl.toString());

        if (!res.ok) {
          throw new Error(`Urban Dictionary API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<UrbanDictionaryResponse>;
      });

      if (!response.list || response.list.length === 0) {
        console.log(`[URBANDICTIONARY] No definitions found for topic: ${topic}`);
        return [];
      }

      // Filter and sort by quality
      const qualityDefinitions = response.list
        .filter(def => 
          def.thumbs_up >= this.minUpvotes && // Minimum quality threshold
          def.definition.length > 20 && // Minimum definition length
          def.definition.length < 1000 && // Maximum definition length
          this.passesContentFilter(def.definition, def.example) // Content filtering
        )
        .sort((a, b) => {
          // Sort by quality score (upvotes - downvotes)
          const scoreA = a.thumbs_up - a.thumbs_down;
          const scoreB = b.thumbs_up - b.thumbs_down;
          return scoreB - scoreA;
        })
        .slice(0, Math.min(maxResults, this.maxResults));

      const sources: SourceMetadata[] = qualityDefinitions.map(def => ({
        url: def.permalink,
        title: `${def.word} - Urban Dictionary Definition`,
        snippet: this.truncateText(def.definition, 150),
        publishedAt: new Date(def.written_on),
        source: 'urbandictionary',
        type: 'text' as const,
        reliability: this.calculateReliability(def),
        industry: 'language', // All Urban Dictionary content is language-related
        metadata: {
          defid: def.defid.toString(),
          author: def.author,
          thumbsUp: def.thumbs_up,
          thumbsDown: def.thumbs_down,
          qualityScore: def.thumbs_up - def.thumbs_down,
          wordCount: this.estimateWordCount(def.definition + ' ' + def.example),
          isSlang: true,
        },
      }));

      console.log(`[URBANDICTIONARY] Found ${sources.length} quality definitions for topic: ${topic}`);
      return sources;
    } catch (error) {
      console.error(`[URBANDICTIONARY] Discovery failed for topic "${topic}":`, error);
      return [];
    }
  }

  async fetch(url: string, context?: string): Promise<Doc | null> {
    try {
      console.log(`[URBANDICTIONARY] Fetching definition from: ${url}`);
      
      const defid = this.extractDefinitionId(url);
      if (!defid) {
        throw new Error('Could not extract definition ID from URL');
      }

      // Urban Dictionary doesn't have a direct API for individual definitions by ID
      // We'll need to search for the term and find the matching definition
      // This is a limitation of their API
      
      // For now, we'll extract the term from the URL and search
      const term = this.extractTermFromUrl(url);
      if (!term) {
        throw new Error('Could not extract term from URL');
      }

      const searchUrl = new URL(`${this.baseUrl}/define`);
      searchUrl.searchParams.set('term', term);

      const response = await backoffRetry(async () => {
        const res = await fetch(searchUrl.toString());
        if (!res.ok) {
          throw new Error(`Urban Dictionary API error: ${res.status} ${res.statusText}`);
        }
        return res.json() as Promise<UrbanDictionaryResponse>;
      });

      if (!response.list || response.list.length === 0) {
        console.warn(`[URBANDICTIONARY] No definitions found for term: ${term}`);
        return null;
      }

      // Find the specific definition by ID or take the best one
      let definition = response.list.find(def => def.defid.toString() === defid);
      if (!definition) {
        // If we can't find the exact definition, take the highest rated one
        definition = response.list
          .filter(def => this.passesContentFilter(def.definition, def.example))
          .sort((a, b) => (b.thumbs_up - b.thumbs_down) - (a.thumbs_up - a.thumbs_down))[0];
      }

      if (!definition) {
        console.warn(`[URBANDICTIONARY] No suitable definition found for: ${term}`);
        return null;
      }

      if (!this.passesContentFilter(definition.definition, definition.example)) {
        console.warn(`[URBANDICTIONARY] Definition filtered out due to content: ${definition.defid}`);
        return null;
      }

      const combinedContent = [
        `Word: ${definition.word}`,
        `Definition: ${definition.definition}`,
        definition.example ? `Example: ${definition.example}` : '',
      ].filter(Boolean).join('\n\n');

      const doc: Doc = {
        url,
        title: `${definition.word} - Urban Dictionary`,
        content: normalizeText(combinedContent),
        contentHash: this.generateContentHash(combinedContent),
        source: 'urbandictionary',
        sourceReliability: this.calculateReliability(definition),
        sourceIndustry: 'language',
        extractedAt: new Date(),
        publishedAt: new Date(definition.written_on),
        metadata: {
          defid: definition.defid.toString(),
          author: definition.author,
          thumbsUp: definition.thumbs_up,
          thumbsDown: definition.thumbs_down,
          qualityScore: definition.thumbs_up - definition.thumbs_down,
          wordCount: this.estimateWordCount(combinedContent),
          isSlang: true,
          word: definition.word,
        },
      };

      console.log(`[URBANDICTIONARY] Successfully fetched: ${definition.word} (score: ${doc.metadata.qualityScore})`);
      return doc;
    } catch (error) {
      console.error(`[URBANDICTIONARY] Fetch failed for URL "${url}":`, error);
      return null;
    }
  }

  private extractDefinitionId(url: string): string | null {
    // Extract definition ID from Urban Dictionary URL
    // Example: https://www.urbandictionary.com/define.php?term=example&defid=123456
    const match = url.match(/[?&]defid=(\d+)/);
    return match ? match[1] : null;
  }

  private extractTermFromUrl(url: string): string | null {
    // Extract term from Urban Dictionary URL
    // Example: https://www.urbandictionary.com/define.php?term=example
    const match = url.match(/[?&]term=([^&]*)/);
    return match ? decodeURIComponent(match[1]) : null;
  }

  private passesContentFilter(definition: string, example: string): boolean {
    const content = `${definition} ${example}`.toLowerCase();
    
    // Filter out extremely explicit content (keeping this conservative)
    const blockedTerms = [
      // Add specific terms you want to block
      // Note: This is a basic filter - you may want more sophisticated filtering
    ];

    // Check for blocked terms
    const hasBlockedTerm = blockedTerms.some(term => content.includes(term));
    if (hasBlockedTerm) {
      return false;
    }

    // Filter out definitions that are just complaints or meta-commentary
    const metaIndicators = [
      'this word doesn\'t exist',
      'not a real word',
      'made up',
      'fake word',
      'this definition sucks',
    ];

    const isMeta = metaIndicators.some(indicator => content.includes(indicator));
    if (isMeta) {
      return false;
    }

    // Require minimum content quality
    if (definition.length < 10 || definition.split(' ').length < 3) {
      return false;
    }

    return true;
  }

  private calculateReliability(definition: UrbanDictionaryResponse['list'][0]): number {
    // Urban Dictionary is inherently less reliable than formal dictionaries
    let reliability = 0.3; // Base reliability

    const totalVotes = definition.thumbs_up + definition.thumbs_down;
    const upvoteRatio = totalVotes > 0 ? definition.thumbs_up / totalVotes : 0;

    // Adjust based on community approval
    if (upvoteRatio > 0.8 && totalVotes > 20) reliability += 0.3;
    else if (upvoteRatio > 0.7 && totalVotes > 10) reliability += 0.2;
    else if (upvoteRatio > 0.6 && totalVotes > 5) reliability += 0.1;
    else if (upvoteRatio < 0.5) reliability -= 0.2;

    // Adjust based on definition quality
    if (definition.definition.length > 100 && definition.example) {
      reliability += 0.1;
    }

    // Cap reliability for Urban Dictionary content
    return Math.max(0.1, Math.min(0.6, reliability));
  }

  private truncateText(text: string, maxLength: number): string {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + '...';
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
export function createUrbanDictionaryAdapter(): UrbanDictionaryAdapter {
  return new UrbanDictionaryAdapter();
}
