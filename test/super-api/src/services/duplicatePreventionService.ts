import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface DuplicateCheckResult {
  isDuplicate: boolean;
  existingTerm?: any;
  existingFact?: any;
}

/**
 * Check if a term already exists for a given topic
 */
export async function checkTermDuplicate(
  topicId: string, 
  term: string
): Promise<DuplicateCheckResult> {
  try {
    const existingTerm = await prisma.term.findFirst({
      where: {
        topicId,
        term: {
          equals: term,
          mode: 'insensitive' // Case-insensitive comparison
        }
      }
    });

    return {
      isDuplicate: !!existingTerm,
      existingTerm
    };
  } catch (error) {
    console.error('Error checking term duplicate:', error);
    return { isDuplicate: false };
  }
}

/**
 * Check if a fact already exists for a given topic
 */
export async function checkFactDuplicate(
  topicId: string, 
  fact: string
): Promise<DuplicateCheckResult> {
  try {
    const existingFact = await prisma.fact.findFirst({
      where: {
        topicId,
        fact: {
          equals: fact,
          mode: 'insensitive' // Case-insensitive comparison
        }
      }
    });

    return {
      isDuplicate: !!existingFact,
      existingFact
    };
  } catch (error) {
    console.error('Error checking fact duplicate:', error);
    return { isDuplicate: false };
  }
}

/**
 * Filter out duplicate terms from a list
 */
export async function filterDuplicateTerms(
  topicId: string, 
  terms: Array<{ term: string; [key: string]: any }>
): Promise<Array<{ term: string; [key: string]: any }>> {
  const filteredTerms: Array<{ term: string; [key: string]: any }> = [];
  
  for (const term of terms) {
    const duplicateCheck = await checkTermDuplicate(topicId, term.term);
    if (!duplicateCheck.isDuplicate) {
      filteredTerms.push(term);
    } else {
      console.log(`🚫 Skipping duplicate term: "${term.term}" for topic ${topicId}`);
    }
  }
  
  return filteredTerms;
}

/**
 * Filter out duplicate facts from a list
 */
export async function filterDuplicateFacts(
  topicId: string, 
  facts: Array<{ fact: string; [key: string]: any }>
): Promise<Array<{ fact: string; [key: string]: any }>> {
  const filteredFacts: Array<{ fact: string; [key: string]: any }> = [];
  
  for (const fact of facts) {
    const duplicateCheck = await checkFactDuplicate(topicId, fact.fact);
    if (!duplicateCheck.isDuplicate) {
      filteredFacts.push(fact);
    } else {
      console.log(`🚫 Skipping duplicate fact: "${fact.fact}" for topic ${topicId}`);
    }
  }
  
  return filteredFacts;
}

/**
 * Get statistics about duplicates found
 */
export async function getDuplicateStats(
  topicId: string,
  terms: Array<{ term: string; [key: string]: any }>,
  facts: Array<{ fact: string; [key: string]: any }>
): Promise<{
  totalTerms: number;
  totalFacts: number;
  duplicateTerms: number;
  duplicateFacts: number;
  uniqueTerms: number;
  uniqueFacts: number;
}> {
  const filteredTerms = await filterDuplicateTerms(topicId, terms);
  const filteredFacts = await filterDuplicateFacts(topicId, facts);
  
  return {
    totalTerms: terms.length,
    totalFacts: facts.length,
    duplicateTerms: terms.length - filteredTerms.length,
    duplicateFacts: facts.length - filteredFacts.length,
    uniqueTerms: filteredTerms.length,
    uniqueFacts: filteredFacts.length
  };
}