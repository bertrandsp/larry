const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

// Mock user data for testing
const TEST_USER = {
  id: 'test-user-' + Date.now(),
  email: 'test@example.com',
  name: 'Test User'
};

// Create a mock token for testing
const mockToken = `access_${TEST_USER.id}_mock_token_12345`;

const headers = {
  'Authorization': `Bearer ${mockToken}`,
  'Content-Type': 'application/json'
};

async function testOnboardingFlow() {
  console.log('🧪 Starting onboarding flow test...\n');

  try {
    // Step 1: Test Welcome endpoint
    console.log('1️⃣ Testing /onboarding/welcome');
    const welcomeResponse = await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
    console.log('✅ Welcome:', welcomeResponse.data);
    console.log('');

    // Step 2: Test Daily Goal endpoint
    console.log('2️⃣ Testing /onboarding/daily-goal');
    const dailyGoalResponse = await axios.post(`${BASE_URL}/onboarding/daily-goal`, {
      goal: 5
    }, { headers });
    console.log('✅ Daily Goal:', dailyGoalResponse.data);
    console.log('');

    // Step 3: Test Week Preview endpoint
    console.log('3️⃣ Testing /onboarding/week-preview');
    const weekPreviewResponse = await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
    console.log('✅ Week Preview:', weekPreviewResponse.data);
    console.log('');

    // Step 4: Test Source endpoint
    console.log('4️⃣ Testing /onboarding/source');
    const sourceResponse = await axios.post(`${BASE_URL}/onboarding/source`, {
      source: 'appStore'
    }, { headers });
    console.log('✅ Source:', sourceResponse.data);
    console.log('');

    // Step 5: Test Skill Level endpoint
    console.log('5️⃣ Testing /onboarding/skill-level');
    const skillLevelResponse = await axios.post(`${BASE_URL}/onboarding/skill-level`, {
      level: 'intermediate'
    }, { headers });
    console.log('✅ Skill Level:', skillLevelResponse.data);
    console.log('');

    // Step 6: Test Widget Preference endpoint
    console.log('6️⃣ Testing /onboarding/widget-preference');
    const widgetResponse = await axios.post(`${BASE_URL}/onboarding/widget-preference`, {
      enabled: true
    }, { headers });
    console.log('✅ Widget Preference:', widgetResponse.data);
    console.log('');

    // Step 7: Test Motivation endpoint
    console.log('7️⃣ Testing /onboarding/motivation');
    const motivationResponse = await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
    console.log('✅ Motivation:', motivationResponse.data);
    console.log('');

    // Step 8: Test Topics endpoint (get available topics first)
    console.log('8️⃣ Testing /topics (get available topics)');
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    console.log('✅ Available Topics:', topicsResponse.data);
    console.log('');

    // Step 9: Test Topics selection endpoint
    console.log('9️⃣ Testing /onboarding/topics');
    const selectedTopics = topicsResponse.data.topics.slice(0, 3).map(t => t.id);
    const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
      topicIds: selectedTopics,
      customTopics: ['Photography', 'Cooking']
    }, { headers });
    console.log('✅ Topics Selection:', topicsSelectionResponse.data);
    console.log('');

    // Step 10: Test Onboarding Complete endpoint
    console.log('🔟 Testing /onboarding/complete');
    const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
    console.log('✅ Onboarding Complete:', completeResponse.data);
    console.log('');

    // Step 11: Test First Daily Word endpoint
    console.log('1️⃣1️⃣ Testing /first-daily');
    const firstDailyResponse = await axios.get(`${BASE_URL}/first-daily?userId=${TEST_USER.id}`);
    console.log('✅ First Daily Word:', firstDailyResponse.data);
    console.log('');

    console.log('🎉 All onboarding flow tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    console.error('Status:', error.response?.status);
    console.error('Headers:', error.response?.headers);
  }
}

// Test individual endpoints
async function testIndividualEndpoints() {
  console.log('🧪 Testing individual endpoints...\n');

  try {
    // Test topics endpoint
    console.log('📚 Testing /topics endpoint');
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    console.log('✅ Topics:', topicsResponse.data.topics?.length || 0, 'topics found');
    console.log('');

    // Test record step endpoint
    console.log('📊 Testing /onboarding/record-step');
    const recordStepResponse = await axios.post(`${BASE_URL}/onboarding/record-step`, {
      step: 'welcome'
    }, { headers });
    console.log('✅ Record Step:', recordStepResponse.data);
    console.log('');

  } catch (error) {
    console.error('❌ Individual endpoint test failed:', error.response?.data || error.message);
  }
}

// Run tests
async function runTests() {
  console.log('🚀 Starting onboarding backend tests...\n');
  
  // Test individual endpoints first
  await testIndividualEndpoints();
  
  // Test full flow
  await testOnboardingFlow();
}

runTests();
