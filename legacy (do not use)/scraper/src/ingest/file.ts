import fs from 'node:fs/promises';

import { fileTypeFromBuffer } from 'file-type';
import mammoth from 'mammoth';
import pdf from 'pdf-parse';

import type { IngestResult } from './types';

export async function fetchFile(path: string): Promise<IngestResult> {
  const buf = await fs.readFile(path);
  const ft = await fileTypeFromBuffer(buf);
  
  if (ft?.mime === 'application/pdf') {
    const result = await pdf(buf);
    return { text: result.text };
  }
  
  if (
    ft?.mime ===
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ) {
    const result = await mammoth.extractRawText({ buffer: buf });
    return { text: result.value };
  }
  
  return { text: buf.toString('utf-8') };
}
