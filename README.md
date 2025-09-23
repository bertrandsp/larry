# Larry - AI-Powered Vocabulary Learning App

Larry is an AI-powered vocabulary app that teaches lingo relevant to a user's career, hobbies, travels, and communities. Users receive 1–3 personalized words per day and explore topics deeper via "Larry Chat," an AI-powered coach.

## 🏗️ Project Structure

```
larry/
├── larry-ios/                    # iOS App (SwiftUI)
│   ├── larry-ios/               # Main iOS app code
│   ├── admin frontend/          # Admin content generation interface
│   └── larry-ios.xcodeproj/     # Xcode project files
├── super-api/                   # Backend API (Node.js + TypeScript)
└── README.md                    # This file
```

## 🚀 Components Overview

### 1. iOS App (`larry-ios/`)
A SwiftUI-based iOS application with 5 core screens:
- **Onboarding**: User interest selection and topic weighting
- **Home**: Daily vocabulary delivery with spaced repetition
- **Larry Chat**: AI-powered conversation about vocabulary
- **Wordbank**: History, favorites, and "want to master" terms
- **Interests**: Topic weighting and preference management

### 2. Admin Frontend (`admin frontend/`)
A web-based admin interface for content generation:
- **AI Content Generation**: Create vocabulary terms and facts
- **Advanced Controls**: Fine-tune AI parameters and generation settings
- **Database Integration**: All generated content is automatically saved
- **Real-time Preview**: See generated content before saving

### 3. Backend API (`super-api/`)
A Node.js/TypeScript backend with:
- **OpenAI Integration**: GPT-4 powered content generation
- **Database Management**: Prisma ORM with PostgreSQL
- **Authentication**: WorkOS integration for user management
- **Content Pipeline**: Spaced repetition and duplicate prevention

## 🛠️ Prerequisites

Before running any component, ensure you have:

- **Node.js** (v18 or higher)
- **npm** or **pnpm**
- **PostgreSQL** (running locally or via Docker)
- **Redis** (for caching and queues)
- **Xcode** (for iOS development)
- **iOS Simulator** or physical iOS device

## 📱 Running the iOS App

### Option 1: Xcode (Recommended)
1. Open `larry-ios/larry-ios.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

### Option 2: Command Line
```bash
cd larry-ios
xcodebuild -project larry-ios.xcodeproj -scheme larry-ios -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### iOS App Features
- **MVVM Architecture**: Clean separation of concerns
- **Combine Framework**: Reactive programming for API calls
- **Keychain Integration**: Secure token storage
- **Dynamic Type Support**: Accessibility compliance
- **Universal Links**: Deep linking support

## 🌐 Running the Admin Frontend

The admin frontend is a standalone HTML file with embedded JavaScript and Tailwind CSS.

### Quick Start
1. **Start the backend API** (see Backend API section below)
2. **Open the admin interface**:
   ```bash
   cd "admin frontend"
   open index.html
   ```
   Or simply double-click `index.html` in Finder

### Admin Frontend Features
- **Real-time AI Generation**: Generate vocabulary content instantly
- **Advanced Parameter Controls**:
  - Definition style (formal, casual, technical)
  - Term selection level (beginner, intermediate, advanced)
  - Definition complexity
  - Number of examples and facts
  - Domain context and language settings
  - Rich metadata options (analogies, synonyms, antonyms, etymology)
- **Database Integration**: All content automatically saved
- **Dynamic Topic Creation**: New topics created for each subject area

### Usage
1. Enter a topic (e.g., "Quantum Computing", "Astrobiology")
2. Configure generation parameters
3. Click "Generate Content"
4. Review the generated terms and facts
5. Content is automatically saved to the database

## 🔧 Running the Backend API

### Environment Setup
1. **Copy environment template**:
   ```bash
   cd super-api
   cp .env.example .env
   ```

2. **Configure your `.env` file**:
   ```env
   DATABASE_URL="postgresql://username:password@localhost:5432/larry"
   REDIS_URL="redis://localhost:6379"
   PORT=4001
   NODE_ENV=development
   JWT_SECRET="your-jwt-secret"
   OPENAI_API_KEY="your-openai-api-key"
   ADMIN_KEY="your-admin-key"
   ADMIN_SECRET="your-admin-secret"
   ```

