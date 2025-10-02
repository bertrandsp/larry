#!/usr/bin/env node

/**
 * Test User Deletion Topic Extraction Script
 * 
 * This script tests the user deletion process to see if topic preferences
 * are being extracted correctly before deletion.
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

async function testTopicExtraction() {
  console.log('🧪 Testing Topic Extraction During User Deletion...\n');
  
  // 1. Create a test user with topics
  console.log('👤 Step 1: Creating test user with topics...');
  const testEmail = `topic-extraction-test-${Date.now()}@example.com`;
  const testUserId = `email-user-${testEmail.replace(/[@.]/g, '')}`;
  
  try {
    // Create user
    const { data: user, error: userError } = await supabase
      .from('User')
      .insert({
        id: testUserId,
        email: testEmail,
        onboardingCompleted: true,
        learningLevel: 'intermediate',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      })
      .select()
      .single();
    
    if (userError) {
      console.error('❌ Error creating user:', userError.message);
      return;
    }
    
    console.log(`✅ Created test user: ${testEmail} (${testUserId})`);
    
    // Add topics to user
    const topicIds = ['topic-blockchain', 'topic-ai', 'topic-startups'];
    const userTopics = topicIds.map(topicId => ({
      id: `ut-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId: testUserId,
      topicId: topicId,
      weight: 33,
      enabled: true
    }));
    
    const { data: insertedTopics, error: topicsError } = await supabase
      .from('UserTopic')
      .insert(userTopics)
      .select(`
        topicId,
        topic:Topic(name)
      `);
    
    if (topicsError) {
      console.error('❌ Error adding topics:', topicsError.message);
    } else {
      console.log(`✅ Added ${insertedTopics.length} topics to user:`);
      insertedTopics.forEach(ut => {
        console.log(`   • ${ut.topic?.name} (${ut.topicId})`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error in user creation:', error.message);
    return;
  }
  
  // 2. Test topic extraction (simulate the deletion process)
  console.log('\n🔍 Step 2: Testing topic extraction...');
  try {
    const { data: userTopics, error: userTopicsError } = await supabase
      .from('UserTopic')
      .select(`
        topicId,
        topic:Topic(name)
      `)
      .eq('userId', testUserId);
    
    let uniqueTopics = ['General Vocabulary']; // Default fallback
    if (!userTopicsError && userTopics && userTopics.length > 0) {
      uniqueTopics = userTopics.map(ut => ut.topic?.name || 'Unknown Topic').filter(Boolean);
    }
    
    console.log('✅ Topic extraction results:');
    console.log(`   • Raw userTopics: ${JSON.stringify(userTopics)}`);
    console.log(`   • Extracted topics: ${JSON.stringify(uniqueTopics)}`);
    
    if (userTopicsError) {
      console.error('❌ Error extracting topics:', userTopicsError.message);
    }
    
  } catch (error) {
    console.error('❌ Error in topic extraction:', error.message);
  }
  
  // 3. Test actual user deletion via API
  console.log('\n🗑️ Step 3: Testing user deletion via API...');
  try {
    const response = await fetch(`http://localhost:4001/user/${testUserId}/delete`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer access_${testUserId}_${Date.now()}`
      }
    });
    
    const result = await response.json();
    
    if (response.ok) {
      console.log('✅ User deletion successful:', result);
    } else {
      console.error('❌ User deletion failed:', result);
    }
    
  } catch (error) {
    console.error('❌ Error calling deletion API:', error.message);
  }
  
  // 4. Check if topic preferences were captured in anonymized data
  console.log('\n📊 Step 4: Checking anonymized data...');
  try {
    const { data: anonymizedData, error } = await supabase
      .from('AnonymizedLearningData')
      .select('topic_preferences, anonymized_at')
      .order('anonymized_at', { ascending: false })
      .limit(1);
    
    if (error) {
      console.error('❌ Error fetching anonymized data:', error.message);
    } else if (anonymizedData && anonymizedData.length > 0) {
      const latest = anonymizedData[0];
      console.log('✅ Latest anonymized record:');
      console.log(`   • Topic Preferences: ${JSON.stringify(latest.topic_preferences)}`);
      console.log(`   • Anonymized At: ${latest.anonymized_at}`);
      
      if (latest.topic_preferences && latest.topic_preferences.length > 0) {
        console.log('🎉 SUCCESS: Topic preferences were captured!');
      } else {
        console.log('❌ ISSUE: Topic preferences are empty');
      }
    } else {
      console.log('❌ No anonymized data found');
    }
    
  } catch (error) {
    console.error('❌ Error checking anonymized data:', error.message);
  }
  
  console.log('\n🎯 Test completed!');
}

async function main() {
  console.log('🎯 User Deletion Topic Extraction Test Script\n');
  await testTopicExtraction();
}

main().catch(console.error);
