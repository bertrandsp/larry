// API Service for connecting to Larry backend
// Configuration for different environments
const getApiBaseUrl = () => {
  if (typeof __DEV__ !== 'undefined' && __DEV__) {
    // In development, use local IP for physical devices
    return 'http://192.168.1.101:4001';
  }
  // For testing in Node.js environment, use localhost
  if (typeof process !== 'undefined' && process.env.NODE_ENV === 'test') {
    return 'http://localhost:4001';
  }
  // In production, use your actual backend URL
  return 'https://your-production-backend.com';
};

const API_BASE_URL = getApiBaseUrl();

// Basic fetch wrapper with error handling
const apiRequest = async (endpoint, options = {}, userId = null) => {
  const url = `${API_BASE_URL}${endpoint}`;
  
  console.log(`🌐 Making API request to: ${url} for user: ${userId || 'unknown'}`);
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  // Add user ID to headers if provided
  if (userId) {
    headers['x-user-id'] = userId;
  }
  
  const defaultOptions = {
    headers,
  };

  try {
    const response = await fetch(url, { ...defaultOptions, ...options });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    console.log(`✅ API request successful: ${endpoint}`);
    return data;
  } catch (error) {
    console.error(`❌ API request failed for ${endpoint}:`, error);
    console.error(`🌐 URL attempted: ${url}`);
    throw error;
  }
};

// Health check function to test API connectivity
export const checkHealth = async () => {
  return apiRequest('/health');
};

// Get daily word from the backend
export const getDailyWord = async (userId) => {
  return apiRequest('/daily', {}, userId);
};

// Mark word for learning again
export const markLearnAgain = async (termId, userId) => {
  return apiRequest('/learn-again', {
    method: 'POST',
    body: JSON.stringify({ termId }),
  }, userId);
};

// Favorite a word
export const favoriteWord = async (termId, userId) => {
  return apiRequest('/favorite', {
    method: 'POST',
    body: JSON.stringify({ termId }),
  }, userId);
};

// Get available interests (preset)
export const getAvailableInterests = async () => {
  return apiRequest('/interests');
};

// Save user's interests
export const saveUserInterests = async (presetIds, customNames, userId) => {
  return apiRequest('/user/interests', {
    method: 'POST',
    body: JSON.stringify({ userId, presetIds, customNames }),
  }, userId);
};

// Get user's interests
export const getUserInterests = async (userId) => {
  return apiRequest('/user/interests', {}, userId);
};

// Get words for a specific interest
export const getInterestWords = async (interestId, userId) => {
  return apiRequest(`/interests/${interestId}/words`, {}, userId);
};

// Search user's words
export const searchUserWords = async (query, userId) => {
  return apiRequest('/words/search', {
    method: 'POST',
    body: JSON.stringify({ query }),
  }, userId);
};

// Get user's learning statistics
export const getUserStats = async (userId) => {
  return apiRequest('/user/stats', {}, userId);
};

// Save user's notification preferences
export const saveUserNotifications = async (localTz, localHHmm, frequency, pushToken, userId) => {
  return apiRequest('/user/notifications', {
    method: 'POST',
    body: JSON.stringify({ userId, localTz, localHHmm, frequency, pushToken }),
  }, userId);
};

// Get user's notification preferences
export const getUserNotifications = async (userId) => {
  return apiRequest('/user/notifications', {}, userId);
};

// Test function to verify API connection
export const testApiConnection = async () => {
  console.log(`🔧 Testing API connection to: ${API_BASE_URL}`);
  try {
    const health = await checkHealth();
    console.log('✅ API connection successful:', health);
    return { success: true, data: health };
  } catch (error) {
    console.error('❌ API connection failed:', error);
    return { success: false, error: error.message };
  }
};

// Test mobile connection specifically
export const testMobileConnection = async () => {
  console.log(`📱 Testing mobile connection to: ${API_BASE_URL}`);
  try {
    const response = await fetch(`${API_BASE_URL}/test-mobile`);
    const data = await response.json();
    console.log('📱 Mobile connection successful:', data);
    return { success: true, data };
  } catch (error) {
    console.error('📱 Mobile connection failed:', error);
    return { success: false, error: error.message };
  }
};

// Direct OAuth endpoints (no WorkOS dependency)
export const startDirectGoogleOAuth = async () => {
  return apiRequest('/auth-direct/google/start', { method: 'POST' });
};

export const authenticateWithApple = async (identityToken, email, name, appleUserId) => {
  return apiRequest('/auth-direct/apple', {
    method: 'POST',
    body: JSON.stringify({ identityToken, email, name, appleUserId }),
  });
};

export const refreshToken = async (refreshToken) => {
  return apiRequest('/auth-direct/refresh', {
    method: 'POST',
    body: JSON.stringify({ refreshToken }),
  });
};

export const signOut = async () => {
  return apiRequest('/auth-direct/signout', { method: 'POST' });
};

// User profile endpoints
export const getUserProfile = async (accessToken, userId) => {
  return apiRequest('/auth-direct/profile', {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
    },
  }, userId);
};

export const updateUserProfile = async (accessToken, profileData, userId) => {
  return apiRequest('/auth-direct/profile', {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
    },
    body: JSON.stringify(profileData),
  }, userId);
};


