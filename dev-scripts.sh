#!/bin/bash

# Development scripts for Larry project

echo "🚀 Larry Development Scripts"
echo "=============================="

case "$1" in
  "start-all")
    echo "Starting all services with Docker Compose..."
    docker compose up -d
    echo "✅ All services started!"
    echo "📊 Backend: http://192.168.1.178:4000"
    echo "🗄️  PostgreSQL: localhost:5433"
    echo "🔴 Redis: localhost:6380"
    ;;
    
  "stop-all")
    echo "Stopping all services..."
    docker compose down
    echo "✅ All services stopped!"
    ;;
    
  "logs")
    echo "Showing backend logs..."
    docker compose logs -f backend
    ;;
    
  "test-api")
    echo "Testing API endpoints..."
    echo "Health check:"
    curl -s http://192.168.1.178:4000/health | jq .
    echo ""
    echo "Topics endpoint:"
    curl -s http://192.168.1.178:4000/topics | jq .
    ;;
    
  "reset-db")
    echo "Resetting database..."
    docker compose down -v
    docker compose up -d postgres redis
    sleep 5
    cd api && npm run prisma:migrate:reset
    echo "✅ Database reset!"
    ;;
    
  "expo-start")
    echo "Starting Expo development server..."
    cd app && npx expo start --clear
    ;;
    
  *)
    echo "Usage: $0 {start-all|stop-all|logs|test-api|reset-db|expo-start}"
    echo ""
    echo "Commands:"
    echo "  start-all    - Start all services (PostgreSQL, Redis, Backend)"
    echo "  stop-all     - Stop all services"
    echo "  logs         - Show backend logs"
    echo "  test-api     - Test API endpoints"
    echo "  reset-db     - Reset database and run migrations"
    echo "  expo-start   - Start Expo development server"
    ;;
esac
