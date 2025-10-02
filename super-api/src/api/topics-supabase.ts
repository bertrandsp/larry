import express from 'express';
import { supabase } from '../config/supabase';
import { z } from 'zod';

const router = express.Router();

// Validation schemas
const addTopicSchema = z.object({
  topicId: z.string().min(1),
  weight: z.number().min(0).max(100).default(50),
});

const updateWeightSchema = z.object({
  weight: z.number().min(0).max(100),
});

// GET /topics/available - Get all available topics that users can add
router.get('/topics/available', async (req, res) => {
  try {
    const { userId } = req.query;
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }

    // Get all active topics with counts
    const { data: allTopics, error: topicsError } = await supabase
      .from('Topic')
      .select(`
        id,
        name,
        description,
        isActive,
        createdAt,
        updatedAt,
        userTopics:UserTopic(count),
        terms:Term(count)
      `)
      .eq('isActive', true)
      .order('name', { ascending: true });

    if (topicsError) {
      console.error('Error fetching topics:', topicsError);
      return res.status(500).json({ error: 'Failed to fetch topics' });
    }

    let availableTopics = allTopics || [];

    // If userId provided, exclude topics user already has
    if (userId) {
      const { data: userTopics, error: userTopicsError } = await supabase
        .from('UserTopic')
        .select('topicId')
        .eq('userId', userId as string);

      if (userTopicsError) {
        console.error('Error fetching user topics:', userTopicsError);
        return res.status(500).json({ error: 'Failed to fetch user topics' });
      }

      const userTopicIds = new Set((userTopics || []).map(ut => ut.topicId));
      availableTopics = allTopics?.filter(topic => !userTopicIds.has(topic.id)) || [];
    }

    const result = availableTopics.map(topic => {
      // Handle Supabase count aggregations
      const termCount = Array.isArray(topic.terms) ? topic.terms.length : (topic.terms as any)?.count || 0;
      const userCount = Array.isArray(topic.userTopics) ? topic.userTopics.length : (topic.userTopics as any)?.count || 0;
      
      return {
        id: topic.id,
        name: topic.name,
        description: topic.description,
        category: 'other', // Default category since we removed it from query
        isActive: topic.isActive,
        termCount,
        userCount,
        isPopular: userCount > 10,
        createdAt: topic.createdAt,
        updatedAt: topic.updatedAt
      };
    });

    res.json({
      success: true,
      topics: result,
      totalCount: result.length
    });
  } catch (error: any) {
    console.error('Error fetching available topics:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /user/:userId/topics - List user topics
router.get('/user/:userId/topics', async (req, res) => {
  try {
    const { userId } = req.params;
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }

    // Check if user exists
    const { data: user, error: userError } = await supabase
      .from('User')
      .select('id')
      .eq('id', userId)
      .single();

    if (userError || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get user topics with topic details
    const { data: userTopics, error: topicsError } = await supabase
      .from('UserTopic')
      .select(`
        id,
        topicId,
        weight,
        enabled,
        topic:Topic(
          id,
          name,
          description,
          isActive,
          terms:Term(count)
        )
      `)
      .eq('userId', userId)
      .order('id', { ascending: true });

    if (topicsError) {
      console.error('Error fetching user topics:', topicsError);
      return res.status(500).json({ error: 'Failed to fetch user topics' });
    }

    const result = (userTopics || []).map(ut => {
      // Handle the case where topic might be an array (Supabase sometimes returns arrays for single relations)
      const topic = Array.isArray(ut.topic) ? ut.topic[0] : ut.topic;
      const terms = Array.isArray(topic?.terms) ? topic.terms : [topic?.terms].filter(Boolean);
      
      return {
        id: ut.id,
        topicId: ut.topicId,
        name: topic?.name || 'Unknown Topic',
        weight: ut.weight,
        enabled: ut.enabled,
        termCount: terms.length || (topic?.terms as any)?.count || 0,
        category: 'other' // Default category
      };
    });

    res.json({
      success: true,
      topics: result,
      totalCount: result.length
    });
  } catch (error: any) {
    console.error('Error fetching user topics:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /user/:userId/topics/add - Add existing topic to user
router.post('/user/:userId/topics/add', async (req, res) => {
  try {
    const { userId } = req.params;
    const { topicId, weight } = addTopicSchema.parse(req.body);
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }

    // Check if user exists
    const { data: user, error: userError } = await supabase
      .from('User')
      .select('id')
      .eq('id', userId)
      .single();

    if (userError || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if topic exists
    const { data: topic, error: topicError } = await supabase
      .from('Topic')
      .select('id, name, description, isActive')
      .eq('id', topicId)
      .single();

    if (topicError || !topic) {
      return res.status(404).json({ error: 'Topic not found' });
    }

    if (!topic.isActive) {
      return res.status(400).json({ error: 'Topic is not active' });
    }

    // Check if user already has this topic
    const { data: existingUserTopic, error: existingError } = await supabase
      .from('UserTopic')
      .select('id')
      .eq('userId', userId)
      .eq('topicId', topicId)
      .single();

    if (existingUserTopic) {
      return res.status(409).json({ error: 'User already has this topic' });
    }

    // Generate unique ID for UserTopic
    const userTopicId = `ut-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    // Add topic to user
    const { data: userTopic, error: createError } = await supabase
      .from('UserTopic')
      .insert({
        id: userTopicId,
        userId,
        topicId,
        weight,
        enabled: true
      })
      .select(`
        id,
        topicId,
        userId,
        weight,
        enabled
      `)
      .single();

    if (createError) {
      console.error('Error creating user topic:', createError);
      return res.status(500).json({ error: 'Failed to add topic to user' });
    }

    // Get term count for the topic
    const { count: termCount } = await supabase
      .from('Term')
      .select('*', { count: 'exact', head: true })
      .eq('topicId', topicId);

    res.status(201).json({
      success: true,
      userTopic: {
        id: userTopic.id,
        topicId: userTopic.topicId,
        userId: userTopic.userId,
        weight: userTopic.weight,
        enabled: userTopic.enabled,
        topic: {
          id: topic.id,
          name: topic.name,
          description: topic.description,
          category: 'other', // Default category
          termCount: termCount || 0
        }
      }
    });
  } catch (error: any) {
    console.error('Error adding topic to user:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /user/topics/:userTopicId - Update topic weight
router.put('/user/topics/:userTopicId', async (req, res) => {
  try {
    const { userTopicId } = req.params;
    const { weight } = updateWeightSchema.parse(req.body);
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }

    // Update the user topic
    const { data: userTopic, error: updateError } = await supabase
      .from('UserTopic')
      .update({
        weight
      })
      .eq('id', userTopicId)
      .select(`
        id,
        topicId,
        userId,
        weight,
        enabled,
        createdAt,
        updatedAt,
        topic:Topic(
          id,
          name,
          description
        )
      `)
      .single();

    if (updateError) {
      console.error('Error updating topic weight:', updateError);
      if (updateError.code === 'PGRST116') {
        return res.status(404).json({ error: 'User topic not found' });
      }
      return res.status(500).json({ error: 'Failed to update topic weight' });
    }

    res.json({
      success: true,
      userTopic
    });
  } catch (error: any) {
    console.error('Error updating topic weight:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /user/topics/:userTopicId/toggle - Toggle topic enabled/disabled
router.put('/user/topics/:userTopicId/toggle', async (req, res) => {
  try {
    const { userTopicId } = req.params;
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }

    // Get current state
    const { data: currentTopic, error: fetchError } = await supabase
      .from('UserTopic')
      .select('enabled')
      .eq('id', userTopicId)
      .single();

    if (fetchError || !currentTopic) {
      return res.status(404).json({ error: 'User topic not found' });
    }

    // Toggle the enabled state
    const { data: userTopic, error: updateError } = await supabase
      .from('UserTopic')
      .update({
        enabled: !currentTopic.enabled
      })
      .eq('id', userTopicId)
      .select(`
        id,
        topicId,
        userId,
        weight,
        enabled,
        createdAt,
        updatedAt,
        topic:Topic(
          id,
          name,
          description
        )
      `)
      .single();

    if (updateError) {
      console.error('Error toggling topic:', updateError);
      return res.status(500).json({ error: 'Failed to toggle topic' });
    }

    res.json({
      success: true,
      userTopic
    });
  } catch (error: any) {
    console.error('Error toggling topic:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /user/topics/:userTopicId - Remove topic from user
router.delete('/user/topics/:userTopicId', async (req, res) => {
  try {
    const { userTopicId } = req.params;
    
    if (!supabase) {
      return res.status(503).json({ error: 'Database not available' });
    }

    // Delete the user topic
    const { error: deleteError } = await supabase
      .from('UserTopic')
      .delete()
      .eq('id', userTopicId);

    if (deleteError) {
      console.error('Error deleting user topic:', deleteError);
      if (deleteError.code === 'PGRST116') {
        return res.status(404).json({ error: 'User topic not found' });
      }
      return res.status(500).json({ error: 'Failed to remove topic' });
    }

    res.status(204).send();
  } catch (error: any) {
    console.error('Error removing topic from user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
