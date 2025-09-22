# Larry Frontend

React-based web interface for the Larry Vocab Coach application.

## Features

- **Topic Submission**: Submit new topics for vocabulary generation
- **Topic Management**: View and manage your submitted topics
- **Vocabulary Feed**: Browse generated vocabulary terms with definitions and examples
- **Term Flagging**: Flag inappropriate or incorrect terms

## Tech Stack

- **React 18** with TypeScript
- **Next.js 14** for routing and optimization
- **Tailwind CSS** for styling
- **Axios** for API communication

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## API Integration

The frontend connects to the super-api backend running on port 4001. Make sure the backend is running before starting the frontend.

## Environment Variables

Create a `.env.local` file with:

```env
NEXT_PUBLIC_API_URL=http://localhost:4001
```
