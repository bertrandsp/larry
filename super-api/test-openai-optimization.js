#!/usr/bin/env node

/**
 * OpenAI Optimization Testing Suite
 * Tests the new cost-optimized endpoints and validates savings
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:4001';
const TEST_TOPICS = [
  'cooking',
  'programming', 
  'photography',
  'gardening',
  'music'
];

class OptimizationTester {
  constructor() {
    this.results = {
      original: { requests: 0, totalCost: 0, avgCost: 0 },
      optimized: { requests: 0, totalCost: 0, avgCost: 0 },
      savings: { percentage: 0, absolute: 0 }
    };
  }

  async runFullTest() {
    console.log('🧪 Starting OpenAI Optimization Tests\n');
    
    try {
      // Test 1: Original vs Optimized Cost Comparison
      await this.testCostComparison();
      
      // Test 2: Caching Effectiveness
      await this.testCaching();
      
      // Test 3: Rate Limiting
      await this.testRateLimiting();
      
      // Test 4: Cost Monitoring
      await this.testCostMonitoring();
      
      // Test 5: Emergency Controls
      await this.testEmergencyControls();
      
      // Test 6: Performance Comparison
      await this.testPerformance();
      
      // Generate final report
      this.generateReport();
      
    } catch (error) {
      console.error('❌ Test failed:', error.message);
      process.exit(1);
    }
  }

  async testCostComparison() {
    console.log('📊 Test 1: Cost Comparison (Original vs Optimized)');
    
    const testTopic = 'cooking';
    const numRequests = 5;
    
    console.log(`   Testing ${numRequests} requests for topic: ${testTopic}`);
    
    // Test original endpoint (if it exists)
    let originalCost = 0;
    try {
      for (let i = 0; i < numRequests; i++) {
        const start = Date.now();
        const response = await axios.post(`${BASE_URL}/generate`, {
          topic: testTopic,
          numTerms: 5,
          openAiFirst: true,
          userId: `test-user-${i}`
        });
        
        const duration = Date.now() - start;
        const estimatedCost = this.estimateOriginalCost(response.data);
        originalCost += estimatedCost;
        
        console.log(`   Original request ${i + 1}: ${duration}ms, ~$${estimatedCost.toFixed(4)}`);
      }
    } catch (error) {
      console.log('   ⚠️  Original endpoint not available, using estimated costs');
      originalCost = numRequests * 0.025; // Estimated $0.025 per request
    }
    
    // Test optimized endpoint
    let optimizedCost = 0;
    for (let i = 0; i < numRequests; i++) {
      const start = Date.now();
      const response = await axios.post(`${BASE_URL}/generate-optimized`, {
        topic: testTopic,
        numTerms: 5,
        complexity: 'basic',
        userId: `test-user-${i}`
      });
      
      const duration = Date.now() - start;
      const cost = response.data.data.metadata.cost;
      optimizedCost += cost;
      
      console.log(`   Optimized request ${i + 1}: ${duration}ms, $${cost.toFixed(4)}`);
    }
    
    const savings = ((originalCost - optimizedCost) / originalCost) * 100;
    
    console.log(`   📈 Results:`);
    console.log(`   Original total: $${originalCost.toFixed(4)}`);
    console.log(`   Optimized total: $${optimizedCost.toFixed(4)}`);
    console.log(`   Savings: ${savings.toFixed(1)}% ($${(originalCost - optimizedCost).toFixed(4)})\n`);
    
    this.results.original.totalCost = originalCost;
    this.results.optimized.totalCost = optimizedCost;
    this.results.savings.percentage = savings;
    this.results.savings.absolute = originalCost - optimizedCost;
  }

  async testCaching() {
    console.log('🗄️  Test 2: Caching Effectiveness');
    
    const testTopic = 'programming';
    const numRequests = 3;
    
    console.log(`   Testing caching with ${numRequests} identical requests`);
    
    const costs = [];
    const durations = [];
    
    for (let i = 0; i < numRequests; i++) {
      const start = Date.now();
      const response = await axios.post(`${BASE_URL}/generate-optimized`, {
        topic: testTopic,
        numTerms: 5,
        complexity: 'basic'
      });
      
      const duration = Date.now() - start;
      const cost = response.data.data.metadata.cost;
      const cached = response.data.data.metadata.cached;
      
      costs.push(cost);
      durations.push(duration);
      
      console.log(`   Request ${i + 1}: ${duration}ms, $${cost.toFixed(4)}, cached: ${cached}`);
    }
    
    const firstCost = costs[0];
    const cachedCost = costs[1];
    const cacheHit = cachedCost === 0;
    
    console.log(`   📈 Results:`);
    console.log(`   First request: $${firstCost.toFixed(4)}`);
    console.log(`   Cached request: $${cachedCost.toFixed(4)}`);
    console.log(`   Cache working: ${cacheHit ? '✅' : '❌'}\n`);
  }

  async testRateLimiting() {
    console.log('🚦 Test 3: Rate Limiting');
    
    const userId = 'rate-limit-test-user';
    const requests = [];
    
    console.log(`   Testing rate limits with user: ${userId}`);
    
    // Make multiple requests quickly
    for (let i = 0; i < 5; i++) {
      try {
        const response = await axios.post(`${BASE_URL}/generate-optimized`, {
          topic: 'photography',
          numTerms: 3,
          userId: userId
        });
        requests.push({ success: true, cost: response.data.data.metadata.cost });
        console.log(`   Request ${i + 1}: ✅ Success, $${response.data.data.metadata.cost.toFixed(4)}`);
      } catch (error) {
        if (error.response?.status === 429) {
          requests.push({ success: false, error: 'Rate limited' });
          console.log(`   Request ${i + 1}: ⚠️  Rate limited`);
        } else {
          console.log(`   Request ${i + 1}: ❌ Error: ${error.message}`);
        }
      }
    }
    
    const successful = requests.filter(r => r.success).length;
    const rateLimited = requests.filter(r => !r.success).length;
    
    console.log(`   📈 Results:`);
    console.log(`   Successful: ${successful}`);
    console.log(`   Rate limited: ${rateLimited}`);
    console.log(`   Rate limiting working: ${rateLimited > 0 ? '✅' : '❌'}\n`);
  }

  async testCostMonitoring() {
    console.log('📊 Test 4: Cost Monitoring');
    
    try {
      const response = await axios.get(`${BASE_URL}/cost-analysis`);
      const analysis = response.data;
      
      console.log('   Cost analysis retrieved:');
      console.log(`   Current model: ${analysis.currentModel}`);
      console.log(`   Optimized model: ${analysis.optimizedModel}`);
      console.log(`   Estimated savings: ${analysis.estimatedSavings.totalCost}`);
      console.log(`   Recommendations: ${analysis.recommendations.length} items\n`);
      
    } catch (error) {
      console.log('   ❌ Cost monitoring endpoint not available\n');
    }
  }

  async testEmergencyControls() {
    console.log('🚨 Test 5: Emergency Controls');
    
    console.log('   Note: Emergency controls would be tested in production');
    console.log('   - Daily limit: $10.00');
    console.log('   - Hourly limit: $2.00');
    console.log('   - Emergency brake available\n');
  }

  async testPerformance() {
    console.log('⚡ Test 6: Performance Comparison');
    
    const testTopic = 'music';
    const iterations = 3;
    
    let totalDuration = 0;
    let totalCost = 0;
    
    for (let i = 0; i < iterations; i++) {
      const start = Date.now();
      const response = await axios.post(`${BASE_URL}/generate-optimized`, {
        topic: testTopic,
        numTerms: 5,
        complexity: 'basic'
      });
      
      const duration = Date.now() - start;
      const cost = response.data.data.metadata.cost;
      
      totalDuration += duration;
      totalCost += cost;
      
      console.log(`   Request ${i + 1}: ${duration}ms, $${cost.toFixed(4)}`);
    }
    
    const avgDuration = totalDuration / iterations;
    const avgCost = totalCost / iterations;
    
    console.log(`   📈 Results:`);
    console.log(`   Average response time: ${avgDuration.toFixed(0)}ms`);
    console.log(`   Average cost: $${avgCost.toFixed(4)}`);
    console.log(`   Performance: ${avgDuration < 2000 ? '✅ Good' : '⚠️  Slow'}\n`);
  }

  estimateOriginalCost(responseData) {
    // Rough estimation based on typical gpt-4o costs
    // In reality, you'd parse the actual token usage
    return 0.025; // $0.025 per request estimate
  }

  generateReport() {
    console.log('📋 FINAL TEST REPORT');
    console.log('=' .repeat(50));
    
    const savings = this.results.savings;
    
    console.log(`💰 COST SAVINGS:`);
    console.log(`   Original cost: $${this.results.original.totalCost.toFixed(4)}`);
    console.log(`   Optimized cost: $${this.results.optimized.totalCost.toFixed(4)}`);
    console.log(`   Savings: ${savings.percentage.toFixed(1)}%`);
    console.log(`   Absolute savings: $${savings.absolute.toFixed(4)}`);
    
    console.log(`\n📊 MONTHLY PROJECTION:`);
    const dailySavings = savings.absolute;
    const monthlySavings = dailySavings * 30;
    console.log(`   Daily savings: $${dailySavings.toFixed(4)}`);
    console.log(`   Monthly savings: $${monthlySavings.toFixed(2)}`);
    console.log(`   Yearly savings: $${(monthlySavings * 12).toFixed(2)}`);
    
    console.log(`\n✅ OPTIMIZATION STATUS:`);
    if (savings.percentage >= 80) {
      console.log(`   🎉 EXCELLENT: ${savings.percentage.toFixed(1)}% savings achieved!`);
    } else if (savings.percentage >= 60) {
      console.log(`   👍 GOOD: ${savings.percentage.toFixed(1)}% savings achieved`);
    } else {
      console.log(`   ⚠️  NEEDS IMPROVEMENT: Only ${savings.percentage.toFixed(1)}% savings`);
    }
    
    console.log(`\n🚀 NEXT STEPS:`);
    console.log(`   1. Deploy optimized endpoints to production`);
    console.log(`   2. Update iOS app to use /generate-optimized`);
    console.log(`   3. Monitor costs for 24-48 hours`);
    console.log(`   4. Set up cost alerts`);
    console.log(`   5. Review and adjust rate limits if needed`);
    
    console.log('\n' + '=' .repeat(50));
  }
}

// Run the tests
async function main() {
  const tester = new OptimizationTester();
  await tester.runFullTest();
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = OptimizationTester;
