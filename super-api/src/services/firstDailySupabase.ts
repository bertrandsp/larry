import { supabase } from '../config/supabase';
import { parseVocabularyFields } from '../utils/vocabularyUtils';

export interface FirstDailyWord {
  id: string;
  term: string;
  definition: string;
  example: string;
  category: string;
  complexityLevel: string;
  source: string;
  sourceUrl?: string;
  confidenceScore: number;
  topic: string;
  
  // 🔥 NEW: Rich vocabulary fields
  synonyms: string[];
  antonyms: string[];
  relatedTerms: Array<{
    term: string;
    difference: string;
  }>;
  partOfSpeech?: string;
  difficulty?: number;
  etymology?: string;
  pronunciation?: string;
  tags: string[];
  
  facts: Array<{
    id: string;
    fact: string;
    category: string;
  }>;
  delivery: {
    id: string;
    deliveredAt: string;
  };
  wordbank: {
    id: string;
    bucket: number;
    status: string;
  };
  isFirstWord: boolean;
}

/**
 * Get the first daily word for a user after onboarding completion
 */
export async function getFirstDailyWord(userId: string): Promise<FirstDailyWord | null> {
  console.log(`🎯 Getting first daily word for user ${userId}`);
  
  try {
    if (!supabase) {
      console.error('❌ Supabase client not initialized');
      return null;
    }

    // Set user context for RLS
    await supabase.rpc('set_current_user_id', { user_id: userId });

    // Get user with their topics
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
      console.error('❌ User not found:', userError);
      return null;
    }

    if (!user.onboardingCompleted) {
      console.error('❌ User onboarding not completed');
      return null;
    }

    if (user.firstVocabGenerated) {
      console.log('✅ User already has first vocab generated');
      return null; // Should redirect to regular daily endpoint
    }

    if (!user.topics || user.topics.length === 0) {
      console.error('❌ User has no topics selected');
      return null;
    }

    console.log(`📚 User has ${user.topics.length} topics selected`);

    // Get topic IDs
    const topicIds = user.topics.map((ut: any) => ut.topicId);

    // Find available terms from user's topics (prioritize recently created terms)
    const { data: availableTerms, error: termsError } = await supabase
      .from('Term')
      .select(`
        *,
        topic:Topic(*)
      `)
      .in('topicId', topicIds)
      .eq('moderationStatus', 'approved')
      .order('createdAt', { ascending: false })
      .limit(10);

    if (termsError || !availableTerms || availableTerms.length === 0) {
      console.error('❌ No available terms found:', termsError);
      return null;
    }

    console.log(`📖 Found ${availableTerms.length} available terms`);

    // Select first available term
    const selectedTerm = availableTerms[0];
    console.log(`🎯 Selected first term: ${selectedTerm.term} from topic: ${selectedTerm.topic.name}`);

    // Create delivery record
    const delivery = await createDelivery(userId, selectedTerm.id);
    if (!delivery) {
      console.error('❌ Failed to create delivery record');
      return null;
    }

    // Add to wordbank
    const wordbankEntry = await addToWordbank(userId, selectedTerm.id);
    if (!wordbankEntry) {
      console.error('❌ Failed to create wordbank entry');
      return null;
    }

    // Update user to mark first vocab as generated
    const { error: updateError } = await supabase
      .from('User')
      .update({
        firstVocabGenerated: true,
        lastDailyWordDate: new Date().toISOString(),
        dailyWordStreak: 1
      })
      .eq('id', userId);

    if (updateError) {
      console.error('❌ Failed to update user:', updateError);
      return null;
    }

    // Get related facts
    const { data: facts, error: factsError } = await supabase
      .from('Fact')
      .select('*')
      .eq('topicId', selectedTerm.topicId)
      .limit(3);

    // Parse rich vocabulary fields from JSON
    const enrichedTerm = parseVocabularyFields(selectedTerm);

    const firstDailyWord: FirstDailyWord = {
      id: selectedTerm.id,
      term: selectedTerm.term,
      definition: selectedTerm.definition,
      example: selectedTerm.example,
      category: selectedTerm.category || 'Vocabulary',
      complexityLevel: selectedTerm.complexityLevel || 'Intermediate',
      
      // 🔥 NEW: Rich vocabulary fields
      synonyms: enrichedTerm.synonyms,
      antonyms: enrichedTerm.antonyms,
      relatedTerms: enrichedTerm.relatedTerms,
      partOfSpeech: selectedTerm.partOfSpeech,
      difficulty: selectedTerm.difficulty,
      etymology: selectedTerm.etymology,
      pronunciation: selectedTerm.pronunciation,
      tags: enrichedTerm.tags,
      source: selectedTerm.source || 'AI Generated',
      sourceUrl: selectedTerm.sourceUrl,
      confidenceScore: selectedTerm.confidenceScore || 0.95,
      topic: selectedTerm.topic?.name || 'General Vocabulary',
      facts: (facts || []).map(f => ({
        id: f.id,
        fact: f.fact,
        category: f.category || 'General'
      })),
      delivery: {
        id: delivery.id,
        deliveredAt: delivery.deliveredAt
      },
      wordbank: {
        id: wordbankEntry.id,
        bucket: wordbankEntry.bucket,
        status: wordbankEntry.status
      },
      isFirstWord: true
    };

    console.log('✅ First daily word delivered successfully');
    return firstDailyWord;

  } catch (error: any) {
    console.error('❌ Error getting first daily word:', error);
    return null;
  }
}

