# Larry - AI-Powered Vocabulary App

An AI-powered vocabulary app built with **React Native (Expo)** on the frontend and **Node.js (Express)** on the backend. The app personalizes vocabulary based on the user's profession, goals, hobbies, travel plans, and communities, delivering 1–3 relevant words per day and enabling deeper exploration via "Larry Chat," an AI-powered topic coach.

## 🏗️ Architecture

### Frontend (React Native + Expo)
- **Framework**: React Native with Expo
- **Navigation**: Expo Router
- **State Management**: Zustand
- **Data Fetching**: React Query
- **Authentication**: Direct OAuth (Apple/Google)

### Backend (Node.js + Express)
- **Framework**: Express.js with TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Cache**: Redis
- **Authentication**: JWT tokens
- **AI Integration**: OpenAI API
- **Background Jobs**: BullMQ

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Database Persistence**: Docker volumes
- **Auto-Backup**: Every 30 minutes
- **Development**: Local development environment

## 🚀 Quick Start

### Prerequisites
- Docker Desktop
- Node.js 18+
- pnpm

### 1. Clone and Setup
```bash
git clone <your-repo>
cd larry
pnpm install
```

### 2. Start All Services
```bash
# Start everything (database, backend, frontend)
docker compose up -d

# Start frontend separately
cd larry-app
npm start
```

### 3. Access Services
- **Frontend**: http://localhost:8081 (Expo DevTools)
- **Backend API**: http://localhost:4000
- **Database**: localhost:5433 (PostgreSQL)
- **pgAdmin**: http://localhost:5050 (admin@larry.com / admin123)

## 📱 Features

### Core Features
- **Daily Words**: Personalized vocabulary delivery
- **Onboarding**: Interest selection and notification setup
- **Authentication**: Apple/Google OAuth
- **Wordbank**: History and favorites
- **Profile Management**: User preferences and settings

### AI Features
- **Word Generation**: OpenAI-powered vocabulary creation
- **Content Scraping**: Wikipedia, YouTube, Reddit integration
- **Quality Rating**: Self and user quality assessment
- **Spaced Repetition**: Intelligent word scheduling

### Technical Features
- **Persistent Database**: Data survives restarts
- **Auto-Backup**: Every 30 minutes with retention
- **Docker Setup**: Complete containerized environment
- **Type Safety**: Full TypeScript implementation

## 🗄️ Database

### Persistence
Your database is **fully persistent** and will survive:
- Container restarts
- Docker restarts
- Computer restarts
- Backend rebuilds

### Backup System
- **Auto-backup**: Every 30 minutes via Docker service
- **Manual backup**: `pnpm db:backup:enhanced`
- **Retention**: 7 days with auto-cleanup
- **Compression**: Gzip compression for space efficiency

### Management Commands
```bash
# Check database status
docker compose exec postgres psql -U jacquesbloom -d larry

# View backup logs
docker compose logs backup

# Manual backup
pnpm db:backup:enhanced

# Setup cron-based backup
pnpm db:backup:setup-auto
```

## 🔧 Development

### Available Scripts
```bash
# Database
pnpm db:backup              # Basic backup
pnpm db:backup:enhanced     # Enhanced backup with compression
pnpm db:backup:setup-auto   # Setup cron-based backup

# Testing
pnpm test                   # Run backend tests
pnpm test:run              # Run tests without coverage
pnpm test:acceptance       # Run acceptance tests
pnpm test:coverage         # Run tests with coverage

# Development
pnpm dev                    # Start development servers
```

### Docker Commands
```bash
# Start all services
docker compose up -d

# Start specific service
docker compose up -d backend

# View logs
docker compose logs backend
docker compose logs postgres
docker compose logs backup

# Restart service
docker compose restart backend

# Rebuild and restart
docker compose up backend --build
```

### Database Commands
```bash
# Connect to database
docker compose exec postgres psql -U jacquesbloom -d larry

# Run Prisma commands
docker compose exec backend npx prisma studio
docker compose exec backend npx prisma migrate dev

# View database tables
docker compose exec postgres psql -U jacquesbloom -d larry -c "\dt"
```

## 📊 API Endpoints

### Authentication
- `POST /apple` - Apple OAuth
- `POST /google/start` - Google OAuth start
- `GET /google/callback` - Google OAuth callback
- `POST /signout` - Sign out

### Daily Words
- `GET /daily` - Get daily word
- `POST /learn-again` - Mark word for review
- `POST /actions/favorite` - Favorite a word

### User Management
- `GET /profile` - Get user profile
- `POST /user/interests` - Save user interests
- `POST /user/notifications` - Save notification preferences

### Interests
- `GET /interests` - Get available interests
- `GET /user/interests` - Get user interests

### Admin
- `POST /admin/seed-topic` - Seed topic with words
- `POST /admin/ingest` - Ingest content
- `GET /health` - Health check

## 🔒 Security & Data

### Authentication Flow
1. User signs in with Apple/Google
2. Backend validates OAuth token
3. JWT tokens issued for session
4. User data persisted in PostgreSQL

### Data Protection
- **Persistent Storage**: Docker volumes
- **Regular Backups**: Every 30 minutes
- **Encryption**: JWT tokens for sessions
- **Validation**: Zod schema validation

### Environment Variables
```bash
# Required
DATABASE_URL=postgresql://jacquesbloom:password@postgres:5432/larry
REDIS_URL=redis://redis:6379
OPENAI_API_KEY=your_openai_key
JWT_SECRET=your_jwt_secret

# OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

## 📚 Documentation

- [Database Setup](./docs/dev-db-notes.md) - Database persistence and backup
- [API Documentation](./docs/API.md) - Detailed API reference
- [Deployment Guide](./docs/DEPLOYMENT.md) - Production deployment

## 🚨 Important Notes

### Data Safety
- **DO NOT** run `docker volume rm larry_postgres_data` - deletes all data
- **DO NOT** run `prisma migrate reset` - wipes database
- **DO NOT** run `docker compose down -v` - removes volumes

### Backup Safety
- Backups run automatically every 30 minutes
- 7-day retention with auto-cleanup
- Manual backups available anytime
- Backup files stored in `backups/` directory

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Test thoroughly
4. Commit with descriptive messages
5. Push and create a pull request

## 📄 License

[Your License Here]

---

**Larry** - Making vocabulary learning personal and engaging through AI-powered content discovery.
