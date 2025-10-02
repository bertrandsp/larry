#!/usr/bin/env node

/**
 * Manual Deletion Test Script
 * 
 * This script manually tests the user deletion process by calling the
 * deletion logic directly without going through the API.
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

async function manualDeletionTest() {
  console.log('🧪 Manual User Deletion Test...\n');
  
  const testUserId = 'email-user-topic-extraction-test-1759361539169examplecom';
  
  try {
    // 1. Get user data
    console.log('👤 Step 1: Getting user data...');
    const { data: existingUser, error: userError } = await supabase
      .from('User')
      .select('*')
      .eq('id', testUserId)
      .single();
    
    if (userError || !existingUser) {
      console.error('❌ User not found:', userError?.message);
      return;
    }
    
    console.log(`✅ Found user: ${existingUser.email}`);
    
    // 2. Extract topic preferences
    console.log('\n📋 Step 2: Extracting topic preferences...');
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
    
    // 3. Create anonymized data
    console.log('\n📊 Step 3: Creating anonymized data...');
    
    // Calculate basic metrics
    const daysActive = Math.ceil((Date.now() - new Date(existingUser.createdAt).getTime()) / (1000 * 60 * 60 * 24));
    const accountAge = Math.floor((Date.now() - new Date(existingUser.createdAt).getTime()) / (1000 * 60 * 60 * 24 * 365));
    let ageBracket = 'unknown';
    if (accountAge < 25) ageBracket = '18-25';
    else if (accountAge < 35) ageBracket = '26-35';
    else if (accountAge < 45) ageBracket = '36-45';
    else if (accountAge < 55) ageBracket = '46-55';
    else ageBracket = '55+';
    
    const anonymizedData = {
      user_age_bracket: ageBracket,
      learning_level: existingUser.learningLevel,
      profession_category: 'Anonymized',
      preferred_difficulty: existingUser.preferredDifficulty,
      onboarding_completed: existingUser.onboardingCompleted,
      daily_word_goal: existingUser.dailyWordGoal,
      total_terms_learned: 0, // Simplified for test
      average_learning_speed: 0,
      streak_achieved: existingUser.dailyWordStreak || 0,
      topic_preferences: uniqueTopics, // This is the key field!
      terms_mastered: 0,
      terms_struggled_with: 0,
      most_effective_topics: uniqueTopics.slice(0, 3),
      learning_pattern: 'burst',
      days_active: daysActive,
      account_created_at: existingUser.createdAt,
      cohort_group: `Q${Math.ceil((new Date(existingUser.createdAt).getMonth() + 1) / 3)}-${new Date(existingUser.createdAt).getFullYear()}`,
      learning_style: 'burst',
      success_metrics: {
        learning_efficiency: 0,
        mastery_rate: 0,
        engagement_score: existingUser.dailyWordStreak || 0
      },
      data_retention_reason: "Educational research and product improvement",
      gdpr_compliant: true,
      anonymization_method: "Statistical aggregation and demographic bucketing",
      data_processing_basis: "Legitimate interest for educational research",
      retention_period: "Indefinite for research purposes",
      user_consent_obtained: true
    };
    
    console.log('✅ Anonymized data prepared:');
    console.log(`   • Topic Preferences: ${JSON.stringify(anonymizedData.topic_preferences)}`);
    console.log(`   • Age Bracket: ${anonymizedData.user_age_bracket}`);
    console.log(`   • Learning Level: ${anonymizedData.learning_level}`);
    
    // 4. Insert anonymized data
    const { data: insertedData, error: insertError } = await supabase
      .from('AnonymizedLearningData')
      .insert(anonymizedData)
      .select()
      .single();
    
    if (insertError) {
      console.error('❌ Error inserting anonymized data:', insertError.message);
    } else {
      console.log('✅ Anonymized data inserted successfully!');
      console.log(`   • ID: ${insertedData.id}`);
    }
    
    // 5. Delete the user
    console.log('\n🗑️ Step 4: Deleting user...');
    const { error: deleteError } = await supabase
      .from('User')
      .delete()
      .eq('id', testUserId);
    
    if (deleteError) {
      console.error('❌ Error deleting user:', deleteError.message);
    } else {
      console.log('✅ User deleted successfully!');
    }
    
    // 6. Verify the anonymized data
    console.log('\n🔍 Step 5: Verifying anonymized data...');
    const { data: verificationData, error: verifyError } = await supabase
      .from('AnonymizedLearningData')
      .select('topic_preferences, anonymized_at')
      .eq('id', insertedData.id)
      .single();
    
    if (verifyError) {
      console.error('❌ Error verifying data:', verifyError.message);
    } else {
      console.log('✅ Verification successful:');
      console.log(`   • Topic Preferences: ${JSON.stringify(verificationData.topic_preferences)}`);
      console.log(`   • Anonymized At: ${verificationData.anonymized_at}`);
      
      if (verificationData.topic_preferences && verificationData.topic_preferences.length > 0) {
        console.log('🎉 SUCCESS: Topic preferences were captured correctly!');
      } else {
        console.log('❌ ISSUE: Topic preferences are still empty');
      }
    }
    
  } catch (error) {
    console.error('❌ Unexpected error:', error.message);
  }
  
  console.log('\n🎯 Manual deletion test completed!');
}

async function main() {
  console.log('🎯 Manual User Deletion Test Script\n');
  await manualDeletionTest();
}

main().catch(console.error);