/**
 * Create a delivery record for a term
 */
async function createDelivery(userId: string, termId: string): Promise<any> {
  try {
    if (!supabase) return null;

    const deliveryData = {
      id: `delivery-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId,
      termId,
      deliveredAt: new Date().toISOString(),
      action: 'NONE'
    };

    const { data, error } = await supabase
      .from('Delivery')
      .insert(deliveryData)
      .select()
      .single();

    if (error) {
      console.error('❌ Error creating delivery:', error);
      return null;
    }

    return data;
  } catch (error) {
    console.error('❌ Error in createDelivery:', error);
    return null;
  }
}

/**
 * Add a term to user's wordbank
 */
async function addToWordbank(userId: string, termId: string): Promise<any> {
  try {
    if (!supabase) return null;

    const wordbankData = {
      id: `wordbank-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId,
      termId,
      status: 'LEARNING',
      bucket: 1,
      reviewCount: 0,
      lastReviewed: null,
      nextReview: null
    };

    const { data, error } = await supabase
      .from('Wordbank')
      .insert(wordbankData)
      .select()
      .single();

    if (error) {
      console.error('❌ Error creating wordbank entry:', error);
      return null;
    }

    return data;
  } catch (error) {
    console.error('❌ Error in addToWordbank:', error);
    return null;
  }
}

/**
 * Record user action on their first daily word
 */
export async function recordFirstDailyWordAction(
  deliveryId: string, 
  action: 'FAVORITE' | 'LEARN_AGAIN' | 'MASTERED',
  wordbankId?: string
): Promise<boolean> {
  try {
    if (!supabase) return false;

    console.log(`🎬 Recording first daily word action: ${action} for delivery ${deliveryId}`);

    // Update delivery record
    const { error: deliveryError } = await supabase
      .from('Delivery')
      .update({ 
        action,
        openedAt: new Date().toISOString()
      })
      .eq('id', deliveryId);

    if (deliveryError) {
      console.error('❌ Error updating delivery:', deliveryError);
      return false;
    }

    // Update wordbank if provided
    if (wordbankId) {
      const { data: wordbank, error: wordbankError } = await supabase
        .from('Wordbank')
        .select('*')
        .eq('id', wordbankId)
        .single();

      if (wordbankError || !wordbank) {
        console.error('❌ Error fetching wordbank:', wordbankError);
        return false;
      }

      let updateData: any = {
        lastReviewed: new Date().toISOString(),
        reviewCount: wordbank.reviewCount + 1
      };

      // Calculate next review based on action
      const nextReview = new Date();
      switch (action) {
        case 'LEARN_AGAIN':
          updateData.bucket = 1;
          nextReview.setDate(nextReview.getDate() + 1);
          updateData.nextReview = nextReview.toISOString();
          break;
        case 'FAVORITE':
          nextReview.setDate(nextReview.getDate() + Math.pow(2, wordbank.bucket));
          updateData.nextReview = nextReview.toISOString();
          break;
        case 'MASTERED':
          updateData.status = 'MASTERED';
          updateData.nextReview = null;
          break;
      }

      const { error: updateError } = await supabase
        .from('Wordbank')
        .update(updateData)
        .eq('id', wordbankId);

      if (updateError) {
        console.error('❌ Error updating wordbank:', updateError);
        return false;
      }
    }

    console.log('✅ First daily word action recorded successfully');
    return true;

  } catch (error: any) {
    console.error('❌ Error recording first daily word action:', error);
    return false;
  }
}
