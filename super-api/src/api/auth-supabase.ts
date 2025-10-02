import express from 'express';
import { supabase } from '../config/supabase';
import { passwordStore } from '../utils/passwordStore';
import { validatePasswordStrength } from '../utils/auth';
import { DatabaseAuth } from '../utils/databaseAuth';

// Mock mode helper
const isMockMode = !supabase;

const router = express.Router();

// POST /auth-direct/signup - Handle Email/Password Signup
router.post('/auth-direct/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email and password are required'
      });
    }
    
    console.log('📧 Email signup request received:', { email, hasPassword: !!password, name });
    
    // Validate password strength
    const passwordValidation = validatePasswordStrength(password);
    if (!passwordValidation.valid) {
      return res.status(400).json({
        success: false,
        error: passwordValidation.message
      });
    }
    
    // Generate user ID based on email
    const userId = `email-user-${email.replace(/[^a-zA-Z0-9]/g, '').toLowerCase()}`;
    
    let dbUser;
    
    if (isMockMode) {
      console.log('🔄 Mock mode: Creating mock user for email signup');
      dbUser = {
        id: userId,
        email: email,
        name: name || 'User',
        subscription: 'free',
        onboardingCompleted: false,
        dailyWordStreak: 0,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
    } else {
      // Real Supabase mode
      if (!supabase) throw new Error('Supabase client not initialized');
      
      console.log('🔄 Creating new user with email/password...');
      
      // Set user context for RLS
      await supabase.rpc('set_current_user_id', { user_id: userId });
      
      // Check if user already exists
      const { data: existingUser, error: findError } = await supabase
        .from('User')
        .select('*')
        .eq('email', email)
        .single();
      
      if (!findError && existingUser) {
        return res.status(400).json({
          success: false,
          error: 'User already exists with this email'
        });
      }
      
      // Create new user
      const { data: newUser, error: createError } = await supabase
        .from('User')
        .insert({
          id: userId,
          email: email,
          name: name || 'User',
          subscription: 'free',
          openAiFirstPreferred: false,
          onboardingCompleted: false,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        })
        .select()
        .single();
      
      if (createError) {
        console.error('❌ Error creating user:', createError);
        throw createError;
      }
      
      dbUser = newUser;
      console.log('✅ Created new user:', dbUser.id);
    }
    
    // Store password securely (try database first, fallback to temp store)
    if (!isMockMode) {
      const dbSuccess = await DatabaseAuth.setUserPassword(email, password);
      if (!dbSuccess) {
        console.log('⚠️ Database password storage failed, using temporary store');
        await passwordStore.setPassword(email, password);
      }
    } else {
      await passwordStore.setPassword(email, password);
    }
    
    // Generate mock tokens
    const accessToken = `access_${dbUser.id}_${Date.now()}`;
    const refreshToken = `refresh_${dbUser.id}_${Date.now()}`;
    
    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: dbUser.id,
        email: dbUser.email,
        name: dbUser.name || "User",
        profile_image_url: "",
        created_at: new Date(dbUser.createdAt).toISOString(),
        updated_at: new Date(dbUser.updatedAt).toISOString(),
        onboarding_completed: dbUser.onboardingCompleted || false,
        streak_count: dbUser.dailyWordStreak || 0,
        total_words_learned: 0,
        subscription: dbUser.subscription
      }
    });
    
  } catch (error: any) {
    console.error('❌ Email signup error:', error);
    res.status(500).json({
      success: false,
      error: 'Signup failed',
      message: error.message
    });
  }
});

