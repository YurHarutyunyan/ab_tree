#!/bin/bash

echo "🧪 Testing Payment Validation Flag..."
echo ""

# Check if MongoDB container is running
if ! docker ps --format '{{.Names}}' | grep -q "^mongodb$"; then
    echo "❌ MongoDB container is not running"
    exit 1
fi

echo "📋 Step 1: Show current user data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "
db.users.find({username: 'YurHar'}).forEach(function(user) {
  print('👤 User: ' + user.username);
  print('   Payment Valid: ' + (user.isPaymentValid ? 'YES ✓' : 'NO ✗'));
  print('   Credits: ' + JSON.stringify(user.appCredits));
})
"

echo ""
echo "📋 Step 2: Simulate payment (set isPaymentValid to true)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "
db.users.updateOne(
  {username: 'YurHar'},
  {\$set: {
    isPaymentValid: true,
    appCredits: {
      'Art Lunch': 5,
      'Smart Portal': 5,
      'Business Hub': 5,
      'Learn Plus': 5,
      'Creative Studio': 5,
      'Finance Tracker': 5
    }
  }}
)
"

echo ""
echo "📋 Step 3: Verify payment flag is set"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "
db.users.find({username: 'YurHar'}).forEach(function(user) {
  print('👤 User: ' + user.username);
  print('   Payment Valid: ' + (user.isPaymentValid ? 'YES ✓' : 'NO ✗'));
  print('   Credits: ' + JSON.stringify(user.appCredits));
})
"

echo ""
echo "📋 Step 4: Reset to unpaid state"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "
db.users.updateOne(
  {username: 'YurHar'},
  {\$set: {
    isPaymentValid: false,
    appCredits: {
      'Art Lunch': 0,
      'Smart Portal': 2,
      'Business Hub': 2,
      'Learn Plus': 2,
      'Creative Studio': 2,
      'Finance Tracker': 2
    }
  }}
)
"

echo ""
echo "📋 Step 5: Verify reset"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec mongodb mongosh ab_tree_db --quiet --eval "
db.users.find({username: 'YurHar'}).forEach(function(user) {
  print('👤 User: ' + user.username);
  print('   Payment Valid: ' + (user.isPaymentValid ? 'YES ✓' : 'NO ✗'));
  print('   Credits: ' + JSON.stringify(user.appCredits));
})
"

echo ""
echo "✅ Test complete!"
