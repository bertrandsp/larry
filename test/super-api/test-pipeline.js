const http = require('http');

// Test health endpoint
const testHealth = () => {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: 'localhost',
      port: 4001,
      path: '/health',
      method: 'GET'
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve(result);
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
};

// Test user creation
const testUserCreation = () => {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      email: `pipeline-test-${Date.now()}@example.com`
    });

    const req = http.request({
      hostname: 'localhost',
      port: 4001,
      path: '/user',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve({ status: res.statusCode, data: result });
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
};

// Test topic creation with AI pipeline
const testTopicCreation = (userId) => {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      userId: userId,
      topicName: 'Machine Learning',
      weight: 75
    });

    const req = http.request({
      hostname: 'localhost',
      port: 4001,
      path: '/user/topics',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve({ status: res.statusCode, data: result });
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
};

// Test getting user topics with term counts
const testGetUserTopics = (userId) => {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: 'localhost',
      port: 4001,
      path: `/user/${userId}/topics`,
      method: 'GET'
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve({ status: res.statusCode, data: result });
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
};

// Test getting user terms
const testGetUserTerms = (userId) => {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: 'localhost',
      port: 4001,
      path: `/user/${userId}/terms`,
      method: 'GET'
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve({ status: res.statusCode, data: result });
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
};

// Run comprehensive pipeline tests
async function runPipelineTests() {
  console.log('🧪 Testing Term + Fact Generation Pipeline...\n');

  try {
    // Test health endpoint
    console.log('1. Testing health endpoint...');
    const health = await testHealth();
    console.log('✅ Health endpoint working:', health);
    console.log('');

    // Test user creation
    console.log('2. Testing user creation...');
    const userResult = await testUserCreation();
    console.log('✅ User creation result:', userResult.status);
    
    let userId = null;
    if (userResult.status === 201 && userResult.data.id) {
      userId = userResult.data.id;
      console.log('   User ID:', userId);
    } else {
      console.log('   Using test user ID for demo');
      userId = 'test-user-id';
    }
    console.log('');

    // Test topic creation with AI pipeline
    console.log('3. Testing topic creation with AI pipeline...');
    const topicResult = await testTopicCreation(userId);
    console.log('✅ Topic creation result:', topicResult.status);
    if (topicResult.status === 201) {
      console.log('   Topic queued for AI generation:', topicResult.data.message);
      console.log('   Topic ID:', topicResult.data.topicId);
    }
    console.log('');

    // Wait a bit for processing
    console.log('4. Waiting for AI processing...');
    await new Promise(resolve => setTimeout(resolve, 5000));
    console.log('   Processing time elapsed');
    console.log('');

    // Test getting user topics with term counts
    console.log('5. Testing get user topics with term counts...');
    const topicsResult = await testGetUserTopics(userId);
    console.log('✅ Get user topics result:', topicsResult.status);
    if (topicsResult.status === 200) {
      console.log('   Topics found:', topicsResult.data.length);
      topicsResult.data.forEach(topic => {
        console.log(`   - ${topic.name}: ${topic.termCount} terms, ${topic.factCount} facts`);
      });
    }
    console.log('');

    // Test getting user terms
    console.log('6. Testing get user terms...');
    const termsResult = await testGetUserTerms(userId);
    console.log('✅ Get user terms result:', termsResult.status);
    if (termsResult.status === 200) {
      console.log('   Terms found:', termsResult.data.length);
      if (termsResult.data.length > 0) {
        console.log('   Sample term:', termsResult.data[0]);
      }
    }
    console.log('');

    console.log('🎉 Pipeline test completed!');
    console.log('📝 Note: AI generation requires OpenAI API key and Redis for queue processing.');
    console.log('   Run "npm run dev:all" to start both API and workers.');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

runPipelineTests();

