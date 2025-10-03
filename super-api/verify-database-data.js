#!/usr/bin/env node

/**
 * Verify the actual data in the Supabase database
 */

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

async function verifyDatabaseData() {
  console.log('🔍 Verifying Database Data');
  console.log('=' .repeat(50));
  
  if (!supabaseUrl || !supabaseServiceRoleKey) {
    console.log('❌ Supabase credentials not configured');
    return;
  }
  
  const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
  
  const userId = 'email-user-btsp60yahoocom';
  
  try {
    // Check if user exists
    console.log(`\n👤 Checking if user exists: ${userId}`);
    const { data: user, error: userError } = await supabase
      .from('User')
      .select('id, email, name')
      .eq('id', userId)
      .single();
    
    if (userError) {
      console.log(`❌ User not found: ${userError.message}`);
    } else {
      console.log(`✅ User found:`, user);
    }
    
    // Check UserTopic records
    console.log(`\n📚 Checking UserTopic records for user: ${userId}`);
    const { data: userTopics, error: topicsError } = await supabase
      .from('UserTopic')
      .select(`
        id,
        userId,
        topicId,
        weight,
        enabled,
        topic:Topic(
          id,
          name,
          description,
          category
        )
      `)
      .eq('userId', userId);
    
    if (topicsError) {
      console.log(`❌ Error fetching user topics: ${topicsError.message}`);
    } else {
      console.log(`✅ Found ${userTopics.length} UserTopic records:`);
      userTopics.forEach((ut, index) => {
        console.log(`  ${index + 1}. ${ut.topic?.name || 'Unknown Topic'}`);
        console.log(`     - UserTopic ID: ${ut.id}`);
        console.log(`     - Topic ID: ${ut.topicId}`);
        console.log(`     - Weight: ${ut.weight}`);
        console.log(`     - Enabled: ${ut.enabled}`);
        console.log(`     - Category: ${ut.topic?.category || 'N/A'}`);
      });
    }
    
    // Check all UserTopic records (to see what users have topics)
    console.log(`\n📊 Checking all UserTopic records in database:`);
    const { data: allUserTopics, error: allTopicsError } = await supabase
      .from('UserTopic')
      .select('userId, topicId')
      .limit(20);
    
    if (allTopicsError) {
      console.log(`❌ Error fetching all user topics: ${allTopicsError.message}`);
    } else {
      console.log(`✅ Found ${allUserTopics.length} total UserTopic records (showing first 20):`);
      const userIds = [...new Set(allUserTopics.map(ut => ut.userId))];
      console.log(`   Unique users with topics: ${userIds.length}`);
      userIds.forEach(userId => {
        const count = allUserTopics.filter(ut => ut.userId === userId).length;
        console.log(`   - ${userId}: ${count} topics`);
      });
    }
    
  } catch (error) {
    console.error(`❌ Database query failed: ${error.message}`);
  }
}

verifyDatabaseData().catch(console.error);
