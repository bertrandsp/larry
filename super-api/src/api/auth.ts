import express from 'express';
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

// POST /auth-direct/apple - Handle Apple Sign In
router.post('/auth-direct/apple', async (req, res) => {
  try {
    const { identityToken, authorizationCode, user } = req.body;
    
    console.log('🍎 Apple Sign In request received:', {
      hasIdentityToken: !!identityToken,
      hasAuthorizationCode: !!authorizationCode,
      userId: user
    });

    // For now, create a simple mock authentication response
    // In production, you would verify the Apple identity token
    const mockUserId = user || 'apple-user-' + Date.now();
    
    // Check if user exists in database
    let dbUser = await prisma.user.findUnique({
      where: { id: mockUserId }
    });

    // Create user if doesn't exist
    if (!dbUser) {
      dbUser = await prisma.user.create({
        data: {
          id: mockUserId,
          email: `user-${mockUserId}@apple-signin.local`,
          subscription: 'free',
          openAiFirstPreferred: false
        }
      });
      console.log('✅ Created new user:', dbUser.id);
    } else {
      console.log('✅ Found existing user:', dbUser.id);
    }

    // Return success response
    res.json({
      success: true,
      user: {
        id: dbUser.id,
        email: dbUser.email,
        subscription: dbUser.subscription
      },
      message: 'Apple Sign In successful'
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
  try {
    console.log('🔍 Google Sign In request received');
    
    res.json({
      success: true,
      message: 'Google Sign In endpoint - not implemented yet'
    });
  } catch (error: any) {
    console.error('❌ Google Sign In error:', error);
    res.status(500).json({
      success: false,
      error: 'Authentication failed',
      message: error.message
    });
  }
});

// GET /auth/status - Check authentication status
router.get('/auth/status', async (req, res) => {
  try {
    const { userId } = req.query;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'User ID required'
      });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId as string }
    });

    if (!user) {
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
        subscription: user.subscription
      }
    });

  } catch (error: any) {
    console.error('❌ Auth status check error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to check auth status',
      message: error.message
    });
  }
});

export default router;



