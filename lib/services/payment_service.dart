import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:math';
import '../models/payment_model.dart';
import '../utils/constants.dart';
import 'mongodb_service.dart';

class PaymentService {
  static PaymentService? _instance;
  final MongoDBService _mongoService = MongoDBService.instance;
  bool _isStripeInitialized = false;

  PaymentService._();

  static PaymentService get instance {
    _instance ??= PaymentService._();
    return _instance!;
  }

  // Initialize Stripe
  Future<void> initializeStripe() async {
    if (_isStripeInitialized) return;

    try {
      if (AppConstants.stripePublishableKey != 'YOUR_STRIPE_PUBLISHABLE_KEY') {
        Stripe.publishableKey = AppConstants.stripePublishableKey;
        await Stripe.instance.applySettings();
        _isStripeInitialized = true;
        print('✅ Stripe initialized');
      } else {
        print('⚠️  Stripe not configured - using simulated payments');
      }
    } catch (e) {
      print('❌ Stripe initialization failed: $e');
      print('Using simulated payments');
    }
  }

  // Generate transaction ID
  String _generateTransactionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(999999).toString().padLeft(6, '0');
    return 'TXN$timestamp$randomPart';
  }

  // Validate card number (basic Luhn algorithm)
  bool validateCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 13 || cleaned.length > 19) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  // Validate expiry date
  bool validateExpiryDate(String expiry) {
    if (!expiry.contains('/')) return false;
    final parts = expiry.split('/');
    if (parts.length != 2) return false;

    try {
      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');
      
      if (month < 1 || month > 12) return false;

      final now = DateTime.now();
      final expiryDate = DateTime(year, month);
      return expiryDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  // Process payment (simulated for demo)
  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
    required String address,
    required String city,
    required String zipCode,
    required String country,
  }) async {
    try {
      // Validate inputs
      if (!validateCardNumber(cardNumber)) {
        return {
          'success': false,
          'message': 'Invalid card number',
        };
      }

      if (!validateExpiryDate(expiryDate)) {
        return {
          'success': false,
          'message': 'Invalid or expired card',
        };
      }

      if (cvv.length < 3 || cvv.length > 4) {
        return {
          'success': false,
          'message': 'Invalid CVV',
        };
      }

      if (amount <= 0) {
        return {
          'success': false,
          'message': 'Invalid amount',
        };
      }

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate transaction ID
      final transactionId = _generateTransactionId();

      // Get last 4 digits of card
      final cardLast4 = cardNumber.replaceAll(RegExp(r'\s+'), '').substring(
            cardNumber.replaceAll(RegExp(r'\s+'), '').length - 4,
          );

      // Create payment record
      final payment = PaymentModel(
        userId: userId,
        amount: amount,
        cardLast4: cardLast4,
        cardHolder: cardHolder,
        transactionId: transactionId,
        status: 'completed',
        recipientCard: AppConstants.recipientCardNumber,
      );

      // Save to database
      final paymentId = await _mongoService.createPayment(payment);

      print('✅ Payment processed successfully');
      print('   Transaction ID: $transactionId');
      print('   Amount: \$$amount');
      print('   From card: ****$cardLast4');
      print('   To: ${AppConstants.recipientCardNumber}');

      return {
        'success': true,
        'message': 'Payment processed successfully',
        'transactionId': transactionId,
        'paymentId': paymentId,
        'amount': amount,
      };
    } catch (e) {
      print('❌ Payment failed: $e');
      return {
        'success': false,
        'message': 'Payment processing failed: $e',
      };
    }
  }

  // Process payment with Stripe (real integration)
  Future<Map<String, dynamic>> processPaymentWithStripe({
    required String userId,
    required double amount,
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
  }) async {
    if (!_isStripeInitialized) {
      return processPayment(
        userId: userId,
        amount: amount,
        cardNumber: cardNumber,
        cardHolder: cardHolder,
        expiryDate: expiryDate,
        cvv: cvv,
        address: '',
        city: '',
        zipCode: '',
        country: '',
      );
    }

    try {
      // Create payment intent on your backend
      // This is a placeholder - you need to implement your backend
      final paymentIntentResponse = await _createPaymentIntent(amount);
      
      if (paymentIntentResponse['success']) {
        // Confirm payment
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: paymentIntentResponse['clientSecret'],
        );

        return {
          'success': true,
          'message': 'Payment successful',
          'transactionId': paymentIntentResponse['paymentIntentId'],
        };
      }

      return {
        'success': false,
        'message': 'Failed to create payment intent',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment failed: $e',
      };
    }
  }

  // Create payment intent (requires backend)
  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    // This should call your backend API to create a payment intent
    // For now, return simulated response
    return {
      'success': false,
      'message': 'Backend not configured',
    };
  }
}
