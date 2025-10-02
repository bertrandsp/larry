import express from 'express';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import { triggerSupabasePostOnboarding } from '../services/postOnboardingSupabaseService';

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

// POST /onboarding/complete - Complete user onboarding (final step)
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
    
    console.log('🎯 Finalizing onboarding completion for user:', userId);

    // Set user context for RLS
    await supabase.rpc('set_current_user_id', { user_id: userId });
    
    // Check if user exists and get their current data
    const { data: userData, error: userError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId)
      .single();

    if (userError || !userData) {
      console.error('❌ User not found during onboarding completion:', userError);
      return res.status(404).json({
        success: false,
        error: 'User not found',
        message: userError?.message || 'User not found'
      });
    }

    console.log('📱 User data for completion check:', {
      userId,
      onboardingSource: userData.onboardingSource,
      learningLevel: userData.learningLevel,
      widgetOptIn: userData.widgetOptIn,
      dailyWordGoal: userData.dailyWordGoal
    });

    // Verify that all required onboarding steps are completed
    const requiredFields = ['onboardingSource', 'learningLevel', 'dailyWordGoal'];
    const missingFields = requiredFields.filter(field => !userData[field]);
    
    if (missingFields.length > 0) {
      console.error('❌ Onboarding incomplete, missing fields:', missingFields);
      return res.status(400).json({
        success: false,
        error: 'Onboarding incomplete',
        message: `Missing required fields: ${missingFields.join(', ')}`,
        missingFields
      });
    }

    // Mark onboarding as completed
    const { data: updatedUser, error: updateError } = await supabase
      .from('User')
      .update({
        onboardingCompleted: true,
        onboardingStep: 'complete',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId)
      .select()
      .single();

    if (updateError) {
      console.error('❌ Error completing onboarding:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to complete onboarding',
        message: updateError.message
      });
    }

    console.log('✅ Onboarding completed successfully for user:', userId);
    console.log('🎯 Ready to trigger first daily word delivery');

    // Respond immediately to prevent timeout
    res.json({
      success: true,
      message: 'Onboarding completed successfully',
      user: updatedUser,
      next_step: 'home',
      onboarding_completed: true,
      ready_for_daily_word: true
    });

    // Run term generation in background (don't await)
    triggerSupabasePostOnboarding(userId).catch((generationError) => {
      console.error('❌ Failed to trigger Supabase post-onboarding generation:', generationError);
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
