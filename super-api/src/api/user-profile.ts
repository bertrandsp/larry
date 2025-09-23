import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Save user profile data incrementally during onboarding
router.put('/profile', async (req, res) => {
  try {
    const { userId, ...profileData } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID is required' });
    }

    // Remove undefined values to avoid overwriting existing data
    const cleanProfileData = Object.fromEntries(
      Object.entries(profileData).filter(([_, value]) => value !== undefined)
    );

    // Update user profile
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        ...cleanProfileData,
        updatedAt: new Date()
      }
    });

    console.log(`✅ Updated profile for user: ${userId}`, cleanProfileData);

    res.json({
      success: true,
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        name: updatedUser.name,
        username: updatedUser.username,
        professionCurrent: updatedUser.professionCurrent,
        professionTarget: updatedUser.professionTarget,
        goal: updatedUser.goal,
        hobbies: updatedUser.hobbies,
        languages: updatedUser.languages,
        travelLocation: updatedUser.travelLocation,
        travelDate: updatedUser.travelDate,
        preferredDifficulty: updatedUser.preferredDifficulty,
        enableNotifications: updatedUser.enableNotifications,
        notificationTime: updatedUser.notificationTime,
        dailyWordGoal: updatedUser.dailyWordGoal,
        onboardingCompleted: updatedUser.onboardingCompleted,
        createdAt: updatedUser.createdAt,
        updatedAt: updatedUser.updatedAt
      }
    });

  } catch (error) {
    console.error('❌ Profile update error:', error);
    res.status(500).json({ 
      error: 'Failed to update profile',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Get user profile
router.get('/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        topics: {
          include: {
            topic: true
          }
        }
      }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        username: user.username,
        professionCurrent: user.professionCurrent,
        professionTarget: user.professionTarget,
        goal: user.goal,
        hobbies: user.hobbies,
        languages: user.languages,
        travelLocation: user.travelLocation,
        travelDate: user.travelDate,
        preferredDifficulty: user.preferredDifficulty,
        enableNotifications: user.enableNotifications,
        notificationTime: user.notificationTime,
        dailyWordGoal: user.dailyWordGoal,
        onboardingCompleted: user.onboardingCompleted,
        topics: user.topics.map(ut => ({
          id: ut.topic.id,
          name: ut.topic.name,
          weight: ut.weight
        })),
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    });

  } catch (error) {
    console.error('❌ Profile fetch error:', error);
    res.status(500).json({ 
      error: 'Failed to fetch profile',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;
