#!/bin/bash

echo "🛑 Stopping AB Tree Flutter App services..."
echo ""

# Stop backend server
BACKEND_PID=$(pgrep -f "node server.js")
if [ ! -z "$BACKEND_PID" ]; then
    echo "💳 Stopping backend server (PID: $BACKEND_PID)..."
    kill $BACKEND_PID 2>/dev/null
    echo "✅ Backend server stopped"
else
    echo "ℹ️  Backend server is not running"
fi

# Stop MongoDB container
if docker ps --format '{{.Names}}' | grep -q "^mongodb$"; then
    echo "📦 Stopping MongoDB container..."
    docker stop mongodb
    echo "✅ MongoDB stopped"
else
    echo "ℹ️  MongoDB container is not running"
fi

echo ""
echo "✅ All services stopped"
echo ""
echo "To start again, run: ./start_app.sh"
echo "To remove MongoDB container: docker rm mongodb"
echo "To view stopped containers: docker ps -a"
echo "To view backend logs: cat backend.log"
