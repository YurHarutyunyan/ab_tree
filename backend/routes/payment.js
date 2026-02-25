const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const Payment = require('../models/Payment');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// @route   POST /api/payments/create-intent
// @desc    Create a Stripe PaymentIntent
// @access  Protected
router.post('/create-intent', auth, async (req, res) => {
  try {
    const { amount, currency = 'usd' } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid amount' 
      });
    }

    // Create PaymentIntent with Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency,
      metadata: {
        userId: req.userId.toString(),
        description: 'App credits purchase'
      }
    });

    // Save payment record to database
    const payment = new Payment({
      userId: req.userId,
      amount,
      currency,
      status: 'pending',
      stripePaymentIntentId: paymentIntent.id
    });

    await payment.save();

    res.json({
      success: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id
    });
  } catch (error) {
    console.error('Create payment intent error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to create payment intent: ' + error.message 
    });
  }
});

// @route   POST /api/payments/confirm
// @desc    Confirm payment and update user credits
// @access  Protected
router.post('/confirm', auth, async (req, res) => {
  try {
    const { paymentIntentId } = req.body;

    if (!paymentIntentId) {
      return res.status(400).json({ 
        success: false, 
        message: 'Payment intent ID is required' 
      });
    }

    // Verify payment with Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status !== 'succeeded') {
      return res.status(400).json({ 
        success: false, 
        message: 'Payment not completed' 
      });
    }

    // Find payment in database
    const payment = await Payment.findOne({ stripePaymentIntentId: paymentIntentId });

    if (!payment) {
      return res.status(404).json({ 
        success: false, 
        message: 'Payment record not found' 
      });
    }

    // Check if payment belongs to this user
    if (payment.userId.toString() !== req.userId.toString()) {
      return res.status(403).json({ 
        success: false, 
        message: 'Unauthorized' 
      });
    }

    // Update payment status
    payment.status = 'completed';
    payment.completedAt = new Date();
    payment.paymentMethod = paymentIntent.payment_method_types[0];
    await payment.save();

    // Update user: set isPaymentValid to true and upgrade all credits to 5
    const user = await User.findById(req.userId);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    user.isPaymentValid = true;
    user.appCredits = new Map([
      ['Art Lunch', 5],
      ['Smart Portal', 5],
      ['Business Hub', 5],
      ['Learn Plus', 5],
      ['Creative Studio', 5],
      ['Finance Tracker', 5]
    ]);

    await user.save();

    res.json({
      success: true,
      message: 'Payment confirmed successfully',
      isPaymentValid: true,
      appCredits: Object.fromEntries(user.appCredits)
    });
  } catch (error) {
    console.error('Confirm payment error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to confirm payment: ' + error.message 
    });
  }
});

// @route   GET /api/payments/history
// @desc    Get user's payment history
// @access  Protected
router.get('/history', auth, async (req, res) => {
  try {
    const payments = await Payment.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .select('-__v');

    res.json({
      success: true,
      payments
    });
  } catch (error) {
    console.error('Get payment history error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get payment history' 
    });
  }
});

module.exports = router;
