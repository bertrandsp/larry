const { postProcessTerms, postProcessFacts } = require('./dist/services/postProcessingService');
const { getOrCreateCanonicalSetForTopic } = require('./dist/services/canonicalSetService');

async function testPostProcessing() {
  console.log('🧪 Testing Post-Processing Pipeline...\n');

  // Test data
  const testTerms = [
    {
      term: 'Machine Learning',
      definition: 'A subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed.',
      example: 'Machine learning algorithms can identify patterns in large datasets.',
      source: 'AI Generated',
      sourceUrl: null,
      gptGenerated: true
    },
    {
      term: 'machine learning', // Duplicate with different casing
      definition: 'A type of AI that learns from data',
      example: 'The machine learning model improved accuracy over time.',
      source: 'AI Generated',
      sourceUrl: null,
      gptGenerated: true
    },
    {
      term: 'Neural Network',
      definition: 'A computing system inspired by biological neural networks.',
      example: 'Deep neural networks can recognize images.',
      source: 'Wikipedia',
      sourceUrl: 'https://en.wikipedia.org/wiki/Neural_network',
      gptGenerated: false
    },
    {
      term: 'Algorithm',
      definition: 'A set of rules or instructions given to an AI system to help it learn on its own.',
      example: 'The algorithm processed the data efficiently.',
      source: 'AI Generated',
      sourceUrl: null,
      gptGenerated: true
    }
  ];

  const testFacts = [
    {
      fact: 'Machine learning was first coined in 1959 by Arthur Samuel.',
      source: 'AI Generated',
      sourceUrl: null
    },
    {
      fact: 'machine learning was first coined in 1959 by arthur samuel.', // Duplicate with different casing
      source: 'AI Generated',
      sourceUrl: null
    },
    {
      fact: 'Neural networks were inspired by the human brain structure.',
      source: 'Wikipedia',
      sourceUrl: 'https://en.wikipedia.org/wiki/Neural_network'
    }
  ];

  try {
    // Test term post-processing
    console.log('📝 Testing Term Post-Processing...');
    const termResult = await postProcessTerms(testTerms, 'Artificial Intelligence');
    
    console.log('✅ Term Post-Processing Results:');
    console.log(`   Original terms: ${termResult.stats.originalCount}`);
    console.log(`   Normalized: ${termResult.stats.normalizedCount}`);
    console.log(`   Deduplicated: ${termResult.stats.deduplicatedCount}`);
    console.log(`   Final enriched: ${termResult.stats.enrichedCount}`);
    console.log(`   Duplicates removed: ${termResult.stats.duplicatesRemoved}`);
    console.log(`   Confidence improved: ${termResult.stats.confidenceImproved}\n`);

    // Show sample processed terms
    console.log('📊 Sample Processed Terms:');
    termResult.terms.slice(0, 3).forEach((term, index) => {
      console.log(`   ${index + 1}. "${term.term}"`);
      console.log(`      Definition: ${term.definition.substring(0, 60)}...`);
      console.log(`      Confidence: ${term.confidenceScore}`);
      console.log(`      Complexity: ${term.complexityLevel}`);
      console.log(`      Category: ${term.category}`);
      console.log(`      Verified: ${term.verified}`);
      console.log('');
    });

    // Test fact post-processing
    console.log('📚 Testing Fact Post-Processing...');
    const factResult = await postProcessFacts(testFacts, 'Artificial Intelligence');
    
    console.log('✅ Fact Post-Processing Results:');
    console.log(`   Original facts: ${testFacts.length}`);
    console.log(`   Final facts: ${factResult.length}`);
    console.log(`   Duplicates removed: ${testFacts.length - factResult.length}\n`);

    // Show sample processed facts
    console.log('📊 Sample Processed Facts:');
    factResult.slice(0, 2).forEach((fact, index) => {
      console.log(`   ${index + 1}. ${fact.fact.substring(0, 60)}...`);
      console.log(`      Category: ${fact.category}`);
      console.log(`      GPT Generated: ${fact.gptGenerated}`);
      console.log('');
    });

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

async function testCanonicalSets() {
  console.log('🔍 Testing Canonical Set Management...\n');

  try {
    // Test getting/creating canonical set
    console.log('📝 Testing getOrCreateCanonicalSetForTopic...');
    
    const result1 = await getOrCreateCanonicalSetForTopic('Machine Learning');
    console.log('✅ First call result:');
    console.log(`   Topic: ${result1.topicName}`);
    console.log(`   Canonical Set ID: ${result1.id}`);
    console.log(`   Was Created: ${result1.wasCreated}\n`);

    // Test reusing existing canonical set
    console.log('🔄 Testing reuse of existing canonical set...');
    const result2 = await getOrCreateCanonicalSetForTopic('Machine Learning');
    console.log('✅ Second call result:');
    console.log(`   Topic: ${result2.topicName}`);
    console.log(`   Canonical Set ID: ${result2.id}`);
    console.log(`   Was Created: ${result2.wasCreated}\n`);

    // Verify same canonical set is returned
    if (result1.id === result2.id) {
      console.log('✅ SUCCESS: Same canonical set reused for duplicate topic');
    } else {
      console.log('❌ FAILURE: Different canonical sets created for same topic');
    }

  } catch (error) {
    console.error('❌ Canonical set test failed:', error);
  }
}

async function runAllTests() {
  console.log('🚀 Starting Post-Processing and Canonical Set Tests\n');
  console.log('=' .repeat(60) + '\n');

  await testPostProcessing();
  
  console.log('=' .repeat(60) + '\n');
  
  await testCanonicalSets();
  
  console.log('=' .repeat(60) + '\n');
  console.log('🎉 All tests completed!');
}

// Run tests if this file is executed directly
if (require.main === module) {
  runAllTests().catch(console.error);
}

module.exports = { testPostProcessing, testCanonicalSets };
