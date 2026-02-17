# AB Tree Payment Backend

Node.js/Express backend for handling Stripe payment processing.

## Features

- Stripe payment intent creation
- Payment confirmation and MongoDB storage
- Payment history retrieval
- CORS enabled for Flutter app
- Health check endpoint
- Docker support

## API Endpoints

### Health Check
```
GET /health
```

### Create Payment Intent
```
POST /api/create-payment-intent
Content-Type: application/json

{
  "amount": 100.00,
  "currency": "usd",
  "userId": "user123",
  "metadata": {}
}
```

### Confirm Payment
```
POST /api/confirm-payment
Content-Type: application/json

{
  "paymentIntentId": "pi_xxx",
  "userId": "user123",
  "amount": 100.00,
  "cardLast4": "4242",
  "cardHolder": "John Doe",
  "status": "completed"
}
```

### Get Payment History
```
GET /api/payments/:userId
```

## Setup

1. Copy `.env.example` to `.env`
2. Add your Stripe secret key
3. Configure MongoDB URI
4. Run `npm install`
5. Run `npm start`

## Docker

Build image:
```bash
docker build -t ab-tree-backend .
```

Run container:
```bash
docker run -p 3000:3000 --env-file .env ab-tree-backend
```

## Environment Variables

- `STRIPE_SECRET_KEY` - Your Stripe secret key
- `MONGODB_URI` - MongoDB connection string
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `ALLOWED_ORIGINS` - CORS allowed origins