// POST /auth-direct/login - Handle Email/Password Login
router.post('/auth-direct/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email and password are required'
      });
    }
    
    console.log('📧 Email login request received:', { email, hasPassword: !!password });
    
    // First, verify the password (try database first, fallback to temp store)
    let isPasswordValid = false;
    
    if (!isMockMode) {
      isPasswordValid = await DatabaseAuth.verifyUserPassword(email, password);
      
      // If database verification failed, try temp store (for migration period)
      if (!isPasswordValid) {
        console.log('🔄 Database auth failed, trying temporary store...');
        isPasswordValid = await passwordStore.verifyPassword(email, password);
        
        // If temp store works, migrate to database
        if (isPasswordValid) {
          console.log('🔄 Migrating password from temp store to database...');
          await DatabaseAuth.migrateFromTempStore(email, password);
        }
      }
    } else {
      isPasswordValid = await passwordStore.verifyPassword(email, password);
    }
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }
    
    // Generate user ID based on email
    const userId = `email-user-${email.replace(/[^a-zA-Z0-9]/g, '').toLowerCase()}`;
    
    let dbUser;
    
    if (isMockMode) {
      console.log('🔄 Mock mode: Finding mock user for email login');
      // In mock mode, assume user exists if they're trying to login
      dbUser = {
        id: userId,
        email: email,
        name: 'User',
        subscription: 'free',
        onboardingCompleted: false, // Default to false for testing
        dailyWordStreak: 0,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
    } else {
      // Real Supabase mode
      if (!supabase) throw new Error('Supabase client not initialized');
      
      console.log('🔄 Finding user by email...');
      
      // Set user context for RLS
      await supabase.rpc('set_current_user_id', { user_id: userId });
      
      const { data: user, error: findError } = await supabase
        .from('User')
        .select('*')
        .eq('email', email)
        .single();
      
      if (findError || !user) {
        return res.status(401).json({
          success: false,
          error: 'Invalid email or password'
        });
      }
      
      dbUser = user;
      console.log('✅ Found user:', dbUser.id);
    }
    
    // Generate mock tokens
    const accessToken = `access_${dbUser.id}_${Date.now()}`;
    const refreshToken = `refresh_${dbUser.id}_${Date.now()}`;
    
    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: dbUser.id,
        email: dbUser.email,
        name: dbUser.name || "User",
        profile_image_url: "",
        created_at: new Date(dbUser.createdAt).toISOString(),
        updated_at: new Date(dbUser.updatedAt).toISOString(),
        onboarding_completed: dbUser.onboardingCompleted || false,
        streak_count: dbUser.dailyWordStreak || 0,
        total_words_learned: 0,
        subscription: dbUser.subscription
      }
    });
    
  } catch (error: any) {
    console.error('❌ Email login error:', error);
    res.status(500).json({
      success: false,
      error: 'Login failed',
      message: error.message
    });
  }
});

// POST /auth-direct/apple - Handle Apple Sign In
router.post('/auth-direct/apple', async (req, res) => {
  try {
    const { identityToken, authorizationCode, fullName, email } = req.body;
    
    // Extract email from identity token if not provided directly
    let userEmail = email;
    if (!userEmail && identityToken) {
      try {
        // Decode JWT payload (without verification for now)
        const payload = JSON.parse(Buffer.from(identityToken.split('.')[1], 'base64').toString());
        userEmail = payload.email;
      } catch (e) {
        console.log('Could not decode identity token for email extraction');
      }
    }
    
    console.log('🍎 Apple Sign In request received:', {
      hasIdentityToken: !!identityToken,
      hasAuthorizationCode: !!authorizationCode,
      email: userEmail
    });

    // For now, create a simple mock authentication response
    // In production, you would verify the Apple identity token
    const mockUserId = 'apple-user-' + Date.now();
    
    let dbUser;
    
    if (isMockMode) {
      // Mock mode - create a simple user object
      console.log('🔄 Mock mode: Creating mock user');
      dbUser = {
        id: mockUserId,
        email: userEmail || `${mockUserId}@apple-signin.local`,
        name: fullName?.givenName || 'User',
        subscription: 'free',
        onboardingCompleted: false,
        dailyWordStreak: 0,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
    } else {
      // Real Supabase mode with proper RLS handling
      if (!supabase) throw new Error('Supabase client not initialized');
      
      console.log('🔄 Checking for existing user...');
      
      // First, try to find existing user by setting a temporary context
      // We'll use the email as a temporary identifier for the lookup
      try {
        await supabase.rpc('set_current_user_id', { user_id: mockUserId });
        
        const { data: existingUser, error: findError } = await supabase
          .from('User')
          .select('*')
          .eq('email', userEmail || `${mockUserId}@apple-signin.local`)
          .single();

        if (!findError && existingUser) {
          dbUser = existingUser;
          console.log('✅ Found existing user:', dbUser.id);
        } else {
          // User doesn't exist, create new one
          console.log('🔄 Creating new user...');
          
          const { data: newUser, error: createError } = await supabase
            .from('User')
            .insert({
              id: mockUserId,
              email: userEmail || `${mockUserId}@apple-signin.local`,
              subscription: 'free',
              openAiFirstPreferred: false,
              createdAt: new Date().toISOString(),
              updatedAt: new Date().toISOString()
            })
            .select()
            .single();

          if (createError) {
            // If it's a duplicate key error, the user exists
            if (createError.code === '23505') {
              console.log('🔄 User already exists, returning success with existing user info');
              
              // For existing users, return a success response with a note that they already exist
              // The client should treat this as a successful login
              const existingUserResponse = {
                id: `existing-user-${userEmail?.replace(/[^a-zA-Z0-9]/g, '').toLowerCase()}`,
                email: userEmail || `${mockUserId}@apple-signin.local`,
                name: fullName?.givenName || 'User',
                subscription: 'free',
                onboardingCompleted: true, // Assume existing users have completed onboarding
                dailyWordStreak: 0,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
              };
              
              dbUser = existingUserResponse;
              console.log('✅ Returning existing user response:', existingUserResponse.id);
            
            } else {
              console.error('❌ Error creating user:', createError);
              throw createError;
            }
          } else {
            dbUser = newUser;
            console.log('✅ Created new user:', dbUser.id);
          }
        }
      } catch (contextError) {
        console.error('❌ Error with user context operations:', contextError);
        throw contextError;
      }
    }

    // Generate mock tokens (in production, use proper JWT)
    const accessToken = `access_${dbUser.id}_${Date.now()}`;
    const refreshToken = `refresh_${dbUser.id}_${Date.now()}`;

    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: dbUser.id,
        email: dbUser.email,
        name: dbUser.name || "User",
        profile_image_url: "",
        created_at: new Date(dbUser.createdAt).toISOString(),
        updated_at: new Date(dbUser.updatedAt).toISOString(),
        onboarding_completed: dbUser.onboardingCompleted || false,
        streak_count: dbUser.dailyWordStreak || 0,
        total_words_learned: 0,
        subscription: dbUser.subscription
      }
    });

  } catch (error: any) {
    console.error('❌ Apple Sign In error:', error);
    res.status(500).json({
      success: false,
      error: 'Authentication failed',
      message: error.message
    });
  }
});

