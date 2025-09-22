/**
 * Development fixtures for testing real adapters
 * 
 * These fixtures provide realistic data for development and testing
 * without making actual network requests to external services.
 */

import wiktionaryMachineLearning from './wiktionary-machine-learning.json';
import rssTechcrunch from './rss-techcrunch.json';

import type { IngestResult } from '../ingest/types';

/**
 * Available fixtures for testing
 */
export const FIXTURES = {
  wiktionary: {
    'machine_learning': wiktionaryMachineLearning,
  },
  rss: {
    'techcrunch': rssTechcrunch,
  },
} as const;

/**
 * Fixture-based data fetcher for development
 */
export async function fetchFromFixture(
  source: 'wiktionary' | 'rss',
  key: string
): Promise<IngestResult | null> {
  const fixture = (FIXTURES as any)[source]?.[key];
  
  if (!fixture) {
    console.warn(`[FIXTURE] No fixture found for ${source}:${key}`);
    return null;
  }
  
  console.log(`[FIXTURE] Loading ${source}:${key} from fixture`);
  
  // Simulate network delay
  await new Promise(resolve => setTimeout(resolve, 100));
  
  return fixture.content;
}

/**
 * Check if URL should use fixtures (for development)
 */
export function shouldUseFixture(url: string): boolean {
  return process.env.NODE_ENV === 'development' && process.env.USE_FIXTURES === 'true';
}

/**
 * Get fixture key from URL
 */
export function getFixtureKey(url: string): { source: 'wiktionary' | 'rss'; key: string } | null {
  // Wiktionary URLs
  if (url.includes('wiktionary.org/wiki/machine_learning') || url.includes('machine%20learning')) {
    return { source: 'wiktionary', key: 'machine_learning' };
  }
  
  // RSS feed URLs
  if (url.includes('techcrunch.com/feed')) {
    return { source: 'rss', key: 'techcrunch' };
  }
  
  return null;
}

/**
 * Enhanced fetcher that can use fixtures in development
 */
export async function fetchWithFixtureFallback(
  originalFetcher: (url: string) => Promise<IngestResult>,
  url: string
): Promise<IngestResult> {
  // Try fixture first in development
  if (shouldUseFixture(url)) {
    const fixtureKey = getFixtureKey(url);
    if (fixtureKey) {
      const fixture = await fetchFromFixture(fixtureKey.source, fixtureKey.key);
      if (fixture) {
        return fixture;
      }
    }
  }
  
  // Fallback to original fetcher
  return originalFetcher(url);
}

/**
 * List all available fixtures
 */
export function listFixtures(): Record<string, string[]> {
  return {
    wiktionary: Object.keys(FIXTURES.wiktionary),
    rss: Object.keys(FIXTURES.rss),
  };
}
