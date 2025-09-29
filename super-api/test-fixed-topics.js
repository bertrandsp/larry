const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testFixedTopics() {
  console.log('🧪 Testing fixed topics flow...\n');

  try {
    // Step 1: Create a test user
    console.log('👤 Creating test user...');
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: `topics-test-${Date.now()}@example.com`,
      password: 'test123',
      name: 'Topics Test User'
    });
    
    const userId = signupResponse.data.user.id;
    const accessToken = signupResponse.data.access_token;
    const headers = {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    };
    
    console.log('✅ User created:', userId);
    console.log('');

    // Step 2: Get topics and verify structure
    console.log('📚 Testing /topics endpoint...');
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    console.log('✅ Topics retrieved:', topicsResponse.data.topics.length, 'topics');
    console.log('Sample topic:', topicsResponse.data.topics[0]);
    console.log('');

    // Step 3: Complete onboarding steps quickly
    console.log('🔄 Completing onboarding steps...');
    await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
    await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 3 }, { headers });
    await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
    await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers });
    await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'beginner' }, { headers });
    await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers });
    await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
    console.log('✅ All onboarding steps completed');
    console.log('');

    // Step 4: Test topic selection with real topic IDs
    console.log('🎯 Testing topic selection with real IDs...');
    const selectedTopics = topicsResponse.data.topics.slice(0, 3).map(t => t.id);
    console.log('Selected topic IDs:', selectedTopics);
    
    const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
      topicIds: selectedTopics,
      customTopics: []
    }, { headers });
    console.log('✅ Topics selection:', topicsSelectionResponse.data);
    console.log('');

    // Step 5: Test onboarding completion
    console.log('🏁 Testing onboarding completion...');
    const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
    console.log('✅ Onboarding completed successfully!');
    console.log('User data:', {
      onboardingSource: completeResponse.data.user.onboardingSource,
      learningLevel: completeResponse.data.user.learningLevel,
      widgetOptIn: completeResponse.data.user.widgetOptIn,
      dailyWordGoal: completeResponse.data.user.dailyWordGoal
    });
    console.log('');

    console.log('🎉 All tests passed! The topics issue is fixed.');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    console.error('Status:', error.response?.status);
  }
}

testFixedTopics();
