# 🎯 Cursor Developer Ergonomics Guide

*Complete guide to efficient Larry development using Cursor IDE*

## 🚀 **One-Click Operations** 

### Using Cursor Tasks (Cmd/Ctrl + Shift + P → "Tasks: Run Task")

**Essential Development Tasks:**
- **Start API Server** → Launches dev server with hot reload
- **Open Prisma Studio** → Database inspection and management  
- **Health Check** → Verify API server status
- **TypeScript Check** → Validate code without compilation

**Vocabulary Operations:**
- **Seed Topic (Machine Learning)** → Generate 10 ML terms  
- **Ingest Topic (AI)** → Discover and process AI content
- **Check Daily Endpoint** → Test vocabulary selection
- **Review Queue Status** → Check pending terms

**Provider & Content Discovery:**
- **Discover Content** → Multi-provider content discovery
- **View Metrics** → Prometheus metrics dashboard
- **Cost Gate Status** → OpenAI usage monitoring

**Database & Infrastructure:**
- **Generate Database Migration** → Schema changes
- **Reset Database** → Fresh start (DESTRUCTIVE)
- **Start/Stop Redis** → Job queue management

**Debugging & Testing:**
- **Run All Tests** → Comprehensive test suite
- **Debug Routes** → Automated 404 issue resolution

---

## 🔍 **Multi-Edit Workflows**

### TODO Management (`Cmd/Ctrl + P` → Search "TODO")

**High-Priority TODOs:**
```typescript
// TODO: Complete provider adapter integration
// Location: api/src/workers/fetch.worker.ts:8-15
// Action: Uncomment real adapter imports

// TODO: Add Stack Overflow to worker initialization  
// Location: api/src/workers/fetch.worker.ts:40
// Action: Add stackoverflow: createStackOverflowAdapter(),

// TODO: Test real provider implementations
// Location: Root directory
// Action: Run `node test-real-providers.mjs`

// TODO: Fix integration test failures
// Location: api/src/integration/database.integration.test.ts
// Action: Update Prisma field references (source, slug, content)
```

### Quick Multi-Edit Commands
1. **Cmd/Ctrl + P** → Type "TODO" → Jump to each TODO tag
2. **Cmd/Ctrl + D** → Select matching text for batch edits
3. **Cmd/Ctrl + Shift + L** → Select all occurrences
4. **Alt + Click** → Multiple cursor placement

---

## 🤖 **Ask Cursor Features**

### Context-Aware Code Generation

**Select code block + Ask Cursor:**

**1. Provider Implementation:**
```typescript
// Select this block in fetch.worker.ts and ask:
// "Generate missing Stack Overflow adapter integration"

const adapters = {
  wikipedia: createWikipediaAdapter(),
  wiktionary: createWiktionaryAdapter(),
  // ADD STACKOVERFLOW HERE
};
```

**2. Worker Enhancement:**
```typescript
// Select worker function and ask:
// "Add error handling and retry logic for provider failures"

export const contentDiscoveryWorker = new Worker(/* ... */);
```

**3. Test Generation:**
```typescript
// Select service function and ask:
// "Generate comprehensive unit tests for this function"

export async function extractAndStoreTerm(/* ... */) {
  // ...function implementation
}
```

### Smart Completions
- **Type `// TODO:`** → Cursor suggests implementation
- **Import statements** → Auto-completion for providers/adapters
- **Prisma queries** → Schema-aware suggestions
- **TypeScript types** → Inferred from context

---

## 📁 **File Navigation Shortcuts**

### Quick Access (`Cmd/Ctrl + P`)
```
# Core Files
index.ts        → Main API server
admin.ts        → Admin routes & authentication  
extract.ts      → Vocabulary extraction service
fetch.worker.ts → Content fetching worker

# Provider System
wikipedia.ts    → Wikipedia/Wiktionary adapter
stackoverflow.ts → Stack Overflow adapter (NEW)
youtube.ts      → YouTube Data API adapter
reddit.ts       → Reddit API adapter

# Database & Schema
schema.prisma   → Database models & relationships
extract.test.ts → Unit tests for extraction
database.integration.test.ts → DB integration tests

# Configuration
.cursortasks    → One-click operations
TODO.md         → Multi-edit task tracking
ACCEPTANCE-STATUS.md → Production readiness
```

### Directory Structure Navigation
```
larry/
├── api/          → Backend API (Express + TypeScript)
├── app/          → Mobile app (Expo + React Native)  
├── scraper/      → Content discovery microservice
├── docs/         → Documentation & guides
├── scripts/      → Automation & debugging tools
└── test-*.mjs    → Integration test scripts
```

