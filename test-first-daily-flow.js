#!/usr/bin/env node

/**
 * Test script for the complete onboarding → first daily word flow
 * This validates Phase 4 implementation
 */

const API_BASE = 'http://localhost:4001';

async function testCompleteFlow() {
    console.log('🧪 Testing Complete Onboarding → First Daily Word Flow\n');

    try {
        // Step 1: Create a test user via auth
        console.log('1️⃣ Creating test user...');
        const authResponse = await fetch(`${API_BASE}/auth-direct/apple`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                identityToken: 'test-token',
                authorizationCode: 'test-code',
                email: 'testuser@example.com'
            })
        });
        
        const authData = await authResponse.json();
        if (!authData.user) {
            throw new Error(`Auth failed: ${authData.error || 'No user returned'}`);
        }
        
        const userId = authData.user.id;
        console.log(`✅ User created: ${userId}\n`);

        // Step 2: Complete onboarding
        console.log('2️⃣ Completing onboarding...');
        const onboardingResponse = await fetch(`${API_BASE}/onboarding/complete`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authData.access_token}`
            },
            body: JSON.stringify({
                name: 'Test User',
                username: 'testuser123',
                profession_current: 'Developer',
                profession_target: 'Senior Developer',
                goal: 'Learn technical vocabulary',
                hobbies: ['programming', 'reading'],
                languages: ['English', 'Spanish'],
                travel_plan: {
                    location: 'Tokyo',
                    start_date: '2025-12-01'
                },
                selected_topics: ['technology', 'programming', 'travel'],
                preferred_difficulty: 'intermediate',
                enable_notifications: true,
                notification_time: '09:00',
                daily_word_goal: 2
            })
        });

        const onboardingData = await onboardingResponse.json();
        if (!onboardingData.success) {
            throw new Error(`Onboarding failed: ${JSON.stringify(onboardingData)}`);
        }
        console.log(`✅ Onboarding completed for user: ${userId}\n`);

        // Step 3: Wait a moment for content generation to start
        console.log('3️⃣ Waiting for content generation...');
        await new Promise(resolve => setTimeout(resolve, 2000));

        // Step 4: Try to get first daily word
        console.log('4️⃣ Getting first daily word...');
        let firstDailyResponse;
        let attempts = 0;
        const maxAttempts = 6;

        do {
            attempts++;
            console.log(`   Attempt ${attempts}/${maxAttempts}...`);
            
            firstDailyResponse = await fetch(`${API_BASE}/first-daily?userId=${userId}`);
            const firstDailyData = await firstDailyResponse.json();
            
            if (firstDailyData.generating) {
                console.log(`   🚀 Still generating... (${firstDailyData.estimatedTime})`);
                await new Promise(resolve => setTimeout(resolve, (firstDailyData.retryAfter || 10) * 1000));
            } else if (firstDailyData.success && firstDailyData.firstVocabGenerated) {
                console.log(`✅ First daily word ready!`);
                console.log(`   Word: ${firstDailyData.dailyWord.term}`);
                console.log(`   Definition: ${firstDailyData.dailyWord.definition}`);
                console.log(`   Topic: ${firstDailyData.dailyWord.topic}`);
                console.log(`   Delivery ID: ${firstDailyData.dailyWord.delivery.id}`);
                console.log(`   Wordbank ID: ${firstDailyData.dailyWord.wordbank.id}\n`);

                // Step 5: Test delivery action tracking
                console.log('5️⃣ Testing delivery action tracking...');
                const actionResponse = await fetch(`${API_BASE}/first-daily/action`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        deliveryId: firstDailyData.dailyWord.delivery.id,
                        action: 'FAVORITE',
                        wordbankId: firstDailyData.dailyWord.wordbank.id
                    })
                });

                const actionData = await actionResponse.json();
                if (actionData.success) {
                    console.log(`✅ Action tracked: ${actionData.action}\n`);
                } else {
                    console.log(`❌ Action tracking failed: ${actionData.message}\n`);
                }

                return true; // Success!
            } else if (firstDailyData.redirect) {
                console.log(`ℹ️ User already has vocab, redirecting to: ${firstDailyData.redirect}\n`);
                return true; // Also success
            } else {
                console.log(`❌ Unexpected response: ${JSON.stringify(firstDailyData)}`);
                return false;
            }
        } while (attempts < maxAttempts);

        console.log(`❌ Max attempts reached, first word generation may have failed\n`);
        return false;

    } catch (error) {
        console.error(`❌ Test failed: ${error.message}`);
        return false;
    }
}

// Run the test
testCompleteFlow().then(success => {
    if (success) {
        console.log('🎉 All tests passed! The complete onboarding → first daily word flow is working!');
        process.exit(0);
    } else {
        console.log('💥 Some tests failed. Check the implementation.');
        process.exit(1);
    }
});
