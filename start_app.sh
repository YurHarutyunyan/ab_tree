#!/bin/bash

echo "🚀 Starting AB Tree Flutter App..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "🐳 Starting backend services with Docker Compose..."
echo ""

# Check if backend dependencies are installed
if [ ! -d "backend/node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    cd backend && npm install && cd ..
fi

# Check if .env file exists
if [ ! -f "backend/.env" ]; then
    echo "⚠️  Warning: backend/.env not found. Using .env.example as template."
    echo "   Please update backend/.env with your Stripe API keys."
    cp backend/.env.example backend/.env
fi

# Start Docker Compose services
cd backend
docker-compose up -d
cd ..

echo "⏳ Waiting for services to start..."
sleep 5

# Check if MongoDB is running
if docker ps --format '{{.Names}}' | grep -q "ab_tree_mongodb"; then
    echo "✅ MongoDB is ready!"
else
    echo "⚠️  MongoDB might still be starting up..."
fi

# Check if backend is running
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Backend API is ready!"
else
    echo "⚠️  Backend might still be starting up..."
    echo "   Check logs with: cd backend && docker-compose logs"
fi

echo ""
echo "📱 Starting Flutter app..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Services Running:"
echo "  - MongoDB: http://localhost:27017"
echo "  - Backend API: http://localhost:3000"
echo "  - Backend Health: http://localhost:3000/health"
echo "  - API Docs: http://localhost:3000/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run Flutter in development mode
flutter run --dart-define=DEVELOPMENT=true

echo ""
echo "ℹ️  Backend services are still running."
echo "   To stop all services: ./stop_app.sh"
echo "   To view backend logs: cd backend && docker-compose logs -f"
echo "   To view database: ./view_db.sh"
