import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AuthService {
  static AuthService? _instance;
  final ApiClient _apiClient = ApiClient.instance;

  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  // Hash password (for compatibility - backend handles actual hashing)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'All fields are required',
        };
      }

      // Validate email format
      if (!AppConstants.emailRegex.hasMatch(email)) {
        return {
          'success': false,
          'message': 'Invalid email format',
        };
      }

      // Validate password length
      if (!AppConstants.passwordRegex.hasMatch(password)) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters',
        };
      }

      // Call API to register
      final response = await _apiClient.post(
        '/api/auth/register',
        body: {
          'username': username,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response['success'] == true) {
        // Store JWT token
        final token = response['token'];
        if (token != null) {
          await _apiClient.setToken(token);
        }

        // Store user info in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userData = response['user'] as Map<String, dynamic>;
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', userData['id']);
        await prefs.setString('username', userData['username']);
        await prefs.setString('userEmail', userData['email']);

        return response;
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (username.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Username and password are required',
        };
      }

      // Call API to login
      final response = await _apiClient.post(
        '/api/auth/login',
        body: {
          'username': username,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response['success'] == true) {
        // Store JWT token
        final token = response['token'];
        if (token != null) {
          await _apiClient.setToken(token);
        }

        // Store user info in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userData = response['user'] as Map<String, dynamic>;
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setString(AppConstants.keyUserId, userData['id']);
        await prefs.setString(AppConstants.keyUsername, userData['username']);
        await prefs.setString(AppConstants.keyUserEmail, userData['email']);

        return response;
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Get current user info
  Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(AppConstants.keyUserId),
      'username': prefs.getString(AppConstants.keyUsername),
      'email': prefs.getString(AppConstants.keyUserEmail),
    };
  }

  // Logout
  Future<void> logout() async {
    await _apiClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
