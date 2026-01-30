import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Update this to your backend URL
  // For development: http://localhost:5000
  // For Flutter web/emulator: http://10.0.2.2:5000 (Android emulator)
  // For physical device: use your computer's IP address
  static const String baseUrl = 'http://10.0.2.2:5000'; // Change as needed
  
  String? _token;

  // Headers for API requests
  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Initialize token from shared preferences
  Future<void> initialize() async {
    await _loadToken();
  }

  // Load token from shared preferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token (logout)
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Check if user is logged in
  bool get isLoggedIn => _token != null;

  // Get current token
  String? get token => _token;

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token and user data
        await _saveToken(data['token']);
        
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Save token and user data
        await _saveToken(data['token']);
        
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: _headers,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch user',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: _headers,
      );

      // Clear local token regardless of server response
      await clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logged out successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Logout failed',
        };
      }
    } catch (e) {
      // Still clear local data even if server call fails
      await clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }

  // Forgot password (you'll need to implement this endpoint in backend)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset email sent',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to send reset email',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Helper method to handle API errors
  String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Map && error['error'] != null) return error['error'].toString();
    return 'An unexpected error occurred';
  }
}
