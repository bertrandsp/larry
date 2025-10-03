#!/usr/bin/env node

/**
 * Detailed debug script to investigate user topics discrepancy
 * This will help identify why iOS shows topics that aren't in the database
 */

const BASE_URL = 'http://localhost:4001';

async function testAPIEndpoint(userId) {
  console.log(`🔍 Testing API Endpoint for User: ${userId}`);
  console.log('=' .repeat(60));
  
  try {
    console.log(`📡 Making request to: GET ${BASE_URL}/user/${userId}/topics`);
    
    const response = await fetch(`${BASE_URL}/user/${userId}/topics`);
    const responseText = await response.text();
    
    console.log(`📊 Response Status: ${response.status}`);
    console.log(`📊 Response Headers:`, Object.fromEntries(response.headers.entries()));
    console.log(`📊 Response Body (Raw):`, responseText);
    
    try {
      const data = JSON.parse(responseText);
      console.log(`📊 Response Body (Parsed):`, JSON.stringify(data, null, 2));
      
      if (data.success && data.topics) {
        console.log(`\n✅ API Found ${data.topics.length} topics:`);
        data.topics.forEach((topic, index) => {
          console.log(`  ${index + 1}. ${topic.name}`);
          console.log(`     - ID: ${topic.id}`);
          console.log(`     - TopicID: ${topic.topicId}`);
          console.log(`     - Weight: ${topic.weight}`);
          console.log(`     - Enabled: ${topic.enabled}`);
          console.log(`     - Category: ${topic.category}`);
          console.log(`     - TermCount: ${topic.termCount}`);
        });
      } else if (data.error) {
        console.log(`❌ API Error: ${data.error}`);
      } else {
        console.log(`⚠️  Unexpected response format`);
      }
      
    } catch (parseError) {
      console.log(`❌ Failed to parse JSON response: ${parseError.message}`);
    }
    
  } catch (error) {
    console.error(`❌ Request failed: ${error.message}`);
  }
}

async function testHealthEndpoint() {
  console.log(`\n🔍 Testing Health Endpoint`);
  console.log('=' .repeat(60));
  
  try {
    const response = await fetch(`${BASE_URL}/health`);
    const data = await response.json();
    
    console.log(`📊 Health Status: ${response.status}`);
    console.log(`📊 Health Response:`, JSON.stringify(data, null, 2));
    
  } catch (error) {
    console.error(`❌ Health check failed: ${error.message}`);
  }
}

async function testAvailableTopics() {
  console.log(`\n🔍 Testing Available Topics Endpoint`);
  console.log('=' .repeat(60));
  
  try {
    const response = await fetch(`${BASE_URL}/topics/available`);
    const data = await response.json();
    
    console.log(`📊 Available Topics Status: ${response.status}`);
    
    if (data.success && data.topics) {
      console.log(`📊 Found ${data.topics.length} available topics`);
      console.log(`📊 First 5 topics:`, data.topics.slice(0, 5).map(t => t.name));
    } else {
      console.log(`📊 Available Topics Response:`, JSON.stringify(data, null, 2));
    }
    
  } catch (error) {
    console.error(`❌ Available topics failed: ${error.message}`);
  }
}

async function checkServerLogs() {
  console.log(`\n🔍 Checking Recent Server Logs`);
  console.log('=' .repeat(60));
  
  try {
    const fs = require('fs');
    const path = require('path');
    
    const logFiles = ['server.log', 'logs/combined.log', 'logs/error.log'];
    
    for (const logFile of logFiles) {
      const logPath = path.join(__dirname, logFile);
      if (fs.existsSync(logPath)) {
        console.log(`\n📄 ${logFile}:`);
        const content = fs.readFileSync(logPath, 'utf8');
        const lines = content.split('\n').slice(-10); // Last 10 lines
        lines.forEach(line => {
          if (line.trim()) {
            console.log(`   ${line}`);
          }
        });
      }
    }
    
  } catch (error) {
    console.error(`❌ Failed to read logs: ${error.message}`);
  }
}

async function main() {
  const userId = process.argv[2] || 'email-user-btsp60yahoocom';
  
  console.log('🚀 Detailed User Topics Debug Script');
  console.log(`📍 Base URL: ${BASE_URL}`);
  console.log(`👤 User ID: ${userId}`);
  console.log(`⏰ Timestamp: ${new Date().toISOString()}`);
  
  await testHealthEndpoint();
  await testAvailableTopics();
  await testAPIEndpoint(userId);
  await checkServerLogs();
  
  console.log(`\n📋 Debug Summary:`);
  console.log(`1. Check if the API is responding correctly`);
  console.log(`2. Verify the user ID format matches database`);
  console.log(`3. Check server logs for any errors`);
  console.log(`4. Compare API response with database records`);
  
  console.log(`\n🔧 Next Steps:`);
  console.log(`1. Run this in Supabase SQL Editor:`);
  console.log(`   SELECT * FROM "UserTopic" WHERE "userId" = '${userId}';`);
  console.log(`2. Check if user exists:`);
  console.log(`   SELECT * FROM "User" WHERE "id" = '${userId}';`);
  console.log(`3. Clear iOS app cache and retry`);
}

main().catch(console.error);
