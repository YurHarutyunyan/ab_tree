#!/bin/bash

echo "🧪 Testing Payment Backend API..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backend is running
echo "1️⃣  Checking if backend is running..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is running${NC}"
else
    echo -e "${RED}❌ Backend is not running. Please run ./start_app.sh first${NC}"
    exit 1
fi

echo ""
echo "2️⃣  Testing Health Endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3000/health)
echo "$HEALTH_RESPONSE" | jq '.' 2>/dev/null || echo "$HEALTH_RESPONSE"

echo ""
echo "3️⃣  Testing Create Payment Intent..."
PAYMENT_INTENT_RESPONSE=$(curl -s -X POST http://localhost:3000/api/create-payment-intent \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100.50,
    "currency": "usd",
    "userId": "test_user_123"
  }')

echo "$PAYMENT_INTENT_RESPONSE" | jq '.' 2>/dev/null || echo "$PAYMENT_INTENT_RESPONSE"

# Check if payment intent was successful
if echo "$PAYMENT_INTENT_RESPONSE" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ Payment intent created successfully${NC}"
    
    # Extract payment intent ID
    PAYMENT_INTENT_ID=$(echo "$PAYMENT_INTENT_RESPONSE" | jq -r '.paymentIntentId' 2>/dev/null)
    
    if [ ! -z "$PAYMENT_INTENT_ID" ] && [ "$PAYMENT_INTENT_ID" != "null" ]; then
        echo ""
        echo "4️⃣  Testing Confirm Payment..."
        CONFIRM_RESPONSE=$(curl -s -X POST http://localhost:3000/api/confirm-payment \
          -H "Content-Type: application/json" \
          -d "{
            \"paymentIntentId\": \"$PAYMENT_INTENT_ID\",
            \"userId\": \"test_user_123\",
            \"amount\": 100.50,
            \"cardLast4\": \"4242\",
            \"cardHolder\": \"Test User\",
            \"status\": \"completed\"
          }")
        
        echo "$CONFIRM_RESPONSE" | jq '.' 2>/dev/null || echo "$CONFIRM_RESPONSE"
        
        if echo "$CONFIRM_RESPONSE" | grep -q '"success":true'; then
            echo -e "${GREEN}✅ Payment confirmed and saved to database${NC}"
        else
            echo -e "${YELLOW}⚠️  Payment confirmation had issues${NC}"
        fi
    fi
else
    echo -e "${RED}❌ Failed to create payment intent${NC}"
    echo -e "${YELLOW}Note: This is expected if you haven't set up real Stripe API keys yet${NC}"
    echo -e "${YELLOW}To fix: Add your Stripe test keys to backend/.env${NC}"
fi

echo ""
echo "5️⃣  Testing Get Payment History..."
HISTORY_RESPONSE=$(curl -s http://localhost:3000/api/payments/test_user_123)
echo "$HISTORY_RESPONSE" | jq '.' 2>/dev/null || echo "$HISTORY_RESPONSE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Backend API Test Complete!"
echo ""
echo "Next steps:"
echo "  1. Get your Stripe test API keys from https://dashboard.stripe.com/test/apikeys"
echo "  2. Update backend/.env with your keys"
echo "  3. Run this test again to verify real Stripe integration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
