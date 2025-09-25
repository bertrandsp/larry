import express from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const router = express.Router();

// GET /user/:userId - Get user by ID
router.get('/user/:userId', async (req, res) => {
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

    res.json(user);
  } catch (error: any) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /user - Create new user
router.post('/user', async (req, res) => {
  try {
    const { email, subscription = 'free' } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const user = await prisma.user.create({
      data: {
        email,
        subscription
      }
    });

    res.status(201).json(user);
  } catch (error: any) {
    console.error('Error creating user:', error);
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'User with this email already exists' });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /user/interests - Save user interests
router.post('/user/interests', async (req, res) => {
  try {
    const { userId, interests, presetIds, customNames } = req.body;
    
    console.log('📊 Saving user interests - Full request body:', req.body);
    console.log('📊 Saving user interests:', { userId, interestsCount: interests?.length, presetIds, customNames });
    
    // Check if userId is in body, query params, or headers
    const actualUserId = userId || req.query.userId || req.headers['x-user-id'];
    
    if (!actualUserId) {
      console.log('❌ No userId found in body, query, or headers');
      return res.status(400).json({ error: 'User ID required' });
    }

    // Convert presetIds and customNames to interests array if needed
    let finalInterests = interests;
    
    // If no interests provided, try to get from presetIds and customNames
    if (!finalInterests || finalInterests.length === 0) {
      finalInterests = [];
      
      // Add preset interests
      if (presetIds && Array.isArray(presetIds) && presetIds.length > 0) {
        finalInterests.push(...presetIds.map(id => `Preset-${id}`));
      }
      
      // Add custom interests
      if (customNames && Array.isArray(customNames) && customNames.length > 0) {
        finalInterests.push(...customNames);
      }
    }
    
    console.log('📊 Final interests after processing:', finalInterests);

    // Check if user exists, create if not
    let user = await prisma.user.findUnique({
      where: { id: actualUserId as string }
    });

    if (!user) {
      // Create user if doesn't exist
      user = await prisma.user.create({
        data: {
          id: actualUserId as string,
          email: `user-${actualUserId}@apple-signin.local`,
          subscription: 'free',
          openAiFirstPreferred: false
        }
      });
      console.log('✅ Created new user for interests:', user.id);
    }

    // For now, just return success - in production you'd save to database
    // Process each interest
    const createdTopics = [];
    const userTopics = [];

    if (finalInterests && Array.isArray(finalInterests) && finalInterests.length > 0) {
      for (const interest of finalInterests) {
        // Create or find topic
        let topic = await prisma.topic.findFirst({
          where: { name: interest }
        });

        if (!topic) {
          topic = await prisma.topic.create({
            data: {
              name: interest
            }
          });
          console.log('✅ Created topic:', topic.name);
          createdTopics.push(topic);
        }

        // Link user to topic
        const existingUserTopic = await prisma.userTopic.findFirst({
          where: {
            userId: actualUserId as string,
            topicId: topic.id
          }
        });

        if (!existingUserTopic) {
          await prisma.userTopic.create({
            data: {
              userId: actualUserId as string,
              topicId: topic.id,
              weight: 100 // Default weight for user interests
            }
          });
          userTopics.push({ userId: actualUserId, topicId: topic.id, topicName: interest });
          console.log('✅ Linked user to topic:', interest);
        }
      }

      // Start content generation for new topics
      for (const topic of createdTopics) {
        try {
          console.log('🚀 Starting content generation for topic:', topic.name, 'with ID:', topic.id);
          // Trigger content generation with topicId
          const generateResponse = await fetch('http://localhost:4001/generate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              topic: topic.name,
              topicId: topic.id,
              userTier: 'free'
            })
          });
          
          if (generateResponse.ok) {
            console.log('✅ Content generation started for:', topic.name);
          }
        } catch (error) {
          console.error('❌ Failed to start content generation for:', topic.name, error);
        }
      }
    }

    res.json({
      success: true,
      message: 'Interests saved successfully',
      interests: finalInterests || [],
      topicsCreated: createdTopics.length,
      userTopicsLinked: userTopics.length
    });

  } catch (error: any) {
    console.error('❌ Error saving interests:', error);
    res.status(500).json({ 
      error: 'Failed to save interests',
      message: error.message 
    });
  }
});

// GET /user/interests - Get user interests
router.get('/user/interests', async (req, res) => {
  try {
    const { userId } = req.query;
    
    console.log('📊 Getting user interests for:', userId);
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }

    // Check if user exists, create if not
    let user = await prisma.user.findUnique({
      where: { id: userId as string }
    });

    if (!user) {
      // Create user if doesn't exist
      user = await prisma.user.create({
        data: {
          id: userId as string,
          email: `user-${userId}@apple-signin.local`,
          subscription: 'free',
          openAiFirstPreferred: false
        }
      });
      console.log('✅ Created new user for interests:', user.id);
    }

    // For now, return mock interests
    res.json({
      success: true,
      interests: [
        { id: '1', name: 'Machine Learning', weight: 100 },
        { id: '2', name: 'Cooking', weight: 75 }
      ]
    });

  } catch (error: any) {
    console.error('❌ Error getting interests:', error);
    res.status(500).json({ 
      error: 'Failed to get interests',
      message: error.message 
    });
  }
});

