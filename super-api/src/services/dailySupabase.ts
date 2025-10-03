import { supabase } from '../config/supabase';
import { parseVocabularyFields } from '../utils/vocabularyUtils';
import { generateVocabulary } from './openAiService';

export interface DailyWord {
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
  
  // Rich vocabulary fields
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
  isReview: boolean;
  userProgress?: {
    wordsLearned: number;
    streak: number;
    level: string;
  };
}

/**
 * Get the next daily word for a user using spaced repetition algorithm
 */
export async function getNextDailyWord(userId: string): Promise<DailyWord | null> {
  console.log(`🎯 Getting next daily word for user ${userId}`);
  
  try {
    if (!supabase) {
      console.error('❌ Supabase client not initialized');
      return null;
    }

    // Set user context for RLS
    await supabase.rpc('set_current_user_id', { user_id: userId });

    // First, check for words due for review (spaced repetition)
    const reviewWord = await getNextReviewWord(userId);
    if (reviewWord) {
      console.log(`📖 Returning review word: ${reviewWord.term}`);
      return reviewWord;
    }

    // No words to review, get a new word from user's topics
    const newWord = await getNewWordFromUserTopics(userId);
    if (newWord) {
      console.log(`🆕 Returning new word: ${newWord.term}`);
      return newWord;
    }

    console.log('⚠️ No words available for user');
    return null;

  } catch (error: any) {
    console.error('❌ Error getting next daily word:', error);
    return null;
  }
}

/**
 * Get the next unseen word for a user (for swipe-to-next functionality)
 */
export async function getNextUnseenWord(userId: string): Promise<DailyWord | null> {
  console.log(`🎯 Getting next unseen word for user ${userId}`);
  
  try {
    if (!supabase) {
      console.error('❌ Supabase client not initialized');
      return null;
    }

    // Set user context for RLS
    await supabase.rpc('set_current_user_id', { user_id: userId });

    // Get a completely new word that user hasn't seen before
    const newWord = await getNewWordFromUserTopics(userId);
    if (newWord) {
      console.log(`🆕 Returning unseen word: ${newWord.term}`);
      return newWord;
    }

    console.log('⚠️ No unseen words available for user');
    return null;

  } catch (error: any) {
    console.error('❌ Error getting next unseen word:', error);
    return null;
  }
}

/**
 * Get the next word due for review using spaced repetition
 */
async function getNextReviewWord(userId: string): Promise<DailyWord | null> {
  try {
    const { data: reviewWords, error } = await supabase
      .from('Wordbank')
      .select(`
        *,
        term:Term(
          *,
          topic:Topic(*)
        )
      `)
      .eq('userId', userId)
      .eq('status', 'LEARNING')
      .lte('nextReview', new Date().toISOString())
      .order('nextReview', { ascending: true })
      .limit(1);

    if (error || !reviewWords || reviewWords.length === 0) {
      return null;
    }

    const wordbankEntry = reviewWords[0];
    const term = wordbankEntry.term;

    // Create delivery record
    const delivery = await createDelivery(userId, term.id);

    // Get related facts
    const facts = await getFactsForTopic(term.topicId);

    // Parse rich vocabulary fields
    const enrichedTerm = parseVocabularyFields(term);

    const dailyWord: DailyWord = {
      id: term.id,
      term: term.term,
      definition: term.definition,
      example: term.example,
      category: term.category || 'Vocabulary',
      complexityLevel: term.complexityLevel || 'Intermediate',
      source: term.source || 'AI Generated',
      sourceUrl: term.sourceUrl,
      confidenceScore: term.confidenceScore || 0.95,
      topic: term.topic?.name || 'General Vocabulary',
      synonyms: enrichedTerm.synonyms,
      antonyms: enrichedTerm.antonyms,
      relatedTerms: enrichedTerm.relatedTerms,
      partOfSpeech: term.partOfSpeech,
      difficulty: term.difficulty,
      etymology: term.etymology,
      pronunciation: term.pronunciation,
      tags: enrichedTerm.tags,
      facts,
      delivery: {
        id: delivery.id,
        deliveredAt: new Date(delivery.deliveredAt).toISOString()
      },
      wordbank: {
        id: wordbankEntry.id,
        bucket: wordbankEntry.bucket,
        status: wordbankEntry.status
      },
      isReview: true
    };

    return dailyWord;

  } catch (error) {
    console.error('❌ Error getting review word:', error);
    return null;
  }
}

