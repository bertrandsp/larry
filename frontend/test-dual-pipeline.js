const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testDualPipeline() {
  console.log('🧪 Testing Dual Pipeline Vocabulary Generator\n');

  try {
    // Test 1: Get pipeline information
    console.log('📋 Test 1: Getting pipeline information...');
    const pipelineResponse = await axios.get(`${BASE_URL}/generate/pipelines`);
    console.log('✅ Pipeline info retrieved:');
    pipelineResponse.data.data.pipelines.forEach(pipeline => {
      console.log(`   - ${pipeline.name}: ${pipeline.description}`);
    });
    console.log('');

    // Test 2: Test generation (small scale)
    console.log('📋 Test 2: Test generation (anime, source-first)');
    const testResponse = await axios.post(`${BASE_URL}/generate/test`, {
      topic: 'anime',
      pipeline: 'source-first'
    });

    console.log('✅ Test generation results:');
    console.log(`   - Pipeline: ${testResponse.data.data.pipeline}`);
    console.log(`   - Terms generated: ${testResponse.data.data.terms.length}`);
    console.log(`   - Facts generated: ${testResponse.data.data.facts.length}`);
    console.log(`   - Processing time: ${testResponse.data.data.stats.processingTime}ms`);
    console.log(`   - Sample terms: ${testResponse.data.data.terms.map(t => t.term).join(', ')}`);
    console.log('');

    // Test 3: Quick generation
    console.log('📋 Test 3: Quick generation (blockchain, openai-first)');
    const quickResponse = await axios.post(`${BASE_URL}/generate/quick`, {
      topic: 'blockchain',
      numTerms: 8,
      openAiFirst: true
    });

    console.log('✅ Quick generation results:');
    console.log(`   - Pipeline: ${quickResponse.data.data.pipeline}`);
    console.log(`   - Terms generated: ${quickResponse.data.data.terms.length}`);
    console.log(`   - Facts generated: ${quickResponse.data.data.facts.length}`);
    console.log(`   - Processing time: ${quickResponse.data.data.stats.processingTime}ms`);
    console.log(`   - Sample terms: ${quickResponse.data.data.terms.slice(0, 3).map(t => t.term).join(', ')}`);
    console.log('');

    // Test 4: Full generation with parameters
    console.log('📋 Test 4: Full generation (machine learning, technical style)');
    const fullResponse = await axios.post(`${BASE_URL}/generate`, {
      topic: 'machine learning',
      openAiFirst: false,
      numTerms: 10,
      numFacts: 3,
      definitionStyle: 'technical',
      audienceLevel: 'intermediate',
      includeSynonyms: true,
      includeEtymology: true
    });

    console.log('✅ Full generation results:');
    console.log(`   - Pipeline: ${fullResponse.data.data.pipeline}`);
    console.log(`   - Terms generated: ${fullResponse.data.data.terms.length}`);
    console.log(`   - Facts generated: ${fullResponse.data.data.facts.length}`);
    console.log(`   - Processing time: ${fullResponse.data.data.stats.processingTime}ms`);
    console.log(`   - Sample terms: ${fullResponse.data.data.terms.slice(0, 3).map(t => t.term).join(', ')}`);
    console.log('');

    console.log('🎉 All tests completed successfully!');
    console.log('\n📊 Summary:');
    console.log('   - Pipeline information endpoint: ✅');
    console.log('   - Test generation endpoint: ✅');
    console.log('   - Quick generation endpoint: ✅');
    console.log('   - Full generation endpoint: ✅');
    console.log('   - Both pipelines working: ✅');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    console.log('\n🔧 Troubleshooting:');
    console.log('   1. Make sure the backend server is running on port 4001');
    console.log('   2. Check that all dependencies are installed');
    console.log('   3. Verify the OpenAI API key is set in the environment');
    console.log('   4. Check the server logs for detailed error information');
  }
}

// Run tests
testDualPipeline();


