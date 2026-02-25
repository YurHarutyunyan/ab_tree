const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  firstName: {
    type: String,
    required: true,
    trim: true
  },
  lastName: {
    type: String,
    required: true,
    trim: true
  },
  passwordHash: {
    type: String,
    required: true
  },
  phone: {
    type: String,
    default: null
  },
  isPaymentValid: {
    type: Boolean,
    default: false
  },
  appCredits: {
    type: Map,
    of: Number,
    default: () => new Map([
      ['Art Lunch', 2],
      ['Smart Portal', 2],
      ['Business Hub', 2],
      ['Learn Plus', 2],
      ['Creative Studio', 2],
      ['Finance Tracker', 2]
    ])
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for faster queries
userSchema.index({ username: 1 });
userSchema.index({ email: 1 });

module.exports = mongoose.model('User', userSchema);
