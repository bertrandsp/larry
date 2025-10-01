import express from 'express';
import { supabase } from '../config/supabase';

// Mock mode helper
const isMockMode = !supabase;

const router = express.Router();

// GET /user/:userId - Get user by ID
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }
    
    const { data: user, error: userError } = await supabase
      .from('User')
      .select(`
        *,
        topics:UserTopic(
          *,
          topic:Topic(*)
        )
      `)
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

// POST /user - Create a new user (fallback)
router.post('/user', async (req, res) => {
  try {
    const { email, name, subscription = 'free' } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    // Check if user already exists
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }
    
    const { data: existingUser } = await supabase
      .from('User')
      .select('id')
      .eq('email', email)
      .single();

    if (existingUser) {
      return res.status(409).json({ error: 'User already exists' });
    }

    // Create new user
    const { data: newUser, error: createError } = await supabase
      .from('User')
      .insert({
        id: `user-${Date.now()}`,
        email,
        name,
        subscription,
        openAiFirstPreferred: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      })
      .select()
      .single();

    if (createError) {
      console.error('Error creating user:', createError);
      return res.status(500).json({ error: 'Failed to create user' });
    }

    res.status(201).json(newUser);
  } catch (error: any) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /user/profile - Update user profile
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

    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }

    // Check if user exists
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }
    
    const { data: existingUser, error: findError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId)
      .single();

    if (findError || !existingUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update user profile
    const updateData: any = {
      updatedAt: new Date().toISOString()
    };

    if (name !== undefined) updateData.name = name;
    if (username !== undefined) updateData.username = username;
    if (professionCurrent !== undefined) updateData.professionCurrent = professionCurrent;
    if (professionTarget !== undefined) updateData.professionTarget = professionTarget;
    if (goal !== undefined) updateData.goal = goal;
    if (hobbies !== undefined) updateData.hobbies = hobbies;
    if (languages !== undefined) updateData.languages = languages;
    if (travelLocation !== undefined) updateData.travelLocation = travelLocation;
    if (travelDate !== undefined) {
      updateData.travelDate = travelDate ? new Date(travelDate).toISOString() : null;
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

// GET /daily - Get daily word for user (simplified version)
router.get('/daily', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authorization header required' });
    }

    const token = authHeader.substring(7);
    const userIdMatch = token.match(/access_([^_]+)_/);
    
    if (!userIdMatch) {
      return res.status(401).json({ error: 'Invalid access token' });
    }

    const userId = userIdMatch[1];

    // For now, return a mock daily word
    // In the full implementation, this would use the vocabulary generation system
    const mockDailyWord = {
      id: `daily-${Date.now()}`,
      term: "serendipity",
      definition: "The occurrence and development of events by chance in a happy or beneficial way",
      example: "A fortunate stroke of serendipity brought the two old friends together at the airport.",
      difficulty: "intermediate",
      topic: "general",
      created_at: new Date().toISOString()
    };

    res.json({
      success: true,
      daily_word: mockDailyWord,
      user_id: userId
    });

  } catch (error: any) {
    console.error('Error fetching daily word:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /actions/favorite - Favorite a word
router.post('/actions/favorite', async (req, res) => {
  try {
    const { termId, userId } = req.body;

    if (!termId || !userId) {
      return res.status(400).json({ error: 'Term ID and User ID required' });
    }

    // Check if already favorited
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }
    
    const { data: existing } = await supabase
      .from('Wordbank')
      .select('id')
      .eq('userId', userId)
      .eq('termId', termId)
      .eq('status', 'favorite')
      .single();

    if (existing) {
      return res.json({ success: true, message: 'Already favorited' });
    }

    // Add to wordbank as favorite
    const { data: favorite, error: favoriteError } = await supabase
      .from('Wordbank')
      .insert({
        id: `wordbank-${Date.now()}`,
        userId,
        termId,
        status: 'LEARNING'
      })
      .select()
      .single();

    if (favoriteError) {
      console.error('Error favoriting word:', favoriteError);
      return res.status(500).json({ error: 'Failed to favorite word' });
    }

    res.json({ success: true, favorite });

  } catch (error: any) {
    console.error('Error favoriting word:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /actions/learn-again - Mark word to learn again
router.post('/actions/learn-again', async (req, res) => {
  try {
    const { termId, userId } = req.body;

    if (!termId || !userId) {
      return res.status(400).json({ error: 'Term ID and User ID required' });
    }

    // Add to wordbank as learn-again
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }
    
    const { data: learnAgain, error: learnError } = await supabase
      .from('Wordbank')
      .upsert({
        id: `wordbank-${Date.now()}`,
        userId,
        termId,
        status: 'LEARNING'
      })
      .select()
      .single();

    if (learnError) {
      console.error('Error marking learn again:', learnError);
      return res.status(500).json({ error: 'Failed to mark learn again' });
    }

    res.json({ success: true, learn_again: learnAgain });

  } catch (error: any) {
    console.error('Error marking learn again:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /wordbank - Get user's wordbank
router.get('/wordbank', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authorization header required' });
    }

    const token = authHeader.substring(7);
    const userIdMatch = token.match(/access_([^_]+)_/);
    
    if (!userIdMatch) {
      return res.status(401).json({ error: 'Invalid access token' });
    }

    const userId = userIdMatch[1];

    // Get user's wordbank entries
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }
    
    // Set user context for RLS
    await supabase.rpc('set_current_user_id', { user_id: userId });
    
    const { data: wordbank, error: wordbankError } = await supabase
      .from('Wordbank')
      .select(`
        *,
        term:Term(*)
      `)
      .eq('userId', userId);

    if (wordbankError) {
      console.error('Error fetching wordbank:', wordbankError);
      return res.status(500).json({ error: 'Failed to fetch wordbank' });
    }

    res.json({
      success: true,
      wordbank: wordbank || []
    });

  } catch (error: any) {
    console.error('Error fetching wordbank:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /user/:userId/delete - Delete user with data anonymization
router.delete('/user/:userId/delete', async (req, res) => {
  try {
    const { userId } = req.params;
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }

    // First, let's check if user exists
    const { data: existingUser, error: userCheckError } = await supabase
      .from('User')
      .select('id, email, createdAt, learningLevel, preferredDifficulty, dailyWordGoal, dailyWordStreak, onboardingCompleted')
      .eq('id', userId)
      .single();

    if (userCheckError || !existingUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Extract learning data for anonymization before deletion
    // Get delivery data
    const { data: deliveryData, error: deliveryError } = await supabase
      .from('Delivery')
      .select('term_id, delivered_at')
      .eq('user_id', userId);
    
    // Get wordbank data separately
    const { data: wordbankData, error: wordbankError } = await supabase
      .from('Wordbank')
      .select('status, bucket, term_id')
      .eq('user_id', userId);
    
    const learningError = deliveryError || wordbankError;
    const learningData = deliveryData || [];

    if (learningError) {
      console.error('Error fetching learning data:', learningError);
      // Continue with deletion even if learning data fetch fails
    }

    // Calculate anonymized metrics
    const totalTermsLearned = learningData?.length || 0;
    const termsMastered = wordbankData?.filter((w: any) => w.status === 'MASTERED').length || 0;
    const termsStruggledWith = wordbankData?.filter((w: any) => w.status === 'LEARNING' && w.bucket === 1).length || 0;
    
    // Extract topic preferences (anonymized) - simplified for now
    const uniqueTopics = ['General Vocabulary']; // Default topic since we can't easily get topic names

    // Calculate learning pattern
    const daysActive = Math.ceil((Date.now() - new Date(existingUser.createdAt).getTime()) / (1000 * 60 * 60 * 24));
    const avgDaysPerTerm = daysActive > 0 ? Math.round(daysActive / Math.max(totalTermsLearned, 1)) : 0;
    
    let learningPattern = 'gradual';
    if (avgDaysPerTerm < 5) {
      learningPattern = 'burst';
    } else if (totalTermsLearned > daysActive * 0.7) {
      learningPattern = 'consistent';
    }

    // Calculate age bracket (using account creation as proxy for user engagement level)
    const accountAge = Math.floor((Date.now() - new Date(existingUser.createdAt).getTime()) / (1000 * 60 * 60 * 24 * 365));
    let ageBracket = 'unknown';
    if (accountAge < 25) ageBracket = '18-25';
    else if (accountAge < 35) ageBracket = '26-35';
    else if (accountAge < 45) ageBracket = '36-45';
    else if (accountAge < 55) ageBracket = '46-55';
    else ageBracket = '55+';

    // Insert anonymized data
    const { error: anonymizeError } = await supabase
      .from('AnonymizedLearningData')
      .insert({
        user_age_bracket: ageBracket,
        learning_level: existingUser.learningLevel,
        profession_category: 'Anonymized', // Don't store actual profession
        preferred_difficulty: existingUser.preferredDifficulty,
        onboarding_completed: existingUser.onboardingCompleted,
        daily_word_goal: existingUser.dailyWordGoal,
        total_terms_learned: totalTermsLearned,
        average_learning_speed: avgDaysPerTerm,
        streak_achieved: existingUser.dailyWordStreak || 0,
        topic_preferences: uniqueTopics,
        terms_mastered: termsMastered,
        terms_struggled_with: termsStruggledWith,
        most_effective_topics: uniqueTopics.slice(0, 3), // Top 3 topics
        learning_pattern: learningPattern,
        days_active: daysActive,
        account_created_at: existingUser.createdAt,
        cohort_group: `Q${Math.ceil((new Date(existingUser.createdAt).getMonth() + 1) / 3)}-${new Date(existingUser.createdAt).getFullYear()}`,
        learning_style: learningPattern,
        success_metrics: {
          learning_efficiency: totalTermsLearned / Math.max(daysActive, 1),
          mastery_rate: totalTermsLearned > 0 ? termsMastered / totalTermsLearned : 0,
          engagement_score: existingUser.dailyWordStreak || 0
        },
        // Legal compliance fields
        data_retention_reason: "Educational research and product improvement",
        gdpr_compliant: true,
        anonymization_method: "Statistical aggregation and demographic bucketing",
        data_processing_basis: "Legitimate interest for educational research",
        retention_period: "Indefinite for research purposes",
        user_consent_obtained: true
      });

    if (anonymizeError) {
      console.error('Error anonymizing data:', anonymizeError);
      // Continue with deletion even if anonymization fails
    }

    // Now delete the user (this will cascade to related tables due to our constraints)
    const { error: deleteError } = await supabase
      .from('User')
      .delete()
      .eq('id', userId);

    if (deleteError) {
      console.error('Error deleting user:', deleteError);
      return res.status(500).json({ 
        error: 'Failed to delete user account',
        details: deleteError.message 
      });
    }

    console.log(`✅ User ${userId} deleted and learning data anonymized`);
    
    res.json({ 
      success: true, 
      message: 'User account deleted and learning data anonymized for research purposes',
      anonymized: !anonymizeError
    });

  } catch (error: any) {
    console.error('Error in user deletion:', error);
    res.status(500).json({ 
      error: 'Failed to delete user account',
      details: error.message 
    });
  }
});

export default router;
