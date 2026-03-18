#!/bin/bash

echo "🔍 Viewing AB Tree MongoDB Database"
echo "=================================================="
echo ""

# Check if MongoDB container is running
if ! docker ps --format '{{.Names}}' | grep -q "ab_tree_mongodb"; then
    echo "❌ MongoDB container is not running"
    echo "   Start it with: ./start_app.sh"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 USERS COLLECTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec ab_tree_mongodb mongosh ab_tree_db --quiet --eval "db.users.find().pretty()"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💳 PAYMENTS COLLECTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec ab_tree_mongodb mongosh ab_tree_db --quiet --eval "db.payments.find().pretty()"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 DATABASE STATS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec ab_tree_mongodb mongosh ab_tree_db --quiet --eval "
  print('Total Users: ' + db.users.countDocuments());
  print('Total Payments: ' + db.payments.countDocuments());
"

echo ""
echo "🔍 To view backend logs: cd backend && docker compose logs -f"
echo ""