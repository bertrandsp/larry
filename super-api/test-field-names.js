const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testFieldNames() {
  console.log('🔍 Testing different field name conventions...\n');

  try {
    // Create a user
    const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
      email: `field-test-${Date.now()}@example.com`,
      password: 'test123',
      name: 'Field Test User'
    });
    
    const userId = signupResponse.data.user.id;
    const mockToken = `access_${userId}_mock_token_12345`;
    const headers = {
      'Authorization': `Bearer ${mockToken}`,
      'Content-Type': 'application/json'
    };
    
    console.log('✅ User created:', userId);
    console.log('');

    // Test with snake_case field names (typical PostgreSQL convention)
    console.log('🐍 Testing with snake_case field names...');
    
    // Try to update with snake_case
    const testUpdate = {
      onboarding_source: 'friend',
      learning_level: 'beginner',
      widget_opt_in: true,
      onboarding_step: 'complete',
      updatedAt: new Date().toISOString()
    };
    
    console.log('Attempting update with snake_case fields...');
    console.log('Fields to update:', Object.keys(testUpdate));
    
    // This will likely fail, but we'll see what error we get
    try {
      const response = await axios.post(`${BASE_URL}/onboarding/source`, { 
        source: 'friend' 
      }, { headers });
      console.log('✅ Source update successful');
    } catch (error) {
      console.log('❌ Source update failed:', error.response?.data);
    }

    console.log('\n💡 The issue is likely one of these:');
    console.log('1. Database migration not run - fields don\'t exist');
    console.log('2. Field name mismatch - code uses camelCase, DB uses snake_case');
    console.log('3. RLS policies blocking updates');
    console.log('4. Supabase client configuration issue');
    
    console.log('\n🔧 To fix this:');
    console.log('1. Run the migration in Supabase SQL Editor:');
    console.log('   ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "onboardingSource" TEXT;');
    console.log('   ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "learningLevel" TEXT;');
    console.log('   ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "widgetOptIn" BOOLEAN;');
    console.log('   ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "onboardingStep" TEXT DEFAULT \'welcome\';');
    console.log('');
    console.log('2. Or update the code to use snake_case field names');
    console.log('3. Check RLS policies allow updates to these fields');

  } catch (error) {
    console.error('❌ Field name test failed:', error.response?.data || error.message);
  }
}

testFieldNames();
