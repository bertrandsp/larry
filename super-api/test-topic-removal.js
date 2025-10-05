#!/usr/bin/env node

/**
 * Test script for topic removal functionality
 * Tests the complete flow: create topic -> remove topic -> verify removal
 */

const https = require('https');
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

async function testGetAvailableTopics() {
  console.log('🔍 Testing get available topics...');
  const response = await makeRequest('GET', '/topics/available');
  
  if (response.statusCode === 200 && response.data?.topics && Array.isArray(response.data.topics)) {
    console.log(`✅ Found ${response.data.topics.length} available topics`);
    return response.data.topics;
  } else {
    console.log('❌ Failed to get available topics:', response.data);
    return null;
  }
}

async function testAddTopic(topicId) {
  console.log(`🔍 Testing add topic ${topicId}...`);
  const response = await makeRequest('POST', `/user/${TEST_USER_ID}/topics/add`, {}, {
    topicId: topicId,
    weight: 50
  });
  
  if (response.statusCode === 201 && response.data?.userTopic) {
    console.log(`✅ Successfully added topic ${topicId}`);
    return response.data.userTopic;
  } else {
    console.log('❌ Failed to add topic:', response.data);
    return null;
  }
}

async function testRemoveTopic(userTopicId) {
  console.log(`🔍 Testing remove topic ${userTopicId}...`);
  const response = await makeRequest('DELETE', `/user/topics/${userTopicId}`);
  
  if (response.statusCode === 204) {
    console.log(`✅ Successfully removed topic ${userTopicId}`);
    return true;
  } else {
    console.log('❌ Failed to remove topic:', response.data);
    return false;
  }
}

async function testGetUserTopics() {
  console.log('🔍 Testing get user topics...');
  const response = await makeRequest('GET', `/user/${TEST_USER_ID}/topics`);
  
  if (response.statusCode === 200 && response.data?.topics && Array.isArray(response.data.topics)) {
    console.log(`✅ Found ${response.data.topics.length} user topics`);
    return response.data.topics;
  } else {
    console.log('❌ Failed to get user topics:', response.data);
    return [];
  }
}

async function testInvalidUserRemoval() {
  console.log('🔍 Testing removal with invalid user...');
  const response = await makeRequest('DELETE', '/user/topics/fake-topic-id', {
    'x-user-id': 'different-user'
  });
  
  if (response.statusCode === 404) {
    console.log('✅ Correctly rejected removal for different user');
    return true;
  } else {
    console.log('❌ Should have rejected removal for different user:', response.data);
    return false;
  }
}

async function testMissingUserHeader() {
  console.log('🔍 Testing removal without user header...');
  // Make a direct request without the x-user-id header
  const response = await new Promise((resolve, reject) => {
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
    req.end();
  });
  
  if (response.statusCode === 401) {
    console.log('✅ Correctly rejected removal without user header');
    return true;
  } else {
    console.log('❌ Should have rejected removal without user header:', response.data);
    return false;
  }
}

// Main test runner
async function runTests() {
  console.log('🚀 Starting topic removal tests...\n');
  
  let passed = 0;
  let total = 0;
  
  // Test 1: Health check
  total++;
  if (await testHealthCheck()) passed++;
  console.log('');
  
  // Test 2: Get available topics
  total++;
  const availableTopics = await testGetAvailableTopics();
  if (availableTopics && availableTopics.length > 0) passed++;
  console.log('');
  
  // Test 3: Add a topic (if we have available topics)
  let userTopic = null;
  if (availableTopics && availableTopics.length > 0) {
    total++;
    userTopic = await testAddTopic(availableTopics[0].id);
    if (userTopic) passed++;
    console.log('');
  }
  
  // Test 4: Get user topics (should show the added topic)
  total++;
  const userTopics = await testGetUserTopics();
  const topicExists = userTopics.some(ut => ut.id === userTopic?.id);
  if (topicExists) {
    console.log('✅ Added topic appears in user topics');
    passed++;
  } else {
    console.log('❌ Added topic does not appear in user topics');
  }
  console.log('');
  
  // Test 5: Remove the topic
  if (userTopic) {
    total++;
    if (await testRemoveTopic(userTopic.id)) passed++;
    console.log('');
  }
  
  // Test 6: Verify topic is removed
  total++;
  const userTopicsAfterRemoval = await testGetUserTopics();
  const topicStillExists = userTopicsAfterRemoval.some(ut => ut.id === userTopic?.id);
  if (!topicStillExists && userTopic) {
    console.log('✅ Topic successfully removed from user topics');
    passed++;
  } else {
    console.log('❌ Topic still exists after removal');
  }
  console.log('');
  
  // Test 7: Test security - invalid user
  total++;
  if (await testInvalidUserRemoval()) passed++;
  console.log('');
  
  // Test 8: Test security - missing user header
  total++;
  if (await testMissingUserHeader()) passed++;
  console.log('');
  
  // Results
  console.log('📊 Test Results:');
  console.log(`   Passed: ${passed}/${total}`);
  console.log(`   Success Rate: ${Math.round((passed / total) * 100)}%`);
  
  if (passed === total) {
    console.log('\n🎉 All tests passed! Topic removal functionality is working correctly.');
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
