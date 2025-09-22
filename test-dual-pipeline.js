const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testDualPipeline() {
  console.log('🧪 Testing Dual Pipeline Vocabulary Generator\n');

  try {
    // Test 1: Source-first pipeline
    console.log('📋 Test 1: Source-first pipeline (anime)');
    const sourceFirstResponse = await axios.post(`${BASE_URL}/generate/test`, {
      topic: 'anime',
      pipeline: 'source-first'
    });

    console.log('✅ Source-first results:');
    console.log(`   - Pipeline: ${sourceFirstResponse.data.data.pipeline}`);
    console.log(`   - Terms generated: ${sourceFirstResponse.data.data.terms.length}`);
    console.log(`   - Facts generated: ${sourceFirstResponse.data.data.facts.length}`);
    console.log(`   - Processing time: ${sourceFirstResponse.data.data.stats.processingTime}ms`);
    console.log(`   - Sample terms: ${sourceFirstResponse.data.data.terms.map(t => t.term).join(', ')}\n`);

    // Test 2: OpenAI-first pipeline
    console.log('📋 Test 2: OpenAI-first pipeline (anime)');
    const openAiFirstResponse = await axios.post(`${BASE_URL}/generate/test`, {
      topic: 'anime',
      pipeline: 'openai-first'
    });

    console.log('✅ OpenAI-first results:');
    console.log(`   - Pipeline: ${openAiFirstResponse.data.data.pipeline}`);
    console.log(`   - Terms generated: ${openAiFirstResponse.data.data.terms.length}`);
    console.log(`   - Facts generated: ${openAiFirstResponse.data.data.facts.length}`);
    console.log(`   - Processing time: ${openAiFirstResponse.data.data.stats.processingTime}ms`);
    console.log(`   - Sample terms: ${openAiFirstResponse.data.data.terms.map(t => t.term).join(', ')}\n`);

    // Test 3: Full parameter generation
    console.log('📋 Test 3: Full parameter generation (blockchain)');
    const fullResponse = await axios.post(`${BASE_URL}/generate`, {
      topic: 'blockchain',
      openAiFirst: false,
      numTerms: 10,
      numFacts: 5,
      definitionStyle: 'technical',
      audienceLevel: 'intermediate',
      includeSynonyms: true,
      includeEtymology: true
    });

    console.log('✅ Full parameter results:');
    console.log(`   - Pipeline: ${fullResponse.data.data.pipeline}`);
    console.log(`   - Terms generated: ${fullResponse.data.data.terms.length}`);
    console.log(`   - Facts generated: ${fullResponse.data.data.facts.length}`);
    console.log(`   - Processing time: ${fullResponse.data.data.stats.processingTime}ms`);
    console.log(`   - Sample terms: ${fullResponse.data.data.terms.slice(0, 3).map(t => t.term).join(', ')}\n`);

    // Test 4: Quick generation
    console.log('📋 Test 4: Quick generation (machine learning)');
    const quickResponse = await axios.post(`${BASE_URL}/generate/quick`, {
      topic: 'machine learning',
      numTerms: 8,
      openAiFirst: true
    });

    console.log('✅ Quick generation results:');
    console.log(`   - Pipeline: ${quickResponse.data.data.pipeline}`);
    console.log(`   - Terms generated: ${quickResponse.data.data.terms.length}`);
    console.log(`   - Facts generated: ${quickResponse.data.data.facts.length}`);
    console.log(`   - Processing time: ${quickResponse.data.data.stats.processingTime}ms`);
    console.log(`   - Sample terms: ${quickResponse.data.data.terms.slice(0, 3).map(t => t.term).join(', ')}\n`);

    // Test 5: Get pipeline information
    console.log('📋 Test 5: Pipeline information');
    const pipelineInfo = await axios.get(`${BASE_URL}/generate/pipelines`);
    
    console.log('✅ Available pipelines:');
    pipelineInfo.data.data.pipelines.forEach(pipeline => {
      console.log(`   - ${pipeline.name}: ${pipeline.description}`);
      console.log(`     Best for: ${pipeline.bestFor.join(', ')}`);
    });

    console.log('\n🎉 All tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run tests
testDualPipeline();



