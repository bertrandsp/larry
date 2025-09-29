const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function checkDatabaseFields() {
  console.log('🔍 Checking database fields...\n');

  try {
    // Create a user and check what fields are actually returned
    console.log('👤 Creating user to check database fields...');
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: `field-check-${Date.now()}@example.com`,
      password: 'field123',
      name: 'Field Check User'
    });
    
    const userId = signupResponse.data.user.id;
    const mockToken = `access_${userId}_mock_token_12345`;
    const headers = {
      'Authorization': `Bearer ${mockToken}`,
      'Content-Type': 'application/json'
    };
    
    console.log('✅ User created:', userId);
    console.log('Initial user data:');
    console.log('  onboardingSource:', signupResponse.data.user.onboardingSource);
    console.log('  learningLevel:', signupResponse.data.user.learningLevel);
    console.log('  widgetOptIn:', signupResponse.data.user.widgetOptIn);
    console.log('  onboardingStep:', signupResponse.data.user.onboardingStep);
    console.log('');

    // Try to set widgetOptIn explicitly
    console.log('🔧 Testing widgetOptIn field update...');
    try {
      const widgetResponse = await axios.post(`${BASE_URL}/onboarding/widget-preference`, { 
        enabled: true 
      }, { headers });
      console.log('✅ Widget preference API call successful:', widgetResponse.data);
    } catch (error) {
      console.log('❌ Widget preference API call failed:', error.response?.data);
    }

    // Now try to complete onboarding to see what fields are missing
    console.log('\n🎯 Testing onboarding completion...');
    try {
      const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
      console.log('✅ Onboarding completed successfully!');
    } catch (error) {
      console.log('❌ Onboarding completion failed:', error.response?.data);
      
      // The error should show us exactly which fields are missing
      if (error.response?.data?.missingFields) {
        console.log('\n🔍 Missing fields analysis:');
        error.response.data.missingFields.forEach(field => {
          console.log(`  - ${field}: Field not found in database or not saved properly`);
        });
      }
    }

    console.log('\n💡 Recommendation:');
    console.log('1. Check if the migration was run in Supabase');
    console.log('2. Verify the field names match between code and database');
    console.log('3. Check RLS policies allow updates to these fields');

  } catch (error) {
    console.error('❌ Field check failed:', error.response?.data || error.message);
  }
}

checkDatabaseFields();