---

## 🔧 **Development Workflows**

### 1. **New Provider Integration**
```bash
# 1. Create adapter (use existing as template)
cp scraper/src/adapters/wikipedia.ts scraper/src/adapters/newprovider.ts

# 2. Update fetch worker (Ask Cursor to integrate)
# Select adapters object in fetch.worker.ts
# Ask: "Add newprovider adapter to this configuration"

# 3. Test integration
node test-real-providers.mjs

# 4. Update documentation  
# Ask Cursor: "Document this new provider in PROVIDER-INTEGRATIONS.md"
```

### 2. **New Vocabulary Feature**
```bash
# 1. Update Prisma schema
# Add field to Term model in schema.prisma

# 2. Generate migration
# Task: "Generate Database Migration"

# 3. Update extract service
# Ask Cursor: "Modify extractAndStoreTerm to handle new field"

# 4. Add tests
# Ask Cursor: "Generate tests for this new feature"
```

### 3. **Debug Route Issues**
```bash
# 1. Run automated debugging
# Task: "Debug Routes"

# 2. Check TypeScript compilation  
# Task: "TypeScript Check"

# 3. Verify server status
# Task: "Health Check"

# 4. Test specific endpoints
# Use .cursortasks for endpoint testing
```

---

## 🧪 **Testing Strategies**

### Cursor-Integrated Testing

**1. Test-Driven Development:**
```typescript
// Write test first, then Ask Cursor:
// "Implement the function that makes this test pass"

describe('extractAndStoreTerm', () => {
  it('should create term with tags and relationships', async () => {
    // Test implementation
  });
});
```

**2. Golden File Testing:**
```bash
# Update golden files after changes
cd api && pnpm test:golden

# Ask Cursor to fix failed tests:
# "Update golden file assertions to match new output format"
```

**3. Integration Testing:**
```bash
# Run comprehensive tests
cd api && pnpm test:advanced

# Focus on specific test types
pnpm test:unit        # Fast feedback loop
pnpm test:performance # Optimization validation  
pnpm test:memory      # Resource leak detection
```

---

## 📊 **Monitoring & Observability**

### Real-Time Development Monitoring

**1. Metrics Dashboard (while developing):**
```bash
# Task: "View Metrics" → Opens Prometheus endpoint
# Monitor: Request counts, error rates, performance
```

**2. Cost Management:**
```bash  
# Task: "Cost Gate Status" → OpenAI usage tracking
# Monitor: Token consumption, spending limits
```

**3. Job Queue Health:**
```bash
# Task: "Review Queue Status" → Background job monitoring
# Monitor: Pending jobs, processing rates, failures
```

### Development Insights
- **API Request Timing** → Response time optimization
- **Worker Performance** → Background job efficiency  
- **Provider Quality Scores** → Content source effectiveness
- **Memory Usage** → Resource leak detection

---

## 🎯 **Pro Tips for Maximum Productivity**

### 1. **Context-Aware Development**
- Always select relevant code before asking Cursor questions
- Use multi-cursor editing for repetitive provider integrations
- Leverage TODO.md for systematic multi-edit workflows

### 2. **Rapid Prototyping**
- Use .cursortasks for instant API testing during development
- Ask Cursor to generate mock data for faster iteration
- Utilize golden tests to catch regressions early

### 3. **Production Readiness**
- Run `./scripts/debug-routes.sh` before commits
- Use TypeScript checks to catch issues early
- Monitor metrics during development to optimize performance

### 4. **Collaboration & Documentation**
- Update TODO.md as you implement features
- Use Ask Cursor to generate documentation
- Maintain ACCEPTANCE-STATUS.md for stakeholder updates

---

## 🚀 **Next Steps**

### Immediate Development (Using Cursor)
1. **Ask Cursor:** "Help me test the provider implementations"
2. **Multi-Edit:** Update all TODO items in fetch.worker.ts
3. **Task:** Run "Discover Content" to test multi-provider pipeline
4. **Ask Cursor:** "Generate performance benchmarks for vocabulary extraction"

### Mobile App Development (Future)
1. **Ask Cursor:** "Create Expo app structure for Larry"
2. **Multi-Edit:** Set up WorkOS authentication flow
3. **Task:** Integration testing between API and mobile app

---

*This guide transforms Larry development into a streamlined, AI-assisted experience. Use Cursor's intelligence to accelerate implementation while maintaining production-quality code.* 🎯✨
