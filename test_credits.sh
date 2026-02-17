#!/bin/bash

echo "🧪 Testing Credits System..."
echo ""

# Check if MongoDB is running
if ! docker ps --format '{{.Names}}' | grep -q "^mongodb$"; then
    echo "❌ MongoDB is not running. Start with: docker start mongodb"
    exit 1
fi

echo "Checking credits for all users:"
echo ""

docker exec mongodb mongosh ab_tree_db --quiet --eval "
  db.users.find({}, {
    username: 1,
    email: 1,
    phone: 1,
    appCredits: 1
  }).forEach(function(user) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('User: ' + user.username);
    print('Email: ' + (user.email || 'Not set'));
    print('Phone: ' + (user.phone || 'Not set'));
    print('');
    if (user.appCredits) {
      print('App Credits:');
      for (var app in Object.keys(user.appCredits)) {
        print('  - ' + app + ': ' + user.appCredits[app]);
      }
    } else {
      print('⚠️  No appCredits field found');
      print('   (User needs to open an app or make a payment)');
    }
    print('');
  });
"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Tips:"
echo "  - New users start with 2 credits per app"
echo "  - After payment, all apps get 5 credits"
echo "  - Credits are saved when you click BUY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
