const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function debugUserData() {
  console.log('🔍 Debugging user data...\n');

  try {
    // Create a user and go through the flow step by step
    console.log('👤 Creating debug user...');
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: `debug-user-${Date.now()}@example.com`,
      password: 'debug123',
      name: 'Debug User'
    });
    
    const userId = signupResponse.data.user.id;
    const mockToken = `access_${userId}_mock_token_12345`;
    const headers = {
      'Authorization': `Bearer ${mockToken}`,
      'Content-Type': 'application/json'
    };
    console.log('✅ User created:', userId);
    console.log('');

    // Go through each step and check the data
    console.log('📱 Step 1: Welcome');
    await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
    console.log('✅ Welcome completed');
    console.log('');

    console.log('📱 Step 2: Daily Goal');
    await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 3 }, { headers });
    console.log('✅ Daily Goal completed');
    console.log('');

    console.log('📱 Step 3: Source');
    await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers });
    console.log('✅ Source completed');
    console.log('');

    console.log('📱 Step 4: Skill Level');
    await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'beginner' }, { headers });
    console.log('✅ Skill Level completed');
    console.log('');

    console.log('📱 Step 5: Widget Preference (THIS IS THE PROBLEMATIC STEP)');
    const widgetResponse = await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers });
    console.log('✅ Widget Preference response:', widgetResponse.data);
    console.log('');

    console.log('📱 Step 6: Motivation');
    await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
    console.log('✅ Motivation completed');
    console.log('');

    // Now try to complete onboarding
    console.log('🎯 Attempting to complete onboarding...');
    try {
      const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
      console.log('✅ Onboarding completed successfully!');
      console.log('Response:', completeResponse.data);
    } catch (error) {
      console.log('❌ Onboarding completion failed:');
      console.log('Error:', error.response?.data);
      console.log('');
      console.log('This suggests the widgetOptIn field is not being saved properly.');
    }

  } catch (error) {
    console.error('❌ Debug failed:', error.response?.data || error.message);
  }
}

debugUserData();
