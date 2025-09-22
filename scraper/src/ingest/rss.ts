import { XMLParser } from 'fast-xml-parser';
import fetch from 'node-fetch';

import type { IngestResult } from './types';

/**
 * RSS/Atom Feed configuration
 */
const USER_AGENT = 'LarryVocabApp/1.0 (https://larry-vocab.com; contact@larry-vocab.com)';
const DEFAULT_ITEM_LIMIT = 10;

/**
 * Feed metadata extracted from RSS/Atom feeds
 */
interface FeedMetadata {
  title?: string;
  description?: string;
  link?: string;
  language?: string;
  lastBuildDate?: string;
  generator?: string;
}

/**
 * Enhanced RSS/Atom feed fetcher with better parsing and metadata extraction
 */
export async function fetchRss(url: string): Promise<IngestResult> {
  try {
    console.log(`[RSS] Fetching feed: ${url}`);
    
    const response = await fetch(url, {
      headers: { 
        'User-Agent': USER_AGENT,
        'Accept': 'application/rss+xml, application/atom+xml, application/xml, text/xml',
      },
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const xml = await response.text();
    
    // Parse XML with enhanced options
    const parser = new XMLParser({ 
      ignoreAttributes: false,
      attributeNamePrefix: '@_',
      parseAttributeValue: true,
      parseTagValue: true,
      trimValues: true,
    });
    
    const feed = parser.parse(xml);
    
    // Detect feed type and extract content
    const isAtom = !!feed.feed;
    const isRss = !!feed.rss;
    
    if (!isAtom && !isRss) {
      throw new Error('Invalid feed format: not RSS or Atom');
    }
    
    const { metadata, items } = isAtom 
      ? parseAtomFeed(feed.feed)
      : parseRssFeed(feed.rss);
    
    const limit = Number(process.env.INGEST_RSS_ITEM_LIMIT) || DEFAULT_ITEM_LIMIT;
    const processedItems = items.slice(0, limit);
    
    // Generate comprehensive text content
    const feedInfo = [
      `Feed: ${metadata.title || 'Unknown'}`,
      metadata.description ? `Description: ${metadata.description}` : '',
      metadata.language ? `Language: ${metadata.language}` : '',
      `Items: ${processedItems.length}/${items.length}`,
    ].filter(Boolean).join('\n');
    
    const itemTexts = processedItems.map(item => formatFeedItem(item));
    
    const fullText = [
      feedInfo,
      '',
      ...itemTexts,
    ].join('\n\n');
    
    console.log(`[RSS] ✅ Processed ${processedItems.length} items from: ${metadata.title || url}`);
    
    return {
      text: fullText,
      title: metadata.title || `RSS Feed from ${new URL(url).hostname}`,
      author: extractFeedAuthor(metadata),
      lang: metadata.language,
      publishedAt: metadata.lastBuildDate ? new Date(metadata.lastBuildDate) : null,
    };
    
  } catch (error) {
    console.error(`[RSS] Failed to fetch ${url}:`, error);
    return {
      text: `Error fetching RSS feed ${url}: ${error instanceof Error ? error.message : 'Unknown error'}`,
      title: 'RSS Fetch Error',
    };
  }
}

/**
 * Parse RSS 2.0 feed structure
 */
function parseRssFeed(rss: any): { metadata: FeedMetadata; items: any[] } {
  const channel = rss.channel || {};
  
  const metadata: FeedMetadata = {
    title: channel.title,
    description: channel.description,
    link: channel.link,
    language: channel.language,
    lastBuildDate: channel.lastBuildDate || channel.pubDate,
    generator: channel.generator,
  };
  
  const items = Array.isArray(channel.item) ? channel.item : [channel.item].filter(Boolean);
  
  return { metadata, items };
}

/**
 * Parse Atom 1.0 feed structure
 */
function parseAtomFeed(atomFeed: any): { metadata: FeedMetadata; items: any[] } {
  const metadata: FeedMetadata = {
    title: atomFeed.title?.['#text'] || atomFeed.title,
    description: atomFeed.subtitle?.['#text'] || atomFeed.subtitle,
    link: extractAtomLink(atomFeed.link),
    language: atomFeed['@_xml:lang'],
    lastBuildDate: atomFeed.updated,
    generator: atomFeed.generator?.['#text'] || atomFeed.generator,
  };
  
  const items = Array.isArray(atomFeed.entry) ? atomFeed.entry : [atomFeed.entry].filter(Boolean);
  
  return { metadata, items };
}

/**
 * Format individual feed item for text extraction
 */
function formatFeedItem(item: any): string {
  // Handle both RSS and Atom formats
  const title = item.title?.['#text'] || item.title || 'Untitled';
  const description = item.description || item.summary?.['#text'] || item.summary || item.content?.['#text'] || item.content;
  const link = item.link?.['@_href'] || item.link;
  const pubDate = item.pubDate || item.published || item.updated;
  const author = item.author?.name || item.author || item['dc:creator'];
  const category = item.category?.['#text'] || item.category;
  
  // Clean up HTML in description
  const cleanDescription = description 
    ? stripHtmlTags(description).substring(0, 500) 
    : '';
  
  const parts = [
    `Title: ${title}`,
    cleanDescription ? `Content: ${cleanDescription}` : '',
    author ? `Author: ${author}` : '',
    category ? `Category: ${category}` : '',
    pubDate ? `Published: ${new Date(pubDate).toISOString().split('T')[0]}` : '',
    link ? `Source: ${link}` : '',
  ].filter(Boolean);
  
  return parts.join('\n');
}

/**
 * Extract feed author information
 */
function extractFeedAuthor(metadata: FeedMetadata): string | undefined {
  if (metadata.title) {
    return `${metadata.title} RSS Feed`;
  }
  return undefined;
}

/**
 * Extract link from Atom link element (can be array or object)
 */
function extractAtomLink(link: any): string | undefined {
  if (!link) return undefined;
  
  if (Array.isArray(link)) {
    // Find first alternate or self link
    const altLink = link.find((l: any) => l['@_rel'] === 'alternate' || l['@_rel'] === 'self');
    return altLink?.['@_href'] || link[0]?.['@_href'];
  }
  
  return link['@_href'] || link;
}

/**
 * Strip HTML tags from text content
 */
function stripHtmlTags(html: string): string {
  return html
    .replace(/<[^>]*>/g, '') // Remove HTML tags
    .replace(/&nbsp;/g, ' ') // Replace &nbsp;
    .replace(/&amp;/g, '&') // Replace &amp;
    .replace(/&lt;/g, '<') // Replace &lt;
    .replace(/&gt;/g, '>') // Replace &gt;
    .replace(/&quot;/g, '"') // Replace &quot;
    .replace(/&#39;/g, "'") // Replace &#39;
    .replace(/\s+/g, ' ') // Normalize whitespace
    .trim();
}

/**
 * Get popular RSS feeds for testing/development
 */
export const POPULAR_RSS_FEEDS = {
  // Technology
  techcrunch: 'https://techcrunch.com/feed/',
  hackernews: 'https://hnrss.org/frontpage',
  arstechnica: 'https://feeds.arstechnica.com/arstechnica/index',
  
  // Science
  sciencedaily: 'https://www.sciencedaily.com/rss/all.xml',
  newscientist: 'https://www.newscientist.com/feed/home/',
  
  // News
  bbc: 'https://feeds.bbci.co.uk/news/rss.xml',
  reuters: 'https://www.reutersagency.com/feed/?taxonomy=best-sectors&post_type=best',
  
  // Learning/Education
  coursera: 'https://blog.coursera.org/feed/',
  khanacademy: 'https://blog.khanacademy.org/feed/',
  
  // Sample feeds for development
  samples: [
    'https://rss.cnn.com/rss/edition.rss',
    'https://feeds.feedburner.com/oreilly/radar',
    'https://www.reddit.com/r/MachineLearning/.rss',
  ],
} as const;
