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

export default router;
