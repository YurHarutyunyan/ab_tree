# Stripe Setup Guide

Complete guide to configuring Stripe payment processing for the AB Tree Flutter application.

## Quick Start

The app works WITHOUT Stripe configuration (simulates payments). Follow this guide only if you want real payment processing.

## Overview

Stripe integration allows your app to:
- Accept credit/debit card payments
- Process real transactions
- Transfer money to your account
- Handle payment security automatically

## Step-by-Step Setup

### 1. Create Stripe Account

1. Go to [Stripe.com](https://stripe.com)
2. Click "Sign up"
3. Fill in your information:
   - Email address
   - Full name
   - Country
   - Password
4. Verify your email address
5. Complete business profile (can skip for testing)

### 2. Activate Test Mode

1. Log into Stripe Dashboard
2. **IMPORTANT**: Toggle "Test mode" ON (top right)
   - Test mode lets you test without real money
   - Uses test card numbers
   - No real charges are made
3. Keep test mode on during development

### 3. Get API Keys

1. In Dashboard, click "Developers" in left menu
2. Click "API keys"
3. You'll see two types of keys:

**Publishable Key** (Safe to use in app)
```
pk_test_51xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Secret Key** (Keep secure, server-side only)
```
sk_test_51xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

4. Click "Reveal test key" for Secret key
5. Copy both keys to a secure location

### 4. Configure Flutter App

1. Open `lib/utils/constants.dart`
2. Find these lines:
   ```dart
   static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
   static const String stripeSecretKey = 'YOUR_STRIPE_SECRET_KEY';
   ```
3. Replace with your actual keys:
   ```dart
   static const String stripePublishableKey = 'pk_test_51xxxxxx...';
   static const String stripeSecretKey = 'sk_test_51xxxxxx...';
   ```
4. Save the file

### 5. Test the Integration

1. Run your Flutter app:
   ```bash
   flutter run
   ```
2. Navigate to Payment screen
3. Use test card numbers (see below)
4. Complete a test payment
5. Check Stripe Dashboard > Payments to see the test transaction

## Test Card Numbers

### Successful Payments

**Basic card (succeeds immediately)**
```
Card Number: 4242 4242 4242 4242
Expiry: Any future date (e.g., 12/25)
CVV: Any 3 digits (e.g., 123)
ZIP: Any 5 digits (e.g., 12345)
```

**Visa (succeeds)**
```
Card: 4000 0566 5566 5556
```

**Mastercard (succeeds)**
```
Card: 5555 5555 5555 4444
```

**American Express (succeeds)**
```
Card: 3782 822463 10005
CVV: 4 digits required
```

### Declined Payments

**Generic decline**
```
Card: 4000 0000 0000 0002
```

**Insufficient funds**
```
Card: 4000 0000 0000 9995
```

**Lost card**
```
Card: 4000 0000 0000 9987
```

**Stolen card**
```
Card: 4000 0000 0000 9979
```

### Special Scenarios

**Requires authentication (3D Secure)**
```
Card: 4000 0025 0000 3155
```

**Processing error**
```
Card: 4000 0000 0000 0119
```

## Payment Flow

### Current Implementation (Test Mode)

```
User enters card → 
App validates format → 
Simulated processing (2-3 seconds) → 
Success/failure response → 
Record saved to database
```

### Production Flow (When deployed)

```
User enters card → 
App validates format → 
Create payment intent (backend) → 
Stripe processes payment → 
Webhook confirms payment → 
Update database → 
Show success to user
```

## Backend Setup (Required for Production)

The current app simulates payments. For production, you need a backend server:

### Why Backend is Needed

🔐 **Security**: Secret keys must NEVER be in the app
💳 **PCI Compliance**: Card data must go through secure servers
✅ **Webhooks**: Get real-time payment confirmations

### Backend Options

**Option 1: Node.js/Express**
```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/create-payment-intent', async (req, res) => {
  const { amount } = req.body;
  
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount * 100, // Convert to cents
    currency: 'usd',
  });
  
  res.json({ clientSecret: paymentIntent.client_secret });
});
```

**Option 2: Firebase Functions**
```javascript
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  const stripe = require('stripe')(functions.config().stripe.secret);
  const paymentIntent = await stripe.paymentIntents.create({
    amount: data.amount * 100,
    currency: 'usd',
  });
  return { clientSecret: paymentIntent.client_secret };
});
```

**Option 3: AWS Lambda**
```python
import stripe
import json

def lambda_handler(event, context):
    stripe.api_key = os.environ['STRIPE_SECRET_KEY']
    intent = stripe.PaymentIntent.create(
        amount=event['amount'] * 100,
        currency='usd'
    )
    return {
        'statusCode': 200,
        'body': json.dumps({'clientSecret': intent.client_secret})
    }
```

## Webhook Configuration (Production)

### 1. Create Webhook Endpoint

1. Go to Stripe Dashboard > Developers > Webhooks
2. Click "Add endpoint"
3. Enter your endpoint URL:
   ```
   https://your-api.com/webhook/stripe
   ```
4. Select events to listen for:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `charge.refunded`
5. Click "Add endpoint"
6. Copy the webhook signing secret

### 2. Handle Webhook in Backend

```javascript
const endpointSecret = 'whsec_...';

app.post('/webhook/stripe', (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  
  if (event.type === 'payment_intent.succeeded') {
    const paymentIntent = event.data.object;
    // Update your database
    // Send confirmation email
  }
  
  res.json({received: true});
});
```

## Security Best Practices

### Development

✅ Use test mode
✅ Use test cards only
✅ Keep keys in constants file (not committed to git)
✅ Don't worry about PCI compliance yet

### Production

🔒 **Critical Security Measures**:

1. **Never include secret key in app**
   - Use backend server
   - Environment variables only
   - Never commit to version control

2. **Use HTTPS everywhere**
   - All API calls must be encrypted
   - No HTTP in production

3. **Validate on server**
   - Don't trust client-side validation
   - Verify amounts on backend
   - Check user permissions

4. **Implement rate limiting**
   - Prevent abuse
   - Limit payment attempts
   - Block suspicious activity

5. **Log everything**
   - Track all payment attempts
   - Monitor for fraud
   - Keep audit trail

6. **Handle errors properly**
   - Don't expose sensitive info
   - Log detailed errors server-side
   - Show generic messages to users

## Testing Checklist

Before going live, test:

- [ ] Successful payment
- [ ] Declined payment
- [ ] Invalid card number
- [ ] Expired card
- [ ] Insufficient funds
- [ ] 3D Secure authentication
- [ ] Network errors
- [ ] Timeout scenarios
- [ ] Multiple currencies (if applicable)
- [ ] Refund process
- [ ] Webhook delivery
- [ ] Database updates
- [ ] Email confirmations
- [ ] Error messages
- [ ] Loading states

## Going Live

### 1. Complete Stripe Onboarding

1. Go to Dashboard > Settings > Account
2. Fill in business details:
   - Legal business name
   - Tax information
   - Bank account (for payouts)
   - Business address
3. Verify your identity
4. Wait for approval (usually 1-2 business days)

### 2. Switch to Live Mode

1. Toggle "Live mode" in Dashboard
2. Get new production API keys
3. Update backend with production keys
4. **DO NOT** update app with secret key
5. Test with real card (small amount)

### 3. Update App

1. Remove any test mode indicators
2. Update API endpoints to production
3. Test thoroughly
4. Deploy to app stores

### 4. Configure Webhooks

1. Set up production webhook endpoints
2. Test webhook delivery
3. Monitor webhook logs

## Monitoring

### Stripe Dashboard

Monitor these metrics:
- Successful payments
- Failed payments
- Refund requests
- Dispute rate
- Revenue trends

### Set Up Alerts

1. Go to Settings > Notifications
2. Enable alerts for:
   - Failed payments
   - Disputes
   - Large transactions
   - Refunds

### Regular Reviews

Weekly:
- Check payment success rate
- Review failed payments
- Address customer issues

Monthly:
- Analyze revenue trends
- Review disputes
- Update business info if needed

## Troubleshooting

### "Invalid API Key" Error

**Problem**: App can't connect to Stripe

**Solutions**:
1. Check if you copied the full key
2. Verify you're using the right mode (test/live)
3. Ensure no extra spaces in key
4. Regenerate key if needed

### Payments Not Processing

**Problem**: Payments stuck in pending

**Solutions**:
1. Check internet connection
2. Verify Stripe account is active
3. Check if test mode is enabled
4. Review Stripe Dashboard logs

### Webhook Not Receiving Events

**Problem**: No webhook notifications

**Solutions**:
1. Verify endpoint URL is accessible
2. Check webhook signing secret
3. Review webhook logs in Dashboard
4. Test with Stripe CLI:
   ```bash
   stripe listen --forward-to localhost:3000/webhook
   ```

### Cards Being Declined

**Problem**: Valid cards getting declined

**Solutions**:
1. Check if account has restrictions
2. Verify card details are correct
3. Try different test card
4. Check Stripe Dashboard for details

## Cost Information

### Pricing

**Per Transaction**:
- 2.9% + $0.30 for US cards
- 3.9% + $0.30 for international cards
- Additional 1% for currency conversion

**Volume Discounts**:
- Available for high-volume businesses
- Contact Stripe sales

**No Monthly Fees**:
- No setup fee
- No monthly fee
- No hidden fees
- Pay only for successful charges

### Example Costs

| Amount | Stripe Fee | You Receive |
|--------|-----------|-------------|
| $10.00 | $0.59 | $9.41 |
| $50.00 | $1.75 | $48.25 |
| $100.00 | $3.20 | $96.80 |
| $500.00 | $14.80 | $485.20 |

## Advanced Features

### 1. Subscription Billing

```dart
// Create recurring payments
// Monthly, yearly, etc.
```

### 2. Save Cards for Later

```dart
// Store payment methods
// Quick checkout for return customers
```

### 3. Multiple Currencies

```dart
// Accept payments in different currencies
// Automatic conversion
```

### 4. Split Payments

```dart
// Split payments between accounts
// Marketplace functionality
```

### 5. Payment Links

```dart
// Generate payment links
// No app required
```

## Support Resources

- [Stripe Documentation](https://stripe.com/docs)
- [Flutter Stripe Plugin Docs](https://pub.dev/packages/flutter_stripe)
- [Stripe Support](https://support.stripe.com/)
- [API Reference](https://stripe.com/docs/api)
- [Discord Community](https://discord.gg/stripe)

## Migration Checklist

When moving from test to production:

- [ ] Complete Stripe onboarding
- [ ] Get production API keys
- [ ] Set up production webhook
- [ ] Update backend with prod keys
- [ ] Test with real small payment
- [ ] Set up monitoring
- [ ] Configure notifications
- [ ] Update app to use prod endpoints
- [ ] Remove test mode indicators
- [ ] Submit app to stores
- [ ] Monitor first transactions closely

---

**You're ready to accept payments!** 💳

Your Flutter app can now process secure payments through Stripe.
