// Performance testing under high load scenarios
require('dotenv').config();
const axios = require('axios');

const BASE_URL = 'http://localhost:4001';
const ADMIN_KEY = 'super-secret-admin-key-2025';

async function testPerformance() {
  console.log('⚡ Performance Testing Under High Load...\n');

  try {
    // Test 1: Multiple concurrent quota checks
    console.log('1. Testing Concurrent Quota Checks...');
    
    const startTime = Date.now();
    const quotaChecks = [];
    
    // Simulate 10 concurrent quota checks
    for (let i = 0; i < 10; i++) {
      quotaChecks.push(
        axios.get(`${BASE_URL}/user/3f5e4322-517f-49f1-a435-d9ca16a7cc82/quota`)
          .then(response => ({ success: true, time: Date.now() - startTime }))
          .catch(error => ({ success: false, error: error.message, time: Date.now() - startTime }))
      );
    }
    
    const results = await Promise.all(quotaChecks);
    const successful = results.filter(r => r.success).length;
    const avgTime = results.reduce((sum, r) => sum + r.time, 0) / results.length;
    
    console.log(`   ✅ ${successful}/10 quota checks successful`);
    console.log(`   ⏱️  Average response time: ${avgTime.toFixed(2)}ms`);
    console.log(`   🎯 Performance: ${avgTime < 100 ? 'EXCELLENT' : avgTime < 200 ? 'GOOD' : 'NEEDS OPTIMIZATION'}`);
    console.log('');

    // Test 2: Analytics query performance
    console.log('2. Testing Analytics Query Performance...');
    
    const analyticsStart = Date.now();
    const analyticsResponse = await axios.get(`${BASE_URL}/admin/analytics`, {
      headers: { 'x-admin-key': ADMIN_KEY }
    });
    const analyticsTime = Date.now() - analyticsStart;
    
    console.log(`   📊 Analytics query time: ${analyticsTime}ms`);
    console.log(`   🎯 Performance: ${analyticsTime < 100 ? 'EXCELLENT' : analyticsTime < 200 ? 'GOOD' : 'NEEDS OPTIMIZATION'}`);
    console.log('');

    // Test 3: Bulk operations performance
    console.log('3. Testing Bulk Operations Performance...');
    
    const bulkStart = Date.now();
    const bulkResponse = await axios.post(`${BASE_URL}/admin/quota/bulk-reset`, {
      tier: 'free',
      reason: 'Performance test'
    }, {
      headers: { 'x-admin-key': ADMIN_KEY, 'Content-Type': 'application/json' }
    });
    const bulkTime = Date.now() - bulkStart;
    
    console.log(`   🔄 Bulk reset time: ${bulkTime}ms`);
    console.log(`   🎯 Performance: ${bulkTime < 100 ? 'EXCELLENT' : bulkTime < 200 ? 'GOOD' : 'NEEDS OPTIMIZATION'}`);
    console.log('');

    // Test 4: Database query optimization check
    console.log('4. Database Query Optimization...');
    
    const dbScenarios = [
      'Quota checks with proper indexing',
      'User queries with efficient joins',
      'Analytics aggregation performance',
      'Bulk update operations'
    ];

    for (const scenario of dbScenarios) {
      console.log(`   🗄️  ${scenario} - Should use optimized queries`);
    }
    console.log('');

    // Test 5: Memory and resource usage
    console.log('5. Memory & Resource Usage...');
    
    const resourceScenarios = [
      'Connection pool management',
      'Memory usage under load',
      'CPU utilization patterns',
      'Network I/O optimization'
    ];

    for (const scenario of resourceScenarios) {
      console.log(`   💾 ${scenario} - Should be monitored`);
    }
    console.log('');

    // Performance summary
    console.log('🎯 Performance Test Summary:');
    console.log(`   📊 Quota Checks: ${avgTime.toFixed(2)}ms average`);
    console.log(`   📈 Analytics: ${analyticsTime}ms`);
    console.log(`   🔄 Bulk Operations: ${bulkTime}ms`);
    console.log('');
    
    const overallPerformance = (avgTime + analyticsTime + bulkTime) / 3;
    console.log(`   🏆 Overall Performance: ${overallPerformance.toFixed(2)}ms average`);
    
    if (overallPerformance < 100) {
      console.log('   🎉 EXCELLENT - Production ready!');
    } else if (overallPerformance < 200) {
      console.log('   ✅ GOOD - Minor optimizations recommended');
    } else {
      console.log('   ⚠️  NEEDS OPTIMIZATION - Review database queries and caching');
    }
    
    console.log('');
    console.log('📋 Production Optimization Recommendations:');
    console.log('   1. Implement Redis caching for frequently accessed data');
    console.log('   2. Add database query result caching');
    console.log('   3. Optimize database indexes for quota queries');
    console.log('   4. Implement connection pooling for database connections');
    console.log('   5. Add performance monitoring and alerting');

  } catch (error) {
    console.error('❌ Performance testing failed:', error.message);
  }
}

// Run performance tests
testPerformance();
