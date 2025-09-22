# Larry API Documentation

## Overview

The Larry API is a RESTful service built with Express.js and TypeScript, providing endpoints for vocabulary learning, user management, and AI-powered content generation.

**Base URL**: `http://localhost:4000` (development)

## Authentication

The API uses JWT tokens for authentication. Include the token in the `Authorization` header:

```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### Authentication

#### Apple OAuth
```http
POST /apple
Content-Type: application/json

{
  "identityToken": "apple-identity-token",
  "email": "user@example.com",
  "name": "User Name",
  "appleUserId": "apple-user-id"
}
```

**Response**:
```json
{
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token",
  "userId": "user-id",
  "userEmail": "user@example.com",
  "userName": "User Name"
}
```

#### Google OAuth Start
```http
POST /google/start
```

**Response**:
```json
{
  "authUrl": "https://accounts.google.com/o/oauth2/v2/auth?..."
}
```

#### Google OAuth Callback
```http
GET /google/callback?code=<auth-code>&state=<state>
```

**Response**: Redirects to deep link with tokens

#### Sign Out
```http
POST /signout
Authorization: Bearer <jwt-token>
```

### Daily Words

#### Get Daily Word
```http
GET /daily
Authorization: Bearer <jwt-token>
```

**Response**:
```json
{
  "term": {
    "id": "term-id",
    "word": "vocabulary",
    "definition": "All the words known and used by a person",
    "examples": ["His vocabulary has improved since reading more books."],
    "similarWords": ["lexicon", "terminology"],
    "interest": "Education",
    "quality": 8.5
  },
  "actions": {
    "canFavorite": true,
    "canLearnAgain": true,
    "canAskLarry": true
  }
}
```

#### Mark Word for Review
```http
POST /learn-again
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "termId": "term-id"
}
```

#### Favorite a Word
```http
POST /actions/favorite
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "termId": "term-id"
}
```

### User Management

#### Get User Profile
```http
GET /profile
Authorization: Bearer <jwt-token>
```

**Response**:
```json
{
  "id": "user-id",
  "email": "user@example.com",
  "name": "User Name",
  "avatar": "https://example.com/avatar.jpg",
  "tier": "free",
  "interests": [
    {
      "id": "interest-id",
      "name": "Technology",
      "weight": 25
    }
  ],
  "notifications": {
    "frequency": "daily",
    "time": "09:00",
    "timezone": "America/Los_Angeles"
  }
}
```

#### Save User Interests
```http
POST /user/interests
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "interests": [
    {
      "interestId": "interest-id",
      "weight": 25
    }
  ]
}
```

#### Save Notification Preferences
```http
POST /user/notifications
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "localTz": "America/Los_Angeles",
  "localHHmm": "09:00",
  "frequency": "daily",
  "pushToken": "expo-push-token"
}
```

### Interests

#### Get Available Interests
```http
GET /interests
```

**Response**:
```json
{
  "items": [
    {
      "id": "interest-id",
      "slug": "technology",
      "name": "Technology",
      "description": "Software, hardware, and digital innovation",
      "locale": "en"
    }
  ]
}
```

#### Get User Interests
```http
GET /user/interests
Authorization: Bearer <jwt-token>
```

### Wordbank

#### Get User Words
```http
GET /wordbank
Authorization: Bearer <jwt-token>
```

**Response**:
```json
{
  "favorites": [
    {
      "id": "term-id",
      "word": "vocabulary",
      "definition": "All the words known and used by a person",
      "interest": "Education",
      "favoritedAt": "2025-08-25T18:00:00Z"
    }
  ],
  "history": [
    {
      "id": "term-id",
      "word": "algorithm",
      "definition": "A set of rules or instructions for solving a problem",
      "interest": "Technology",
      "learnedAt": "2025-08-25T17:00:00Z"
    }
  ]
}
```

### Admin Endpoints

#### Health Check
```http
GET /health
```

**Response**:
```json
{
  "ok": true,
  "timestamp": "2025-08-25T18:00:00Z",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "openai": "healthy"
  }
}
```

#### Seed Topic with Words
```http
POST /admin/seed-topic
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "topic": "Psychology",
  "count": 10
}
```

#### Ingest Content
```http
POST /admin/ingest
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "topic": "Technology",
  "sources": ["wikipedia", "youtube"],
  "count": 5
}
```

## Error Responses

### Standard Error Format
```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": "Additional error details"
}
```

### Common Error Codes

- `401 Unauthorized` - Invalid or missing JWT token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Validation Error` - Invalid request data
- `500 Internal Server Error` - Server error

### Example Error Response
```json
{
  "error": "Invalid timezone or time format",
  "code": "VALIDATION_ERROR",
  "details": "Timezone must be a valid IANA timezone identifier"
}
```

## Rate Limiting

- **General endpoints**: 100 requests per minute
- **Authentication endpoints**: 10 requests per minute
- **Admin endpoints**: 50 requests per minute

## Data Models

### User
```typescript
interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  provider: 'apple' | 'google';
  createdAt: Date;
  lastLoginAt: Date;
}
```

### Term
```typescript
interface Term {
  id: string;
  word: string;
  definition: string;
  examples: string[];
  similarWords: string[];
  interest: string;
  quality: number;
  selfQuality: number;
  userQuality?: number;
  createdAt: Date;
}
```

### Interest
```typescript
interface Interest {
  id: string;
  slug: string;
  name: string;
  description: string;
  locale: string;
  status: 'global' | 'custom';
}
```

### UserInterest
```typescript
interface UserInterest {
  userId: string;
  interestId: string;
  weight: number;
  createdAt: Date;
}
```

## Webhooks

### Push Notifications

The API supports Expo push notifications for daily word delivery:

```http
POST /notifications/send
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "userId": "user-id",
  "title": "Your daily word is ready!",
  "body": "Learn 'vocabulary' today",
  "data": {
    "type": "daily_word",
    "termId": "term-id"
  }
}
```

## Testing

### Health Check
```bash
curl http://localhost:4000/health
```

### Authentication Test
```bash
curl -X POST http://localhost:4000/apple \
  -H "Content-Type: application/json" \
  -d '{"identityToken": "test-token", "email": "test@example.com"}'
```

### Daily Word Test
```bash
curl http://localhost:4000/daily \
  -H "Authorization: Bearer <your-jwt-token>"
```

## Development

### Local Development
1. Start the backend: `docker compose up -d backend`
2. Start the frontend: `cd larry-app && npm start`
3. Access API at: `http://localhost:4000`

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://jacquesbloom:password@postgres:5432/larry

# Redis
REDIS_URL=redis://redis:6379

# OpenAI
OPENAI_API_KEY=your_openai_key

# JWT
JWT_SECRET=your_jwt_secret

# OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

### Logging
The API logs all requests with timing information:
```
API timing: GET took /daily 45ms
API timing: POST took /learn-again 23ms
```

### Metrics
Access metrics at: `http://localhost:4000/metrics`
