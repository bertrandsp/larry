import fetch from 'node-fetch';
import { Readability } from '@mozilla/readability';
import { JSDOM } from 'jsdom';

import type { IngestResult } from './types';

export async function fetchHtml(url: string): Promise<IngestResult> {
  const res = await fetch(url, {
    headers: { 'user-agent': 'LarryMiner/0.1' },
  });
  const raw = await res.text();
  
  try {
    const dom = new JSDOM(raw, { url });
    const reader = new Readability(dom.window.document);
    const article = reader.parse();
    
    return {
      text: article?.textContent || raw,
      title: article?.title || undefined,
    };
  } catch {
    // Fall back to raw HTML if parsing fails
    return {
      text: raw,
      title: undefined,
    };
  }
}
