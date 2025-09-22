import { Source, SourceType } from '../types/source';

import { fetchHtml } from './html';
import { fetchRss } from './rss';
import { fetchApi } from './api';
import { fetchFile } from './file';
import type { IngestResult } from './types';

export async function ingest(
  source: Source,
  locator: string
): Promise<IngestResult> {
  switch (source.type) {
    case SourceType.html:
      return fetchHtml(locator);
    case SourceType.rss:
      return fetchRss(locator);
    case SourceType.api:
      return fetchApi(locator);
    case SourceType.file:
      return fetchFile(locator);
    default:
      return fetchHtml(locator);
  }
}

// Re-export types and individual fetchers for testing
export type { IngestResult } from './types';
export { fetchHtml, fetchRss, fetchApi, fetchFile };
export { SourceType } from '../types/source';
