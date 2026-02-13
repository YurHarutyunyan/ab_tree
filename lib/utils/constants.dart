import 'package:flutter/material.dart';

class AppConstants {
  // MongoDB Configuration
  // Docker MongoDB connection
  static const String mongoDbAppId = 'YOUR_MONGODB_APP_ID';
  static const String mongoDbConnectionString = 'mongodb://localhost:27017/ab_tree_db';
  static const String databaseName = 'ab_tree_db';
  static const String usersCollection = 'users';
  static const String paymentsCollection = 'payments';

  // Stripe Configuration
  // TODO: Replace with your Stripe publishable key (test mode)
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  // TODO: Replace with your Stripe secret key (keep this secure!)
  static const String stripeSecretKey = 'YOUR_STRIPE_SECRET_KEY';

  // Payment Configuration
  static const String recipientCardNumber = '**** **** **** 5678';
  static const String recipientName = 'AB Tree Services Inc.';
  static const String paymentPurpose = 'Service Payment';
  static const double defaultPaymentAmount = 100.00;

  // App Colors
  static const Color primaryOrange = Color(0xFFFF6A00);
  static const Color secondaryOrange = Color(0xFFFF8C00);
  static const Color lightOrange = Color(0xFFFF9500);
  static const Color darkOrange = Color(0xFFFF4D00);
  static const Color textOrange = Color(0xFFD35400);
  static const Color brownText = Color(0xFF7A4A1C);
  
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryBlue = Color(0xFF1E40AF);
  
  static const Color lightBackground = Color(0xFFFFF3E0);
  static const Color cardBackground = Color(0xFFFFFEF5);
  static const Color borderColor = Color(0xFFFFD9A3);

  // Gradients
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightOrange, darkOrange],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, secondaryBlue],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [secondaryOrange, primaryOrange],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
  );

  // Countries list for dropdown
  static const List<Map<String, String>> countries = [
    {'code': 'US', 'name': 'United States'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'UK', 'name': 'United Kingdom'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'OTHER', 'name': 'Other'},
  ];

  // Validation regex
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp passwordRegex = RegExp(
    r'^.{6,}$', // At least 6 characters
  );

  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUsername = 'username';
  static const String keyUserEmail = 'userEmail';
}
