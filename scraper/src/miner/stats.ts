/**
 * Statistical functions for term ranking and extraction
 */

/**
 * C-value algorithm for multi-word term extraction
 * Higher scores for longer terms that are not substrings of even longer terms
 * 
 * @param phrase - The candidate phrase
 * @param freq - Frequency of this phrase in the corpus
 * @param longerCount - Number of longer phrases containing this phrase
 * @param longerFreqSum - Sum of frequencies of longer phrases containing this phrase
 * @returns C-value score
 */
export function cValue(
  phrase: string,
  freq: number,
  longerCount: number,
  longerFreqSum: number
): number {
  const len = phrase.split(' ').length;
  const penalty = longerCount > 0 ? longerFreqSum / longerCount : 0;
  return Math.log2(len) * (freq - penalty);
}

/**
 * Pointwise Mutual Information (PMI) - measures word association strength
 * Higher values indicate stronger association between words
 * 
 * @param joint - Joint frequency of word pair
 * @param x - Frequency of first word
 * @param y - Frequency of second word
 * @param N - Total number of word pairs in corpus
 * @returns PMI score
 */
export function pmi(joint: number, x: number, y: number, N: number): number {
  return Math.log2((joint * N) / (x * y + 1e-6));
}

/**
 * Normalize PMI score to a 0-1 range for easier interpretation
 * 
 * @param pmiScore - Raw PMI score
 * @param maxPmi - Maximum possible PMI in the corpus (for normalization)
 * @returns Normalized PMI score
 */
export function normalizePmi(pmiScore: number, maxPmi: number): number {
  if (maxPmi <= 0) return 0;
  return Math.max(0, Math.min(1, pmiScore / maxPmi));
}

/**
 * Calculate term frequency inverse document frequency (TF-IDF) score
 * 
 * @param termFreq - Frequency of term in document
 * @param docFreq - Number of documents containing the term
 * @param totalDocs - Total number of documents in corpus
 * @returns TF-IDF score
 */
export function tfidf(
  termFreq: number,
  docFreq: number,
  totalDocs: number
): number {
  const tf = Math.log(1 + termFreq);
  const idf = Math.log(totalDocs / (docFreq + 1));
  return tf * idf;
}
