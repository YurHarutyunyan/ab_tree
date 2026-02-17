#!/bin/bash

echo "🚀 Starting AB Tree Flutter App..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if MongoDB container exists
if docker ps -a --format '{{.Names}}' | grep -q "^mongodb$"; then
    echo "📦 MongoDB container found"
    
    # Check if it's running
    if docker ps --format '{{.Names}}' | grep -q "^mongodb$"; then
        echo "✅ MongoDB is already running"
    else
        echo "▶️  Starting MongoDB container..."
        docker start mongodb
        sleep 2
    fi
else
    echo "📦 Creating new MongoDB container..."
    docker run -d \
      --name mongodb \
      -p 27017:27017 \
      -e MONGO_INITDB_DATABASE=ab_tree_db \
      mongo:latest
    
    echo "⏳ Waiting for MongoDB to initialize..."
    sleep 3
fi

# Verify MongoDB is accessible
echo "🔍 Checking MongoDB connection..."
if docker exec mongodb mongosh --eval "db.version()" > /dev/null 2>&1; then
    echo "✅ MongoDB is ready!"
else
    echo "⚠️  MongoDB might still be starting up, but continuing..."
fi

echo ""
echo "💳 Starting Payment Backend Server..."

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

# Start backend server in background
cd backend
node server.js > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

echo "⏳ Waiting for backend to start..."
sleep 3

# Check if backend is running
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Payment backend is ready!"
else
    echo "⚠️  Backend might still be starting up, but continuing..."
fi

echo ""
echo "📱 Starting Flutter app..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Services Running:"
echo "  - MongoDB: http://localhost:27017"
echo "  - Backend API: http://localhost:3000"
echo "  - Backend Health: http://localhost:3000/health"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run Flutter
flutter run

# Cleanup on exit
echo ""
echo "👋 Stopping services..."
if [ ! -z "$BACKEND_PID" ]; then
    kill $BACKEND_PID 2>/dev/null
    echo "✅ Backend server stopped"
fi

echo ""
echo "ℹ️  MongoDB container is still running."
echo "   To stop MongoDB: docker stop mongodb"
echo "   To view MongoDB data: docker exec -it mongodb mongosh ab_tree_db"
echo "   To view backend logs: cat backend.log"
