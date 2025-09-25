import * as express from 'express';
import { database } from '../utils/prisma';
import { createDelivery, addToWordbank } from '../services/deliveryService';
import { generateVocabulary } from '../services/openAiService';

const router = express.Router();

/**
 * Complete onboarding and trigger first vocabulary generation
 */
router.post('/complete', async (req, res) => {
  try {
    const { userId, topics } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'User ID is required' });
    }
    
    if (!topics || !Array.isArray(topics) || topics.length === 0) {
      return res.status(400).json({ error: 'At least one topic is required' });
    }
    
    console.log(`🎯 Completing onboarding for user ${userId} with topics:`, topics);
    
    // Update user onboarding status
    await database.users.update(userId, {
      onboarding_completed: true,
      first_vocab_generated: false // Will be set to true after first vocab is generated
    });
    
    // Link user to topics
    for (const topic of topics) {
      await database.userTopics.create({
        user_id: userId,
        topic_id: topic.id,
        weight: topic.weight || 100
      });
    }
    
    // Generate first vocabulary immediately
    console.log(`🚀 Generating first vocabulary for user ${userId}`);
    
    try {
      // Get the first topic to generate vocabulary for
      const firstTopic = topics[0];
      const topicData = await database.topics.getById(firstTopic.id);
      
      if (!topicData) {
        throw new Error(`Topic not found: ${firstTopic.id}`);
      }
      
      // Generate vocabulary
      const result = await generateVocabulary({
        topic: topicData.name,
        numTerms: 1,
        definitionStyle: 'casual',
        sentenceRange: '2-4',
        numExamples: 2,
        numFacts: 1,
        termSelectionLevel: 'intermediate',
        definitionComplexityLevel: 'intermediate',
        domainContext: 'general',
        language: 'en',
        useAnalogy: true,
        includeSynonyms: true,
        includeAntonyms: true,
        includeRelatedTerms: true,
        includeEtymology: false,
        highlightRootWords: false,
        openAiFirst: true
      });
      
      if (result && result.response && result.response.terms && result.response.terms.length > 0) {
        const newTerm = result.response.terms[0];
        
        // Save the term to database
        const savedTerm = await database.terms.create({
          topic_id: topicData.id,
          term: newTerm.term,
          definition: newTerm.definition,
          example: newTerm.examples && newTerm.examples.length > 0 ? newTerm.examples[0] : '',
          source: 'OpenAI',
          verified: false,
          gpt_generated: true,
          confidence_score: 0.9,
          category: 'general',
          complexity_level: 'intermediate'
        });
        
        console.log(`✅ Generated first term: ${savedTerm.term}`);
        
        // Create delivery record
        const delivery = await createDelivery(userId, savedTerm.id);
        
        // Add to wordbank for spaced repetition
        await addToWordbank(userId, savedTerm.id, 1);
        
        // Update user to mark first vocab as generated
        await database.users.update(userId, {
          first_vocab_generated: true,
          last_daily_word_date: new Date().toISOString(),
          daily_word_streak: 1
        });
        
        return res.json({
          success: true,
          message: 'Onboarding completed successfully',
          firstWord: {
            deliveryId: delivery.id,
            termId: savedTerm.id,
            term: savedTerm.term,
            definition: savedTerm.definition,
            example: savedTerm.example,
            category: savedTerm.category,
            complexityLevel: savedTerm.complexity_level,
            topicId: savedTerm.topic_id
          }
        });
      } else {
        throw new Error('Failed to generate vocabulary');
      }
      
    } catch (error) {
      console.error(`❌ Error generating first vocabulary:`, error);
      
      // Still mark onboarding as complete, but first vocab will be generated later
      await database.users.update(userId, {
        first_vocab_generated: false
      });
      
      return res.json({
        success: true,
        message: 'Onboarding completed, but first vocabulary generation is in progress',
        firstWord: null,
        error: 'Vocabulary generation pending'
      });
    }
    
  } catch (error: any) {
    console.error('❌ Onboarding completion error:', error);
    res.status(500).json({ 
      error: 'Failed to complete onboarding',
      details: error.message 
    });
  }
});

/**
 * Get user's onboarding status
 */
router.get('/status/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await database.users.getById(userId);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const userTopics = await database.userTopics.getAll({ userId });
    const topics = await Promise.all(
      userTopics.map(async (ut) => {
        const topic = await database.topics.getById(ut.topic_id);
        return {
          id: topic.id,
          name: topic.name,
          weight: ut.weight
        };
      })
    );
    
    res.json({
      userId: user.id,
      onboardingCompleted: user.onboarding_completed,
      firstVocabGenerated: user.first_vocab_generated,
      dailyWordStreak: user.daily_word_streak,
      lastDailyWordDate: user.last_daily_word_date,
      topics
    });
    
  } catch (error: any) {
    console.error('❌ Get onboarding status error:', error);
    res.status(500).json({ 
      error: 'Failed to get onboarding status',
      details: error.message 
    });
  }
});

export default router;
