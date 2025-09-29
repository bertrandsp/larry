const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function createSampleTerms() {
  console.log('📝 Creating sample terms for testing...\n');

  try {
    // Get all topics first
    const topicsResponse = await axios.get(`${BASE_URL}/topics`);
    const topics = topicsResponse.data.topics;
    
    console.log(`Found ${topics.length} topics. Creating sample terms...`);

    // Create sample terms for each topic
    for (const topic of topics.slice(0, 3)) { // Only create for first 3 topics
      console.log(`\n📚 Creating terms for topic: ${topic.name}`);
      
      // Create 2-3 sample terms per topic
      const sampleTerms = [
        {
          term: `Sample Term 1 for ${topic.name}`,
          definition: `This is a sample definition for the first term in ${topic.name}`,
          example: `Here's an example of how to use this term in ${topic.name}`,
          source: 'Sample Data',
          sourceUrl: null,
          verified: true,
          gptGenerated: false,
          confidenceScore: 0.95,
          category: 'Vocabulary',
          complexityLevel: 'Intermediate',
          moderationStatus: 'approved'
        },
        {
          term: `Sample Term 2 for ${topic.name}`,
          definition: `This is a sample definition for the second term in ${topic.name}`,
          example: `Here's an example of how to use this term in ${topic.name}`,
          source: 'Sample Data',
          sourceUrl: null,
          verified: true,
          gptGenerated: false,
          confidenceScore: 0.90,
          category: 'Vocabulary',
          complexityLevel: 'Beginner',
          moderationStatus: 'approved'
        }
      ];

      // Note: We can't directly insert into the database via API
      // This is just to show what terms we would create
      console.log(`Would create ${sampleTerms.length} terms for ${topic.name}:`);
      sampleTerms.forEach((term, index) => {
        console.log(`  ${index + 1}. ${term.term} (${term.complexityLevel})`);
      });
    }

    console.log('\n⚠️  Note: Terms need to be created directly in the Supabase database');
    console.log('   You can run this SQL in the Supabase SQL Editor:');
    console.log(`
-- Create sample terms for testing
INSERT INTO "Term" (id, "topicId", term, definition, example, source, verified, "gptGenerated", "confidenceScore", category, "complexityLevel", "moderationStatus") VALUES
('term-1', '${topics[0]?.id}', 'Sample Term 1', 'This is a sample definition', 'Here is an example', 'Sample Data', true, false, 0.95, 'Vocabulary', 'Intermediate', 'approved'),
('term-2', '${topics[0]?.id}', 'Sample Term 2', 'This is another definition', 'Another example here', 'Sample Data', true, false, 0.90, 'Vocabulary', 'Beginner', 'approved'),
('term-3', '${topics[1]?.id}', 'Sample Term 3', 'Third sample definition', 'Third example', 'Sample Data', true, false, 0.85, 'Vocabulary', 'Advanced', 'approved');
    `);

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

createSampleTerms();
