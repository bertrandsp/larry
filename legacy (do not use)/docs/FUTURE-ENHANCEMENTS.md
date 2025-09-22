# Future Enhancements & Roadmap

This document tracks planned enhancements and features for the Larry vocabulary platform.

## 🔮 Planned Features

### 🧠 Semantic Embeddings (pgvector)
**Status**: Pending Implementation  
**Priority**: Medium  
**Complexity**: High  

#### Overview
Add vector embeddings to enable advanced semantic search and improved term relationships.

#### Benefits
- **Semantic similarity search** - Find terms by meaning, not just text matching
- **Better relationship discovery** - Mathematical similarity beyond AI relationships
- **Fuzzy matching** - Connect conceptually related terms automatically
- **"More like this" functionality** - Enhanced recommendations
- **Search by example** - Find terms similar to a given definition

#### Implementation Requirements

1. **Database Setup**
   ```sql
   -- Enable pgvector extension in PostgreSQL
   CREATE EXTENSION vector;
   ```

2. **Dependencies**
   ```bash
   # Install pgvector Node.js client
   npm install pgvector
   ```

3. **Schema Updates**
   ```prisma
   model Term {
     // ... existing fields
     embedding Unsupported("vector(1536)")? // OpenAI embedding
   }
   ```

4. **Service Implementation**
   - Generate embeddings using OpenAI API
   - Store embeddings during term creation
   - Implement similarity search queries
   - Add embedding-based relationship discovery

5. **API Endpoints**
   - `GET /terms/similar?query=...` - Semantic search
   - `GET /terms/:id/similar` - Find similar terms by embedding
   - Enhanced `/terms/:id/related` with embedding data

#### Code Locations
- **Service**: `api/src/services/embeddings.ts` (to be created)
- **Integration**: Update `api/src/services/tagsAndGraph.ts`
- **Schema**: `api/prisma/schema.prisma`
- **Routes**: Update `api/src/routes/related.ts`

#### Acceptance Criteria
- [ ] pgvector extension installed and working
- [ ] Embeddings generated for all new terms
- [ ] Semantic similarity search functional
- [ ] Performance acceptable for 10k+ terms
- [ ] Backward compatibility maintained

---

### 📱 Mobile App Development
**Status**: Not Started  
**Priority**: High  
**Complexity**: High  

#### Overview
Complete the React Native mobile app with Expo Router.

#### Key Features
- [ ] Onboarding flow with WorkOS auth
- [ ] Daily vocabulary delivery
- [ ] Larry Chat AI interaction
- [ ] Wordbank (favorites, history, mastery)
- [ ] Interest management
- [ ] Offline support
- [ ] Push notifications

---

### 🔐 Enhanced Authentication
**Status**: Partially Implemented  
**Priority**: Medium  
**Complexity**: Medium  

#### Planned Improvements
- [ ] Complete WorkOS mobile OAuth flow
- [ ] JWT refresh token rotation
- [ ] Session management
- [ ] Multi-device support
- [ ] Social login providers (Apple, Google)

---

### 📊 Advanced Analytics
**Status**: Basic Implementation  
**Priority**: Medium  
**Complexity**: Medium  

#### Planned Features
- [ ] User learning analytics
- [ ] Vocabulary mastery tracking
- [ ] A/B testing framework
- [ ] Content performance metrics
- [ ] Recommendation effectiveness

---

### 🎨 Content Management
**Status**: Basic Implementation  
**Priority**: Low  
**Complexity**: Medium  

#### Planned Features
- [ ] Admin dashboard for content curation
- [ ] Bulk vocabulary import/export
- [ ] Content moderation tools
- [ ] Topic management interface
- [ ] Quality scoring system

---

## 🛠️ Technical Debt

### Performance Optimizations
- [ ] Database query optimization
- [ ] Caching layer (Redis)
- [ ] CDN for static assets
- [ ] Image optimization
- [ ] Bundle size optimization

### Code Quality
- [ ] Comprehensive test coverage (>80%)
- [ ] TypeScript strict mode compliance
- [ ] ESLint/Prettier enforcement
- [ ] Documentation completion
- [ ] API versioning strategy

### Infrastructure
- [ ] CI/CD pipeline setup
- [ ] Staging environment
- [ ] Production deployment
- [ ] Monitoring and alerting
- [ ] Backup and disaster recovery

---

## 📋 Implementation Guidelines

### Prioritization Framework
1. **User Impact** - Features that directly improve user experience
2. **Technical Risk** - Address high-risk technical debt first
3. **Business Value** - Revenue or retention impact
4. **Development Effort** - Consider implementation complexity

### Feature Flag Strategy
- Use feature flags for gradual rollouts
- A/B test new features with user segments
- Maintain backward compatibility
- Monitor feature adoption and performance

### Documentation Requirements
- Update this document when starting new features
- Document API changes in respective endpoint docs
- Update README with new setup requirements
- Maintain changelog for releases

---

## 🔄 Current Status

**Last Updated**: August 15, 2025  
**Current Sprint**: Task 6E (Tags & Graph) - ✅ Completed  
**Next Priority**: Mobile app development or backend completion  

### Recently Completed
- ✅ Tags and graph relationship system
- ✅ Related terms API endpoints
- ✅ Real-time content pipeline
- ✅ Human review queue
- ✅ File upload support
- ✅ Comprehensive metrics

### In Progress
- 🔄 Acceptance testing framework
- 🔄 API documentation

### Blocked/Waiting
- ⏸️ Mobile app (pending backend completion)
- ⏸️ Production deployment (pending infrastructure)
