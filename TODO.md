## Project TODO (Prioritized)

Priority convention:
- P1 = Critical/Next up
- P2 = Important/This sprint
- P3 = Nice-to-have/Upcoming

Add new action items under the correct section with a short, outcome-focused description. Keep items small and testable.

---

### P1
- [ ] Analytics Integration: Connect to PostHog/Amplitude
  - Configure API keys/secrets in env for app and backend
  - Wire `lib/analytics.ts` to provider SDK (identify, track, flush)
  - Verify key auth events flow into dashboards (start/success/failure, email_link_*)

- [ ] Backend Integration: Switch from mock to real API
  - Point `API_BASE_URL` to the real backend
  - Ensure `/auth/google`, `/auth/apple`, `/auth/email/*`, `/auth/refresh` match contract
  - Enable JWT verification and DB upserts (Prisma) in production
  - Validate `/health` and basic auth flows against real server

### P2
- [ ] Email Service: Integrate real provider (SendGrid/Resend/etc.)
  - Verify domain + sender, add secrets to backend
  - Implement transactional template for magic link
  - Add rate limiting + basic abuse protection (captcha or token bucket)
  - QA: open link via universal link (https) and app scheme (larry://)

- [ ] Testing: E2E auth + deep links
  - Web: Google OAuth real creds, email magic link
  - iOS/Android: Google/Apple flows, deep link callbacks
  - Unit tests for validation + reducers; integration tests for auth endpoints
  - QA matrix coverage (cancelled flows, offline/airplane, token refresh, 401 soft-logout)

### P3
- [ ] Production: Deploy with real OAuth credentials
  - Add redirect URIs in Google/Apple consoles (web + native)
  - EAS builds (iOS/Android); configure secrets + env in CI
  - Enable OTA updates and basic monitoring/alerts
  - Final pass on error copy and UX polish for auth screens

- [ ] **AUTH SYSTEM ENHANCEMENTS** (Post-Auth Success)
  - [ ] Replace ngrok with real domain for production OAuth
  - [ ] Add email authentication if needed
  - [ ] Implement password reset functionality  
  - [ ] Add user profile editing features
  - [ ] Add email verification for new accounts
  - [ ] Implement account deletion with data cleanup

---

Notes
- The authentication system is complete and production-ready from the app’s perspective. Switch to the real backend and email provider to go live.
- When adding future "next steps", append them here with P1–P3 and concrete acceptance criteria.

# Larry Development TODOs

## 🚨 Immediate Fixes Needed

### Database Schema Issues
- [ ] **URGENT**: Fix Prisma schema for test files
  - Add missing fields: `slug`, `source`, `content` to appropriate models
  - Update `Term` model with missing fields
  - Update `TermAnnotation` model structure
  - Re-run `pnpm prisma generate` after schema fixes

### TypeScript Compilation Errors
- [ ] **URGENT**: Fix test file type errors
  - `api/src/integration/database.integration.test.ts` (31 errors)
  - `api/src/services/extract.*.test.ts` (multiple errors)
  - Update mock implementations to match current Prisma schema

### Worker Integration
- [ ] **HIGH**: Complete provider adapter integration
  - Uncomment real adapter imports in `fetch.worker.ts`
  - Add Stack Overflow adapter to worker initialization
  - Test provider discovery pipeline end-to-end

## 🔧 Core Features

### Authentication & Security
- [ ] Update admin authentication to use `ADMIN_SIGNING_KEY`
- [ ] Verify cost gate middleware is working
- [ ] Test rate limiting on all endpoints
- [ ] Validate JWT token handling for user authentication

### Vocabulary Pipeline
- [ ] **TODO**: Complete seed worker implementation
  - File: `api/src/workers/seed.worker.ts`
  - Function: Add tags and relationships to seeded terms
  - Related: `api/src/services/tagsAndGraph.ts`

- [ ] **TODO**: Enhance extract worker
  - File: `api/src/workers/extract.worker.ts`
  - Function: Integrate tags and graph edges after term creation
  - Related: `extractTagsAndRelationships`, `storeTermTags`, `storeTermRelationships`

- [ ] **TODO**: Implement embeddings (optional)
  - Install pgvector: `CREATE EXTENSION vector;`
  - Add dependency: `pnpm add pgvector`
  - Uncomment embedding field in Prisma schema
  - Implement embedding generation in `tagsAndGraph.ts`
  - Create `/terms/:id/related` endpoint using vector similarity

### Content Discovery
- [ ] **TODO**: Test real provider implementations
  - Run: `node test-real-providers.mjs`
  - Verify Wikipedia, YouTube, Reddit, Stack Overflow, Urban Dictionary
  - Check API key configuration for YouTube and Reddit

### Quality & Testing
- [ ] **TODO**: Fix integration test failures
  - Database schema mismatch issues
  - Mock implementation updates
  - Prisma client type errors

- [ ] **TODO**: Add acceptance tests for new features
  - Provider integrations
  - Stack Overflow adapter
  - Enhanced cost management
  - Real-time content pipeline

## 📊 Monitoring & Operations

### Metrics & Observability
- [ ] Verify Prometheus metrics endpoint (`/metrics`)
- [ ] Test metrics collection across all workers
- [ ] Validate cost tracking and token usage logging
- [ ] Monitor job queue performance and error rates

### Performance Optimization
- [ ] **TODO**: Optimize provider discovery concurrency
  - File: `api/src/workers/contentDiscovery.worker.ts`
  - Function: Balance API rate limits vs. speed
  - Related: Provider-specific rate limiting

- [ ] **TODO**: Implement caching for expensive operations
  - Provider discovery results
  - OpenAI API responses (where appropriate)
  - Wikipedia/Stack Overflow content

## 🎯 Developer Experience

### Cursor Integration
- [x] Create `.cursortasks` for one-click operations
- [x] Document TODO items for multi-edit functionality
- [ ] **TODO**: Set up debugging configurations
  - VS Code launch configurations
  - Environment variable templates
  - Docker compose for dependencies

### Documentation
- [ ] **TODO**: Update API documentation
  - Document new provider integrations
  - Add Stack Overflow adapter documentation
  - Update rate limiting and authentication docs

- [ ] **TODO**: Create deployment guide
  - Environment setup requirements
  - API key configuration
  - Database setup and migrations
  - Redis configuration

## 🔮 Future Enhancements

### Provider Ecosystem
- [ ] **FUTURE**: Add news API integration (NewsAPI, Reuters)
- [ ] **FUTURE**: Academic paper abstracts (arXiv, PubMed)
- [ ] **FUTURE**: RSS/Atom feed parsing for topic-specific content
- [ ] **FUTURE**: Stack Overflow specific improvements:
  - Tag-based filtering
  - Reputation-based quality scoring
  - Code example extraction and processing

### AI & ML Features
- [ ] **FUTURE**: Implement semantic embeddings with pgvector
  - Benefits: Better term relationships, semantic search
  - Requirements: PostgreSQL with pgvector extension
  - Implementation: Embedding generation in extraction pipeline

- [ ] **FUTURE**: Enhanced AI processing
  - Context-aware definition generation
  - Industry-specific vocabulary detection
  - Difficulty level prediction improvements

### Mobile App Integration
- [ ] **FUTURE**: Complete Expo app implementation
- [ ] **FUTURE**: WorkOS authentication flow
- [ ] **FUTURE**: Deep linking for vocabulary delivery
- [ ] **FUTURE**: Offline support and sync

---

## 🚀 Quick Commands

### Fix Immediate Issues
```bash
# Fix database schema
cd api && pnpm prisma generate && pnpm prisma migrate dev

# Run TypeScript check
cd api && npx tsc --noEmit

# Start development server
cd api && pnpm dev:tsx
```

### Test Everything
```bash
# Health check
curl -s http://localhost:4000/healthz | jq .

# Test provider discovery
curl -X POST http://localhost:4000/admin/discover-content \
  -H 'x-admin-key: admin_key' \
  -H 'Content-Type: application/json' \
  -d '{"topic": "programming", "maxSources": 5}' | jq .

# Run tests
cd api && pnpm test
```

### Debug Issues
```bash
# Check server health and routes
./scripts/debug-routes.sh

# View metrics
curl -s http://localhost:4000/metrics

# Check cost status
curl -s http://localhost:4000/admin/cost/status -H 'x-admin-key: admin_key' | jq .
```
