import { HttpError } from './util/errors';

/**
 * Larry Scraper Microservice
 * Handles content scraping for vocabulary extraction
 */

console.log('Larry Scraper Microservice starting...');

export { HttpError };

export function healthCheck(): { status: string; timestamp: string } {
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
  };
}
