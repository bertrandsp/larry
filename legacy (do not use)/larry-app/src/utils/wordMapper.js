// Utility function to map backend daily word response to frontend format
export const mapDailyWordResponse = (response) => {
  if (!response || !response.dailyWord) {
    return null;
  }

  return {
    id: response.dailyWord.id,
    term: response.dailyWord.term,
    definition: response.dailyWord.definition,
    example: response.dailyWord.example,
    category: response.dailyWord.category,
    complexityLevel: response.dailyWord.complexityLevel,
    source: response.dailyWord.source,
    sourceUrl: response.dailyWord.sourceUrl,
    confidenceScore: response.dailyWord.confidenceScore,
    topic: response.dailyWord.topic,
    facts: response.dailyWord.facts || [],
    relatedTerms: response.dailyWord.relatedTerms || [],
    pronunciation: 'prəˌnʌnsiˈeɪʃən' // Default pronunciation
  };
};


