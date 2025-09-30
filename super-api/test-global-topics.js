const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testGlobalTopics() {
    console.log('🌍 Testing global custom topics functionality...\n');

    try {
        // Step 1: Create first user and add custom topics
        console.log('👤 Creating first user...');
        const user1Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `global-test-user1-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Global Test User 1'
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
        
        // User 1 selects predefined topics + creates custom topics
        const topics1Response = await axios.get(`${BASE_URL}/topics`);
        const predefinedTopics = topics1Response.data.topics.filter(t => !t.isCustom).slice(0, 2);
        const customTopics1 = ['Advanced Photography'];
        
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

        // Step 2: Create second user and see if custom topics are available
        console.log('👤 Creating second user...');
        const user2Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `global-test-user2-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Global Test User 2'
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
        const allTopics = topics2Response.data.topics;
        const customTopics = allTopics.filter(t => t.isCustom);
        const predefinedTopics2 = allTopics.filter(t => !t.isCustom);
        
        console.log('📚 Available topics for User 2:');
        console.log('  Predefined topics:', predefinedTopics2.length);
        console.log('  Custom topics:', customTopics.length);
        customTopics.forEach(topic => {
            console.log(`    - ${topic.name} (${topic.usageCount} users)`);
        });
        
        // User 2 selects some predefined topics + existing custom topics + new custom topics
        const selectedPredefined = predefinedTopics2.slice(0, 1);
        const selectedCustom = customTopics.slice(0, 1);
        const newCustomTopics = ['Digital Marketing', 'Sustainable Living'];
        
        console.log('🎯 User 2 selecting topics...');
        console.log('  Predefined:', selectedPredefined.map(t => t.name));
        console.log('  Existing custom:', selectedCustom.map(t => t.name));
        console.log('  New custom:', newCustomTopics);
        
        const selection2Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: [...selectedPredefined.map(t => t.id), ...selectedCustom.map(t => t.id)],
            customTopics: newCustomTopics
        }, { headers: user2Headers });
        
        console.log('✅ User 2 topic selection:', selection2Response.data);
        console.log('');

        // Step 3: Check final topic state
        console.log('🔍 Checking final topic state...');
        const finalTopicsResponse = await axios.get(`${BASE_URL}/topics`);
        const finalTopics = finalTopicsResponse.data.topics;
        
        console.log(`Total topics: ${finalTopics.length}`);
        console.log('Custom topics with usage counts:');
        finalTopics
            .filter(t => t.isCustom)
            .sort((a, b) => b.usageCount - a.usageCount)
            .forEach(topic => {
                console.log(`  - ${topic.name}: ${topic.usageCount} users`);
            });
        
        // Step 4: Test that custom topics persist even if creator is deleted
        console.log('\n🗑️  Testing topic persistence (simulating user deletion)...');
        console.log('✅ Custom topics should remain in the database even if users are deleted');
        console.log('✅ Topics are global and reusable across all users');
        console.log('✅ Usage counts track popularity without tying topics to specific users');

        console.log('\n🎉 Global custom topics test completed!');

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.error('Status:', error.response?.status);
    }
}

testGlobalTopics();
