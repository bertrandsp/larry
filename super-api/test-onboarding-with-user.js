const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

// Test user data
const TEST_USER = {
  email: 'test-onboarding@example.com',
  name: 'Test Onboarding User'
};

async function testOnboardingWithUser() {
  console.log('🧪 Testing onboarding flow with user creation...\n');

  try {
    // Step 1: Create a user first (signup)
    console.log('👤 Creating test user...');
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: TEST_USER.email,
      password: 'testpassword123',
      name: TEST_USER.name
    });
    console.log('✅ User created:', signupResponse.data);
    
    const userId = signupResponse.data.user.id;
    const mockToken = `access_${userId}_mock_token_12345`;
    const headers = {
      'Authorization': `Bearer ${mockToken}`,
      'Content-Type': 'application/json'
    };
    console.log('');

    // Step 2: Test onboarding steps
    console.log('1️⃣ Testing /onboarding/welcome');
    const welcomeResponse = await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
    console.log('✅ Welcome:', welcomeResponse.data);
    console.log('');

    console.log('2️⃣ Testing /onboarding/daily-goal');
    const dailyGoalResponse = await axios.post(`${BASE_URL}/onboarding/daily-goal`, {
      goal: 5
    }, { headers });
    console.log('✅ Daily Goal:', dailyGoalResponse.data);
    console.log('');

    console.log('3️⃣ Testing /onboarding/source');
    const sourceResponse = await axios.post(`${BASE_URL}/onboarding/source`, {
      source: 'appStore'
    }, { headers });
    console.log('✅ Source:', sourceResponse.data);
    console.log('');

    console.log('4️⃣ Testing /onboarding/skill-level');
    const skillLevelResponse = await axios.post(`${BASE_URL}/onboarding/skill-level`, {
      level: 'intermediate'
    }, { headers });
    console.log('✅ Skill Level:', skillLevelResponse.data);
    console.log('');

    console.log('5️⃣ Testing /onboarding/widget-preference');
    const widgetResponse = await axios.post(`${BASE_URL}/onboarding/widget-preference`, {
      enabled: true
    }, { headers });
    console.log('✅ Widget Preference:', widgetResponse.data);
    console.log('');

    console.log('6️⃣ Testing /onboarding/motivation');
    const motivationResponse = await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
    console.log('✅ Motivation:', motivationResponse.data);
    console.log('');

    // Step 3: Get available topics
    console.log('📚 Getting available topics...');
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    console.log('✅ Available Topics:', topicsResponse.data.topics.length, 'topics');
    console.log('');

    // Step 4: Test topics selection with just stock topics (no custom topics for now)
    console.log('7️⃣ Testing /onboarding/topics (stock topics only)');
    const selectedTopics = topicsResponse.data.topics.slice(0, 3).map(t => t.id);
    console.log('Selected topic IDs:', selectedTopics);
    
    const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
      topicIds: selectedTopics,
      customTopics: [] // Start with no custom topics
    }, { headers });
    console.log('✅ Topics Selection:', topicsSelectionResponse.data);
    console.log('');

    // Step 5: Test onboarding completion
    console.log('8️⃣ Testing /onboarding/complete');
    const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
    console.log('✅ Onboarding Complete:', completeResponse.data);
    console.log('');

    // Step 6: Test first daily word
    console.log('9️⃣ Testing /first-daily');
    const firstDailyResponse = await axios.get(`${BASE_URL}/first-daily?userId=${userId}`);
    console.log('✅ First Daily Word:', firstDailyResponse.data);
    console.log('');

    console.log('🎉 Complete onboarding flow test successful!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    console.error('Status:', error.response?.status);
    if (error.response?.data) {
      console.error('Response data:', JSON.stringify(error.response.data, null, 2));
    }
  }
}

// Test with custom topics
async function testWithCustomTopics() {
  console.log('\n🧪 Testing onboarding flow with custom topics...\n');

  try {
    // Create another test user
    const TEST_USER_2 = {
      email: 'test-custom@example.com',
      name: 'Test Custom Topics User'
    };

    console.log('👤 Creating second test user...');
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: TEST_USER_2.email,
      password: 'testpassword123',
      name: TEST_USER_2.name
    });
    console.log('✅ User created:', signupResponse.data);
    
    const userId = signupResponse.data.user.id;
    const mockToken = `access_${userId}_mock_token_12345`;
    const headers = {
      'Authorization': `Bearer ${mockToken}`,
      'Content-Type': 'application/json'
    };
    console.log('');

    // Quick onboarding to topics step
    await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
    await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 3 }, { headers });
    await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
    await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers });
    await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'beginner' }, { headers });
    await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers });
    await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });

    // Get topics and test with custom topics
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    const selectedTopics = topicsResponse.data.topics.slice(0, 2).map(t => t.id);

    console.log('🎨 Testing with custom topics...');
    const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
      topicIds: selectedTopics,
      customTopics: ['Photography', 'Cooking', 'Travel']
    }, { headers });
    console.log('✅ Custom Topics Selection:', topicsSelectionResponse.data);
    console.log('');

    // Complete onboarding
    const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
    console.log('✅ Onboarding Complete:', completeResponse.data);
    console.log('');

    console.log('🎉 Custom topics test successful!');

  } catch (error) {
    console.error('❌ Custom topics test failed:', error.response?.data || error.message);
    console.error('Status:', error.response?.status);
  }
}

// Run all tests
async function runAllTests() {
  await testOnboardingWithUser();
  await testWithCustomTopics();
}

runAllTests();
