#!/usr/bin/env node

/**
 * Check which Supabase project the API is connected to
 */

require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

console.log('🔍 Supabase Connection Debug');
console.log('=' .repeat(50));

console.log('📊 Environment Variables:');
console.log(`SUPABASE_URL: ${supabaseUrl ? supabaseUrl.substring(0, 50) + '...' : 'NOT SET'}`);
console.log(`SUPABASE_SERVICE_ROLE_KEY: ${supabaseServiceRoleKey ? supabaseServiceRoleKey.substring(0, 20) + '...' : 'NOT SET'}`);

if (supabaseUrl && supabaseServiceRoleKey) {
  console.log('\n✅ Supabase credentials are configured');
  console.log(`🌐 Supabase URL: ${supabaseUrl}`);
  
  // Extract project ID from URL
  const projectMatch = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.co/);
  if (projectMatch) {
    console.log(`🏷️  Supabase Project ID: ${projectMatch[1]}`);
  }
  
  console.log('\n🔧 To check this project in Supabase Dashboard:');
  console.log(`1. Go to https://supabase.com/dashboard`);
  console.log(`2. Look for project ID: ${projectMatch ? projectMatch[1] : 'unknown'}`);
  console.log(`3. Check the UserTopic table in that project`);
  
} else {
  console.log('\n❌ Supabase credentials not configured');
  console.log('Check your .env file for SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
}

console.log('\n📋 Next Steps:');
console.log('1. Verify you are looking at the correct Supabase project');
console.log('2. Check UserTopic table in that specific project');
console.log('3. Run this SQL query in the correct project:');
console.log(`   SELECT * FROM "UserTopic" WHERE "userId" = 'email-user-btsp60yahoocom';`);