// GET /interests - Get available interests (for onboarding)
router.get('/interests', async (req, res) => {
  try {
    console.log('📊 Getting available interests');
    
    // Return mock interests for onboarding
    res.json({
      success: true,
      interests: [
        { id: 'ml', name: 'Machine Learning', category: 'Technology' },
        { id: 'cooking', name: 'Cooking', category: 'Lifestyle' },
        { id: 'fitness', name: 'Fitness', category: 'Health' },
        { id: 'music', name: 'Music', category: 'Entertainment' },
        { id: 'travel', name: 'Travel', category: 'Lifestyle' },
        { id: 'photography', name: 'Photography', category: 'Arts' }
      ]
    });

  } catch (error: any) {
    console.error('❌ Error getting available interests:', error);
    res.status(500).json({ 
      error: 'Failed to get interests',
      message: error.message 
    });
  }
});

// POST /user/notifications - Save user notification preferences
router.post('/user/notifications', async (req, res) => {
  try {
    const { localTz, localHHmm, frequency, pushToken } = req.body;
    const userId = req.body.userId || req.query.userId || req.headers['x-user-id'];
    
    console.log('📱 Saving user notifications:', { userId, localTz, localHHmm, frequency });
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }

    // Check if user exists, create if not
    let user = await prisma.user.findUnique({
      where: { id: userId as string }
    });

    if (!user) {
      // Create user if doesn't exist
      user = await prisma.user.create({
        data: {
          id: userId as string,
          email: `user-${userId}@apple-signin.local`,
          subscription: 'free',
          openAiFirstPreferred: false
        }
      });
      console.log('✅ Created new user for notifications:', user.id);
    }

    // For now, just return success - in production you'd save to database
    res.json({
      success: true,
      message: 'Notification preferences saved successfully',
      preferences: {
        localTz: localTz || 'UTC',
        localHHmm: localHHmm || '09:00',
        frequency: frequency || 'daily',
        pushToken: pushToken || null
      }
    });

  } catch (error: any) {
    console.error('❌ Error saving notifications:', error);
    res.status(500).json({ 
      error: 'Failed to save notification preferences',
      message: error.message 
    });
  }
});

// GET /user/notifications - Get user notification preferences
router.get('/user/notifications', async (req, res) => {
  try {
    const { userId } = req.query;
    
    console.log('📱 Getting user notifications for:', userId);
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }

    // For now, return mock preferences
    res.json({
      success: true,
      preferences: {
        localTz: 'UTC',
        localHHmm: '09:00',
        frequency: 'daily',
        pushToken: null
      }
    });

  } catch (error: any) {
    console.error('❌ Error getting notifications:', error);
    res.status(500).json({ 
      error: 'Failed to get notification preferences',
      message: error.message 
    });
  }
});

