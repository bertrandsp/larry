#!/usr/bin/env node

/**
 * Test Topic Selection Script
 * 
 * This script tests topic selection during onboarding to ensure
 * users can properly select topics and they get saved to the database.
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

async function testTopicSelection() {
  console.log('🧪 Testing Topic Selection Process...\n');
  
  // 1. First, let's see what topics are available
  console.log('📋 Step 1: Fetching available topics...');
  try {
    const { data: topics, error } = await supabase
      .from('Topic')
      .select('id, name, description, maxTerms, usageCount')
      .eq('isCustom', false)
      .eq('isActive', true)
      .order('name')
      .limit(10);
    
    if (error) {
      console.error('❌ Error fetching topics:', error.message);
      return;
    }
    
    console.log(`✅ Found ${topics.length} available topics:`);
    topics.forEach(topic => {
      console.log(`   • ${topic.name} (${topic.id}) - ${topic.usageCount} users`);
    });
    
    if (topics.length === 0) {
      console.log('❌ No topics found. Run create-sample-topics.js first.');
      return;
    }
    
    // Select first 3 topics for testing
    const selectedTopicIds = topics.slice(0, 3).map(t => t.id);
    console.log(`\n🎯 Selected topics for testing: ${selectedTopicIds.join(', ')}`);
    
  } catch (error) {
    console.error('❌ Error in topic fetching:', error.message);
    return;
  }
  
  // 2. Create a test user
  console.log('\n👤 Step 2: Creating test user...');
  const testEmail = `topic-test-${Date.now()}@example.com`;
  const testUserId = `email-user-${testEmail.replace(/[@.]/g, '')}`;
  
  try {
    const { data: user, error } = await supabase
      .from('User')
      .insert({
        id: testUserId,
        email: testEmail,
        onboardingCompleted: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      })
      .select()
      .single();
    
    if (error) {
      console.error('❌ Error creating user:', error.message);
      return;
    }
    
    console.log(`✅ Created test user: ${testEmail} (${testUserId})`);
    
  } catch (error) {
    console.error('❌ Error creating user:', error.message);
    return;
  }
  
  // 3. Test topic selection API endpoint
  console.log('\n📝 Step 3: Testing topic selection API...');
  const topicIds = ['topic-blockchain', 'topic-ai', 'topic-startups'];
  
  try {
    const response = await fetch('http://localhost:4001/onboarding/topics', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer access_${testUserId}_${Date.now()}`
      },
      body: JSON.stringify({
        topicIds: topicIds
      })
    });
    
    const result = await response.json();
    
    if (response.ok) {
      console.log('✅ Topic selection successful:', result);
    } else {
      console.error('❌ Topic selection failed:', result);
    }
    
  } catch (error) {
    console.error('❌ Error calling topic selection API:', error.message);
  }
  
  // 4. Verify topics were saved
  console.log('\n🔍 Step 4: Verifying topics were saved...');
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
      .eq('userId', testUserId);
    
    if (error) {
      console.error('❌ Error fetching user topics:', error.message);
    } else {
      console.log(`✅ Found ${userTopics.length} user topics:`);
      userTopics.forEach(ut => {
        console.log(`   • ${ut.topic.name} (${ut.topicId}) - weight: ${ut.weight}, enabled: ${ut.enabled}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error verifying user topics:', error.message);
  }
  
  // 5. Check topic usage counts
  console.log('\n📊 Step 5: Checking topic usage counts...');
  try {
    const { data: topics, error } = await supabase
      .from('Topic')
      .select('id, name, usageCount')
      .in('id', topicIds);
    
    if (error) {
      console.error('❌ Error fetching topic usage:', error.message);
    } else {
      console.log('✅ Topic usage counts:');
      topics.forEach(topic => {
        console.log(`   • ${topic.name}: ${topic.usageCount} users`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error checking usage counts:', error.message);
  }
  
  // 6. Clean up test user
  console.log('\n🧹 Step 6: Cleaning up test user...');
  try {
    const { error } = await supabase
      .from('User')
      .delete()
      .eq('id', testUserId);
    
    if (error) {
      console.error('❌ Error deleting test user:', error.message);
    } else {
      console.log('✅ Test user cleaned up');
    }
    
  } catch (error) {
    console.error('❌ Error cleaning up:', error.message);
  }
  
  console.log('\n🎉 Topic selection test completed!');
}

async function main() {
  console.log('🎯 Topic Selection Test Script\n');
  await testTopicSelection();
}

main().catch(console.error);
