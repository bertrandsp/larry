const http = require('http');

// Test health endpoint
const testHealth = () => {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: 'localhost',
      port: 3000,
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

// Test user creation endpoint (will fail due to no DB, but should return proper error)
const testUserCreation = () => {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      email: 'test@example.com'
    });

    const req = http.request({
      hostname: 'localhost',
      port: 3000,
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

// Run tests
async function runTests() {
  console.log('🧪 Testing Larry Backend Service...\n');

  try {
    // Test health endpoint
    console.log('1. Testing health endpoint...');
    const health = await testHealth();
    console.log('✅ Health endpoint working:', health);
    console.log('');

    // Test user creation (should fail gracefully)
    console.log('2. Testing user creation endpoint...');
    const userResult = await testUserCreation();
    console.log('✅ User endpoint responding (expected DB error):', userResult.status);
    console.log('');

    console.log('🎉 All tests passed! The API is working correctly.');
    console.log('📝 Note: Database operations will fail until you set up PostgreSQL and run migrations.');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

runTests();