// GET /daily - Get daily word for user
router.get('/daily', async (req, res) => {
  try {
    const userId = req.query.userId || req.headers['x-user-id'];
    
    console.log('📚 Getting daily word for user:', userId);
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }

    // Check if user exists, create if not
    let user = await prisma.user.findUnique({
      where: { id: userId as string }
    });

    if (!user) {
      // Create user if doesn't exist
      user = await prisma.user.create({
        data: {
          id: userId as string,
          email: `user-${userId}@apple-signin.local`,
          subscription: 'free',
          openAiFirstPreferred: false
        }
      });
      console.log('✅ Created new user for daily word:', user.id);
    }

    // Get user's interests to find relevant terms
    const userTopics = await prisma.userTopic.findMany({
      where: { userId: userId as string },
      include: { topic: true }
    });

    console.log('📊 User topics found:', userTopics.length);

    let selectedTerm = null;
    let selectedTopic = null;

    if (userTopics.length > 0) {
      // Get terms from user's interest topics
      const topicIds = userTopics.map(ut => ut.topicId);
      
      const terms = await prisma.term.findMany({
        where: { 
          topicId: { in: topicIds },
          moderationStatus: 'APPROVED'
        },
        include: { topic: true },
        orderBy: { confidenceScore: 'desc' },
        take: 10
      });

      console.log('📚 Available terms for user:', terms.length);

      if (terms.length > 0) {
        // Simple selection: pick a random term from user's interests
        const randomIndex = Math.floor(Math.random() * terms.length);
        selectedTerm = terms[randomIndex];
        selectedTopic = selectedTerm.topic;
      }
    }

    // Fallback: if no user-specific terms, get any approved term
    if (!selectedTerm) {
      console.log('📚 No user-specific terms found, using fallback');
      selectedTerm = await prisma.term.findFirst({
        where: { moderationStatus: 'APPROVED' },
        include: { topic: true },
        orderBy: { confidenceScore: 'desc' }
      });
      
      if (selectedTerm) {
        selectedTopic = selectedTerm.topic;
      }
    }

    // If still no terms, try to get any approved term from the database
    if (!selectedTerm) {
      console.log('📚 No user-specific terms found, getting any approved term');
      selectedTerm = await prisma.term.findFirst({
        where: { moderationStatus: 'APPROVED' },
        include: { topic: true },
        orderBy: { confidenceScore: 'desc' }
      });
      
      if (selectedTerm) {
        selectedTopic = selectedTerm.topic;
        console.log('✅ Found approved term:', selectedTerm.term);
      }
    }

    // Final fallback: return error if no terms exist
    if (!selectedTerm) {
      console.log('📚 No terms found in database');
      return res.status(404).json({
        error: 'No vocabulary terms available',
        message: 'No terms found in the database. Please try again later or contact support.'
      });
    }

    // selectedTerm should be available now

    // Get related facts for the selected term
    const facts = await prisma.fact.findMany({
      where: { topicId: selectedTerm.topicId },
      take: 3
    });

    console.log('✅ Selected term:', selectedTerm.term, 'from topic:', selectedTopic?.name);

    const dailyWord = {
      id: selectedTerm.id,
      term: selectedTerm.term,
      definition: selectedTerm.definition,
      example: selectedTerm.example,
      category: selectedTerm.category || 'Vocabulary',
      complexityLevel: selectedTerm.complexityLevel || 'Intermediate',
      source: selectedTerm.source || 'AI Generated',
      sourceUrl: selectedTerm.sourceUrl,
      confidenceScore: selectedTerm.confidenceScore || 0.95,
      topic: selectedTopic?.name || 'General Vocabulary',
      facts: facts.map(f => ({
        id: f.id,
        fact: f.fact,
        category: f.category || 'General'
      })),
      relatedTerms: [] // Could be populated from database if needed
    };

    res.json({
      success: true,
      dailyWord: dailyWord,
      userProgress: {
        wordsLearned: 0,
        streak: 1,
        level: 'Beginner'
      }
    });

  } catch (error: any) {
    console.error('❌ Error getting daily word:', error);
    res.status(500).json({ 
      error: 'Failed to get daily word',
      message: error.message 
    });
  }
});

// POST /save-sample-terms - Save sample terms for testing (public endpoint)
router.post('/save-sample-terms', async (req, res) => {
  try {
    // Find or create Basketball topic
    let topic = await prisma.topic.findFirst({
      where: { name: 'Basketball' }
    });

    if (!topic) {
      topic = await prisma.topic.create({
        data: { name: 'Basketball' }
      });
      console.log('✅ Created Basketball topic');
    }

    // Create sample basketball terms
    const sampleTerms = [
      {
        topicId: topic.id,
        term: 'Dribble',
        definition: 'In basketball, dribbling is the act of bouncing the ball continuously while walking or running.',
        example: 'She dribbled past her defender with ease.',
        source: 'AI Generated',
        verified: true,
        gptGenerated: false,
        confidenceScore: 0.95,
        category: 'Sports',
        complexityLevel: 'Intermediate',
        moderationStatus: 'APPROVED'
      },
      {
        topicId: topic.id,
        term: 'Rebound',
        definition: 'A rebound occurs when a player retrieves the ball after a missed field goal attempt.',
        example: 'He grabbed the rebound and passed it to his teammate.',
        source: 'AI Generated',
        verified: true,
        gptGenerated: false,
        confidenceScore: 0.90,
        category: 'Sports',
        complexityLevel: 'Intermediate',
        moderationStatus: 'APPROVED'
      },
      {
        topicId: topic.id,
        term: 'Assist',
        definition: 'An assist is a pass that directly leads to a teammate scoring a basket.',
        example: 'Her assist set up the game-winning shot.',
        source: 'AI Generated',
        verified: true,
        gptGenerated: false,
        confidenceScore: 0.88,
        category: 'Sports',
        complexityLevel: 'Intermediate',
        moderationStatus: 'APPROVED'
      }
    ];

    // Save terms to database
    const createdTerms = await prisma.term.createMany({
      data: sampleTerms,
      skipDuplicates: true
    });

    console.log('✅ Saved sample basketball terms to database');

    res.json({
      success: true,
      message: 'Sample terms saved successfully',
      topicId: topic.id,
      termsCount: sampleTerms.length
    });

  } catch (error: any) {
    console.error('❌ Error saving sample terms:', error);
    res.status(500).json({ 
      error: 'Failed to save sample terms',
      message: error.message 
    });
  }
});

export default router;
