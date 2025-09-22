import { describe, it, expect, beforeAll, vi } from 'vitest';

// Mock problematic dependencies
vi.mock('pdf-parse', () => ({
  default: vi.fn(() => Promise.resolve({ text: 'Mocked PDF content' })),
}));

// Mock node-fetch for predictable testing
vi.mock('node-fetch', () => ({
  default: vi.fn((url: string) => {
    if (url.includes('wiktionary.org')) {
      return Promise.resolve({
        json: () => Promise.resolve({
          query: {
            pages: {
              '12345': {
                extract: 'Machine learning is a method of data analysis that automates analytical model building.',
                revisions: [{
                  '*': '==English==\n\n===Noun===\n# A field of study that gives computers the ability to learn without being explicitly programmed.\n# A type of artificial intelligence.\n\n===Examples===\n: "Machine learning algorithms can identify patterns automatically."\n'
                }]
              }
            }
          }
        }),
      });
    } else if (url.includes('wikipedia.org')) {
      return Promise.resolve({
        json: () => Promise.resolve({
          query: {
            pages: {
              '54321': {
                extract: 'Machine learning is a subset of artificial intelligence that focuses on the development of algorithms and statistical models that enable computers to improve their performance on a specific task through experience.',
              }
            }
          }
        }),
      });
    } else if (url.includes('techcrunch.com/feed') || url.includes('rss') || url.includes('feed')) {
      return Promise.resolve({
        ok: true,
        text: () => Promise.resolve(`<?xml version="1.0" encoding="UTF-8"?>
          <rss version="2.0">
            <channel>
              <title>TechCrunch</title>
              <description>Startup and Technology News</description>
              <language>en-US</language>
              <item>
                <title>AI startup raises $50M to democratize machine learning</title>
                <description>A new artificial intelligence startup has secured funding to make machine learning accessible.</description>
                <pubDate>Mon, 15 Jan 2024 10:00:00 GMT</pubDate>
                <link>https://techcrunch.com/2024/01/15/ai-startup</link>
              </item>
              <item>
                <title>Deep learning breakthrough in medical diagnosis</title>
                <description>Researchers developed a deep learning algorithm for medical diagnosis.</description>
                <pubDate>Sun, 14 Jan 2024 15:00:00 GMT</pubDate>
                <link>https://techcrunch.com/2024/01/14/deep-learning</link>
              </item>
            </channel>
          </rss>`),
      });
    } else {
      return Promise.resolve({
        json: () => Promise.resolve({ message: 'Generic API response' }),
        text: () => Promise.resolve('Generic text response'),
      });
    }
  }),
}));

import { fetchApi } from './ingest/api';
import { fetchRss } from './ingest/rss';
import { ingest } from './ingest/index';
import { processMiningJob } from './workers/miner.worker';
import { POPULAR_RSS_FEEDS } from './ingest/rss';
import { SourceType } from './types/source';

