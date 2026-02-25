import 'api_client.dart';

class ApiDataService {
  static ApiDataService? _instance;
  final ApiClient _apiClient = ApiClient.instance;

  ApiDataService._();

  static ApiDataService get instance {
    _instance ??= ApiDataService._();
    return _instance!;
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      return await _apiClient.get('/api/user/profile');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get profile: $e',
      };
    }
  }

  // Update user profile (email and phone)
  Future<Map<String, dynamic>> updateUserProfile({
    String? email,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      return await _apiClient.put('/api/user/profile', body: body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile: $e',
      };
    }
  }

  // Get credits for a specific app
  Future<Map<String, dynamic>> getAppCredits(String appName) async {
    try {
      final encodedAppName = Uri.encodeComponent(appName);
      return await _apiClient.get('/api/user/credits/$encodedAppName');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get credits: $e',
      };
    }
  }

  // Use a credit (buy/decrement) for a specific app
  Future<Map<String, dynamic>> buyWithCredit(String appName) async {
    try {
      final encodedAppName = Uri.encodeComponent(appName);
      return await _apiClient.post('/api/user/credits/$encodedAppName/buy');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to process purchase: $e',
      };
    }
  }

  // Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    String currency = 'usd',
  }) async {
    try {
      return await _apiClient.post(
        '/api/payments/create-intent',
        body: {
          'amount': amount,
          'currency': currency,
        },
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create payment intent: $e',
      };
    }
  }

  // Confirm payment
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentId) async {
    try {
      return await _apiClient.post(
        '/api/payments/confirm',
        body: {
          'paymentIntentId': paymentIntentId,
        },
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to confirm payment: $e',
      };
    }
  }

  // Get payment history
  Future<Map<String, dynamic>> getPaymentHistory() async {
    try {
      return await _apiClient.get('/api/payments/history');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get payment history: $e',
      };
    }
  }
}
