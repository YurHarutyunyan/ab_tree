#!/bin/bash

echo "🛑 Stopping AB Tree services..."
echo ""

# Stop Docker Compose services
if [ -d "backend" ] && [ -f "backend/docker-compose.yml" ]; then
    echo "🐳 Stopping backend services..."
    cd backend
    docker-compose down
    cd ..
    echo "✅ Backend services stopped"
else
    echo "⚠️  backend/docker-compose.yml not found"
fi

echo ""
echo "✅ All services stopped!"
echo ""
echo "To start services again: ./start_app.sh"
echo "To view database: ./view_db.sh (services must be running)"
