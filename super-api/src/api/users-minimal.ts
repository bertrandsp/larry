import express from 'express';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

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

const router = express.Router();

// GET /user/:userId - Get user by ID
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { data: user, error: userError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId)
      .single();

    if (userError || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error: any) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /user/profile - Update user profile (for onboarding)
router.put('/user/profile', async (req, res) => {
  try {
    const {
      userId,
      name,
      username,
      professionCurrent,
      professionTarget,
      goal,
      hobbies,
      languages,
      travelLocation,
      travelDate,
      preferredDifficulty,
      enableNotifications,
      notificationTime,
      dailyWordGoal
    } = req.body;

    console.log('👤 Updating user profile for:', userId);
    console.log('👤 Profile data:', req.body);

    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }

    // Check if user exists
    const { data: existingUser, error: findError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId)
      .single();

    if (findError || !existingUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update user profile
    const updateData: any = {};

    if (name !== undefined) updateData.name = name;
    if (username !== undefined) updateData.username = username;
    if (professionCurrent !== undefined) updateData.professionCurrent = professionCurrent;
    if (professionTarget !== undefined) updateData.professionTarget = professionTarget;
    if (goal !== undefined) updateData.goal = goal;
    if (hobbies !== undefined) updateData.hobbies = hobbies;
    if (languages !== undefined) updateData.languages = languages;
    if (travelLocation !== undefined) updateData.travelLocation = travelLocation;
    if (travelDate !== undefined) {
      updateData.travelDate = travelDate ? new Date(travelDate) : null;
    }
    if (preferredDifficulty !== undefined) updateData.preferredDifficulty = preferredDifficulty;
    if (enableNotifications !== undefined) updateData.enableNotifications = enableNotifications;
    if (notificationTime !== undefined) updateData.notificationTime = notificationTime;
    if (dailyWordGoal !== undefined) updateData.dailyWordGoal = dailyWordGoal;

    const { data: updatedUser, error: updateError } = await supabase
      .from('User')
      .update(updateData)
      .eq('id', userId)
      .select()
      .single();

    if (updateError) {
      console.error('❌ Error updating user profile:', updateError);
      return res.status(500).json({
        error: 'Failed to update profile',
        message: updateError.message
      });
    }

    console.log('✅ Profile updated for user:', userId);

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: updatedUser
    });

  } catch (error: any) {
    console.error('❌ Error updating user profile:', error);
    res.status(500).json({
      error: 'Failed to update profile',
      message: error.message
    });
  }
});

export default router;
