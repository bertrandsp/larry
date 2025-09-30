const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testUsageCountFix() {
    console.log('🔧 Testing usage count increment fix...\n');

    try {
        // Step 1: Create first user and create a custom topic
        console.log('👤 Creating first user...');
        const user1Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `usage-test-user1-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Usage Test User 1'
        });
        
        const user1Id = user1Response.data.user.id;
        const user1Token = user1Response.data.access_token;
        const user1Headers = {
            'Authorization': `Bearer ${user1Token}`,
            'Content-Type': 'application/json'
        };
        
        console.log('✅ User 1 created:', user1Id);
        
        // Quick onboarding to topics
        await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers: user1Headers });
        await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 3 }, { headers: user1Headers });
        await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers: user1Headers });
        await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers: user1Headers });
        await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'beginner' }, { headers: user1Headers });
        await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers: user1Headers });
        await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers: user1Headers });
        
        // User 1 creates a custom topic
        const topics1Response = await axios.get(`${BASE_URL}/topics`);
        const predefinedTopics = topics1Response.data.topics.filter(t => !t.isCustom).slice(0, 2);
        const customTopics1 = ['Machine Learning'];
        
        console.log('📚 User 1 creating custom topic "Machine Learning"...');
        
        const selection1Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: predefinedTopics.map(t => t.id),
            customTopics: customTopics1
        }, { headers: user1Headers });
        
        console.log('✅ User 1 topic selection:', selection1Response.data);
        
        // Check the topic was created with usage count 1
        const mlTopicResponse = await axios.get(`${BASE_URL}/topics`);
        const mlTopic = mlTopicResponse.data.topics.find(t => t.name === 'Machine Learning');
        console.log(`📊 Machine Learning topic after User 1: usage count = ${mlTopic.usageCount}`);
        console.log('');

        // Step 2: Create second user and select the existing custom topic
        console.log('👤 Creating second user...');
        const user2Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `usage-test-user2-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Usage Test User 2'
        });
        
        const user2Id = user2Response.data.user.id;
        const user2Token = user2Response.data.access_token;
        const user2Headers = {
            'Authorization': `Bearer ${user2Token}`,
            'Content-Type': 'application/json'
        };
        
        console.log('✅ User 2 created:', user2Id);
        
        // Quick onboarding to topics
        await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers: user2Headers });
        await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 2 }, { headers: user2Headers });
        await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers: user2Headers });
        await axios.post(`${BASE_URL}/onboarding/source`, { source: 'search' }, { headers: user2Headers });
        await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'intermediate' }, { headers: user2Headers });
        await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: true }, { headers: user2Headers });
        await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers: user2Headers });
        
        // User 2 selects the existing "Machine Learning" topic
        const topics2Response = await axios.get(`${BASE_URL}/topics`);
        const predefinedTopics2 = topics2Response.data.topics.filter(t => !t.isCustom).slice(0, 1);
        const existingCustomTopic = topics2Response.data.topics.find(t => t.name === 'Machine Learning');
        
        console.log('📚 User 2 selecting existing custom topic "Machine Learning"...');
        console.log(`📊 Machine Learning topic before User 2: usage count = ${existingCustomTopic.usageCount}`);
        
        const selection2Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: [...predefinedTopics2.map(t => t.id), existingCustomTopic.id],
            customTopics: ['Artificial Intelligence'] // Add one new custom topic
        }, { headers: user2Headers });
        
        console.log('✅ User 2 topic selection:', selection2Response.data);
        
        // Check the usage count was incremented
        const finalTopicsResponse = await axios.get(`${BASE_URL}/topics`);
        const finalMlTopic = finalTopicsResponse.data.topics.find(t => t.name === 'Machine Learning');
        console.log(`📊 Machine Learning topic after User 2: usage count = ${finalMlTopic.usageCount}`);
        
        // Verify the fix worked
        if (finalMlTopic.usageCount === 2) {
            console.log('\n🎉 SUCCESS: Usage count increment fix working correctly!');
            console.log('✅ Existing custom topics now properly increment usage count when selected by new users');
        } else {
            console.log('\n❌ ISSUE: Usage count did not increment as expected');
            console.log(`Expected: 2, Got: ${finalMlTopic.usageCount}`);
        }

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.error('Status:', error.response?.status);
    }
}

testUsageCountFix();
