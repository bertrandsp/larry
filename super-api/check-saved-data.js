const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function checkSavedData() {
  try {
    console.log('🔍 Checking saved data from dual-pipeline generation...\n');

    // Check topics
    const topics = await prisma.topic.findMany({
      where: {
        name: { contains: 'culinary', mode: 'insensitive' }
      },
      include: {
        terms: true,
        facts: true
      }
    });

    console.log(`📚 Found ${topics.length} topics matching "culinary":`);
    topics.forEach(topic => {
      console.log(`  - Topic: ${topic.name} (ID: ${topic.id})`);
      console.log(`    - Terms: ${topic.terms.length}`);
      console.log(`    - Facts: ${topic.facts.length}`);
      
      if (topic.terms.length > 0) {
        console.log(`    - Recent terms:`);
        topic.terms.slice(-3).forEach(term => {
          console.log(`      * ${term.term}: ${term.definition.substring(0, 50)}...`);
        });
      }
      
      if (topic.facts.length > 0) {
        console.log(`    - Recent facts:`);
        topic.facts.slice(-2).forEach(fact => {
          console.log(`      * ${fact.fact.substring(0, 60)}...`);
        });
      }
      console.log('');
    });

    // Check recent terms
    const recentTerms = await prisma.term.findMany({
      where: {
        source: 'OpenAI (Enhanced)'
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: 5,
      include: {
        topic: true
      }
    });

    console.log(`🤖 Recent OpenAI-generated terms (${recentTerms.length}):`);
    recentTerms.forEach(term => {
      console.log(`  - ${term.term} (Topic: ${term.topic.name})`);
      console.log(`    Definition: ${term.definition.substring(0, 80)}...`);
      console.log(`    Source: ${term.source}`);
      console.log(`    Created: ${term.createdAt}`);
      console.log('');
    });

    // Check recent facts
    const recentFacts = await prisma.fact.findMany({
      where: {
        gptGenerated: true
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: 3,
      include: {
        topic: true
      }
    });

    console.log(`📝 Recent AI-generated facts (${recentFacts.length}):`);
    recentFacts.forEach(fact => {
      console.log(`  - Topic: ${fact.topic.name}`);
      console.log(`    Fact: ${fact.fact.substring(0, 80)}...`);
      console.log(`    Source: ${fact.source}`);
      console.log(`    Created: ${fact.createdAt}`);
      console.log('');
    });

  } catch (error) {
    console.error('❌ Error checking saved data:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkSavedData();



