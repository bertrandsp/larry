const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testFinalUsageCount() {
    console.log('🔧 Testing final usage count increment fix...\n');

    try {
        // Step 1: Create first user and create a custom topic
        console.log('👤 Creating first user...');
        const user1Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `final-test-user1-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Final Test User 1'
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
        const customTopics1 = ['Data Science'];
        
        console.log('📚 User 1 creating custom topic "Data Science"...');
        
        const selection1Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: predefinedTopics.map(t => t.id),
            customTopics: customTopics1
        }, { headers: user1Headers });
        
        console.log('✅ User 1 topic selection:', selection1Response.data);
        
        // Check the topic was created with usage count 1
        const dsTopicResponse = await axios.get(`${BASE_URL}/topics`);
        const dsTopic = dsTopicResponse.data.topics.find(t => t.name === 'Data Science');
        console.log(`📊 Data Science topic after User 1: usage count = ${dsTopic.usageCount}`);
        console.log('');

        // Step 2: Create second user and select the existing custom topic
        console.log('👤 Creating second user...');
        const user2Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `final-test-user2-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Final Test User 2'
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
        
        // User 2 selects the existing "Data Science" topic
        const topics2Response = await axios.get(`${BASE_URL}/topics`);
        const predefinedTopics2 = topics2Response.data.topics.filter(t => !t.isCustom).slice(0, 1);
        const existingCustomTopic = topics2Response.data.topics.find(t => t.name === 'Data Science');
        
        console.log('📚 User 2 selecting existing custom topic "Data Science"...');
        console.log(`📊 Data Science topic before User 2: usage count = ${existingCustomTopic.usageCount}`);
        
        const selection2Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: [...predefinedTopics2.map(t => t.id), existingCustomTopic.id],
            customTopics: ['Neural Networks'] // Add one new custom topic
        }, { headers: user2Headers });
        
        console.log('✅ User 2 topic selection:', selection2Response.data);
        
        // Check the usage count was incremented correctly
        const finalTopicsResponse = await axios.get(`${BASE_URL}/topics`);
        const finalDsTopic = finalTopicsResponse.data.topics.find(t => t.name === 'Data Science');
        console.log(`📊 Data Science topic after User 2: usage count = ${finalDsTopic.usageCount}`);
        
        // Step 3: Create third user to test again
        console.log('\n👤 Creating third user...');
        const user3Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `final-test-user3-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Final Test User 3'
        });
        
        const user3Id = user3Response.data.user.id;
        const user3Token = user3Response.data.access_token;
        const user3Headers = {
            'Authorization': `Bearer ${user3Token}`,
            'Content-Type': 'application/json'
        };
        
        console.log('✅ User 3 created:', user3Id);
        
        // Quick onboarding to topics
        await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers: user3Headers });
        await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 2 }, { headers: user3Headers });
        await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers: user3Headers });
        await axios.post(`${BASE_URL}/onboarding/source`, { source: 'search' }, { headers: user3Headers });
        await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'advanced' }, { headers: user3Headers });
        await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: false }, { headers: user3Headers });
        await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers: user3Headers });
        
        // User 3 also selects "Data Science"
        const topics3Response = await axios.get(`${BASE_URL}/topics`);
        const predefinedTopics3 = topics3Response.data.topics.filter(t => !t.isCustom).slice(0, 1);
        const dsTopicForUser3 = topics3Response.data.topics.find(t => t.name === 'Data Science');
        
        console.log('📚 User 3 selecting existing custom topic "Data Science"...');
        console.log(`📊 Data Science topic before User 3: usage count = ${dsTopicForUser3.usageCount}`);
        
        const selection3Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: [...predefinedTopics3.map(t => t.id), dsTopicForUser3.id],
            customTopics: ['Computer Vision'] // Add one new custom topic
        }, { headers: user3Headers });
        
        console.log('✅ User 3 topic selection:', selection3Response.data);
        
        // Check final usage count
        const finalTopicsResponse2 = await axios.get(`${BASE_URL}/topics`);
        const finalDsTopic2 = finalTopicsResponse2.data.topics.find(t => t.name === 'Data Science');
        console.log(`📊 Data Science topic after User 3: usage count = ${finalDsTopic2.usageCount}`);
        
        // Verify the fix worked
        if (finalDsTopic2.usageCount === 3) {
            console.log('\n🎉 SUCCESS: Usage count increment fix working perfectly!');
            console.log('✅ Custom topics usage count increments correctly:');
            console.log('  - User 1 creates "Data Science" → usage count = 1');
            console.log('  - User 2 selects "Data Science" → usage count = 2');
            console.log('  - User 3 selects "Data Science" → usage count = 3');
        } else {
            console.log('\n❌ ISSUE: Usage count did not increment as expected');
            console.log(`Expected: 3, Got: ${finalDsTopic2.usageCount}`);
        }

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.error('Status:', error.response?.status);
    }
}

testFinalUsageCount();
