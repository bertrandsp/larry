# Provider Integrations

Larry now includes real API integrations with multiple content providers for vocabulary discovery and extraction. This document outlines the implemented providers, their capabilities, and configuration requirements.

## Overview

The provider system enables Larry to discover and fetch high-quality vocabulary content from various sources:

- **Wikipedia**: Encyclopedic content with high reliability
- **Wiktionary**: Dictionary definitions and etymology
- **YouTube**: Educational video transcripts (requires API key)
- **Reddit**: Community discussions and explanations (requires OAuth)
- **Urban Dictionary**: Slang and informal language (optional)

## Architecture

### Flow

```
Topic Request → Content Discovery → Source Fetching → Vocabulary Extraction → Term Storage
     ↓               ↓                  ↓                    ↓                   ↓
Admin API     Provider Adapters    Specialized APIs    OpenAI Processing    Database
```

### Components

1. **Provider Adapters** (`scraper/src/adapters/`)
   - Specialized implementations for each content source
   - Uniform interface for discovery and fetching
   - Built-in reliability scoring and content filtering

2. **Workers** (`api/src/workers/`)
   - `contentDiscovery.worker.ts`: Orchestrates multi-provider discovery
   - `fetch.worker.ts`: Enhanced to use provider-specific adapters
   - Queue-based processing with error handling and retries

3. **Admin API** (`api/src/routes/admin.ts`)
   - `POST /admin/discover-content`: Trigger content discovery
   - Configurable provider selection and source limits

## Provider Details

### Wikipedia

