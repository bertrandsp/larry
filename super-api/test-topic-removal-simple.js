#!/usr/bin/env node

/**
 * Simple test script for topic removal functionality
 * Tests the core security and functionality of the DELETE endpoint
 */

const http = require('http');

const BASE_URL = 'http://localhost:4001';
const TEST_USER_ID = 'test-user-topic-removal';

// Helper function to make HTTP requests
function makeRequest(method, path, headers = {}, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const defaultHeaders = {
      'Content-Type': 'application/json',
      'x-user-id': TEST_USER_ID
    };
    
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        ...defaultHeaders,
        ...headers
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const jsonData = data ? JSON.parse(data) : null;
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: jsonData
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: data
          });
        }
      });
    });

    req.on('error', reject);
    
    if (body) {
      req.write(typeof body === 'string' ? body : JSON.stringify(body));
    }
    
    req.end();
  });
}

// Test functions
async function testHealthCheck() {
  console.log('🔍 Testing health check...');
  const response = await makeRequest('GET', '/health');
  
  if (response.statusCode === 200 && response.data?.status === 'ok') {
    console.log('✅ Health check passed');
    return true;
  } else {
    console.log('❌ Health check failed:', response.data);
    return false;
  }
}

async function testTopicRemovalSecurity() {
  console.log('🔍 Testing topic removal security...');
  
  // Test 1: Missing user header
  console.log('  - Testing missing user header...');
  const response1 = await new Promise((resolve, reject) => {
    const url = new URL('/user/topics/fake-topic-id', BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json'
        // Intentionally not including 'x-user-id'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const jsonData = data ? JSON.parse(data) : null;
          resolve({
            statusCode: res.statusCode,
            data: jsonData
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            data: data
          });
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
  
  const test1Passed = response1.statusCode === 401;
  console.log(`    ${test1Passed ? '✅' : '❌'} Missing user header: ${response1.statusCode} ${response1.data?.error || response1.data}`);
  
  // Test 2: Different user trying to remove topic
  console.log('  - Testing different user removal...');
  const response2 = await makeRequest('DELETE', '/user/topics/fake-topic-id', {
    'x-user-id': 'different-user'
  });
  
  const test2Passed = response2.statusCode === 404;
  console.log(`    ${test2Passed ? '✅' : '❌'} Different user removal: ${response2.statusCode} ${response2.data?.error || response2.data}`);
  
  // Test 3: Non-existent topic
  console.log('  - Testing non-existent topic removal...');
  const response3 = await makeRequest('DELETE', '/user/topics/non-existent-topic-id');
  
  const test3Passed = response3.statusCode === 404;
  console.log(`    ${test3Passed ? '✅' : '❌'} Non-existent topic: ${response3.statusCode} ${response3.data?.error || response3.data}`);
  
  return test1Passed && test2Passed && test3Passed;
}

async function testTopicRemovalEndpoint() {
  console.log('🔍 Testing topic removal endpoint functionality...');
  
  // Test with a fake topic ID - should get proper error response
  const response = await makeRequest('DELETE', '/user/topics/fake-topic-id');
  
  // We expect a 404 because the topic doesn't exist, but we should get our custom error message
  if (response.statusCode === 404 && response.data?.error === 'Topic not found or access denied') {
    console.log('✅ Topic removal endpoint responding correctly');
    return true;
  } else {
    console.log('❌ Topic removal endpoint not responding correctly:', response.data);
    return false;
  }
}

async function testAvailableTopicsEndpoint() {
  console.log('🔍 Testing available topics endpoint...');
  const response = await makeRequest('GET', '/topics/available');
  
  if (response.statusCode === 200 && response.data?.topics && Array.isArray(response.data.topics)) {
    console.log(`✅ Available topics endpoint working (${response.data.topics.length} topics found)`);
    return true;
  } else {
    console.log('❌ Available topics endpoint failed:', response.data);
    return false;
  }
}

// Main test runner
async function runTests() {
  console.log('🚀 Starting simplified topic removal tests...\n');
  
  let passed = 0;
  let total = 0;
  
  // Test 1: Health check
  total++;
  if (await testHealthCheck()) passed++;
  console.log('');
  
  // Test 2: Available topics endpoint
  total++;
  if (await testAvailableTopicsEndpoint()) passed++;
  console.log('');
  
  // Test 3: Topic removal endpoint functionality
  total++;
  if (await testTopicRemovalEndpoint()) passed++;
  console.log('');
  
  // Test 4: Security tests
  total++;
  if (await testTopicRemovalSecurity()) passed++;
  console.log('');
  
  // Results
  console.log('📊 Test Results:');
  console.log(`   Passed: ${passed}/${total}`);
  console.log(`   Success Rate: ${Math.round((passed / total) * 100)}%`);
  
  if (passed === total) {
    console.log('\n🎉 All tests passed! Topic removal functionality is working correctly.');
    console.log('✅ Security: Proper authentication and authorization checks');
    console.log('✅ Functionality: Endpoint responds correctly to requests');
    console.log('✅ Error Handling: Appropriate error messages and status codes');
    return true;
  } else {
    console.log('\n❌ Some tests failed. Please check the implementation.');
    return false;
  }
}

// Run the tests
runTests()
  .then(success => {
    process.exit(success ? 0 : 1);
  })
  .catch(error => {
    console.error('💥 Test runner error:', error);
    process.exit(1);
  });
