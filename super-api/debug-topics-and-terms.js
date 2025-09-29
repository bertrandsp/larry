const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function debugTopicsAndTerms() {
  console.log('🔍 Debugging topics and terms...\n');

  try {
    // Get all topics
    console.log('📚 Getting all topics...');
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    console.log('Topics found:', topicsResponse.data.topics.length);
    
    topicsResponse.data.topics.forEach((topic, index) => {
      console.log(`${index + 1}. ${topic.name} (${topic.id})`);
    });
    console.log('');

    // Create a test user and get their UserTopic relationships
    console.log('👤 Creating test user for debugging...');
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: 'debug@example.com',
      password: 'testpassword123',
      name: 'Debug User'
    });
    
    const userId = signupResponse.data.user.id;
    const mockToken = `access_${userId}_mock_token_12345`;
    const headers = {
      'Authorization': `Bearer ${mockToken}`,
      'Content-Type': 'application/json'
    };

    // Quick onboarding to topics
    await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
    await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 3 }, { headers });
    await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
    await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers });
    await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'beginner' }, { headers });
    await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers });
    await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });

    // Select topics
    const selectedTopics = topicsResponse.data.topics.slice(0, 3).map(t => t.id);
    const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
      topicIds: selectedTopics,
      customTopics: []
    }, { headers });
    console.log('✅ Topics selected:', topicsSelectionResponse.data);
    console.log('');

    // Complete onboarding
    await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });

    // Try to get first daily word and see what happens
    console.log('🎯 Attempting to get first daily word...');
    try {
      const firstDailyResponse = await axios.get(`${BASE_URL}/first-daily?userId=${userId}`);
      console.log('✅ First daily word:', firstDailyResponse.data);
    } catch (error) {
      console.log('❌ First daily word failed:', error.response?.data);
    }

  } catch (error) {
    console.error('❌ Debug failed:', error.response?.data || error.message);
  }
}

debugTopicsAndTerms();
