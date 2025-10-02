#!/usr/bin/env node

/**
 * Test script for Topic Management API endpoints
 * Tests both Prisma and Supabase implementations
 */

const BASE_URL = 'http://localhost:4001';

// Test user ID (you can replace with a real user ID from your database)
const TEST_USER_ID = 'test-user-123';

async function makeRequest(method, url, body = null) {
  try {
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
      },
    };
    
    if (body) {
      options.body = JSON.stringify(body);
    }
    
    const response = await fetch(`${BASE_URL}${url}`, options);
    const data = await response.json();
    
    return {
      status: response.status,
      data,
      ok: response.ok
    };
  } catch (error) {
    console.error(`❌ Request failed: ${method} ${url}`, error.message);
    return { status: 500, data: { error: error.message }, ok: false };
  }
}

async function testEndpoint(name, method, url, body = null, expectedStatus = 200) {
  console.log(`\n🧪 Testing: ${name}`);
  console.log(`   ${method} ${url}`);
  
  const result = await makeRequest(method, url, body);
  
  if (result.status === expectedStatus) {
    console.log(`   ✅ Status: ${result.status}`);
    if (result.data) {
      console.log(`   📄 Response:`, JSON.stringify(result.data, null, 2));
    }
  } else {
    console.log(`   ❌ Expected status ${expectedStatus}, got ${result.status}`);
    console.log(`   📄 Response:`, JSON.stringify(result.data, null, 2));
  }
  
  return result;
}

async function runTests() {
  console.log('🚀 Starting Topic Management API Tests');
  console.log(`📍 Base URL: ${BASE_URL}`);
  console.log(`👤 Test User ID: ${TEST_USER_ID}`);
  
  // Test 1: Health check
  await testEndpoint('Health Check', 'GET', '/health');
  
  // Test 2: Get available topics
  await testEndpoint('Get Available Topics', 'GET', '/topics/available');
  
  // Test 3: Get available topics for specific user
  await testEndpoint('Get Available Topics for User', 'GET', `/topics/available?userId=${TEST_USER_ID}`);
  
  // Test 4: Get user topics (might return 404 if user doesn't exist)
  await testEndpoint('Get User Topics', 'GET', `/user/${TEST_USER_ID}/topics`, null, [200, 404]);
  
  // Test 5: Try to add a topic to user (will likely fail without real topic ID)
  const sampleTopicId = 'sample-topic-id';
  await testEndpoint(
    'Add Topic to User', 
    'POST', 
    `/user/${TEST_USER_ID}/topics/add`,
    { topicId: sampleTopicId, weight: 75 },
    [201, 404, 409] // Accept multiple possible statuses
  );
  
  console.log('\n✨ Topic Management API Tests Complete!');
  console.log('\n📋 Summary:');
  console.log('   - If you see 404 errors for user-specific endpoints, create a test user first');
  console.log('   - If you see topic-related errors, ensure you have topics in your database');
  console.log('   - All endpoints should return proper JSON responses');
  
  console.log('\n🔧 Next Steps:');
  console.log('   1. Create test topics in your database');
  console.log('   2. Create a test user');
  console.log('   3. Test the full flow: list available → add to user → update weight → remove');
}

// Handle command line arguments
const args = process.argv.slice(2);
if (args.includes('--help') || args.includes('-h')) {
  console.log('Topic Management API Test Script');
  console.log('');
  console.log('Usage: node test-topic-management.js [options]');
  console.log('');
  console.log('Options:');
  console.log('  --help, -h     Show this help message');
  console.log('');
  console.log('Environment:');
  console.log(`  BASE_URL: ${BASE_URL}`);
  console.log(`  TEST_USER_ID: ${TEST_USER_ID}`);
  process.exit(0);
}

// Run the tests
runTests().catch(error => {
  console.error('❌ Test script failed:', error);
  process.exit(1);
});
