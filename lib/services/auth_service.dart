import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'mongodb_service.dart';

class AuthService {
  static AuthService? _instance;
  final MongoDBService _mongoService = MongoDBService.instance;

  // In-memory storage for demo (when MongoDB is not configured)
  final Map<String, UserModel> _demoUsers = {};

  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  // Hash password
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

      // Check if user already exists
      final existingUser = await _mongoService.findUserByUsername(username);
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Check if email already exists
      final existingEmail = await _mongoService.findUserByEmail(email);
      if (existingEmail != null) {
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      // Check demo storage
      if (_demoUsers.containsKey(username)) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Create new user with initial credits (2 for each app)
      final hashedPassword = _hashPassword(password);
      final initialCredits = <String, int>{
        'Art Lunch': 2,
        'Smart Portal': 2,
        'Business Hub': 2,
        'Learn Plus': 2,
        'Creative Studio': 2,
        'Finance Tracker': 2,
      };
      
      final newUser = UserModel(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        passwordHash: hashedPassword,
        appCredits: initialCredits,
      );

      // Save to MongoDB or demo storage
      final userId = await _mongoService.createUser(newUser);
      if (userId != null) {
        final userWithId = newUser.copyWith(id: userId);
        _demoUsers[username] = userWithId;
        
        return {
          'success': true,
          'message': 'Registration successful',
          'user': userWithId,
        };
      } else {
        // Save to demo storage
        final demoId = DateTime.now().millisecondsSinceEpoch.toString();
        final userWithId = newUser.copyWith(id: demoId);
        _demoUsers[username] = userWithId;
        
        return {
          'success': true,
          'message': 'Registration successful',
          'user': userWithId,
        };
      }
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

      final hashedPassword = _hashPassword(password);

      // Try to find user in MongoDB
      UserModel? user = await _mongoService.findUserByUsername(username);
      
      // If not found in MongoDB, check demo storage
      if (user == null && _demoUsers.containsKey(username)) {
        user = _demoUsers[username];
      }

      // Verify password
      if (user != null && user.passwordHash == hashedPassword) {
        // Save session
        await _saveSession(user);
        
        return {
          'success': true,
          'message': 'Login successful',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Invalid username or password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Save session to SharedPreferences
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, user.id ?? '');
    await prefs.setString(AppConstants.keyUsername, user.username);
    await prefs.setString(AppConstants.keyUserEmail, user.email);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
