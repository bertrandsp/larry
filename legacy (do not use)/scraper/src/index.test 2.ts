import { describe, it, expect } from 'vitest';

import { healthCheck, HttpError } from './index';

describe('Larry Scraper', () => {
  it('should have a working health check', () => {
    const result = healthCheck();
    expect(result.status).toBe('ok');
    expect(result.timestamp).toBeDefined();
  });

  it('should export HttpError utility', () => {
    const error = new HttpError(404, 'Not found');
    expect(error.status).toBe(404);
    expect(error.message).toBe('Not found');
    expect(error).toBeInstanceOf(Error);
  });
});