/**
 * Get a new word from user's topics, generating with OpenAI if needed
 */
async function getNewWordFromUserTopics(userId: string): Promise<DailyWord | null> {
  try {
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

    if (userError || !user || !user.topics || user.topics.length === 0) {
      console.error('❌ User not found or has no topics:', userError);
      return null;
    }

    // Get topic IDs
    const topicIds = user.topics.map((ut: any) => ut.topicId);

    // Find terms from user's topics that aren't already seen (in wordbank or delivered)
    const { data: existingWordbank, error: wordbankError } = await supabase
      .from('Wordbank')
      .select('termId')
      .eq('userId', userId);

    if (wordbankError) {
      console.error('❌ Error fetching wordbank:', wordbankError);
      return null;
    }

    const { data: deliveredTerms, error: deliveryError } = await supabase
      .from('Delivery')
      .select('termId')
      .eq('userId', userId);

    if (deliveryError) {
      console.error('❌ Error fetching delivered terms:', deliveryError);
      return null;
    }

    const existingTermIds = existingWordbank?.map(w => w.termId) || [];
    const deliveredTermIds = deliveredTerms?.map(d => d.termId) || [];
    const allSeenTermIds = [...new Set([...existingTermIds, ...deliveredTermIds])]; // Remove duplicates

    // Get available terms from user's topics that haven't been seen
    let { data: availableTerms, error: termsError } = await supabase
      .from('Term')
      .select(`
        *,
        topic:Topic(*)
      `)
      .in('topicId', topicIds)
      .eq('moderationStatus', 'approved')
      .not('id', 'in', `(${allSeenTermIds.join(',')})`)
      .order('createdAt', { ascending: false })
      .limit(10);

    if (termsError) {
      console.error('❌ Error fetching terms:', termsError);
      availableTerms = [];
    }

    // If no terms available, generate new vocabulary using OpenAI
    if (!availableTerms || availableTerms.length === 0) {
      console.log('🚀 No terms available, generating new vocabulary with OpenAI...');
      
      // Select a random topic for generation
      const randomTopic = user.topics[Math.floor(Math.random() * user.topics.length)];
      const generatedTerm = await generateVocabularyForTopic(randomTopic.topic.name, userId);
      
      if (generatedTerm) {
        // Create delivery record
        const delivery = await createDelivery(userId, generatedTerm.id);

        // Add to wordbank
        const wordbankEntry = await addToWordbank(userId, generatedTerm.id);

        // Get related facts
        const facts = await getFactsForTopic(generatedTerm.topicId);

        // Parse rich vocabulary fields
        const enrichedTerm = parseVocabularyFields(generatedTerm);

        const dailyWord: DailyWord = {
          id: generatedTerm.id,
          term: generatedTerm.term,
          definition: generatedTerm.definition,
          example: generatedTerm.example,
          category: generatedTerm.category || 'Vocabulary',
          complexityLevel: generatedTerm.complexityLevel || 'Intermediate',
          source: generatedTerm.source || 'AI Generated',
          sourceUrl: generatedTerm.sourceUrl,
          confidenceScore: generatedTerm.confidenceScore || 0.95,
          topic: generatedTerm.topic?.name || 'General Vocabulary',
          synonyms: enrichedTerm.synonyms,
          antonyms: enrichedTerm.antonyms,
          relatedTerms: enrichedTerm.relatedTerms,
          partOfSpeech: generatedTerm.partOfSpeech,
          difficulty: generatedTerm.difficulty,
          etymology: generatedTerm.etymology,
          pronunciation: generatedTerm.pronunciation,
          tags: enrichedTerm.tags,
          facts,
          delivery: {
            id: delivery.id,
            deliveredAt: delivery.deliveredAt
          },
          wordbank: {
            id: wordbankEntry.id,
            bucket: wordbankEntry.bucket,
            status: wordbankEntry.status
          },
          isReview: false
        };

        return dailyWord;
      }
    }

    // Use existing term
    if (availableTerms && availableTerms.length > 0) {
      const selectedTerm = availableTerms[0];
      console.log(`🎯 Selected existing term: ${selectedTerm.term} from topic: ${selectedTerm.topic.name}`);

      // Create delivery record
      const delivery = await createDelivery(userId, selectedTerm.id);

      // Add to wordbank
      const wordbankEntry = await addToWordbank(userId, selectedTerm.id);

      if (!wordbankEntry) {
        console.error('❌ Failed to create or retrieve wordbank entry');
        return null;
      }

      // Get related facts
      const facts = await getFactsForTopic(selectedTerm.topicId);

      // Parse rich vocabulary fields
      const enrichedTerm = parseVocabularyFields(selectedTerm);

      const dailyWord: DailyWord = {
        id: selectedTerm.id,
        term: selectedTerm.term,
        definition: selectedTerm.definition,
        example: selectedTerm.example,
        category: selectedTerm.category || 'Vocabulary',
        complexityLevel: selectedTerm.complexityLevel || 'Intermediate',
        source: selectedTerm.source || 'AI Generated',
        sourceUrl: selectedTerm.sourceUrl,
        confidenceScore: selectedTerm.confidenceScore || 0.95,
        topic: selectedTerm.topic?.name || 'General Vocabulary',
        synonyms: enrichedTerm.synonyms,
        antonyms: enrichedTerm.antonyms,
        relatedTerms: enrichedTerm.relatedTerms,
        partOfSpeech: selectedTerm.partOfSpeech,
        difficulty: selectedTerm.difficulty,
        etymology: selectedTerm.etymology,
        pronunciation: selectedTerm.pronunciation,
        tags: enrichedTerm.tags,
        facts,
        delivery: {
          id: delivery.id,
          deliveredAt: delivery.deliveredAt
        },
        wordbank: {
          id: wordbankEntry.id,
          bucket: wordbankEntry.bucket,
          status: wordbankEntry.status
        },
        isReview: false
      };

      return dailyWord;
    }

    return null;

  } catch (error) {
    console.error('❌ Error getting new word from user topics:', error);
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

    // First, check if wordbank entry already exists
    const { data: existingEntry } = await supabase
      .from('Wordbank')
      .select('*')
      .eq('userId', userId)
      .eq('termId', termId)
      .single();

    if (existingEntry) {
      console.log(`📚 Wordbank entry already exists for term ${termId}`);
      return existingEntry;
    }

    const wordbankData = {
      id: `wordbank-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId,
      termId,
      status: 'LEARNING',
      bucket: 1,
      reviewCount: 0,
      lastReviewed: null,
      nextReview: null,
      relevance: 'RELATED'
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
 * Get facts for a topic
 */
async function getFactsForTopic(topicId: string): Promise<Array<{id: string, fact: string, category: string}>> {
  try {
    if (!supabase) return [];

    const { data: facts, error } = await supabase
      .from('Fact')
      .select('*')
      .eq('topicId', topicId)
      .limit(3);

    if (error) {
      console.error('❌ Error fetching facts:', error);
      return [];
    }

    return (facts || []).map(f => ({
      id: f.id,
      fact: f.fact,
      category: f.category || 'General'
    }));
  } catch (error) {
    console.error('❌ Error in getFactsForTopic:', error);
    return [];
  }
}

/**
 * Record user action on a daily word
 */
export async function recordDailyWordAction(
  deliveryId: string, 
  action: 'FAVORITE' | 'LEARN_AGAIN' | 'MASTERED',
  wordbankId?: string
): Promise<boolean> {
  try {
    if (!supabase) return false;

    console.log(`🎬 Recording daily word action: ${action} for delivery ${deliveryId}`);

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

      // Calculate next review based on spaced repetition algorithm
      const nextReview = new Date();
      switch (action) {
        case 'LEARN_AGAIN':
          updateData.bucket = 1;
          nextReview.setDate(nextReview.getDate() + 1);
          updateData.nextReview = nextReview.toISOString();
          break;
        case 'FAVORITE':
          updateData.bucket = Math.min(wordbank.bucket + 1, 5); // Max bucket 5
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

    console.log('✅ Daily word action recorded successfully');
    return true;

  } catch (error: any) {
    console.error('❌ Error recording daily word action:', error);
    return false;
  }
}

/**
 * Generate vocabulary for a specific topic using OpenAI
 */
async function generateVocabularyForTopic(topicName: string, userId: string): Promise<any> {
  try {
    console.log(`🤖 Generating vocabulary for topic: ${topicName}`);
    
    // Generate vocabulary using existing OpenAI service
    const { response } = await generateVocabulary({
      topic: topicName,
      numTerms: 1, // Generate just one term for daily word
      definitionStyle: 'formal',
      sentenceRange: '2-3',
      numExamples: 1,
      numFacts: 1,
      termSelectionLevel: 'intermediate',
      definitionComplexityLevel: 'intermediate',
      domainContext: topicName,
      language: 'en',
      useAnalogy: true,
      includeSynonyms: true,
      includeAntonyms: false,
      includeRelatedTerms: true,
      includeEtymology: false,
      highlightRootWords: false,
      openAiFirst: true
    });

    if (!response.terms || response.terms.length === 0) {
      console.error('❌ No terms generated from OpenAI');
      return null;
    }

    const generatedTerm = response.terms[0];
    
    // Get the topic ID
    const { data: topic, error: topicError } = await supabase
      .from('Topic')
      .select('id')
      .eq('name', topicName)
      .single();

    if (topicError || !topic) {
      console.error('❌ Topic not found:', topicError);
      return null;
    }

    // Create term in database
    const termData = {
      id: `term-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      topicId: topic.id,
      term: generatedTerm.term,
      definition: generatedTerm.definition,
      example: generatedTerm.examples?.[0] || generatedTerm.definition,
      category: 'Vocabulary',
      complexityLevel: 'Intermediate',
      source: 'AI Generated',
      sourceUrl: null,
      confidenceScore: 0.8,
      moderationStatus: 'approved',
      // Rich vocabulary fields as JSON
      synonyms: JSON.stringify(generatedTerm.synonyms || []),
      antonyms: JSON.stringify(generatedTerm.antonyms || []),
      relatedTerms: JSON.stringify(generatedTerm.relatedTerms || []),
      partOfSpeech: generatedTerm.partOfSpeech,
      difficulty: generatedTerm.difficulty,
      etymology: generatedTerm.etymology,
      pronunciation: generatedTerm.pronunciation,
      tags: JSON.stringify([topicName, 'AI Generated'])
    };

    const { data: newTerm, error: insertError } = await supabase
      .from('Term')
      .insert(termData)
      .select(`
        *,
        topic:Topic(*)
      `)
      .single();

    if (insertError) {
      console.error('❌ Error inserting generated term:', insertError);
      return null;
    }

    // Create fact if available
    if (response.facts && response.facts.length > 0) {
      const factData = {
        id: `fact-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        topicId: topic.id,
        fact: response.facts[0],
        category: 'General',
        source: 'AI Generated',
        sourceUrl: null
      };

      await supabase
        .from('Fact')
        .insert(factData);
    }

    console.log(`✅ Generated and saved term: ${newTerm.term}`);
    return newTerm;

  } catch (error) {
    console.error('❌ Error generating vocabulary for topic:', error);
    return null;
  }
}
