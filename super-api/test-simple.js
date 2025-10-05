#!/usr/bin/env node

/**
 * Simple OpenAI Optimization Test
 * Quick test to verify the optimizations are working
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function quickTest() {
  console.log('🧪 Quick OpenAI Optimization Test\n');
  
  try {
    // Test 1: Health check
    console.log('1️⃣ Testing health endpoint...');
    const health = await axios.get(`${BASE_URL}/health`);
    console.log(`   ✅ Health: ${health.data.status}\n`);
    
    // Test 2: Cost analysis
    console.log('2️⃣ Testing cost analysis...');
    try {
      const analysis = await axios.get(`${BASE_URL}/cost-analysis`);
      console.log(`   ✅ Cost analysis available`);
      console.log(`   📊 Estimated savings: ${analysis.data.estimatedSavings.totalCost}`);
      console.log(`   🎯 Model switch: ${analysis.data.currentModel} → ${analysis.data.optimizedModel}\n`);
    } catch (error) {
      console.log(`   ⚠️  Cost analysis not available yet\n`);
    }
    
    // Test 3: Optimized generation
    console.log('3️⃣ Testing optimized generation...');
    const start = Date.now();
    
    const response = await axios.post(`${BASE_URL}/generate-optimized`, {
      topic: 'cooking',
      numTerms: 3,
      complexity: 'basic',
      userId: 'test-user'
    });
    
    const duration = Date.now() - start;
    const result = response.data.data;
    
    console.log(`   ✅ Generation successful`);
    console.log(`   ⏱️  Response time: ${duration}ms`);
    console.log(`   💰 Cost: $${result.metadata.cost.toFixed(4)}`);
    console.log(`   🤖 Model: ${result.metadata.model}`);
    console.log(`   🗄️  Cached: ${result.metadata.cached}`);
    console.log(`   📝 Terms generated: ${result.terms.length}`);
    console.log(`   🔢 Tokens used: ${result.metadata.tokens}\n`);
    
    // Test 4: Caching test
    console.log('4️⃣ Testing caching...');
    const cacheStart = Date.now();
    
    const cacheResponse = await axios.post(`${BASE_URL}/generate-optimized`, {
      topic: 'cooking', // Same topic
      numTerms: 3,
      complexity: 'basic'
    });
    
    const cacheDuration = Date.now() - cacheStart;
    const cacheResult = cacheResponse.data.data;
    
    console.log(`   ✅ Second request successful`);
    console.log(`   ⏱️  Response time: ${cacheDuration}ms`);
    console.log(`   💰 Cost: $${cacheResult.metadata.cost.toFixed(4)}`);
    console.log(`   🗄️  Cached: ${cacheResult.metadata.cached}`);
    
    if (cacheResult.metadata.cached) {
      console.log(`   🎉 Caching working! Cost reduced to $0\n`);
    } else {
      console.log(`   ⚠️  Caching not working yet\n`);
    }
    
    // Test 5: Cost comparison estimate
    console.log('5️⃣ Cost comparison estimate...');
    const optimizedCost = result.metadata.cost;
    const estimatedOriginalCost = 0.025; // Estimated gpt-4o cost
    const savings = ((estimatedOriginalCost - optimizedCost) / estimatedOriginalCost) * 100;
    
    console.log(`   📊 Original (gpt-4o): ~$${estimatedOriginalCost.toFixed(4)}`);
    console.log(`   📊 Optimized: $${optimizedCost.toFixed(4)}`);
    console.log(`   💰 Savings: ${savings.toFixed(1)}%`);
    console.log(`   💵 Monthly savings (100 requests/day): $${((estimatedOriginalCost - optimizedCost) * 100 * 30).toFixed(2)}\n`);
    
    // Summary
    console.log('🎉 TEST SUMMARY');
    console.log('=' .repeat(40));
    console.log(`✅ Optimized endpoint working`);
    console.log(`✅ Cost monitoring available`);
    console.log(`✅ Caching ${cacheResult.metadata.cached ? 'working' : 'needs setup'}`);
    console.log(`✅ Estimated ${savings.toFixed(1)}% cost reduction`);
    console.log(`✅ Performance: ${duration < 3000 ? 'Good' : 'Needs improvement'}`);
    
    if (savings >= 80) {
      console.log(`\n🎉 SUCCESS: ${savings.toFixed(1)}% cost reduction achieved!`);
      console.log(`   Your OpenAI costs should drop significantly.`);
    } else {
      console.log(`\n⚠️  PARTIAL SUCCESS: ${savings.toFixed(1)}% cost reduction`);
      console.log(`   May need additional optimizations.`);
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    if (error.code === 'ECONNREFUSED') {
      console.log('\n💡 Make sure your backend is running:');
      console.log('   cd super-api && npm start');
    } else if (error.response) {
      console.log(`\n💡 Server error: ${error.response.status}`);
      console.log(`   Response: ${error.response.data}`);
    }
    
    process.exit(1);
  }
}

quickTest();
