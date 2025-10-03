#!/usr/bin/env node

/**
 * Test the raw Supabase response to see what's being returned
 */

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

async function testRawSupabaseResponse() {
  console.log('🔍 Testing Raw Supabase Response');
  console.log('=' .repeat(50));
  
  const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
  const userId = 'email-user-btsp60yahoocom';
  
  try {
    // Test the exact same query as the API
    console.log('📡 Running API query...');
    const { data: userTopics, error: topicsError } = await supabase
      .from('UserTopic')
      .select(`
        id,
        topicId,
        weight,
        enabled,
        topic:Topic(
          id,
          name,
          description,
          category,
          isActive,
          terms:Term(count)
        )
      `)
      .eq('userId', userId)
      .order('id', { ascending: true });
    
    if (topicsError) {
      console.log(`❌ Error: ${topicsError.message}`);
      return;
    }
    
    console.log(`✅ Raw Supabase response (${userTopics.length} records):`);
    console.log(JSON.stringify(userTopics, null, 2));
    
    // Test the API processing logic
    console.log('\n🔧 Testing API processing logic...');
    const result = (userTopics || []).map(ut => {
      // Handle the case where topic might be an array (Supabase sometimes returns arrays for single relations)
      const topic = Array.isArray(ut.topic) ? ut.topic[0] : ut.topic;
      const terms = Array.isArray(topic?.terms) ? topic.terms : [topic?.terms].filter(Boolean);
      
      console.log(`\nProcessing UserTopic ${ut.id}:`);
      console.log(`  Raw topic data:`, JSON.stringify(ut.topic, null, 2));
      console.log(`  Processed topic:`, JSON.stringify(topic, null, 2));
      console.log(`  Topic category:`, topic?.category);
      
      return {
        id: ut.id,
        topicId: ut.topicId,
        name: topic?.name || 'Unknown Topic',
        weight: ut.weight,
        enabled: ut.enabled,
        termCount: terms.length || (topic?.terms)?.count || 0,
        category: topic?.category || 'other' // Use real category data
      };
    });
    
    console.log('\n✅ Final processed result:');
    console.log(JSON.stringify(result, null, 2));
    
  } catch (error) {
    console.error(`❌ Test failed: ${error.message}`);
  }
}

testRawSupabaseResponse().catch(console.error);
