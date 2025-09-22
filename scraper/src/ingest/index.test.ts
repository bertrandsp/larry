import { describe, it, expect, vi } from 'vitest';

import type { Source } from '../types/source';

import { ingest, SourceType } from './index';

// Mock the individual fetchers
vi.mock('./html', () => ({
  fetchHtml: vi.fn().mockResolvedValue({ text: 'HTML content', title: 'Test Page' })
}));

vi.mock('./rss', () => ({
  fetchRss: vi.fn().mockResolvedValue({ text: 'RSS content' })
}));

vi.mock('./api', () => ({
  fetchApi: vi.fn().mockResolvedValue({ text: 'API content' })
}));

vi.mock('./file', () => ({
  fetchFile: vi.fn().mockResolvedValue({ text: 'File content' })
}));

describe('Ingest Router', () => {
  it('should route to HTML fetcher for html source type', async () => {
    const source: Source = {
      id: '1',
      type: SourceType.html,
      name: 'Test HTML Source',
    };

    const result = await ingest(source, 'https://example.com');
    
    expect(result.text).toBe('HTML content');
    expect(result.title).toBe('Test Page');
  });

  it('should route to RSS fetcher for rss source type', async () => {
    const source: Source = {
      id: '2',
      type: SourceType.rss,
      name: 'Test RSS Source',
    };

    const result = await ingest(source, 'https://example.com/rss');
    
    expect(result.text).toBe('RSS content');
  });

  it('should route to API fetcher for api source type', async () => {
    const source: Source = {
      id: '3',
      type: SourceType.api,
      name: 'Test API Source',
    };

    const result = await ingest(source, 'https://api.example.com');
    
    expect(result.text).toBe('API content');
  });

  it('should route to file fetcher for file source type', async () => {
    const source: Source = {
      id: '4',
      type: SourceType.file,
      name: 'Test File Source',
    };

    const result = await ingest(source, '/path/to/file.txt');
    
    expect(result.text).toBe('File content');
  });

  it('should default to HTML fetcher for unknown source type', async () => {
    const source: Source = {
      id: '5',
      type: 'unknown' as SourceType,
      name: 'Unknown Source',
    };

    const result = await ingest(source, 'https://example.com');
    
    expect(result.text).toBe('HTML content');
  });

  it('should handle API content properly', async () => {
    const source: Source = {
      id: '6',
      type: SourceType.api,
      name: 'Test API Source for content',
    };

    const result = await ingest(source, 'https://api.example.com');
    
    // Should return the mocked API content
    expect(result.text).toBe('API content');
  });
});
