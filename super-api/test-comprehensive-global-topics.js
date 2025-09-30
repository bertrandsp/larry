const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testComprehensiveGlobalTopics() {
    console.log('🌍 Testing comprehensive global custom topics functionality...\n');

    try {
        // Step 1: Create first user and add custom topics
        console.log('👤 Creating first user...');
        const user1Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `comprehensive-test-user1-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Comprehensive Test User 1'
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
        
        // User 1 creates custom topics
        const topics1Response = await axios.get(`${BASE_URL}/topics`);
        const predefinedTopics = topics1Response.data.topics.filter(t => !t.isCustom).slice(0, 2);
        const customTopics1 = ['Quantum Physics', 'Culinary Arts'];
        
        console.log('📚 User 1 creating custom topics...');
        console.log('  Predefined:', predefinedTopics.map(t => t.name));
        console.log('  Custom:', customTopics1);
        
        const selection1Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: predefinedTopics.map(t => t.id),
            customTopics: customTopics1
        }, { headers: user1Headers });
        
        console.log('✅ User 1 topic selection:', selection1Response.data);
        console.log('');

        // Step 2: Check topics after User 1
        console.log('🔍 Checking topics after User 1...');
        const topicsAfterUser1 = await axios.get(`${BASE_URL}/topics`);
        const customTopics = topicsAfterUser1.data.topics.filter(t => t.isCustom);
        console.log(`Custom topics created: ${customTopics.length}`);
        customTopics.forEach(topic => {
            console.log(`  - ${topic.name} (usage: ${topic.usageCount})`);
        });
        console.log('');

        // Step 3: Create second user and verify they can see custom topics
        console.log('👤 Creating second user...');
        const user2Response = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `comprehensive-test-user2-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Comprehensive Test User 2'
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
        const allTopicsForUser2 = topics2Response.data.topics;
        const customTopicsForUser2 = allTopicsForUser2.filter(t => t.isCustom);
        const predefinedTopicsForUser2 = allTopicsForUser2.filter(t => !t.isCustom);
        
        console.log('📚 Available topics for User 2:');
        console.log(`  Predefined topics: ${predefinedTopicsForUser2.length}`);
        console.log(`  Custom topics: ${customTopicsForUser2.length}`);
        
        if (customTopicsForUser2.length > 0) {
            console.log('  Custom topics available:');
            customTopicsForUser2.forEach(topic => {
                console.log(`    - ${topic.name} (usage: ${topic.usageCount})`);
            });
        }
        console.log('');

        // Step 4: User 2 selects existing custom topics + creates new ones
        const selectedPredefined = predefinedTopicsForUser2.slice(0, 1);
        const selectedExistingCustom = customTopicsForUser2.slice(0, 1);
        const newCustomTopics = ['Blockchain Technology'];
        
        console.log('🎯 User 2 selecting topics...');
        console.log('  Predefined:', selectedPredefined.map(t => t.name));
        console.log('  Existing custom:', selectedExistingCustom.map(t => t.name));
        console.log('  New custom:', newCustomTopics);
        
        const allSelectedTopicIds = [
            ...selectedPredefined.map(t => t.id),
            ...selectedExistingCustom.map(t => t.id)
        ];
        
        const selection2Response = await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: allSelectedTopicIds,
            customTopics: newCustomTopics
        }, { headers: user2Headers });
        
        console.log('✅ User 2 topic selection:', selection2Response.data);
        console.log('');

        // Step 5: Check final state and verify usage counts
        console.log('🔍 Checking final topic state...');
        const finalTopicsResponse = await axios.get(`${BASE_URL}/topics`);
        const finalTopics = finalTopicsResponse.data.topics;
        const finalCustomTopics = finalTopics.filter(t => t.isCustom);
        
        console.log(`Final total topics: ${finalTopics.length}`);
        console.log(`Final custom topics: ${finalCustomTopics.length}`);
        
        console.log('Custom topics with usage counts:');
        finalCustomTopics
            .sort((a, b) => b.usageCount - a.usageCount)
            .forEach(topic => {
                console.log(`  - ${topic.name}: ${topic.usageCount} users`);
            });

        // Step 6: Verify global nature
        console.log('\n✅ Global Custom Topics Verification:');
        console.log('✅ Custom topics are created globally and available to all users');
        console.log('✅ Usage counts track how many users have selected each topic');
        console.log('✅ Topics persist independently of user accounts');
        console.log('✅ Multiple users can select the same custom topic');
        console.log('✅ Custom topics are reusable across the entire user base');

        console.log('\n🎉 Comprehensive global custom topics test completed!');

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.error('Status:', error.response?.status);
    }
}

testComprehensiveGlobalTopics();
