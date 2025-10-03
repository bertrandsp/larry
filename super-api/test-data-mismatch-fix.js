#!/usr/bin/env node

/**
 * Test script to verify the data mismatch fixes
 * This tests that the API returns data in the expected format for iOS
 */

const BASE_URL = 'http://localhost:4001';

async function testUserTopics(userId) {
  console.log(`🔍 Testing User Topics API for: ${userId}`);
  console.log('=' .repeat(60));
  
  try {
    const response = await fetch(`${BASE_URL}/user/${userId}/topics`);
    const data = await response.json();
    
    console.log(`📊 Response Status: ${response.status}`);
    
    if (data.success && data.topics) {
      console.log(`✅ Successfully fetched ${data.topics.length} user topics`);
      
      // Verify each topic has the expected fields for iOS
      const expectedFields = ['id', 'topicId', 'name', 'weight', 'enabled', 'termCount', 'category'];
      let allValid = true;
      
      data.topics.forEach((topic, index) => {
        console.log(`\n--- Topic ${index + 1}: ${topic.name} ---`);
        console.log(`ID: ${topic.id}`);
        console.log(`TopicID: ${topic.topicId}`);
        console.log(`Name: ${topic.name}`);
        console.log(`Weight: ${topic.weight}`);
        console.log(`Enabled: ${topic.enabled}`);
        console.log(`TermCount: ${topic.termCount}`);
        console.log(`Category: ${topic.category}`);
        
        // Check for expected fields
        const missingFields = expectedFields.filter(field => !(field in topic));
        if (missingFields.length > 0) {
          console.log(`❌ Missing fields: ${missingFields.join(', ')}`);
          allValid = false;
        }
        
        // Check for unexpected fields (should not have createdAt/updatedAt)
        const unexpectedFields = Object.keys(topic).filter(field => !expectedFields.includes(field));
        if (unexpectedFields.length > 0) {
          console.log(`⚠️  Unexpected fields: ${unexpectedFields.join(', ')}`);
        }
        
        // Validate field types
        if (typeof topic.weight !== 'number') {
          console.log(`❌ Weight should be number, got: ${typeof topic.weight}`);
          allValid = false;
        }
        
        if (typeof topic.enabled !== 'boolean') {
          console.log(`❌ Enabled should be boolean, got: ${typeof topic.enabled}`);
          allValid = false;
        }
        
        if (typeof topic.termCount !== 'number') {
          console.log(`❌ TermCount should be number, got: ${typeof topic.termCount}`);
          allValid = false;
        }
      });
      
      if (allValid) {
        console.log(`\n✅ All topics have valid structure for iOS decoding!`);
      } else {
        console.log(`\n❌ Some topics have invalid structure!`);
      }
      
    } else {
      console.log(`❌ Failed to fetch user topics:`, data);
    }
    
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
  }
}

async function testAvailableTopics() {
  console.log(`\n🔍 Testing Available Topics API`);
  console.log('=' .repeat(60));
  
  try {
    const response = await fetch(`${BASE_URL}/topics/available`);
    const data = await response.json();
    
    console.log(`📊 Response Status: ${response.status}`);
    
    if (data.success && data.topics) {
      console.log(`✅ Successfully fetched ${data.topics.length} available topics`);
      
      // Check first few topics for category data
      data.topics.slice(0, 3).forEach((topic, index) => {
        console.log(`\n--- Available Topic ${index + 1}: ${topic.name} ---`);
        console.log(`Category: ${topic.category}`);
        console.log(`IsActive: ${topic.isActive}`);
        console.log(`TermCount: ${topic.termCount}`);
        console.log(`UserCount: ${topic.userCount}`);
      });
      
      // Check if categories are varied (not all 'other')
      const categories = [...new Set(data.topics.map(t => t.category))];
      console.log(`\n📊 Categories found: ${categories.join(', ')}`);
      
      if (categories.length > 1) {
        console.log(`✅ Categories are varied, not all hardcoded to 'other'`);
      } else {
        console.log(`⚠️  All categories are '${categories[0]}' - may need schema update`);
      }
      
    } else {
      console.log(`❌ Failed to fetch available topics:`, data);
    }
    
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
  }
}

async function main() {
  const userId = process.argv[2] || 'email-user-btsp60yahoocom';
  
  console.log('🚀 Data Mismatch Fix Verification Script');
  console.log(`📍 Base URL: ${BASE_URL}`);
  console.log(`👤 User ID: ${userId}`);
  
  await testAvailableTopics();
  await testUserTopics(userId);
  
  console.log('\n📋 Summary:');
  console.log('✅ UserTopic struct should now decode successfully');
  console.log('✅ Categories should be real data instead of hardcoded "other"');
  console.log('✅ No createdAt/updatedAt fields that cause decoding errors');
  console.log('\n🔧 Next Steps:');
  console.log('1. Test the iOS app to see if topics load properly');
  console.log('2. Verify that categories display correctly in the UI');
  console.log('3. Check that user can add/remove topics without issues');
}

main().catch(console.error);
