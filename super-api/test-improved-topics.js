const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testImprovedTopics() {
    console.log('🧪 Testing improved topic system...\n');

    try {
        // Step 1: Check current topics after cleanup
        console.log('📚 Checking current topics...');
        const topicsResponse = await axios.get(`${BASE_URL}/topics`);
        const topics = topicsResponse.data.topics;
        
        console.log(`Found ${topics.length} topics:`);
        topics.forEach((topic, index) => {
            const isGoodTopic = !topic.name.includes('-') && !topic.name.includes('custom') && !topic.name.includes('preview');
            console.log(`${index + 1}. ${topic.name} (${topic.id}) ${isGoodTopic ? '✅' : '❌'}`);
        });
        console.log('');

        // Step 2: Create a test user and go through onboarding
        console.log('👤 Creating test user...');
        const signupResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `improved-topics-test-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Improved Topics Test User'
        });
        
        const userId = signupResponse.data.user.id;
        const accessToken = signupResponse.data.access_token;
        const headers = {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
        };
        
        console.log('✅ User created:', userId);
        console.log('');

        // Step 3: Quick onboarding to topics step
        console.log('🔄 Completing onboarding steps...');
        await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
        await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 3 }, { headers });
        await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
        await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers });
        await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'beginner' }, { headers });
        await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers });
        await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
        console.log('✅ All onboarding steps completed');
        console.log('');

        // Step 4: Test topic selection with proper topics
        console.log('🎯 Testing topic selection...');
        
        // Get good topics (filter out any remaining bad ones)
        const goodTopics = topics.filter(topic => 
            !topic.name.includes('-') && 
            !topic.name.includes('custom') && 
            !topic.name.includes('preview')
        );
        
        if (goodTopics.length < 3) {
            console.log('⚠️  Not enough good topics available. Need to run the cleanup SQL first.');
            console.log('📝 Run this SQL in Supabase SQL Editor:');
            console.log('```sql');
            console.log('-- Clean up bad topics');
            console.log('DELETE FROM "Topic" WHERE name LIKE \'custom-%\';');
            console.log('DELETE FROM "Topic" WHERE name LIKE \'preview-topic-%\';');
            console.log('');
            console.log('-- Add proper topics');
            console.log('INSERT INTO "Topic" (id, name) VALUES ');
            console.log('    (\'topic-technology-programming\', \'Technology & Programming\'),');
            console.log('    (\'topic-business-finance\', \'Business & Finance\'),');
            console.log('    (\'topic-health-wellness\', \'Health & Wellness\'),');
            console.log('    (\'topic-science-research\', \'Science & Research\'),');
            console.log('    (\'topic-arts-culture\', \'Arts & Culture\'),');
            console.log('    (\'topic-travel-tourism\', \'Travel & Tourism\'),');
            console.log('    (\'topic-sports-fitness\', \'Sports & Fitness\'),');
            console.log('    (\'topic-education-learning\', \'Education & Learning\'),');
            console.log('    (\'topic-food-cooking\', \'Food & Cooking\'),');
            console.log('    (\'topic-photography-media\', \'Photography & Media\');');
            console.log('```');
            return;
        }

        const selectedTopics = goodTopics.slice(0, 3).map(t => t.id);
        console.log('Selected topics:', selectedTopics.map(id => {
            const topic = goodTopics.find(t => t.id === id);
            return `${topic.name} (${id})`;
        }));
        
        // Test with custom topics
        const customTopics = ['Advanced Photography', 'Gourmet Cooking'];
        console.log('Custom topics:', customTopics);
        console.log('');

        const topicsSelectionResponse = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: selectedTopics,
            customTopics: customTopics
        }, { headers });
        
        console.log('✅ Topic selection result:', topicsSelectionResponse.data);
        console.log('');

        // Step 5: Complete onboarding
        console.log('🏁 Completing onboarding...');
        const completeResponse = await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
        console.log('✅ Onboarding completed successfully!');
        console.log('');

        // Step 6: Check what topics were actually created
        console.log('🔍 Checking created topics...');
        const finalTopicsResponse = await axios.get(`${BASE_URL}/topics`);
        const finalTopics = finalTopicsResponse.data.topics;
        
        console.log(`Final topic count: ${finalTopics.length}`);
        console.log('Recent topics:');
        finalTopics.slice(-5).forEach(topic => {
            console.log(`  - ${topic.name} (${topic.id})`);
        });

        console.log('\n🎉 Improved topic system test completed!');

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.error('Status:', error.response?.status);
    }
}

testImprovedTopics();
