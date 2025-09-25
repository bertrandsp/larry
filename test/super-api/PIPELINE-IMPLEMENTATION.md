# 🚀 Term + Fact Generation Pipeline Implementation

## 🎯 Overview

This document describes the complete implementation of the AI-powered term and fact generation pipeline for the Larry Backend Service. The pipeline processes user-submitted topics and generates vocabulary terms and facts using OpenAI, with external validation and confidence scoring.

## 🏗️ Architecture

### **Pipeline Flow**
```
User submits topic → Queue job → OpenAI generation → External validation → GPT fallback → Confidence scoring → Database storage
```

### **Components**
- **Queue System**: BullMQ with Redis for job management
- **AI Service**: OpenAI integration for term/fact generation
- **Validation Service**: External API integration (Wikipedia, etc.)
- **Term Service**: Orchestrates the entire pipeline
- **Worker System**: Background processing with retry logic

## 📁 File Structure

```
src/
├── services/
│   ├── openAiService.ts      # OpenAI integration
│   ├── validationService.ts  # External API validation
│   └── termService.ts        # Pipeline orchestration
├── utils/
│   └── cleanAndDedupe.ts     # Data cleaning utilities
├── queues/
│   └── topicPipelineQueue.ts # BullMQ queue setup
├── workers/
│   └── topicWorker.ts        # Background worker
└── api/
    └── topics.ts             # API endpoints
```

## 🔧 Implementation Details

### **1. OpenAI Service** (`openAiService.ts`)

**Features:**
- GPT-4 integration for term and fact generation
- Structured JSON responses
- Fallback generation for missing definitions
- Error handling and retry logic

**Key Methods:**
- `generateTopicTermsAndFacts(topicName)`: Generates 10-15 terms and 5-8 facts
- `gptFallbackIfMissing(terms)`: Provides definitions for missing terms

**Prompt Engineering:**
```typescript
const prompt = `Generate vocabulary terms and facts for the topic: "${topicName}"

Please provide:
1. 10-15 important vocabulary terms with definitions and examples
2. 5-8 interesting facts about this topic

Format as JSON:
{
  "terms": [
    {
      "term": "term name",
      "definition": "clear definition",
      "example": "example sentence"
    }
  ],
  "facts": [
    {
      "fact": "interesting fact about the topic"
    }
  ]
}`;
```

### **2. Validation Service** (`validationService.ts`)

**Features:**
- Wikipedia API integration for external definitions
- Extensible architecture for additional sources
- Timeout handling and error recovery
- Source attribution and URL tracking

**External Sources:**
- **Wikipedia**: Free API for term definitions
- **Merriam-Webster**: Placeholder for future integration
- **Custom APIs**: Extensible for additional sources

### **3. Term Service** (`termService.ts`)

**Pipeline Steps:**
1. **OpenAI Generation**: Create initial terms and facts
2. **Cleaning & Deduplication**: Remove duplicates and normalize
3. **External Validation**: Enrich with external definitions
4. **GPT Fallback**: Fill missing definitions
5. **Confidence Scoring**: Calculate confidence levels
6. **Database Storage**: Save to PostgreSQL

**Confidence Scoring:**
- **1.0**: External source (Wikipedia, etc.)
- **0.7**: GPT fallback
- **0.8**: Default AI generation

**Complexity Assessment:**
- **Beginner**: < 15 words, avg word length < 6
- **Intermediate**: 15-20 words, avg word length 6-8
- **Advanced**: > 20 words, avg word length > 8

### **4. Queue System** (`topicPipelineQueue.ts`)

**Configuration:**
- **Queue Name**: `generate-topic-pipeline`
- **Retry Attempts**: 3 with exponential backoff
- **Timeout**: 5 minutes per job
- **Concurrency**: 3 jobs (reduced for API rate limits)
- **Cleanup**: Automatic removal of completed/failed jobs

### **5. Worker System** (`topicWorker.ts`)

**Features:**
- Background job processing
- Error handling and logging
- Job completion tracking
- Graceful shutdown handling

## 🚀 Usage

### **Starting the Pipeline**

```bash
# Start API server only
npm run dev

# Start background workers only
npm run dev:workers

# Start both API and workers
npm run dev:all
```

