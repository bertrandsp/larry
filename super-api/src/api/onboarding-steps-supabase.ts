import express from 'express';
import { supabase } from '../config/supabase';

const router = express.Router();

// Helper function to extract user ID from token
function extractUserIdFromToken(authHeader: string | undefined): string | null {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  
  const token = authHeader.substring(7);
  const userIdMatch = token.match(/access_([^_]+)_/);
  return userIdMatch ? userIdMatch[1] : null;
}

// Helper function to set user context for RLS
async function setUserContext(userId: string): Promise<void> {
  if (supabase) {
    await supabase.rpc('set_current_user_id', { user_id: userId });
  }
}

// POST /onboarding/welcome - Record welcome step
router.post('/onboarding/welcome', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    await setUserContext(userId);

    const { error } = await supabase
      ?.from('User')
      .update({ 
        onboardingStep: 'dailyGoal',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, nextStep: 'dailyGoal' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/daily-goal - Record daily goal
router.post('/onboarding/daily-goal', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { goal } = req.body;
    if (!goal || goal < 1 || goal > 10) {
      return res.status(400).json({ success: false, error: 'Daily goal must be between 1 and 10' });
    }

    await setUserContext(userId);

    const { error } = await supabase
      ?.from('User')
      .update({ 
        dailyWordGoal: goal,
        onboardingStep: 'weekPreview',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, nextStep: 'weekPreview' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/week-preview - Record week preview (informational step)
router.post('/onboarding/week-preview', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    await setUserContext(userId);

    const { error } = await supabase
      ?.from('User')
      .update({ 
        onboardingStep: 'source',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, nextStep: 'source' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/source - Record how user found the app
router.post('/onboarding/source', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { source } = req.body;
    if (!source) {
      return res.status(400).json({ success: false, error: 'Source is required' });
    }

    await setUserContext(userId);

    const { error } = await supabase
      ?.from('User')
      .update({ 
        onboardingSource: source,
        onboardingStep: 'skillLevel',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, nextStep: 'skillLevel' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/skill-level - Record user's skill level
router.post('/onboarding/skill-level', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { level } = req.body;
    if (!level) {
      return res.status(400).json({ success: false, error: 'Skill level is required' });
    }

    await setUserContext(userId);

    const { error } = await supabase
      ?.from('User')
      .update({ 
        learningLevel: level,
        onboardingStep: 'widgetPrompt',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, nextStep: 'widgetPrompt' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/widget-preference - Record widget preference
router.post('/onboarding/widget-preference', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { enabled } = req.body;
    if (typeof enabled !== 'boolean') {
      return res.status(400).json({ success: false, error: 'Widget preference must be boolean' });
    }

    await setUserContext(userId);

    const { error } = await supabase
      ?.from('User')
      .update({ 
        widgetOptIn: enabled,
        onboardingStep: 'motivation',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    console.log('📱 Widget preference saved:', { userId, enabled, error: error?.message });

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, nextStep: 'motivation' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/motivation - Record motivation step (informational)
router.post('/onboarding/motivation', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    await setUserContext(userId);

    const { error } = await supabase
      ?.from('User')
      .update({ 
        onboardingStep: 'topics',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, nextStep: 'topics' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/topics - Record selected topics
router.post('/onboarding/topics', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { topicIds, customTopics } = req.body;
    if (!topicIds || !Array.isArray(topicIds) || topicIds.length < 3) {
      return res.status(400).json({ success: false, error: 'At least 3 topics must be selected' });
    }

    await setUserContext(userId);

    // Handle custom topics first (create them if they don't exist)
    const createdCustomTopics = [];
    if (customTopics && customTopics.length > 0) {
      for (const customTopicName of customTopics) {
        // Check if topic already exists
        const { data: existingTopic } = await supabase
          ?.from('Topic')
          .select('id')
          .eq('name', customTopicName)
          .single() || { data: null };

        if (!existingTopic) {
          // Create new custom topic
          const { data: newTopic, error: createError } = await supabase
            ?.from('Topic')
            .insert({
              id: `topic-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
              name: customTopicName
            })
            .select()
            .single() || { data: null, error: null };

          if (createError) {
            console.error('❌ Error creating custom topic:', createError);
            return res.status(500).json({ success: false, error: 'Failed to create custom topic' });
          }

          if (newTopic) {
            createdCustomTopics.push(newTopic.id);
            console.log(`✅ Created custom topic: ${customTopicName} (${newTopic.id})`);
          }
        } else {
          createdCustomTopics.push(existingTopic.id);
          console.log(`✅ Found existing custom topic: ${customTopicName} (${existingTopic.id})`);
        }
      }
    }

    // Combine stock topics and custom topics
    const allTopicIds = [...topicIds, ...createdCustomTopics];
    console.log('📋 All topic IDs to process:', allTopicIds);

    // Create UserTopic entries for all selected topics
    const userTopics = allTopicIds.map((topicId, index) => ({
      id: `usertopic-${Date.now()}-${index}-${Math.random().toString(36).substr(2, 9)}`,
      userId,
      topicId,
      weight: Math.floor(100 / allTopicIds.length) // Distribute weight evenly
    }));

    // Insert UserTopic entries
    const { error: userTopicError } = await supabase
      ?.from('UserTopic')
      .insert(userTopics) || { error: null };

    if (userTopicError) {
      console.error('❌ Error creating UserTopic entries:', userTopicError);
      return res.status(500).json({ success: false, error: 'Failed to save topic selections' });
    }

    console.log(`✅ Created ${userTopics.length} UserTopic entries`);

    // Update user's onboarding step to complete
    const { error: userError } = await supabase
      ?.from('User')
      .update({ 
        onboardingStep: 'complete',
        updatedAt: new Date().toISOString()
      })
      .eq('id', userId) || { error: null };

    if (userError) {
      return res.status(500).json({ success: false, error: userError.message });
    }

    console.log('📋 Selected topics processed successfully');
    console.log('📋 Stock topics:', topicIds);
    console.log('📋 Custom topics created:', createdCustomTopics);

    res.json({ 
      success: true, 
      nextStep: 'complete',
      topicsProcessed: userTopics.length,
      customTopicsCreated: createdCustomTopics.length
    });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /onboarding/record-step - Record step completion for analytics
router.post('/onboarding/record-step', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req.headers.authorization);
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Invalid authorization' });
    }

    const { step } = req.body;
    if (!step) {
      return res.status(400).json({ success: false, error: 'Step is required' });
    }

    // For now, just log the step completion
    // In a full implementation, you might store this in a separate analytics table
    console.log(`📊 User ${userId} completed step: ${step}`);

    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /topics - Get available topics for selection
router.get('/topics', async (req, res) => {
  try {
    const { data: topics, error } = await supabase
      ?.from('Topic')
      .select('*')
      .order('name') || { data: [], error: null };

    if (error) {
      return res.status(500).json({ success: false, error: error.message });
    }

    res.json({ success: true, topics: topics || [] });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
