const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testOnboardingFixes() {
  console.log('🧪 Testing onboarding fixes...\n');

  try {
    // Step 1: Create a test user
    console.log('👤 Creating test user...');
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: `fix-test-${Date.now()}@example.com`,
      password: 'test123',
      name: 'Fix Test User'
    });
    
    const userId = signupResponse.data.user.id;
    const accessToken = signupResponse.data.access_token;
    const headers = {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    };
    
    console.log('✅ User created:', userId);
    console.log('');

    // Step 2: Test the fixed endpoints with correct request bodies
    console.log('🔧 Testing fixed endpoints...');
    
    // Test welcome
    console.log('1️⃣ Testing /onboarding/welcome');
    const welcomeResponse = await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
    console.log('✅ Welcome:', welcomeResponse.data);
    console.log('');

    // Test daily goal with correct request body
    console.log('2️⃣ Testing /onboarding/daily-goal with correct body');
    const dailyGoalResponse = await axios.post(`${BASE_URL}/onboarding/daily-goal`, {
      goal: 5
    }, { headers });
    console.log('✅ Daily Goal:', dailyGoalResponse.data);
    console.log('');

    // Test week preview
    console.log('3️⃣ Testing /onboarding/week-preview');
    const weekPreviewResponse = await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
    console.log('✅ Week Preview:', weekPreviewResponse.data);
    console.log('');

    // Test source with correct request body
    console.log('4️⃣ Testing /onboarding/source with correct body');
    const sourceResponse = await axios.post(`${BASE_URL}/onboarding/source`, {
      source: 'appStore'
    }, { headers });
    console.log('✅ Source:', sourceResponse.data);
    console.log('');

    // Test skill level with correct request body
    console.log('5️⃣ Testing /onboarding/skill-level with correct body');
    const skillLevelResponse = await axios.post(`${BASE_URL}/onboarding/skill-level`, {
      level: 'intermediate'
    }, { headers });
    console.log('✅ Skill Level:', skillLevelResponse.data);
    console.log('');

    // Test widget preference with correct endpoint and body
    console.log('6️⃣ Testing /onboarding/widget-preference with correct body');
    const widgetResponse = await axios.post(`${BASE_URL}/onboarding/widget-preference`, {
      enabled: true
    }, { headers });
    console.log('✅ Widget Preference:', widgetResponse.data);
    console.log('');

    // Test motivation
    console.log('7️⃣ Testing /onboarding/motivation');
    const motivationResponse = await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
    console.log('✅ Motivation:', motivationResponse.data);
    console.log('');

    // Test topics
    console.log('8️⃣ Testing /onboarding/topics');
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    const selectedTopics = topicsResponse.data.topics.slice(0, 3).map(t => t.id);
    
    const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
      topicIds: selectedTopics,
      customTopics: []
    }, { headers });
    console.log('✅ Topics Selection:', topicsSelectionResponse.data);
    console.log('');

    // Test onboarding completion
    console.log('🎯 Testing /onboarding/complete');
    const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
    console.log('✅ Onboarding Complete:', completeResponse.data);
    console.log('');

    console.log('🎉 All onboarding fixes working correctly!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    console.error('Status:', error.response?.status);
    
    if (error.response?.data?.missingFields) {
      console.log('\n🔍 Missing fields:', error.response.data.missingFields);
      console.log('💡 This means the database migration still needs to be run.');
    }
  }
}

// Test the old broken endpoints to confirm they're fixed
async function testOldBrokenEndpoints() {
  console.log('\n🧪 Testing old broken endpoints (should fail)...\n');

  try {
    const headers = {
      'Authorization': `Bearer test_token`,
      'Content-Type': 'application/json'
    };

    // Test the old widget endpoint (should return 404)
    console.log('🔍 Testing old /onboarding/widget endpoint (should fail)...');
    try {
      await axios.post(`${BASE_URL}/onboarding/widget`, { enabled: true }, { headers });
      console.log('❌ Old endpoint still works (this is bad)');
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('✅ Old endpoint correctly returns 404');
      } else {
        console.log('⚠️  Old endpoint returned unexpected error:', error.response?.status);
      }
    }

    // Test wrong request body format (should fail)
    console.log('\n🔍 Testing wrong request body format (should fail)...');
    try {
      await axios.post(`${BASE_URL}/onboarding/daily-goal`, { userId: 'test' }, { headers });
      console.log('❌ Wrong request body was accepted (this is bad)');
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('✅ Wrong request body correctly rejected');
      } else {
        console.log('⚠️  Request body validation returned unexpected error:', error.response?.status);
      }
    }

  } catch (error) {
    console.error('❌ Endpoint test failed:', error.message);
  }
}

// Run all tests
async function runAllTests() {
  await testOnboardingFixes();
  await testOldBrokenEndpoints();
}

runAllTests();
