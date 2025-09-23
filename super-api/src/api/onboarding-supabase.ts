import express from 'express';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  }
);

// POST /onboarding/complete - Complete user onboarding
router.post('/onboarding/complete', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Authorization header required'
      });
    }

    const token = authHeader.substring(7);
    
    // Extract user ID from mock access token
    const userIdMatch = token.match(/access_([^_]+)_/);
    if (!userIdMatch) {
      return res.status(401).json({
        success: false,
        error: 'Invalid access token'
      });
    }

    const userId = userIdMatch[1];
    
    const {
      name,
      username,
      profession_current,
      profession_target,
      goal,
      hobbies,
      languages,
      travel_plan,
      selected_topics,
      preferred_difficulty,
      enable_notifications,
      notification_time,
      daily_word_goal
    } = req.body;

    console.log('📋 Completing onboarding for user:', userId);
    console.log('📋 Onboarding data:', {
      name,
      username,
      profession_current,
      profession_target,
      goal,
      hobbies,
      languages,
      travel_plan,
      selected_topics,
      preferred_difficulty,
      enable_notifications,
      notification_time,
      daily_word_goal
    });

    // Set user context for RLS
    await supabase.rpc('set_current_user_id', { user_id: userId });
    
    // Check if user exists
    const { data: existingUser, error: userError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId)
      .single();

    if (userError || !existingUser) {
      console.error('❌ User not found during onboarding:', userError);
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: userError?.message
      });
    }

    // Update user profile with onboarding data (override existing values)
    const updateData: any = {
      onboardingCompleted: true,
      updatedAt: new Date().toISOString(),
      // Always update these fields, even if empty (to override existing data)
      name: name || existingUser.name,
      username: username || existingUser.username,
      professionCurrent: profession_current || null,
      professionTarget: profession_target || null,
      goal: goal || null,
      hobbies: hobbies || [],
      languages: languages || [],
      travelLocation: travel_plan?.location || null,
      travelDate: travel_plan?.start_date ? new Date(travel_plan.start_date).toISOString() : null,
      preferredDifficulty: preferred_difficulty || 'intermediate',
      enableNotifications: enable_notifications !== undefined ? enable_notifications : false,
      notificationTime: notification_time || null,
      dailyWordGoal: daily_word_goal || 1
    };

    console.log('📋 Update data prepared:', updateData);

    // Update user in database
    const { data: updatedUser, error: updateError } = await supabase
      .from('User')
      .update(updateData)
      .eq('id', userId)
      .select()
      .single();

    if (updateError) {
      console.error('❌ Error updating user during onboarding:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to complete onboarding',
        message: updateError.message
      });
    }

    // Handle selected topics (simplified for now)
    if (selected_topics && Array.isArray(selected_topics) && selected_topics.length > 0) {
      console.log('📋 Processing selected topics:', selected_topics);
      
      // For now, just log the topics. In a full implementation, you'd:
      // 1. Create UserTopic entries for each selected topic
      // 2. Handle custom topics
      // 3. Set topic weights
      
      // This is a placeholder - the topics will be handled in a future update
      console.log('📋 Topics will be processed in a future update');
    }

    console.log('✅ Onboarding completed successfully for user:', userId);

    res.json({
      success: true,
      message: 'Onboarding completed successfully',
      user: updatedUser,
      next_step: 'home', // Indicate that the client should navigate to home/daily word screen
      onboarding_completed: true
    });

  } catch (error: any) {
    console.error('❌ Onboarding completion error:', error);
    res.status(500).json({
      success: false,
      error: 'Onboarding completion failed',
      message: error.message
    });
  }
});

export default router;
