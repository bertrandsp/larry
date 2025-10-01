#!/usr/bin/env node

/**
 * Test Script for User Deletion and Analytics
 * 
 * This script helps test the user deletion endpoint and analytics system
 */

const API_BASE = 'http://localhost:4001';

async function testAnalytics() {
  console.log('🔍 Testing Analytics Endpoints...\n');
  
  try {
    // Test dashboard analytics
    console.log('📊 Testing Dashboard Analytics...');
    const dashboard = await fetch(`${API_BASE}/analytics/dashboard`);
    const dashboardData = await dashboard.json();
    console.log('Dashboard Response:', JSON.stringify(dashboardData, null, 2));
    
    // Test topic popularity
    console.log('\n📈 Testing Topic Popularity...');
    const topics = await fetch(`${API_BASE}/analytics/topics/popularity`);
    const topicsData = await topics.json();
    console.log('Topics Response:', JSON.stringify(topicsData, null, 2));
    
    // Test learning patterns
    console.log('\n🧠 Testing Learning Patterns...');
    const patterns = await fetch(`${API_BASE}/analytics/learning-patterns`);
    const patternsData = await patterns.json();
    console.log('Patterns Response:', JSON.stringify(patternsData, null, 2));
    
  } catch (error) {
    console.error('❌ Analytics test failed:', error.message);
  }
}

async function testUserDeletion(userId) {
  console.log(`🗑️ Testing User Deletion for ID: ${userId}...\n`);
  
  try {
    // First, check if user exists
    console.log('1️⃣ Checking if user exists...');
    const userCheck = await fetch(`${API_BASE}/user/${userId}`);
    
    if (!userCheck.ok) {
      console.log('❌ User not found or endpoint not accessible');
      return;
    }
    
    const userData = await userCheck.json();
    console.log('✅ User found:', userData.user?.email || 'Unknown email');
    
    // Test deletion
    console.log('\n2️⃣ Testing user deletion...');
    const deleteResponse = await fetch(`${API_BASE}/user/${userId}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const deleteData = await deleteResponse.json();
    
    if (deleteResponse.ok) {
      console.log('✅ User deletion successful!');
      console.log('Deletion Response:', JSON.stringify(deleteData, null, 2));
      
      // Check if anonymized data was created
      console.log('\n3️⃣ Checking anonymized data...');
      const analytics = await fetch(`${API_BASE}/analytics/dashboard`);
      const analyticsData = await analytics.json();
      console.log('Analytics after deletion:', JSON.stringify(analyticsData, null, 2));
      
    } else {
      console.log('❌ User deletion failed:', deleteData);
    }
    
  } catch (error) {
    console.error('❌ User deletion test failed:', error.message);
  }
}

async function createTestUser() {
  console.log('👤 Creating test user...\n');
  
  try {
    const signupResponse = await fetch(`${API_BASE}/auth-direct/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'test-deletion@example.com',
        password: 'testpassword123',
        firstName: 'Test',
        lastName: 'User'
      })
    });
    
    const signupData = await signupResponse.json();
    
    if (signupResponse.ok) {
      console.log('✅ Test user created successfully!');
      console.log('User ID:', signupData.user?.id);
      return signupData.user?.id;
    } else {
      console.log('❌ Test user creation failed:', signupData);
      return null;
    }
    
  } catch (error) {
    console.error('❌ Test user creation failed:', error.message);
    return null;
  }
}

async function main() {
  console.log('🚀 Starting User Deletion and Analytics Tests\n');
  
  // Test analytics first
  await testAnalytics();
  
  console.log('\n' + '='.repeat(60) + '\n');
  
  // Ask for user ID to test deletion
  const args = process.argv.slice(2);
  let userId = args[0];
  
  if (!userId) {
    console.log('💡 To test user deletion, run:');
    console.log('   node test-user-deletion.js [USER_ID]');
    console.log('\n💡 Or create a test user:');
    console.log('   node test-user-deletion.js create');
    
    if (args[0] === 'create') {
      userId = await createTestUser();
      if (!userId) {
        console.log('❌ Could not create test user');
        return;
      }
    } else {
      return;
    }
  }
  
  // Test user deletion
  await testUserDeletion(userId);
  
  console.log('\n✅ Tests completed!');
}

// Run the tests
main().catch(console.error);
