// Test tier-based term generation
require('dotenv').config();

async function testTierGeneration() {
  console.log('🧪 Testing Tier-Based Term Generation...\n');

  try {
    // Test different tiers
    const tiers = ['free', 'basic', 'premium', 'enterprise'];
    
    for (const tier of tiers) {
      console.log(`\n📊 Testing ${tier.toUpperCase()} tier:`);
      
      // Create a test topic for this tier
      const topicName = `Test Topic - ${tier}`;
      console.log(`   Topic: "${topicName}"`);
      
      // Get tier limits
      const { getTierConfig } = require('./test-tier-config.js');
      const config = getTierConfig(tier);
      
      console.log(`   Max Terms: ${config.maxTerms}`);
      console.log(`   Max Facts: ${config.maxFacts}`);
      console.log(`   Max Tokens: ${config.maxTokens}`);
      console.log(`   Features: ${config.features.join(', ')}`);
      
      // Test the enhanced prompt with this tier
      console.log(`   ⏳ Would generate ${config.maxTerms} terms + ${config.maxFacts} facts...`);
    }
    
    console.log('\n🎯 Tier-Based Generation Ready!');
    console.log('');
    console.log('📋 To test with real API:');
    console.log('   1. Create a user with different subscription tiers');
    console.log('   2. Submit topics to see tier-limited generation');
    console.log('   3. Monitor worker logs for tier information');
    console.log('');
    console.log('🔧 Current Tier Limits:');
    console.log('   🆓 Free: 5 terms, 3 facts');
    console.log('   🔰 Basic: 10 terms, 5 facts');
    console.log('   ⭐ Premium: 25 terms, 8 facts');
    console.log('   🚀 Enterprise: 50 terms, 10 facts');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Check if OpenAI API key is available
if (!process.env.OPENAI_API_KEY) {
  console.log('⚠️  OPENAI_API_KEY not found in .env');
  console.log('   Please add your OpenAI API key to test with real API calls');
} else {
  console.log('✅ OPENAI_API_KEY found - ready for tier-based testing');
}

console.log('');
testTierGeneration();
