import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiClient {
  static ApiClient? _instance;
  String? _token;

  ApiClient._();

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  // Get base URL
  String get baseUrl => AppConstants.apiBaseUrl;

  // Set JWT token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Get JWT token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }

  // Clear JWT token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle different status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        clearToken();
        return {
          'success': false,
          'message': data['message'] ?? 'Authentication failed',
          'requiresLogin': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: $e',
      };
    }
  }
}
