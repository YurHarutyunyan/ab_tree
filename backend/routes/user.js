const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const User = require('../models/User');

// @route   GET /api/user/profile
// @desc    Get user profile
// @access  Protected
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-passwordHash');
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    res.json({
      success: true,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        isPaymentValid: user.isPaymentValid,
        appCredits: Object.fromEntries(user.appCredits),
        createdAt: user.createdAt
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get profile' 
    });
  }
});

// @route   PUT /api/user/profile
// @desc    Update user profile (email and phone)
// @access  Protected
router.put('/profile', [
  auth,
  body('email').optional().isEmail().normalizeEmail().withMessage('Invalid email format'),
  body('phone').optional().trim()
], async (req, res) => {
  try {
    // Validate inputs
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        success: false, 
        message: errors.array()[0].msg 
      });
    }

    const { email, phone } = req.body;
    const updateData = {};

    if (email) {
      // Check if email is already used by another user
      const existingEmail = await User.findOne({ 
        email, 
        _id: { $ne: req.userId } 
      });
      if (existingEmail) {
        return res.status(400).json({ 
          success: false, 
          message: 'Email already in use' 
        });
      }
      updateData.email = email;
    }

    if (phone !== undefined) {
      updateData.phone = phone;
    }

    const user = await User.findByIdAndUpdate(
      req.userId, 
      updateData, 
      { new: true, runValidators: true }
    ).select('-passwordHash');

    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone
      }
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update profile' 
    });
  }
});

// @route   GET /api/user/credits/:appName
// @desc    Get credits for a specific app
// @access  Protected
router.get('/credits/:appName', auth, async (req, res) => {
  try {
    const { appName } = req.params;
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    // Get credits for the app
    let credits = user.appCredits.get(appName);
    
    // If app not found, initialize with default based on payment status
    if (credits === undefined) {
      credits = user.isPaymentValid ? 5 : 2;
      user.appCredits.set(appName, credits);
      await user.save();
    }

    res.json({
      success: true,
      appName,
      credits,
      isPaymentValid: user.isPaymentValid
    });
  } catch (error) {
    console.error('Get credits error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get credits' 
    });
  }
});

// @route   POST /api/user/credits/:appName/buy
// @desc    Use a credit (decrement) for a specific app
// @access  Protected
router.post('/credits/:appName/buy', auth, async (req, res) => {
  try {
    const { appName } = req.params;
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    // Get current credits
    let credits = user.appCredits.get(appName);
    
    if (credits === undefined) {
      credits = user.isPaymentValid ? 5 : 2;
    }

    // Check if user has credits
    if (credits <= 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'No credits available' 
      });
    }

    // Decrement credit
    const newCredits = credits - 1;
    user.appCredits.set(appName, newCredits);
    await user.save();

    res.json({
      success: true,
      message: 'Purchase successful',
      appName,
      credits: newCredits
    });
  } catch (error) {
    console.error('Buy credit error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to process purchase' 
    });
  }
});

module.exports = router;