### **API Endpoints**

**Create Topic (Triggers Pipeline):**
```bash
POST /user/topics
{
  "userId": "user-uuid",
  "topicName": "Machine Learning",
  "weight": 75
}
```

**Response:**
```json
{
  "message": "Topic submitted and queued for generation.",
  "userTopicId": "uuid",
  "topicId": "uuid"
}
```

**Get User Topics (with Term Counts):**
```bash
GET /user/{userId}/topics
```

**Response:**
```json
[
  {
    "id": "uuid",
    "topicId": "uuid",
    "name": "Machine Learning",
    "weight": 75,
    "termCount": 12,
    "factCount": 6
  }
]
```

### **Testing**

```bash
# Basic API tests
npm test

# Enhanced API tests
npm run test:enhanced

# Pipeline tests
npm run test:pipeline
```

## 🔧 Configuration

### **Environment Variables**

```bash
# Required
OPENAI_API_KEY=your_openai_api_key_here
DATABASE_URL=postgresql://user:pass@localhost:5432/larry

# Optional
REDIS_URL=redis://localhost:6379
NODE_ENV=development
```

### **OpenAI Configuration**

- **Model**: GPT-4
- **Temperature**: 0.7 (balanced creativity)
- **Max Tokens**: 2000 (sufficient for 10-15 terms)
- **Timeout**: 30 seconds per request

## 📊 Monitoring & Observability

### **Logging**

The pipeline provides comprehensive logging:
- Job start/completion
- Generation progress
- Error details
- Performance metrics

### **Queue Monitoring**

- Job completion rates
- Failure tracking
- Processing times
- Queue depth

### **Database Metrics**

- Terms generated per topic
- Facts generated per topic
- Confidence score distribution
- Source attribution tracking

## 🔮 Future Enhancements

### **Planned Features**
1. **Real-time Updates**: WebSocket notifications for job completion
2. **Job Status API**: Track individual job progress
3. **Rate Limiting**: API cost controls and limits
4. **Caching**: Redis caching for repeated terms
5. **Moderation**: Content filtering and safety checks

### **External Integrations**
1. **Merriam-Webster API**: Enhanced definition validation
2. **Urban Dictionary**: Slang and colloquial terms
3. **Academic APIs**: Scholarly definitions and sources
4. **Translation APIs**: Multi-language support

### **Performance Optimizations**
1. **Batch Processing**: Process multiple topics simultaneously
2. **Parallel Validation**: Concurrent external API calls
3. **Smart Caching**: Cache common terms and definitions
4. **Load Balancing**: Distribute jobs across multiple workers

## 🛠️ Troubleshooting

### **Common Issues**

**OpenAI API Errors:**
- Check API key configuration
- Verify rate limits and quotas
- Monitor API response times

**Queue Processing Issues:**
- Ensure Redis is running
- Check worker startup logs
- Verify job timeout settings

**Database Errors:**
- Confirm PostgreSQL connection
- Check schema migrations
- Verify data constraints

### **Debug Commands**

```bash
# Check Redis connection
redis-cli ping

# Monitor queue jobs
redis-cli monitor

# Check worker logs
npm run dev:workers

# Test OpenAI connection
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
  https://api.openai.com/v1/models
```

## 📚 API Reference

### **OpenAI Service Methods**

```typescript
// Generate terms and facts for a topic
generateTopicTermsAndFacts(topicName: string): Promise<{
  terms: GeneratedTerm[];
  facts: GeneratedFact[];
}>

// Provide fallback definitions
gptFallbackIfMissing(terms: GeneratedTerm[]): Promise<GeneratedTerm[]>
```

### **Validation Service Methods**

```typescript
// Validate and enrich terms with external sources
validateAndEnrich(terms: Term[]): Promise<Term[]>
```

### **Term Service Methods**

```typescript
// Main pipeline orchestration
generateTermsAndFacts(params: TermGenerationParams): Promise<{
  success: boolean;
  termsGenerated: number;
  factsGenerated: number;
  topicName: string;
}>
```

---

**🎉 The Term + Fact Generation Pipeline is now fully implemented and ready for production use!**