**Source**: [Wikipedia REST API](https://www.mediawiki.org/wiki/API:Main_page)

**Capabilities**:
- Search articles by topic
- Extract clean text content
- Category-based industry classification
- High reliability scoring (0.9)

**Configuration**: None required

**Example URLs**:
- `https://en.wikipedia.org/wiki/Machine_learning`
- `https://en.wikipedia.org/wiki/Artificial_intelligence`

**Quality Features**:
- Removes HTML and navigation elements
- Includes article categories for context
- Estimates word count and reading level
- Filters out disambiguation and meta pages

### Wiktionary

**Source**: [Wiktionary API](https://en.wiktionary.org/w/api.php)

**Capabilities**:
- Dictionary definitions and etymologies
- Multiple word senses and usage examples
- Cross-language references
- Very high reliability (0.95)

**Configuration**: None required

**Example URLs**:
- `https://en.wiktionary.org/wiki/algorithm`
- `https://en.wiktionary.org/wiki/machine_learning`

**Quality Features**:
- Specialized for vocabulary and definitions
- Includes pronunciation and etymology
- Community-curated for accuracy
- Language-specific categorization

### YouTube Data API

**Source**: [YouTube Data API v3](https://developers.google.com/youtube/v3)

**Capabilities**:
- Search educational videos by topic
- Access video metadata and descriptions
- Caption/transcript availability detection
- Duration and engagement filtering

**Configuration Required**:
```bash
YOUTUBE_API_KEY=your_youtube_api_key_here
```

**Setup**:
1. Create project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable YouTube Data API v3
3. Create API credentials (API Key)
4. Set quota limits and monitoring

**Quality Features**:
- Filters for videos with captions
- Duration limits (under 30 minutes)
- View count and engagement scoring
- Educational content prioritization

**Limitations**:
- Caption download requires additional OAuth2 setup
- API quota limits apply
- Currently extracts descriptions only (transcript integration pending)

### Reddit API

**Source**: [Reddit API v1](https://www.reddit.com/dev/api/)

**Capabilities**:
- Search text posts across subreddits
- Access high-quality discussions
- Community scoring and filtering
- Subreddit-based categorization

**Configuration Required**:
```bash
REDDIT_CLIENT_ID=your_reddit_client_id
REDDIT_CLIENT_SECRET=your_reddit_client_secret
REDDIT_USER_AGENT=Larry-VocabApp/1.0 by /u/YourUsername
```

**Setup**:
1. Create application at [Reddit App Preferences](https://www.reddit.com/prefs/apps)
2. Choose "script" application type
3. Note client ID (under app name) and secret
4. Set appropriate user agent

**Quality Features**:
- OAuth2 authentication for reliable access
- Score-based filtering (minimum upvotes)
- Engagement ratio analysis
- Quality subreddit prioritization
- NSFW content filtering

**Content Types**:
- Text posts with substantial content
- High-scoring comments and discussions
- Community-validated explanations
- Domain-specific terminology

### Urban Dictionary

**Source**: [Urban Dictionary API](https://urbandictionary.com/)

**Capabilities**:
- Slang and informal language definitions
- Community-generated content
- Voting-based quality scoring
- Contemporary language evolution

**Configuration**: None required

**Quality Features**:
- Minimum upvote thresholds
- Content filtering for appropriateness
- Definition length validation
- Meta-content removal

**Use Cases**:
- Informal language learning
- Contemporary slang understanding
- Cultural context for vocabulary
- Community-driven definitions

**Content Filtering**:
- Blocks extremely explicit content
- Removes meta-commentary and complaints
- Validates definition quality
- Limited reliability scoring (max 0.6)

## API Usage

### Content Discovery Endpoint

```http
POST /admin/discover-content
Content-Type: application/json
x-admin-key: your_admin_key

{
  "topic": "machine learning",
  "maxSources": 20,
  "providers": ["wikipedia", "wiktionary", "youtube", "reddit"],
  "context": "Technology vocabulary for developers"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Content discovery started for topic: machine learning",
  "jobId": "contentDiscovery:12345",
  "topic": "machine learning",
  "maxSources": 20,
  "providers": ["wikipedia", "wiktionary", "youtube", "reddit"],
  "estimatedSources": 20
}
```

### Provider Selection

**Default providers**: `["wikipedia", "wiktionary"]` (no API keys required)

**Available providers**:
- `wikipedia`: High-quality encyclopedic content
- `wiktionary`: Dictionary definitions and etymology
- `youtube`: Educational video content (requires API key)
- `reddit`: Community discussions (requires OAuth)
- `urbandictionary`: Slang and informal language

### Quality Scoring

Each provider implements reliability scoring:

| Provider | Base Score | Factors |
|----------|------------|---------|
| Wiktionary | 0.95 | Community curation, definition focus |
| Wikipedia | 0.90 | Editorial oversight, references |
| Reddit | 0.40-0.80 | Upvotes, engagement, subreddit quality |
| YouTube | 0.60-0.90 | Views, likes, educational content |
| Urban Dictionary | 0.10-0.60 | Community votes, content filtering |

## Configuration Examples

### Basic Configuration (No API Keys)
```bash
# Uses Wikipedia + Wiktionary (free, reliable)
# No additional configuration needed
```

### Enhanced Configuration (With APIs)
```bash
# YouTube integration
YOUTUBE_API_KEY=AIzaSyC...

# Reddit integration  
REDDIT_CLIENT_ID=abc123...
REDDIT_CLIENT_SECRET=xyz789...
REDDIT_USER_AGENT=Larry-VocabApp/1.0 by /u/YourUsername

# Optional admin customization
ADMIN_KEY=your_secure_admin_key
```

## Testing

Run the provider integration test:

```bash
node test-real-providers.mjs
```

This test verifies:
- Provider API connectivity
- Content discovery functionality
- Job queue processing
- Source storage and retrieval
- Multi-provider coordination

## Monitoring

### Metrics Tracked

- `docs_ingested_total{type, source, status}`: Content ingestion by provider
- `provider_requests_total{provider, status}`: API request tracking
- `provider_latency_seconds{provider}`: Response time monitoring
- `content_quality_score{provider}`: Average quality by source

### Health Checks

- Provider API availability
- Authentication status (YouTube, Reddit)
- Rate limiting compliance
- Content quality thresholds

## Rate Limiting & Respectful Usage

### Wikipedia/Wiktionary
- Built-in request throttling
- User-Agent identification
- Terms of service compliance

### YouTube Data API
- Daily quota management (10,000 units default)
- Request optimization
- Caching strategies

### Reddit API
- OAuth token refresh handling
- Rate limit headers respected
- Community guidelines compliance

### Urban Dictionary
- Request throttling
- Content filtering
- Terms of service adherence

## Future Enhancements

### Planned Improvements

1. **YouTube Transcript Integration**
   - OAuth2 setup for caption downloads
   - Transcript processing and segmentation
   - Speaker identification and context

2. **Advanced Reddit Features**
   - Subreddit-specific targeting
   - Thread conversation analysis
   - Author expertise scoring

3. **Additional Providers**
   - Stack Overflow Q&A
   - Academic paper abstracts
   - News article integration
   - Domain-specific glossaries

4. **Enhanced Quality Scoring**
   - Machine learning-based scoring
   - User feedback integration
   - Context-aware reliability

5. **Real-time Processing**
   - Live content monitoring
   - Trending topic detection
   - Breaking vocabulary identification

## Troubleshooting

### Common Issues

**Wikipedia/Wiktionary not working**:
- Check network connectivity
- Verify User-Agent string
- Review API status pages

**YouTube API errors**:
- Validate API key
- Check quota usage
- Review enabled APIs in Google Console

**Reddit authentication fails**:
- Verify client credentials
- Check user agent format
- Confirm application permissions

**Urban Dictionary content filtered**:
- Review content filtering settings
- Check minimum quality thresholds
- Verify topic appropriateness

### Debug Mode

Enable detailed logging:
```bash
DEBUG=larry:providers node your-app.js
```

This provides detailed information about:
- Provider selection logic
- API request/response details
- Content filtering decisions
- Quality scoring calculations

## Contributing

When adding new providers:

1. **Implement SourceAdapter interface**
2. **Add comprehensive error handling**
3. **Include quality scoring logic**
4. **Implement respectful rate limiting**
5. **Add configuration documentation**
6. **Create integration tests**
7. **Update monitoring metrics**

See `scraper/src/adapters/` for implementation examples.