### Database Setup
1. **Start PostgreSQL** (using Docker recommended):
   ```bash
   docker run --name larry-postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=larry -p 5432:5432 -d postgres:15
   ```

2. **Run database migrations**:
   ```bash
   cd super-api
   npx prisma migrate dev
   npx prisma generate
   ```

3. **Seed the database** (optional):
   ```bash
   npx prisma db seed
   ```

### Start the Backend
```bash
cd super-api
npm install
npm run dev
```

The API will be available at `http://localhost:4001`

### Backend API Endpoints
- `GET /health` - Health check
- `POST /generate` - Generate vocabulary content
- `GET /daily` - Get daily vocabulary for user
- `POST /actions/favorite` - Mark term as favorite
- `POST /actions/learn-again` - Reset term for review
- `GET /topics` - Get available topics
- `POST /auth/mobile/start` - Start OAuth flow
- `GET /auth/mobile/callback` - OAuth callback

## 🗄️ Database Management

### Prisma Studio
View and manage your database with Prisma Studio:
```bash
cd super-api
npx prisma studio --port 5556
```
Open `http://localhost:5556` in your browser.

### Database Schema
- **Users**: User accounts and preferences
- **Topics**: Subject areas for vocabulary
- **Terms**: Individual vocabulary words with definitions
- **Facts**: Interesting facts related to topics
- **CanonicalSets**: Groups of related terms
- **UserProgress**: Learning progress and spaced repetition data

## 🔄 Development Workflow

### 1. Start All Services
```bash
# Terminal 1: Backend API
cd super-api
npm run dev

# Terminal 2: Database (if using Docker)
docker start larry-postgres

# Terminal 3: iOS App
# Open in Xcode and run
```

### 2. Generate Content
1. Open admin frontend (`admin frontend/index.html`)
2. Generate vocabulary for different topics
3. Verify content in Prisma Studio
4. Test in iOS app

### 3. Test iOS Integration
1. Ensure backend is running on `http://localhost:4001`
2. Run iOS app in simulator
3. Test authentication and content loading

## 🧪 Testing

### Backend API Testing
```bash
cd super-api
npm test
```

### iOS App Testing
- Use Xcode's built-in testing framework
- Run unit tests: `Cmd + U` in Xcode
- UI tests available in `larry-iosUITests/`

## 📊 Monitoring and Logs

### Backend Logs
```bash
cd super-api
tail -f logs/combined.log
```

### Database Monitoring
- Use Prisma Studio for real-time database inspection
- Monitor query performance in logs

## 🚀 Deployment

### Backend Deployment
1. Set production environment variables
2. Run database migrations
3. Deploy to your preferred platform (Vercel, Railway, etc.)

### iOS App Deployment
1. Configure production API endpoints
2. Update bundle identifier and signing
3. Archive and upload to App Store Connect

## 🔐 Security

- **API Keys**: Never commit real API keys to version control
- **Environment Variables**: Use `.env` files for local development
- **Database**: Use strong passwords and connection encryption
- **Authentication**: JWT tokens with proper expiration

## 📚 Key Features

### AI-Powered Content Generation
- **GPT-4 Integration**: High-quality vocabulary explanations
- **Contextual Learning**: Terms relevant to user interests
- **Rich Metadata**: Examples, analogies, synonyms, etymology
- **Quality Control**: Duplicate prevention and validation

### Spaced Repetition System
- **Leitner Method**: Optimized learning intervals
- **Progress Tracking**: Monitor learning effectiveness
- **Adaptive Difficulty**: Adjust based on user performance

### User Experience
- **Personalized Content**: Based on interests and career
- **Offline Support**: Cached content for offline learning
- **Accessibility**: Dynamic Type and VoiceOver support
- **Modern UI**: SwiftUI with smooth animations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is private and proprietary.

## 🆘 Troubleshooting

### Common Issues

**Backend won't start:**
- Check if PostgreSQL is running
- Verify environment variables
- Ensure all dependencies are installed

**iOS app can't connect to backend:**
- Verify backend is running on correct port
- Check network connectivity
- Ensure API endpoints are correct

**Database connection issues:**
- Verify PostgreSQL is running
- Check connection string in `.env`
- Run `npx prisma migrate dev` to ensure schema is up to date

**Admin frontend not generating content:**
- Ensure backend API is running
- Check browser console for errors
- Verify OpenAI API key is valid

For more help, check the logs in `super-api/logs/` or open an issue.