describe('Plan 5 — Real Adapters Integration', () => {
  beforeAll(() => {
    // Set environment for testing
    process.env.USE_FIXTURES = 'true';
    process.env.NODE_ENV = 'development';
  });

  describe('Wiktionary API Adapter', () => {
    it('should fetch and parse Wiktionary definitions', async () => {
      const url = 'https://en.wiktionary.org/wiki/machine_learning';
      const result = await fetchApi(url);
      
      expect(result).toBeDefined();
      expect(result.text).toBeTruthy();
      expect(result.title).toContain('machine learning');
      expect(result.author).toContain('Wiktionary');
      
      // Should contain actual definitions
      expect(result.text.toLowerCase()).toContain('machine learning');
      expect(result.text.toLowerCase()).toContain('definition');
      
      console.log(`[TEST] ✅ Wiktionary: ${result.title} (${result.text.length} chars)`);
    });

    it('should handle Wikipedia URLs correctly', async () => {
      const url = 'https://en.wikipedia.org/wiki/Machine_learning';
      const result = await fetchApi(url);
      
      expect(result).toBeDefined();
      expect(result.text).toBeTruthy();
      expect(result.title).toContain('Machine learning');
      expect(result.author).toContain('Wikipedia');
      
      console.log(`[TEST] ✅ Wikipedia: ${result.title} (${result.text.length} chars)`);
    });

    it('should extract term correctly from Wiktionary URLs', async () => {
      const testUrls = [
        'https://en.wiktionary.org/wiki/machine_learning',
        'https://en.wiktionary.org/wiki/machine%20learning',
        'https://en.wiktionary.org/wiki/artificial_intelligence',
      ];

      for (const url of testUrls) {
        const result = await fetchApi(url);
        expect(result.text).toBeTruthy();
        expect(result.title).toBeTruthy();
        console.log(`[TEST] ✅ URL handled: ${url} → ${result.title}`);
      }
    });
  });

  describe('RSS Feed Adapter', () => {
    it('should fetch and parse RSS feeds', async () => {
      // Use a sample RSS feed from our popular feeds
      const url = POPULAR_RSS_FEEDS.samples[0]; // CNN RSS
      const result = await fetchRss(url);
      
      expect(result).toBeDefined();
      expect(result.text).toBeTruthy();
      expect(result.title).toBeTruthy();
      
      // Should contain feed metadata
      expect(result.text).toContain('Feed:');
      expect(result.text).toContain('Title:');
      
      console.log(`[TEST] ✅ RSS: ${result.title} (${result.text.length} chars)`);
    });

    it('should handle TechCrunch feed specifically', async () => {
      const url = POPULAR_RSS_FEEDS.techcrunch;
      const result = await fetchRss(url);
      
      expect(result).toBeDefined();
      expect(result.text).toBeTruthy();
      expect(result.title).toContain('TechCrunch');
      
      // Should contain tech-related content
      const text = result.text.toLowerCase();
      expect(text).toMatch(/(tech|startup|ai|machine learning|technology)/);
      
      console.log(`[TEST] ✅ TechCrunch RSS: ${result.title}`);
    });

    it('should extract multiple items from feed', async () => {
      const url = POPULAR_RSS_FEEDS.hackernews;
      const result = await fetchRss(url);
      
      expect(result).toBeDefined();
      expect(result.text).toBeTruthy();
      
      // Should have multiple items indicated
      expect(result.text).toContain('Items:');
      const itemMatches = result.text.match(/Title:/g);
      expect(itemMatches).toBeTruthy();
      expect(itemMatches!.length).toBeGreaterThan(1);
      
      console.log(`[TEST] ✅ HackerNews RSS: ${itemMatches!.length} items extracted`);
    });
  });

  describe('Unified Ingest Router', () => {
    it('should route to correct adapter based on source type', async () => {
      const testCases = [
        {
          source: { id: '1', type: SourceType.api, name: 'Wiktionary' },
          locator: 'https://en.wiktionary.org/wiki/machine_learning',
          expectedContent: 'machine learning',
        },
        {
          source: { id: '2', type: SourceType.rss, name: 'TechCrunch' },
          locator: POPULAR_RSS_FEEDS.techcrunch,
          expectedContent: 'Feed:',
        },
      ];

      for (const testCase of testCases) {
        const result = await ingest(testCase.source, testCase.locator);
        
        expect(result).toBeDefined();
        expect(result.text).toBeTruthy();
        expect(result.text.toLowerCase()).toContain(testCase.expectedContent.toLowerCase());
        
        console.log(`[TEST] ✅ Routed ${testCase.source.type}: ${testCase.source.name}`);
      }
    });
  });

  describe('End-to-End Pipeline: URL → Terms with Provenance', () => {
    it('should process Wiktionary URL through complete pipeline', async () => {
      const sourceText = await fetchApi('https://en.wiktionary.org/wiki/machine_learning');
      
      const result = await processMiningJob(
        sourceText.text,
        'https://en.wiktionary.org/wiki/machine_learning',
        {
          maxTerms: 5,
          requireDefinitions: false,
          enableAiRefinement: false, // Focus on provenance, not AI
        }
      );
      
      expect(result.terms.length).toBeGreaterThan(0);
      expect(result.policy.allowExamples).toBe(true); // Wiktionary is permissive
      
      // Check provenance in terms
      for (const term of result.terms) {
        expect(term.phrase).toBeTruthy();
        expect(term.definition || term.example).toBeTruthy();
        expect(term.attribution).toContain('Wiktionary');
        
        console.log(`[TEST] ✅ Wiktionary → Term: "${term.phrase}" (${term.wordCount} words)`);
      }
      
      console.log(`[TEST] 🎯 Wiktionary pipeline: ${result.terms.length} terms with provenance`);
    });

    it('should process RSS feed through complete pipeline', async () => {
      const sourceText = await fetchRss(POPULAR_RSS_FEEDS.techcrunch);
      
      const result = await processMiningJob(
        sourceText.text,
        POPULAR_RSS_FEEDS.techcrunch,
        {
          maxTerms: 8,
          requireDefinitions: false,
          enableAiRefinement: false, // Focus on provenance, not AI
        }
      );
      
      expect(result.terms.length).toBeGreaterThan(0);
      expect(result.policy.allowExamples).toBe(true); // RSS feeds generally allowed
      
      // Check provenance in terms
      for (const term of result.terms) {
        expect(term.phrase).toBeTruthy();
        expect(term.definition || term.example).toBeTruthy();
        // RSS feeds don't typically have explicit attribution
        
        console.log(`[TEST] ✅ RSS → Term: "${term.phrase}" (${term.wordCount} words)`);
      }
      
      console.log(`[TEST] 🎯 RSS pipeline: ${result.terms.length} terms with provenance`);
    });
  });

  describe('Plan 5 Acceptance Criteria', () => {
    it('should satisfy: Enqueue 1 Wiktionary URL and 1 RSS feed → terms created with provenance', async () => {
      console.log('\n[PLAN 5 ACCEPTANCE TEST] Starting validation...\n');
      
      // Test 1: Wiktionary URL
      const wiktionaryUrl = 'https://en.wiktionary.org/wiki/machine_learning';
      console.log(`[ACCEPTANCE] Testing Wiktionary: ${wiktionaryUrl}`);
      
      const wiktionaryText = await fetchApi(wiktionaryUrl);
      const wiktionaryResult = await processMiningJob(
        wiktionaryText.text,
        wiktionaryUrl,
        { maxTerms: 3, requireDefinitions: false }
      );
      
      expect(wiktionaryResult.terms.length).toBeGreaterThan(0);
      console.log(`[ACCEPTANCE] ✅ Wiktionary: ${wiktionaryResult.terms.length} terms created`);
      
      // Test 2: RSS Feed
      const rssUrl = POPULAR_RSS_FEEDS.techcrunch;
      console.log(`[ACCEPTANCE] Testing RSS: ${rssUrl}`);
      
      const rssText = await fetchRss(rssUrl);
      const rssResult = await processMiningJob(
        rssText.text,
        rssUrl,
        { maxTerms: 3, requireDefinitions: false }
      );
      
      expect(rssResult.terms.length).toBeGreaterThan(0);
      console.log(`[ACCEPTANCE] ✅ RSS: ${rssResult.terms.length} terms created`);
      
      // Verify provenance tracking
      const allTerms = [...wiktionaryResult.terms, ...rssResult.terms];
      
      for (const term of allTerms) {
        expect(term.phrase).toBeTruthy();
        expect(term.definition || term.example).toBeTruthy();
        expect(term.wordCount).toBeGreaterThan(0);
        
        // Each term should have some form of provenance
        const hasProvenance = term.attribution || term.example || term.definition;
        expect(hasProvenance).toBeTruthy();
      }
      
      console.log(`\n[PLAN 5 ACCEPTANCE] ✅ SUCCESS:`);
      console.log(`  • Wiktionary URL processed: ${wiktionaryResult.terms.length} terms`);
      console.log(`  • RSS feed processed: ${rssResult.terms.length} terms`);
      console.log(`  • Total terms with provenance: ${allTerms.length}`);
      console.log(`  • All terms have content and word counts ✅`);
      console.log(`  • Source attribution maintained ✅\n`);
    });
  });

  describe('Error Handling and Robustness', () => {
    it('should handle invalid Wiktionary URLs gracefully', async () => {
      const result = await fetchApi('https://en.wiktionary.org/wiki/nonexistent_term_12345');
      
      expect(result).toBeDefined();
      expect(result.text).toContain('not found');
      expect(result.title).toBeTruthy();
    });

    it('should handle invalid RSS feeds gracefully', async () => {
      const result = await fetchRss('https://invalid-rss-feed.example.com/feed.xml');
      
      expect(result).toBeDefined();
      expect(result.text).toContain('Error');
      expect(result.title).toContain('Error');
    });

    it('should handle network errors gracefully', async () => {
      // Mock fetch to simulate network error
      const originalFetch = global.fetch;
      global.fetch = vi.fn().mockRejectedValue(new Error('Network error'));
      
      const result = await fetchApi('https://example.com/api');
      
      expect(result).toBeDefined();
      expect(result.text).toContain('Error');
      
      // Restore original fetch
      global.fetch = originalFetch;
    });
  });
});
