# 🧠 Larry Backend Service

A modern, scalable backend service for the Larry AI-powered vocabulary app.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL
- Redis (optional, for future queue features)

### Installation

1. **Clone and install dependencies:**
```bash
cd super-api
npm install
```

2. **Set up environment variables:**
```bash
cp .env.example .env
# Edit .env with your database and API keys
```

3. **Set up the database:**
```bash
# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate
```

4. **Start the development server:**
```bash
npm run dev
```

The server will start on `http://localhost:3000`

## 📊 API Endpoints

### Health Check
- `GET /health` - Server health status

### Users
- `POST /user` - Create a new user
- `GET /user/:userId` - Get user by ID

### Topics
- `POST /user/topics` - Create topic and associate with user
- `GET /user/:userId/topics` - Get all topics for a user
- `PUT /user/topics/:userTopicId` - Update topic weight
- `DELETE /user/topics/:userTopicId` - Remove topic from user

### Terms & Facts
- `GET /user/:userId/terms` - Get all terms for a user's topics
- `GET /user/terms/:topicId` - Get terms for a specific topic
- `POST /user/terms` - Create a new term
- `GET /user/facts/:topicId` - Get facts for a specific topic
- `POST /user/facts` - Create a new fact

## 🗄️ Database Schema

The service uses PostgreSQL with the following main models:

- **User** - User accounts and subscriptions
- **Topic** - Vocabulary topics/categories
- **UserTopic** - User-topic associations with weights
- **Term** - Vocabulary terms with definitions and examples
- **Fact** - Related facts for topics
- **CanonicalSet** - Canonical term sets

## 🛠️ Development

### Available Scripts
- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Run database migrations
- `npm run prisma:studio` - Open Prisma Studio
- `npm run db:push` - Push schema changes to database

### Project Structure
```
src/
├── app.ts              # Main application entry point
└── api/
    ├── users.ts        # User management endpoints
    ├── topics.ts       # Topic management endpoints
    └── terms.ts        # Terms and facts endpoints
```

## 🔮 Future Features

- **Queue Pipeline** - BullMQ integration for background processing
- **OpenAI Integration** - AI-powered term and fact generation
- **Authentication** - JWT-based user authentication
- **Rate Limiting** - API rate limiting and cost controls
- **Real-time Updates** - WebSocket support for live updates

## 🧪 Testing

```bash
# Run tests (when implemented)
npm test
```

## 📝 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `DATABASE_URL` | PostgreSQL connection string | Required |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |
| `OPENAI_API_KEY` | OpenAI API key | Required for AI features |
| `JWT_SECRET` | JWT signing secret | Required for auth |

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Add tests if applicable
4. Submit a pull request

## 📄 License

ISC


