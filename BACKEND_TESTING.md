# Backend Testing Guide

## Quick Start - Test Backend Without Stripe Keys

You can test the backend API endpoints even without real Stripe keys. The backend will run and accept requests, but payment intent creation will fail (which is expected).

### Step 1: Start Services

```bash
./start_app.sh
```

This will:
- Start MongoDB container
- Install backend dependencies (if needed)
- Start backend server on port 3000
- Start Flutter app

### Step 2: Test Backend API (In Another Terminal)

```bash
./test_backend.sh
```

This script tests all backend endpoints:
- Health check
- Create payment intent (will fail without real keys)
- Confirm payment
- Get payment history

## Testing With Real Stripe Keys

### Get Stripe Test Keys

1. Go to https://dashboard.stripe.com/register
2. Create a free account
3. Go to Developers → API Keys
4. Copy your **Test mode** keys:
   - Publishable key (starts with `pk_test_`)
   - Secret key (starts with `sk_test_`)

### Configure Backend

Edit `backend/.env`:

```bash
STRIPE_SECRET_KEY=sk_test_your_actual_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_actual_key_here
MONGODB_URI=mongodb://localhost:27017/ab_tree_db
PORT=3000
NODE_ENV=development
ALLOWED_ORIGINS=*
```

### Restart Backend

```bash
./stop_app.sh
./start_app.sh
```

### Test Again

```bash
./test_backend.sh
```

Now payment intent creation should succeed!

## Manual Testing with curl

### Health Check
```bash
curl http://localhost:3000/health
```

### Create Payment Intent
```bash
curl -X POST http://localhost:3000/api/create-payment-intent \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50.00,
    "currency": "usd",
    "userId": "user_12345"
  }'
```

### Confirm Payment
```bash
curl -X POST http://localhost:3000/api/confirm-payment \
  -H "Content-Type: application/json" \
  -d '{
    "paymentIntentId": "pi_test_123",
    "userId": "user_12345",
    "amount": 50.00,
    "cardLast4": "4242",
    "cardHolder": "John Doe"
  }'
```

### Get Payment History
```bash
curl http://localhost:3000/api/payments/user_12345
```

## View Backend Logs

```bash
cat backend.log
```

Or watch in real-time:
```bash
tail -f backend.log
```

## Stripe Test Cards

Once you have real Stripe keys, test with these cards:

| Card Number | Type | Result |
|------------|------|--------|
| 4242 4242 4242 4242 | Visa | Success |
| 4000 0566 5566 5556 | Visa Debit | Success |
| 5555 5555 5555 4444 | Mastercard | Success |
| 3782 822463 10005 | Amex | Success |
| 4000 0000 0000 0002 | Visa | Declined |
| 4000 0025 0000 3155 | Visa | Requires 3D Secure |

Use any future expiry date (e.g., 12/25) and any CVV (e.g., 123).

## Troubleshooting

### Backend won't start
```bash
# Check if port 3000 is already in use
sudo lsof -i :3000

# Check backend logs
cat backend.log
```

### MongoDB connection failed
```bash
# Check if MongoDB is running
docker ps | grep mongodb

# Start MongoDB manually
docker start mongodb
```

### Can't reach backend from Flutter
Make sure backend is running on `0.0.0.0:3000` not `localhost:3000` for Docker networking.

## Next Steps

After backend testing succeeds:
1. ✅ Backend is working
2. Next: Integrate Flutter app with backend
3. Next: Test end-to-end payment flow
4. Next: Deploy to production
