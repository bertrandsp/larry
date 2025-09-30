const axios = require('axios');

const BASE_URL = 'http://localhost:4001';

async function testUserDashboard() {
    console.log('📊 Testing comprehensive user dashboard functionality...\n');

    try {
        // Step 1: Create a test user and complete onboarding
        console.log('👤 Creating test user...');
        const userResponse = await axios.post(`${BASE_URL}/auth-direct/signup`, {
            email: `dashboard-test-${Date.now()}@example.com`,
            password: 'test123',
            name: 'Dashboard Test User'
        });
        
        const userId = userResponse.data.user.id;
        const accessToken = userResponse.data.access_token;
        const headers = {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
        };
        
        console.log('✅ User created:', userId);
        
        // Quick onboarding to topics
        console.log('🔄 Completing onboarding...');
        await axios.post(`${BASE_URL}/onboarding/welcome`, {}, { headers });
        await axios.post(`${BASE_URL}/onboarding/daily-goal`, { goal: 5 }, { headers });
        await axios.post(`${BASE_URL}/onboarding/week-preview`, {}, { headers });
        await axios.post(`${BASE_URL}/onboarding/source`, { source: 'friend' }, { headers });
        await axios.post(`${BASE_URL}/onboarding/skill-level`, { level: 'intermediate' }, { headers });
        await axios.post(`${BASE_URL}/onboarding/widget-preference`, { enabled: true }, { headers });
        await axios.post(`${BASE_URL}/onboarding/motivation`, {}, { headers });
        
        // Select topics including custom ones
        const topicsResponse = await axios.get(`${BASE_URL}/topics`);
        const predefinedTopics = topicsResponse.data.topics.filter(t => !t.isCustom).slice(0, 2);
        const customTopics = ['Dashboard Testing', 'User Analytics'];
        
        await axios.post(`${BASE_URL}/onboarding/topics`, {
            topicIds: predefinedTopics.map(t => t.id),
            customTopics: customTopics
        }, { headers });
        
        await axios.post(`${BASE_URL}/onboarding/complete`, {}, { headers });
        console.log('✅ Onboarding completed');
        console.log('');

        // Step 2: Get comprehensive user dashboard
        console.log('📊 Fetching user dashboard...');
        const dashboardResponse = await axios.get(`${BASE_URL}/user/dashboard`, { headers });
        const dashboard = dashboardResponse.data.dashboard;
        
        console.log('✅ Dashboard data received:');
        console.log(`👤 User: ${dashboard.user.name} (${dashboard.user.email})`);
        console.log(`📚 Subscribed Topics: ${dashboard.subscribedTopics.length}`);
        dashboard.subscribedTopics.forEach(topic => {
            console.log(`  - ${topic.name} (weight: ${topic.weight}%, custom: ${topic.isCustom})`);
        });
        
        console.log(`📖 Wordbank: ${dashboard.wordbank.total} words`);
        console.log(`  - Learning: ${dashboard.wordbank.learning}`);
        console.log(`  - Reviewing: ${dashboard.wordbank.reviewing}`);
        console.log(`  - Mastered: ${dashboard.wordbank.mastered}`);
        console.log(`  - Archived: ${dashboard.wordbank.archived}`);
        
        console.log(`📬 Delivery History: ${dashboard.deliveryHistory.total} deliveries`);
        console.log(`  - Opened: ${dashboard.deliveryHistory.opened}`);
        console.log(`  - Favorited: ${dashboard.deliveryHistory.favorited}`);
        console.log(`  - Learn Again: ${dashboard.deliveryHistory.learnAgain}`);
        console.log(`  - Mastered: ${dashboard.deliveryHistory.mastered}`);
        
        console.log(`📈 Statistics:`);
        console.log(`  - Total Words Learned: ${dashboard.statistics.totalWordsLearned}`);
        console.log(`  - Average Review Count: ${dashboard.statistics.averageReviewCount}`);
        console.log(`  - Completion Rate: ${dashboard.statistics.completionRate}%`);
        console.log('');

        // Step 3: Test topic management
        console.log('🎯 Testing topic management...');
        
        // Update topic weight
        if (dashboard.subscribedTopics.length > 0) {
            const topicToUpdate = dashboard.subscribedTopics[0];
            console.log(`📊 Updating weight for "${topicToUpdate.name}" from ${topicToUpdate.weight}% to 80%...`);
            
            const updateWeightResponse = await axios.put(`${BASE_URL}/user/topics/${topicToUpdate.id}/weight`, {
                weight: 80
            }, { headers });
            
            console.log('✅ Weight updated:', updateWeightResponse.data.message);
        }
        
        // Unsubscribe from a topic (if we have multiple topics)
        if (dashboard.subscribedTopics.length > 1) {
            const topicToUnsubscribe = dashboard.subscribedTopics[1];
            console.log(`🚫 Unsubscribing from "${topicToUnsubscribe.name}"...`);
            
            const unsubscribeResponse = await axios.delete(`${BASE_URL}/user/topics/${topicToUnsubscribe.id}`, { headers });
            
            console.log('✅ Unsubscribed:', unsubscribeResponse.data.message);
        }
        console.log('');

        // Step 4: Test wordbank management
        console.log('📖 Testing wordbank management...');
        
        // Get current wordbank
        const wordbankResponse = await axios.get(`${BASE_URL}/user/wordbank`, { headers });
        const wordbank = wordbankResponse.data.wordbank;
        
        if (wordbank.length > 0) {
            const wordToUpdate = wordbank[0];
            console.log(`📝 Updating word status: "${wordToUpdate.term?.term || 'word'}" → MASTERED`);
            
            const updateStatusResponse = await axios.put(`${BASE_URL}/user/wordbank/${wordToUpdate.id}/status`, {
                status: 'MASTERED'
            }, { headers });
            
            console.log('✅ Status updated:', updateStatusResponse.data.message);
            
            // Remove a word from wordbank (if we have multiple words)
            if (wordbank.length > 1) {
                const wordToRemove = wordbank[1];
                console.log(`🗑️  Removing "${wordToRemove.term?.term || 'word'}" from wordbank...`);
                
                const removeResponse = await axios.delete(`${BASE_URL}/user/wordbank/${wordToRemove.id}`, { headers });
                
                console.log('✅ Word removed:', removeResponse.data.message);
            }
        }
        console.log('');

        // Step 5: Get updated dashboard
        console.log('📊 Fetching updated dashboard...');
        const updatedDashboardResponse = await axios.get(`${BASE_URL}/user/dashboard`, { headers });
        const updatedDashboard = updatedDashboardResponse.data.dashboard;
        
        console.log('✅ Updated dashboard data:');
        console.log(`📚 Subscribed Topics: ${updatedDashboard.subscribedTopics.length} (was ${dashboard.subscribedTopics.length})`);
        console.log(`📖 Wordbank: ${updatedDashboard.wordbank.total} words (was ${dashboard.wordbank.total})`);
        console.log(`📈 Total Words Learned: ${updatedDashboard.statistics.totalWordsLearned} (was ${dashboard.statistics.totalWordsLearned})`);
        
        if (updatedDashboard.subscribedTopics.length > 0) {
            const updatedTopic = updatedDashboard.subscribedTopics[0];
            console.log(`📊 Topic weight updated: "${updatedTopic.name}" is now ${updatedTopic.weight}%`);
        }

        console.log('\n🎉 User dashboard functionality test completed!');
        console.log('\n📋 Available Dashboard Features:');
        console.log('✅ GET /user/dashboard - Comprehensive user overview');
        console.log('✅ DELETE /user/topics/:topicId - Unsubscribe from topics');
        console.log('✅ PUT /user/topics/:topicId/weight - Update topic preferences');
        console.log('✅ DELETE /user/wordbank/:wordbankId - Remove words from wordbank');
        console.log('✅ PUT /user/wordbank/:wordbankId/status - Update word status');
        console.log('✅ GET /wordbank - View all words in wordbank');
        console.log('✅ POST /actions/favorite - Favorite words');
        console.log('✅ POST /actions/learn-again - Mark words to learn again');

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.error('Status:', error.response?.status);
    }
}

testUserDashboard();