// POST /auth-direct/google - Handle Google Sign In (placeholder)
router.post('/auth-direct/google', async (req, res) => {
  // TODO: Implement Google Sign-In
  res.status(501).json({
    success: false,
    error: 'Google Sign-In not implemented yet'
  });
});

// POST /auth-direct/refresh - Refresh access token
router.post('/auth-direct/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    
    if (!refresh_token) {
      return res.status(401).json({
        success: false,
        error: 'Refresh token required'
      });
    }
    
    // Extract user ID from mock refresh token
    const userIdMatch = refresh_token.match(/refresh_([^_]+)_/);
    if (!userIdMatch) {
      return res.status(401).json({
        success: false,
        error: 'Invalid refresh token'
      });
    }

    const userId = userIdMatch[1];
    
    if (!supabase) {
      return res.status(401).json({
        success: false,
        error: 'Database not available'
      });
    }
    
    const { data: user, error: userError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId)
      .single();

    if (userError || !user) {
      return res.status(401).json({
        success: false,
        error: 'User not found'
      });
    }

    // Generate new tokens
    const newAccessToken = `access_${user.id}_${Date.now()}`;
    const newRefreshToken = `refresh_${user.id}_${Date.now()}`;

    res.json({
      access_token: newAccessToken,
      refresh_token: newRefreshToken
    });

  } catch (error: any) {
    console.error('❌ Token refresh error:', error);
    res.status(500).json({
      success: false,
      error: 'Token refresh failed',
      message: error.message
    });
  }
});

// GET /auth-direct/profile - Get user profile
router.get('/auth-direct/profile', async (req, res) => {
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
    
    if (!supabase) {
      return res.status(404).json({
        success: false,
        error: 'Database not available'
      });
    }
    
    // Set user context for RLS
    await supabase.rpc('set_current_user_id', { user_id: userId });
    
    const { data: user, error: userError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId)
      .single();

    if (userError || !user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      id: user.id,
      email: user.email,
      name: user.name || "User",
      profile_image_url: "",
      created_at: new Date(user.createdAt).toISOString(),
      updated_at: new Date(user.updatedAt).toISOString(),
      onboarding_completed: user.onboardingCompleted || false,
      streak_count: user.dailyWordStreak || 0,
      total_words_learned: 0,
      subscription: user.subscription,
      profession_current: user.professionCurrent,
      profession_target: user.professionTarget,
      goal: user.goal,
      hobbies: user.hobbies,
      languages: user.languages,
      travel_location: user.travelLocation,
      travel_date: user.travelDate,
      preferred_difficulty: user.preferredDifficulty,
      enable_notifications: user.enableNotifications,
      notification_time: user.notificationTime,
      daily_word_goal: user.dailyWordGoal
    });

  } catch (error: any) {
    console.error('❌ Profile fetch error:', error);
    res.status(500).json({
      success: false,
      error: 'Profile fetch failed',
      message: error.message
    });
  }
});

// GET /auth/status - Check authentication status
router.get('/auth/status', async (req, res) => {
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

    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required'
      });
    }

    if (!supabase) {
      return res.status(404).json({
        success: false,
        error: 'Database not available'
      });
    }

    const { data: user, error: userError } = await supabase
      .from('User')
      .select('*')
      .eq('id', userId as string)
      .single();

    if (userError || !user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name || "User",
        onboarding_completed: user.onboardingCompleted || false
      }
    });

  } catch (error: any) {
    console.error('❌ Auth status check error:', error);
    res.status(500).json({
      success: false,
      error: 'Auth status check failed',
      message: error.message
    });
  }
});

export default router;
