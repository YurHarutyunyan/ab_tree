const express = require('express');
const router = express.Router();

// Create Payment Intent
router.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount, currency = 'usd', userId, metadata = {} } = req.body;

    // Validate amount
    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid amount. Amount must be greater than 0.'
      });
    }

    // Validate user ID
    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'User ID is required.'
      });
    }

    // Get Stripe instance from app
    const stripe = req.app.get('stripe');

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: currency,
      metadata: {
        userId: userId,
        ...metadata
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    console.log(`✅ Payment Intent created: ${paymentIntent.id} for $${amount}`);

    res.json({
      success: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      amount: amount
    });
  } catch (error) {
    console.error('❌ Error creating payment intent:', error.message);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Confirm Payment and Save to Database
router.post('/confirm-payment', async (req, res) => {
  try {
    const {
      paymentIntentId,
      userId,
      amount,
      cardLast4,
      cardHolder,
      status = 'completed'
    } = req.body;

    // Validate required fields
    if (!paymentIntentId || !userId || !amount) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields'
      });
    }

    // Get MongoDB client from app
    const db = req.app.get('db');
    const paymentsCollection = db.collection('payments');

    // Create payment record
    const paymentRecord = {
      userId: userId,
      amount: amount,
      cardLast4: cardLast4 || 'XXXX',
      cardHolder: cardHolder || 'Unknown',
      transactionId: paymentIntentId,
      status: status,
      recipientCard: process.env.RECIPIENT_CARD || '**** **** **** 5678',
      timestamp: new Date(),
      createdAt: new Date()
    };

    // Save to MongoDB
    const result = await paymentsCollection.insertOne(paymentRecord);

    console.log(`✅ Payment record saved: ${paymentIntentId}`);

    res.json({
      success: true,
      paymentId: result.insertedId,
      transactionId: paymentIntentId,
      message: 'Payment confirmed and recorded'
    });
  } catch (error) {
    console.error('❌ Error confirming payment:', error.message);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get Payment History for User
router.get('/payments/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'User ID is required'
      });
    }

    const db = req.app.get('db');
    const paymentsCollection = db.collection('payments');

    const payments = await paymentsCollection
      .find({ userId: userId })
      .sort({ timestamp: -1 })
      .toArray();

    res.json({
      success: true,
      payments: payments,
      count: payments.length
    });
  } catch (error) {
    console.error('❌ Error fetching payments:', error.message);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;
