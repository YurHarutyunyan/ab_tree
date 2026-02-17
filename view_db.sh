#!/bin/bash

echo "🔍 Viewing AB Tree MongoDB Database..."
echo ""

# Check if MongoDB container is running
if ! docker ps --format '{{.Names}}' | grep -q "^mongodb$"; then
    echo "❌ MongoDB container is not running"
    echo "   Start it with: ./start_app.sh or docker start mongodb"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 USERS COLLECTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "db.users.find().pretty()"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💳 PAYMENTS COLLECTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "db.payments.find().pretty()"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 DATABASE STATS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "
  print('Total Users: ' + db.users.countDocuments());
  print('Total Payments: ' + db.payments.countDocuments());
"

echo ""
