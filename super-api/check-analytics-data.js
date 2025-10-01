#!/usr/bin/env node

/**
 * Check Analytics Data Script
 * 
 * This script checks what data is actually in the AnonymizedLearningData table
 * and UserTopic table to understand why topic analytics aren't working.
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

async function checkAnalyticsData() {
  console.log('🔍 Checking Analytics Data Structure...\n');
  
  // 1. Check AnonymizedLearningData table
  console.log('📊 Step 1: Checking AnonymizedLearningData table...');
  try {
    const { data: anonymizedData, error } = await supabase
      .from('AnonymizedLearningData')
      .select('*')
      .limit(3);
    
    if (error) {
      console.error('❌ Error fetching anonymized data:', error.message);
    } else {
      console.log(`✅ Found ${anonymizedData.length} anonymized records:`);
      if (anonymizedData.length > 0) {
        console.log('📋 Sample record fields:', Object.keys(anonymizedData[0]));
        console.log('📋 Sample record:', JSON.stringify(anonymizedData[0], null, 2));
      }
    }
    
  } catch (error) {
    console.error('❌ Error checking anonymized data:', error.message);
  }
  
  // 2. Check UserTopic table
  console.log('\n📋 Step 2: Checking UserTopic table...');
  try {
    const { data: userTopics, error } = await supabase
      .from('UserTopic')
      .select(`
        id,
        userId,
        topicId,
        weight,
        enabled,
        topic:Topic(id, name, usageCount)
      `)
      .limit(10);
    
    if (error) {
      console.error('❌ Error fetching user topics:', error.message);
    } else {
      console.log(`✅ Found ${userTopics.length} user topic relationships:`);
      userTopics.forEach(ut => {
        console.log(`   • User ${ut.userId} → ${ut.topic?.name} (${ut.topicId}) - weight: ${ut.weight}, enabled: ${ut.enabled}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error checking user topics:', error.message);
  }
  
  // 3. Check Topic table usage counts
  console.log('\n📈 Step 3: Checking Topic usage counts...');
  try {
    const { data: topics, error } = await supabase
      .from('Topic')
      .select('id, name, usageCount, isActive, isCustom')
      .eq('isActive', true)
      .order('usageCount', { ascending: false })
      .limit(10);
    
    if (error) {
      console.error('❌ Error fetching topics:', error.message);
    } else {
      console.log(`✅ Found ${topics.length} active topics:`);
      topics.forEach(topic => {
        console.log(`   • ${topic.name} (${topic.id}) - ${topic.usageCount} users - Custom: ${topic.isCustom}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error checking topics:', error.message);
  }
  
  // 4. Check if we have any active users with topics
  console.log('\n👥 Step 4: Checking active users with topics...');
  try {
    const { data: activeUsers, error } = await supabase
      .from('User')
      .select(`
        id,
        email,
        onboardingCompleted,
        userTopics:UserTopic(
          topic:Topic(name, usageCount)
        )
      `)
      .eq('onboardingCompleted', true)
      .limit(5);
    
    if (error) {
      console.error('❌ Error fetching active users:', error.message);
    } else {
      console.log(`✅ Found ${activeUsers.length} active users:`);
      activeUsers.forEach(user => {
        console.log(`   • ${user.email} - ${user.userTopics?.length || 0} topics`);
        user.userTopics?.forEach(ut => {
          console.log(`     - ${ut.topic?.name}`);
        });
      });
    }
    
  } catch (error) {
    console.error('❌ Error checking active users:', error.message);
  }
  
  console.log('\n🎯 Summary:');
  console.log('   • If AnonymizedLearningData is empty, topic analytics will be empty');
  console.log('   • If UserTopic has data, we can create real-time topic analytics');
  console.log('   • If Topic.usageCount is 0, topic popularity will be 0');
}

async function main() {
  console.log('🎯 Analytics Data Check Script\n');
  await checkAnalyticsData();
}

main().catch(console.error);
