const { generateVocabulary } = require('./src/services/openAiService');

async function testOpenAIGeneration() {
  console.log('🧪 Testing OpenAI generation quality...');
  
  try {
    const params = {
      topic: "The Bear",
      numTerms: 3,
      definitionStyle: 'formal',
      sentenceRange: '2-3',
      numExamples: 2,
      numFacts: 2,
      audienceLevel: 'intermediate',
      domainContext: 'TV show about a Chicago sandwich shop',
      language: 'English',
      useAnalogy: true,
      includeSynonyms: true,
      includeAntonyms: false,
      includeRelatedTerms: true,
      includeEtymology: true,
      highlightRootWords: true,
      openAiFirst: true
    };

    const result = await generateVocabulary(params, 'test-job-123');
    
    console.log('\n✅ OpenAI Generation Results:');
    console.log('=====================================');
    
    result.response.terms.forEach((term, index) => {
      console.log(`\n${index + 1}. ${term.term}`);
      console.log(`   Definition: ${term.definition}`);
      console.log(`   Examples: ${term.examples.join(', ')}`);
      if (term.synonyms) console.log(`   Synonyms: ${term.synonyms.join(', ')}`);
      if (term.etymology) console.log(`   Etymology: ${term.etymology}`);
    });
    
    console.log('\n📚 Facts:');
    result.response.facts.forEach((fact, index) => {
      console.log(`${index + 1}. ${fact}`);
    });
    
    console.log('\n💰 Cost:', result.usage);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testOpenAIGeneration();



