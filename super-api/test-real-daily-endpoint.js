const fetch = require('node-fetch');

async function testRealDailyEndpoint() {
  console.log('🧪 Testing Real Daily Endpoint Implementation');
  console.log('===============================================\n');

  try {
    // Test 1: Health check
    console.log('1️⃣ Testing health endpoint...');
    const healthResponse = await fetch('http://localhost:4001/health');
    const healthData = await healthResponse.json();
    console.log('✅ Health check:', healthData.status);
    console.log('');

    // Test 2: Test daily endpoint with valid auth token
    console.log('2️⃣ Testing /daily endpoint with auth...');
    
    // Use the same token format as the iOS app
    const testUserId = 'email-user-btsp60yahoocom';
    const authToken = `access_${testUserId}_${Date.now()}`;
    
    const dailyResponse = await fetch('http://localhost:4001/daily', {
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      }
    });

    console.log('📊 Daily endpoint response status:', dailyResponse.status);
    
    if (dailyResponse.status === 200) {
      const dailyData = await dailyResponse.json();
      console.log('✅ Daily endpoint response:');
      console.log('   - Success:', dailyData.success);
      console.log('   - Has dailyWord:', !!dailyData.dailyWord);
      console.log('   - Term:', dailyData.dailyWord?.term);
      console.log('   - Topic:', dailyData.dailyWord?.topic);
      console.log('   - Is Review:', dailyData.dailyWord?.isReview);
      console.log('   - Has delivery:', !!dailyData.dailyWord?.delivery);
      console.log('   - Has wordbank:', !!dailyData.dailyWord?.wordbank);
      console.log('   - User Progress:', dailyData.userProgress);
      
      // Test action endpoint
      if (dailyData.dailyWord?.delivery?.id) {
        console.log('\n3️⃣ Testing /daily/action endpoint...');
        
        const actionResponse = await fetch('http://localhost:4001/daily/action', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${authToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            deliveryId: dailyData.dailyWord.delivery.id,
            action: 'FAVORITE',
            wordbankId: dailyData.dailyWord.wordbank.id
          })
        });

        console.log('📊 Action endpoint response status:', actionResponse.status);
        
        if (actionResponse.status === 200) {
          const actionData = await actionResponse.json();
          console.log('✅ Action recorded successfully:', actionData.success);
        } else {
          const errorData = await actionResponse.text();
          console.log('❌ Action failed:', errorData);
        }
      }
      
    } else {
      const errorData = await dailyResponse.text();
      console.log('❌ Daily endpoint failed:', errorData);
    }

    console.log('\n4️⃣ Testing /first-daily endpoint for comparison...');
    const firstDailyResponse = await fetch(`http://localhost:4001/first-daily?userId=${testUserId}`);
    console.log('📊 First daily response status:', firstDailyResponse.status);
    
    if (firstDailyResponse.status === 200) {
      const firstDailyData = await firstDailyResponse.json();
      console.log('✅ First daily response:');
      console.log('   - Success:', firstDailyData.success);
      console.log('   - First vocab generated:', firstDailyData.firstVocabGenerated);
      console.log('   - Has dailyWord:', !!firstDailyData.dailyWord);
    } else {
      const errorData = await firstDailyResponse.text();
      console.log('❌ First daily failed:', errorData);
    }

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run the test
testRealDailyEndpoint();
