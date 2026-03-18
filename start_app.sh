#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting AB Tree Flutter App - Complete Setup"
echo "=================================================="
echo ""

# Check if Docker is running
echo "🔍 Checking prerequisites..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi
echo "✅ Docker is running"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi
echo "✅ Flutter is installed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Backend Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if backend dependencies are installed
if [ ! -d "backend/node_modules" ]; then
    echo "📦 Installing backend dependencies (this may take a minute)..."
    cd backend && npm install --silent && cd ..
    echo "✅ Backend dependencies installed"
else
    echo "✅ Backend dependencies already installed"
fi

# Check if .env file exists
if [ ! -f "backend/.env" ]; then
    echo "⚠️  Warning: backend/.env not found. Creating from template..."
    cp backend/.env.example backend/.env
    echo "   ⚠️  IMPORTANT: Update backend/.env with your real Stripe API keys!"
    echo "   File location: backend/.env"
else
    echo "✅ Backend .env file exists"
fi

echo ""
echo "🐳 Starting backend services (Docker Compose)..."
cd backend
docker compose up -d
cd ..

echo "⏳ Waiting for services to initialize..."
sleep 8

# Check MongoDB health
echo "🔍 Checking MongoDB..."
if docker ps --format '{{.Names}}' | grep -q "ab_tree_mongodb"; then
    if docker exec ab_tree_mongodb mongosh --eval "db.version()" > /dev/null 2>&1; then
        echo "✅ MongoDB is healthy and ready"
    else
        echo "⚠️  MongoDB container running but not ready yet"
    fi
else
    echo "❌ MongoDB container not found"
    exit 1
fi

# Check Backend API health
echo "🔍 Checking Backend API..."
max_retries=5
retry_count=0
while [ $retry_count -lt $max_retries ]; do
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo "✅ Backend API is healthy and ready"
        break
    else
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo "   Waiting for backend... (attempt $retry_count/$max_retries)"
            sleep 2
        else
            echo "⚠️  Backend might still be starting. Check logs: cd backend && docker compose logs"
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Flutter App Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Install/update Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get
echo "✅ Flutter dependencies ready"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Starting Flutter App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📱 Available devices:"
flutter devices --machine | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | head -5 || echo "No devices found"

echo ""
echo "✅ All Services Running:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🗄️  MongoDB:      http://localhost:27017"
echo "  🔧 Backend API:   http://localhost:3000"
echo "  💚 Health Check:  http://localhost:3000/health"
echo "  📖 API Docs:      http://localhost:3000/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎯 Quick Commands:"
echo "  • View database:    ./view_db.sh"
echo "  • Test API:         ./test_complete_flow.sh"
echo "  • Backend logs:     cd backend && docker compose logs -f"
echo "  • Stop services:    ./stop_app.sh"
echo ""
echo "🚀 Launching Flutter app in DEVELOPMENT mode..."
echo ""

# Run Flutter in development mode
flutter run --dart-define=DEVELOPMENT=true

# This runs after Flutter exits (user presses 'q')
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Flutter app stopped."
echo ""
echo "Backend services are still running."
echo "To stop all services: ./stop_app.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
