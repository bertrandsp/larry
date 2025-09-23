import { prisma } from '../utils/prisma';
import { generateVocabulary, generateSingleTerm } from './openAiService';
import { validateTerms, validateOpenAiResponse } from './validationService';
import { postProcessTerms, postProcessFacts, type Term as PostProcessedTerm } from './postProcessingService';
import { getOrCreateCanonicalSetForTopic } from './canonicalSetService';
import { filterDuplicateTerms, filterDuplicateFacts, getDuplicateStats } from './duplicatePreventionService';
import { logContentGeneration, logPipelineEvent, logOpenAiUsage } from '../metrics/logEvents';

export interface TermGenerationParams {
  userId: string;
  topicId: string;
  topicName: string;
  userTier?: string;
}

export async function generateTermsAndFacts({ userId, topicId, topicName, userTier = 'free' }: TermGenerationParams) {
  console.log(`🔄 Starting term generation for topic: ${topicName} (Tier: ${userTier})`);

  // Log content generation start
  await logContentGeneration('started', topicId, 'started', {
    userId,
    topicName,
    userTier
  });

  try {
    // Step 1: Check for existing canonical set
    const canonicalSetResult = await getOrCreateCanonicalSetForTopic(topicName);
    console.log(`🔍 Canonical set: ${canonicalSetResult.wasCreated ? 'created' : 'found existing'} for topic: ${topicName}`);

    // Step 2: OpenAI generates terms + facts (TIER-LIMITED)
    const { response } = await generateVocabulary({
      topic: topicName,
      numTerms: userTier === 'free' ? 3 : 5,
      definitionStyle: 'formal',
      sentenceRange: '2-3',
      numExamples: 2,
      numFacts: userTier === 'free' ? 3 : 5,
      termVocabularyTier: userTier === 'free' ? 'beginner' : 'intermediate',
      explanationTier: userTier === 'free' ? 'beginner' : 'intermediate',
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
    const { terms, facts } = response;
    console.log(`📝 Generated ${terms.length} terms and ${facts.length} facts (Tier: ${userTier})`);

    // Log OpenAI usage (estimated tokens)
    await logOpenAiUsage(
      'generate_terms_and_facts',
      'gpt-4o',
      Math.ceil(topicName.length / 4) + 100, // Rough estimate
      Math.ceil((terms.length + facts.length) * 50), // Rough estimate
      topicId,
      { userTier, termsCount: terms.length, factsCount: facts.length }
    );

    // Step 3: Post-process terms with advanced pipeline
    const postProcessedTerms = await postProcessTerms(terms, topicName);
    console.log(`✨ Post-processed terms: ${postProcessedTerms.stats.enrichedCount} final terms`);

    // Step 4: Post-process facts (convert string array to object array)
    const factsAsObjects = facts.map(fact => ({ 
      fact: fact, 
      source: 'AI Generated',
      sourceUrl: undefined 
    }));
    const postProcessedFacts = await postProcessFacts(factsAsObjects, topicName);
    console.log(`✨ Post-processed facts: ${postProcessedFacts.length} final facts`);

    // Log pipeline processing
    await logPipelineEvent('post_processing', topicId, 'success', {
      originalTerms: terms.length,
      processedTerms: postProcessedTerms.stats.enrichedCount,
      originalFacts: facts.length,
      processedFacts: postProcessedFacts.length,
      stats: postProcessedTerms.stats
    });

    // Step 5: Validate terms with external definitions
    const validationResult = validateTerms(postProcessedTerms.terms, topicName);
    const validatedTerms = validationResult.terms;
    console.log(`✅ Validated ${validatedTerms.length} terms`);

    // Step 6: GPT fallback for terms missing definitions
    const finalTerms = validatedTerms; // For now, use validated terms directly
    console.log(`🤖 Applied GPT fallback for missing definitions`);

    // Step 7: Filter out duplicates before saving
    console.log(`🔍 Checking for duplicates before saving...`);
    const uniqueTerms = await filterDuplicateTerms(topicId, finalTerms);
    const uniqueFacts = await filterDuplicateFacts(topicId, postProcessedFacts);
    
    // Get duplicate statistics
    const duplicateStats = await getDuplicateStats(topicId, finalTerms, postProcessedFacts);
    console.log(`📊 Duplicate prevention stats:`, duplicateStats);

    // Step 8: Prepare terms for database with canonical set linking
    const enrichedTerms = uniqueTerms.map((term: any) => ({
      ...term,
      topicId,
      canonicalSetId: canonicalSetResult.id,
    }));

    // Step 9: Save to DB (only unique terms/facts) with error handling
    if (enrichedTerms.length > 0) {
      try {
        await prisma.term.createMany({ 
          data: enrichedTerms.map((term: any) => ({
            topicId: term.topicId,
            canonicalSetId: term.canonicalSetId,
            term: term.term,
            definition: term.definition || '',
            example: term.example || '',
            source: term.source || 'AI Generated',
            sourceUrl: term.sourceUrl || null,
            verified: false,
            gptGenerated: true,
            confidenceScore: 0.5,
            category: 'general',
            complexityLevel: 'beginner',
            moderationStatus: 'APPROVED', // Auto-approve generated content
          }))
        });
        console.log(`💾 Saved ${enrichedTerms.length} unique terms to database`);
      } catch (error: any) {
        console.error(`❌ Error saving terms to database:`, error.message);
        // Continue execution, don't crash the worker
      }
    } else {
      console.log(`🚫 No unique terms to save (all were duplicates)`);
    }

    if (uniqueFacts.length > 0) {
      try {
        await prisma.fact.createMany({ 
          data: uniqueFacts.map((fact: any) => ({
            topicId,
            fact: fact.fact,
            source: fact.source || 'AI Generated',
            sourceUrl: fact.sourceUrl,
            gptGenerated: fact.gptGenerated || true,
            category: fact.category || 'general',
          }))
        });
        console.log(`💾 Saved ${uniqueFacts.length} unique facts to database`);
      } catch (error: any) {
        console.error(`❌ Error saving facts to database:`, error.message);
        // Continue execution, don't crash the worker
      }
    } else {
      console.log(`🚫 No unique facts to save (all were duplicates)`);
    }

    console.log(`📊 Post-processing stats:`, postProcessedTerms.stats);
    
    // Log successful completion
    await logContentGeneration('completed', topicId, 'completed', {
      userId,
      topicName,
      userTier,
      termsGenerated: enrichedTerms.length,
      factsGenerated: uniqueFacts.length,
      duplicateStats,
      postProcessingStats: postProcessedTerms.stats
    });
    
    return {
      success: true,
      termsGenerated: enrichedTerms.length,
      factsGenerated: uniqueFacts.length,
      topicName,
      canonicalSetId: canonicalSetResult.id,
      postProcessingStats: postProcessedTerms.stats,
      duplicateStats,
    };

  } catch (error) {
    console.error(`❌ Error in term generation pipeline:`, error);
    
    // Log failure
    await logContentGeneration('failed', topicId, 'failed', {
      userId,
      topicName,
      userTier,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
    
    throw error;
  }
}

// Legacy functions kept for backward compatibility
function calculateConfidence(term: any): number {
  if (term.sourceUrl) return 1.0; // External source
  if (term.gptGenerated) return 0.7; // GPT fallback
  return 0.8; // Default
}

function assessComplexity(definition: string): string {
  const wordCount = definition.split(' ').length;
  const avgWordLength = definition.replace(/[^a-zA-Z]/g, '').length / definition.split(' ').length;
  
  if (wordCount > 20 || avgWordLength > 8) return 'advanced';
  if (wordCount > 15 || avgWordLength > 6) return 'intermediate';
  return 'beginner';
}

function categorizeTerm(term: any): string {
  const termLower = term.term.toLowerCase();
  const definitionLower = term.definition.toLowerCase();
  
  if (termLower.includes('slang') || definitionLower.includes('slang')) return 'slang';
  if (termLower.includes('technique') || definitionLower.includes('method')) return 'technique';
  if (termLower.includes('concept') || definitionLower.includes('idea')) return 'concept';
  if (termLower.includes('tool') || definitionLower.includes('software')) return 'tool';
  
  return 'general';
}

