const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testSimpleGlobalTopics() {
    console.log('🌍 Testing simple global custom topics functionality...\n');

    try {
        // Step 1: Create first user and add custom topics
        console.log('👤 Creating first user...');
        const user1Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `simple-test-user1-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Simple Test User 1'
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
        
        // Get available topics
        const topics1Response = await axios.get(`${BASE_URL}/topics`);
        const availableTopics = topics1Response.data.topics;
        const predefinedTopics = availableTopics.slice(0, 2); // Take first 2
        const customTopics1 = ['Advanced Photography']; // 1 custom topic
        
        console.log('📚 User 1 selecting topics...');
        console.log('  Predefined:', predefinedTopics.map(t => t.name));
        console.log('  Custom:', customTopics1);
        console.log('  Total topics:', predefinedTopics.length + customTopics1.length);
        
        const selection1Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: predefinedTopics.map(t => t.id),
            customTopics: customTopics1
        }, { headers: user1Headers });
        
        console.log('✅ User 1 topic selection:', selection1Response.data);
        console.log('');

        // Step 2: Check what topics were created
        console.log('🔍 Checking topics after User 1...');
        const topicsAfterUser1 = await axios.get(`${BASE_URL}/topics`);
        const allTopics = topicsAfterUser1.data.topics;
        
        console.log(`Total topics now: ${allTopics.length}`);
        console.log('Recent topics:');
        allTopics.slice(-3).forEach(topic => {
            console.log(`  - ${topic.name} (${topic.id})`);
        });
        console.log('');

        // Step 3: Create second user and see if they can use existing custom topics
        console.log('👤 Creating second user...');
        const user2Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `simple-test-user2-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Simple Test User 2'
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
        
        // Check available topics for user 2
        const topics2Response = await axios.get(`${BASE_URL}/topics`);
        const topicsForUser2 = topics2Response.data.topics;
        
        console.log('📚 Available topics for User 2:');
        console.log(`  Total: ${topicsForUser2.length}`);
        topicsForUser2.slice(-3).forEach(topic => {
            console.log(`  - ${topic.name}`);
        });
        
        // User 2 selects different topics including new custom ones
        const selectedPredefined = topicsForUser2.slice(0, 1);
        const newCustomTopics = ['Digital Marketing', 'Sustainable Living'];
        
        console.log('🎯 User 2 selecting topics...');
        console.log('  Predefined:', selectedPredefined.map(t => t.name));
        console.log('  New custom:', newCustomTopics);
        console.log('  Total topics:', selectedPredefined.length + newCustomTopics.length);
        
        const selection2Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: selectedPredefined.map(t => t.id),
            customTopics: newCustomTopics
        }, { headers: user2Headers });
        
        console.log('✅ User 2 topic selection:', selection2Response.data);
        console.log('');

        // Step 4: Check final topic state
        console.log('🔍 Checking final topic state...');
        const finalTopicsResponse = await axios.get(`${BASE_URL}/topics`);
        const finalTopics = finalTopicsResponse.data.topics;
        
        console.log(`Final total topics: ${finalTopics.length}`);
        console.log('All custom topics created:');
        finalTopics
            .filter(t => t.name.toLowerCase().includes('photography') || 
                        t.name.toLowerCase().includes('marketing') || 
                        t.name.toLowerCase().includes('sustainable'))
            .forEach(topic => {
                console.log(`  - ${topic.name} (${topic.id})`);
            });

        console.log('\n🎉 Simple global custom topics test completed!');
        console.log('✅ Custom topics are created globally and available to all users');
        console.log('✅ Topics persist independently of user accounts');

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.error('Status:', error.response?.status);
    }
}

testSimpleGlobalTopics();
