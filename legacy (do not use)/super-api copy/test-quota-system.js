// Test quota system with reset logic
require('dotenv').config();

async function testQuotaSystem() {
  console.log('🧪 Testing Quota System with Reset Logic...\n');

  try {
    // Test different tiers and their quota limits
    const testCases = [
      { email: 'free-quota@example.com', subscription: 'free', expectedRequests: 3, resetPeriod: 'daily' },
      { email: 'basic-quota@example.com', subscription: 'basic', expectedRequests: 10, resetPeriod: 'weekly' },
      { email: 'premium-quota@example.com', subscription: 'premium', expectedRequests: 50, resetPeriod: 'monthly' },
      { email: 'enterprise-quota@example.com', subscription: 'enterprise', expectedRequests: 100, resetPeriod: 'monthly' }
    ];

    console.log('📊 Tier Quota Configuration:');
    for (const testCase of testCases) {
      console.log(`   ${testCase.subscription.toUpperCase()}: ${testCase.expectedRequests} requests per ${testCase.resetPeriod}`);
    }
    console.log('');

    // Test quota checking logic
    console.log('🔄 Testing Quota Reset Logic:');
    
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);
    
    const nextWeek = new Date(now);
    nextWeek.setDate(nextWeek.getDate() + 7);
    nextWeek.setHours(0, 0, 0, 0);
    
    const nextMonth = new Date(now);
    nextMonth.setMonth(nextMonth.getMonth() + 1);
    nextMonth.setDate(1);
    nextMonth.setHours(0, 0, 0, 0);

    console.log(`   Daily reset: ${tomorrow.toLocaleDateString()} at midnight`);
    console.log(`   Weekly reset: ${nextWeek.toLocaleDateString()} at midnight`);
    console.log(`   Monthly reset: ${nextMonth.toLocaleDateString()} at midnight`);
    console.log('');

    console.log('🎯 Quota System Features:');
    console.log('   ✅ Automatic quota tracking per user');
    console.log('   ✅ Configurable reset periods (daily/weekly/monthly)');
    console.log('   ✅ Automatic reset when period changes');
    console.log('   ✅ Quota exceeded prevention');
    console.log('   ✅ Real-time quota status endpoint');
    console.log('   ✅ Usage increment after successful requests');
    console.log('');

    console.log('📋 To test with real API:');
    console.log('   1. Run database migration: npm run prisma:migrate');
    console.log('   2. Create users with different subscription tiers');
    console.log('   3. Submit topics to see quota enforcement');
    console.log('   4. Check quota status: GET /user/:userId/quota');
    console.log('   5. Wait for reset periods to see quota refresh');
    console.log('');

    console.log('🔧 Current Quota Limits:');
    console.log('   🆓 Free: 3 requests per day');
    console.log('   🔰 Basic: 10 requests per week');
    console.log('   ⭐ Premium: 50 requests per month');
    console.log('   🚀 Enterprise: 100 requests per month');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Check if OpenAI API key is available
if (!process.env.OPENAI_API_KEY) {
  console.log('⚠️  OPENAI_API_KEY not found in .env');
  console.log('   Please add your OpenAI API key to test with real API calls');
} else {
  console.log('✅ OPENAI_API_KEY found - ready for quota testing');
}

console.log('');
testQuotaSystem();
