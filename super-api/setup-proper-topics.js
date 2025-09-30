const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

// Define proper predefined topics that should exist in the database
const PROPER_TOPICS = [
    { name: 'Technology & Programming', category: 'technology' },
    { name: 'Business & Finance', category: 'business' },
    { name: 'Health & Wellness', category: 'health' },
    { name: 'Science & Research', category: 'science' },
    { name: 'Arts & Culture', category: 'arts' },
    { name: 'Travel & Tourism', category: 'travel' },
    { name: 'Sports & Fitness', category: 'sports' },
    { name: 'Education & Learning', category: 'education' },
    { name: 'Food & Cooking', category: 'food' },
    { name: 'Photography & Media', category: 'media' },
    { name: 'Music & Entertainment', category: 'entertainment' },
    { name: 'Environment & Nature', category: 'environment' }
];

async function setupProperTopics() {
    console.log('🧹 Setting up proper predefined topics...\n');

    try {
        // First, get current topics to see what needs to be cleaned up
        console.log('📋 Current topics in database:');
        const currentTopicsResponse = await axios.get(`${BASE_URL}/topics`);
        const currentTopics = currentTopicsResponse.data.topics;
        
        console.log(`Found ${currentTopics.length} topics:`);
        currentTopics.forEach((topic, index) => {
            console.log(`${index + 1}. ${topic.name} (${topic.id})`);
        });
        console.log('');

        // Identify topics that should be kept (good ones)
        const goodTopics = currentTopics.filter(topic => 
            !topic.name.startsWith('custom-') && 
            !topic.name.startsWith('preview-topic-') &&
            !topic.name.includes('-') // Avoid UUID-like names
        );

        console.log(`✅ Good topics to keep: ${goodTopics.length}`);
        goodTopics.forEach(topic => console.log(`  - ${topic.name}`));
        console.log('');

        // Create SQL to clean up bad topics and add proper ones
        const topicsToKeep = goodTopics.map(t => t.name.toLowerCase());
        const newTopics = PROPER_TOPICS.filter(topic => 
            !topicsToKeep.includes(topic.name.toLowerCase())
        );

        console.log(`🆕 New topics to add: ${newTopics.length}`);
        newTopics.forEach(topic => console.log(`  - ${topic.name} (${topic.category})`));
        console.log('');

        // Generate SQL script for Supabase
        console.log('📝 SQL Script for Supabase SQL Editor:');
        console.log('```sql');
        console.log('-- Clean up bad topics');
        console.log('DELETE FROM "Topic" WHERE name LIKE \'custom-%\';');
        console.log('DELETE FROM "Topic" WHERE name LIKE \'preview-topic-%\';');
        console.log('DELETE FROM "Topic" WHERE name ~ \'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$\';');
        console.log('');
        console.log('-- Add proper predefined topics');
        
        newTopics.forEach((topic, index) => {
            const topicId = `topic-${topic.category}-${Date.now()}-${index}`;
            console.log(`INSERT INTO "Topic" (id, name) VALUES ('${topicId}', '${topic.name}');`);
        });
        
        console.log('```');
        console.log('');

        // Also create a test to verify the topics work
        console.log('🧪 Testing topic selection with proper topics...');
        
        // Create a test user
        const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `topic-test-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Topic Test User'
        });
        
        const userId = signupResponse.data.user.id;
        const accessToken = signupResponse.data.access_token;
        const headers = {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
        };
        
        console.log('✅ Test user created:', userId);
        
        // Quick onboarding to topics step
        await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
        await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 3 }, { headers });
        await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
        await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers });
        await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'beginner' }, { headers });
        await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers });
        await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
        
        // Get current topics and test selection
        const topicsResponse = await axios.get(`${BASE_URL}/topics`);
        const availableTopics = topicsResponse.data.topics;
        
        console.log('📚 Available topics for selection:');
        availableTopics.forEach((topic, index) => {
            console.log(`${index + 1}. ${topic.name} (${topic.id})`);
        });
        
        // Select first 3 topics
        const selectedTopics = availableTopics.slice(0, 3).map(t => t.id);
        console.log('\n🎯 Selected topics:', selectedTopics);
        
        // Test topic selection
        const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: selectedTopics,
            customTopics: ['Custom Photography', 'Advanced Cooking']
        }, { headers });
        
        console.log('✅ Topic selection result:', topicsSelectionResponse.data);
        
        console.log('\n🎉 Topic setup completed!');
        console.log('');
        console.log('📋 Next steps:');
        console.log('1. Run the SQL script in Supabase SQL Editor');
        console.log('2. Test the iOS app to see clean topic names');
        console.log('3. Verify custom topics work correctly');

    } catch (error) {
        console.error('❌ Setup failed:', error.response?.data || error.message);
    }
}

setupProperTopics();
