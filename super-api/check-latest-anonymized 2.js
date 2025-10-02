#!/usr/bin/env node

/**
 * Check Latest Anonymized Data Script
 * 
 * This script checks the most recent anonymized data to see if topic preferences
 * are being captured correctly after the fix.
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  }
);

async function checkLatestAnonymized() {
  console.log('🔍 Checking Latest Anonymized Data...\n');
  
  // Check the most recent anonymized records
  console.log('📊 Checking most recent anonymized records...');
  try {
    const { data: anonymizedData, error } = await supabase
      .from('AnonymizedLearningData')
      .select('*')
      .order('anonymized_at', { ascending: false })
      .limit(5);
    
    if (error) {
      console.error('❌ Error fetching anonymized data:', error.message);
    } else {
      console.log(`✅ Found ${anonymizedData.length} anonymized records (most recent first):`);
      anonymizedData.forEach((record, index) => {
        console.log(`\n📋 Record ${index + 1} (anonymized: ${record.anonymized_at}):`);
        console.log(`   • Age Bracket: ${record.user_age_bracket}`);
        console.log(`   • Learning Level: ${record.learning_level}`);
        console.log(`   • Topic Preferences: ${JSON.stringify(record.topic_preferences)}`);
        console.log(`   • Learning Pattern: ${record.learning_pattern}`);
        console.log(`   • Terms Learned: ${record.total_terms_learned}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error checking anonymized data:', error.message);
  }
  
  // Check if we have any records with non-empty topic preferences
  console.log('\n🎯 Checking for records with topic preferences...');
  try {
    const { data: recordsWithTopics, error } = await supabase
      .from('AnonymizedLearningData')
      .select('id, topic_preferences, anonymized_at')
      .not('topic_preferences', 'eq', '[]')
      .limit(10);
    
    if (error) {
      console.error('❌ Error fetching records with topics:', error.message);
    } else {
      console.log(`✅ Found ${recordsWithTopics.length} records with topic preferences:`);
      recordsWithTopics.forEach(record => {
        console.log(`   • ${record.anonymized_at}: ${JSON.stringify(record.topic_preferences)}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error checking records with topics:', error.message);
  }
}

async function main() {
  console.log('🎯 Latest Anonymized Data Check Script\n');
  await checkLatestAnonymized();
}

main().catch(console.error);
