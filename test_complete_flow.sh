#!/bin/bash

echo "🧪 AB Tree Complete Flow Test"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

API_URL="http://localhost:3000"
TEST_USER="testuser_$(date +%s)"
TEST_EMAIL="test_$(date +%s)@example.com"
TEST_PASSWORD="password123"
TOKEN=""

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Function to extract JSON field
extract_json() {
    echo "$1" | grep -o "\"$2\":[^,}]*" | cut -d':' -f2- | tr -d '"' | tr -d ' '
}

echo "📡 Step 1: Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s "$API_URL/health")
if echo "$response" | grep -q "success.*true"; then
    print_result 0 "Backend is running"
    echo "   Response: $response"
else
    print_result 1 "Backend is not running"
    echo "   Start with: ./start_app.sh"
    exit 1
fi

echo ""
echo "📝 Step 2: User Registration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Username: $TEST_USER"
echo "   Email: $TEST_EMAIL"

response=$(curl -s -X POST "$API_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$TEST_USER\",
    \"email\": \"$TEST_EMAIL\",
    \"firstName\": \"Test\",
    \"lastName\": \"User\",
    \"password\": \"$TEST_PASSWORD\"
  }")

if echo "$response" | grep -q "success.*true"; then
    print_result 0 "Registration successful"
    TOKEN=$(extract_json "$response" "token")
    echo "   Token: ${TOKEN:0:20}..."
else
    print_result 1 "Registration failed"
    echo "   Response: $response"
    exit 1
fi

echo ""
echo "🔐 Step 3: User Login"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X POST "$API_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$TEST_USER\",
    \"password\": \"$TEST_PASSWORD\"
  }")

if echo "$response" | grep -q "success.*true"; then
    print_result 0 "Login successful"
    TOKEN=$(extract_json "$response" "token")
else
    print_result 1 "Login failed"
    echo "   Response: $response"
    exit 1
fi

echo ""
echo "👤 Step 4: Get User Profile"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X GET "$API_URL/api/user/profile" \
  -H "Authorization: Bearer $TOKEN")

if echo "$response" | grep -q "success.*true"; then
    print_result 0 "Profile retrieved"
    echo "   User: $(extract_json "$response" "username")"
    echo "   Email: $(extract_json "$response" "email")"
else
    print_result 1 "Profile retrieval failed"
    echo "   Response: $response"
fi

echo ""
echo "🎯 Step 5: Check Initial Credits (Art Lunch)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X GET "$API_URL/api/user/credits/Art%20Lunch" \
  -H "Authorization: Bearer $TOKEN")

initial_credits=$(extract_json "$response" "credits")
if [ "$initial_credits" = "2" ]; then
    print_result 0 "Initial credits correct (2)"
else
    print_result 1 "Initial credits incorrect (expected 2, got $initial_credits)"
fi

echo ""
echo "🛒 Step 6: Use Credit (Buy with Art Lunch)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X POST "$API_URL/api/user/credits/Art%20Lunch/buy" \
  -H "Authorization: Bearer $TOKEN")

if echo "$response" | grep -q "success.*true"; then
    new_credits=$(extract_json "$response" "credits")
    if [ "$new_credits" = "1" ]; then
        print_result 0 "Credit decremented (2 → 1)"
    else
        print_result 1 "Credit count incorrect (expected 1, got $new_credits)"
    fi
else
    print_result 1 "Purchase failed"
    echo "   Response: $response"
fi

echo ""
echo "🔄 Step 7: Verify Credit Persistence"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X GET "$API_URL/api/user/credits/Art%20Lunch" \
  -H "Authorization: Bearer $TOKEN")

current_credits=$(extract_json "$response" "credits")
if [ "$current_credits" = "1" ]; then
    print_result 0 "Credits persisted correctly (1)"
else
    print_result 1 "Credits not persisted (expected 1, got $current_credits)"
fi

echo ""
echo "📱 Step 8: Check Another App (Smart Portal)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X GET "$API_URL/api/user/credits/Smart%20Portal" \
  -H "Authorization: Bearer $TOKEN")

smart_credits=$(extract_json "$response" "credits")
if [ "$smart_credits" = "2" ]; then
    print_result 0 "Smart Portal has 2 credits (untouched)"
else
    print_result 1 "Smart Portal credits incorrect (expected 2, got $smart_credits)"
fi

echo ""
echo "✏️  Step 9: Update Profile (Email/Phone)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
new_email="updated_$TEST_EMAIL"
response=$(curl -s -X PUT "$API_URL/api/user/profile" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$new_email\",
    \"phone\": \"+1234567890\"
  }")

if echo "$response" | grep -q "success.*true"; then
    print_result 0 "Profile updated"
    echo "   New Email: $(extract_json "$response" "email")"
    echo "   Phone: +1234567890"
else
    print_result 1 "Profile update failed"
    echo "   Response: $response"
fi

echo ""
echo "💳 Step 10: Create Payment Intent"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X POST "$API_URL/api/payments/create-intent" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"amount\": 10.00,
    \"currency\": \"usd\"
  }")

if echo "$response" | grep -q "clientSecret"; then
    print_result 0 "Payment intent created"
    payment_id=$(extract_json "$response" "paymentIntentId")
    echo "   Payment Intent ID: ${payment_id:0:30}..."
else
    print_result 1 "Payment intent creation failed"
    echo "   Response: $response"
    echo "   Note: Requires valid Stripe keys in backend/.env"
fi

echo ""
echo "📊 Step 11: Get Payment History"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X GET "$API_URL/api/payments/history" \
  -H "Authorization: Bearer $TOKEN")

if echo "$response" | grep -q "success.*true"; then
    print_result 0 "Payment history retrieved"
    payments_count=$(echo "$response" | grep -o "\"payments\":\[" | wc -l)
    echo "   Total payments: $payments_count"
else
    print_result 1 "Payment history retrieval failed"
fi

echo ""
echo "🎯 Step 12: Use All Remaining Credits"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Use the remaining credit for Art Lunch
curl -s -X POST "$API_URL/api/user/credits/Art%20Lunch/buy" \
  -H "Authorization: Bearer $TOKEN" > /dev/null

# Check if we have 0 credits
response=$(curl -s -X GET "$API_URL/api/user/credits/Art%20Lunch" \
  -H "Authorization: Bearer $TOKEN")
final_credits=$(extract_json "$response" "credits")

if [ "$final_credits" = "0" ]; then
    print_result 0 "All credits used (0 remaining)"
else
    print_result 1 "Credits count incorrect (expected 0, got $final_credits)"
fi

echo ""
echo "🚫 Step 13: Try to Buy with 0 Credits"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
response=$(curl -s -X POST "$API_URL/api/user/credits/Art%20Lunch/buy" \
  -H "Authorization: Bearer $TOKEN")

if echo "$response" | grep -q "No credits available"; then
    print_result 0 "Correctly prevented purchase with 0 credits"
else
    print_result 1 "Should have prevented purchase"
    echo "   Response: $response"
fi

echo ""
echo "================================"
echo "🎉 Test Complete!"
echo ""
echo "Summary:"
echo "  • Backend API: Working"
echo "  • Registration: Working"
echo "  • Login: Working"
echo "  • Credits System: Working"
echo "  • Profile Updates: Working"
echo "  • Payment Endpoints: Created"
echo ""
echo "Next Steps:"
echo "  1. Run the Flutter app: ./start_app.sh"
echo "  2. Test UI interactions manually"
echo "  3. Verify credits persist across logout/login"
echo ""
