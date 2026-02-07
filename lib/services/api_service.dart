import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // IMPORTANT: Uncomment the one you're using
  static const String baseUrl = 'https://foodsharingbackend.onrender.com'; // Production
  // static const String baseUrl = 'http://localhost:5000'; // Local development
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  
  String? _token;
  bool _isInitialized = false;

  // Get headers for authenticated requests
  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Initialize - must be called at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🔄 Initializing ApiService...');
    await _loadToken();
    _isInitialized = true;
    
    print('✅ ApiService initialized');
    print('🔑 Token loaded: ${_token != null ? "YES (${_token!.substring(0, 30)}...)" : "NO"}');
  }

  // Load token from shared preferences
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      
      if (_token != null) {
        print('📁 Loaded token from storage: ${_token!.substring(0, 30)}...');
      } else {
        print('📁 No token found in storage');
      }
    } catch (e) {
      print('❌ Error loading token: $e');
      _token = null;
    }
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    try {
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('💾 Token saved to storage: ${token.substring(0, 30)}...');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  // Clear token (logout)
  Future<void> clearToken() async {
    try {
      print('🗑️ Clearing token...');
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print('✅ Token cleared');
    } catch (e) {
      print('❌ Error clearing token: $e');
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // Get current token
  String? get token => _token;

  // ============ AUTH METHODS ============

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('=' * 50);
      print('🔄 LOGIN STARTED');
      print('📤 Email: $email');
      print('🌐 URL: $baseUrl/api/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      print('📥 HTTP Status: ${response.statusCode}');
      print('📥 Response length: ${response.body.length} characters');
      
      // Debug: Show response preview
      if (response.body.length > 200) {
        print('📥 Response preview: ${response.body.substring(0, 200)}...');
      } else {
        print('📥 Response: ${response.body}');
      }

      // Handle empty response
      if (response.body.isEmpty) {
        print('❌ ERROR: Empty response from server');
        return {
          'success': false,
          'error': 'Server returned empty response',
          'statusCode': response.statusCode,
        };
      }

      // Parse JSON
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
        print('✅ JSON parsed successfully');
        print('📊 Response keys: ${data.keys.toList()}');
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        print('❌ Raw response: ${response.body}');
        return {
          'success': false,
          'error': 'Invalid JSON response from server: $e',
          'statusCode': response.statusCode,
        };
      }

      // Handle successful login (200)
      if (response.statusCode == 200) {
        // Check for token in response
        final token = data['token'];
        
        if (token != null && token is String && token.isNotEmpty) {
          print('✅ Token found: ${token.substring(0, 50)}...');
          
          // Save token
          await _saveToken(token);
          
          // Save user data
          if (data['user'] != null) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_data', jsonEncode(data['user']));
              print('✅ User data saved');
            } catch (e) {
              print('⚠️ Warning: Could not save user data: $e');
            }
          }
          
          print('✅ LOGIN SUCCESS');
          print('=' * 50);
          
          return {
            'success': true,
            'token': token,
            'user': data['user'],
            'message': data['message'] ?? 'Login successful',
          };
        } else {
          print('❌ ERROR: Token missing or invalid in response');
          print('❌ Token value: $token');
          return {
            'success': false,
            'error': 'Authentication token missing from server response',
            'responseData': data,
            'statusCode': response.statusCode,
          };
        }
      } 
      // Handle error responses
      else {
        print('❌ ERROR: Server returned status ${response.statusCode}');
        final errorMessage = data['error'] ?? 
                           data['message'] ?? 
                           'Login failed with status ${response.statusCode}';
        
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('💥 EXCEPTION: $e');
      print('=' * 50);
      return {
        'success': false,
        'error': 'Network error: $e',
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
      print('=' * 50);
      print('🔄 REGISTRATION STARTED');
      print('📤 Email: $email, Name: $name');
      print('🌐 URL: $baseUrl/api/auth/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
          'phone': phone.trim(),
        }),
      );

      print('📥 HTTP Status: ${response.statusCode}');
      print('📥 Response length: ${response.body.length} characters');
      
      // Parse JSON
      Map<String, dynamic> data = jsonDecode(response.body);
      print('📊 Response keys: ${data.keys.toList()}');

      // Handle successful registration (201)
      if (response.statusCode == 201) {
        final token = data['token'];
        
        if (token != null && token is String && token.isNotEmpty) {
          print('✅ Token found: ${token.substring(0, 50)}...');
          
          // Save token
          await _saveToken(token);
          
          // Save user data
          if (data['user'] != null) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_data', jsonEncode(data['user']));
              print('✅ User data saved');
            } catch (e) {
              print('⚠️ Warning: Could not save user data: $e');
            }
          }
          
          print('✅ REGISTRATION SUCCESS');
          print('=' * 50);
          
          return {
            'success': true,
            'token': token,
            'user': data['user'],
            'message': data['message'] ?? 'Registration successful',
          };
        } else {
          print('❌ ERROR: Token missing in registration response');
          return {
            'success': false,
            'error': 'Authentication token missing from server response',
            'responseData': data,
          };
        }
      } else {
        print('❌ ERROR: Registration failed');
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('💥 EXCEPTION: $e');
      print('=' * 50);
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('=' * 50);
      print('🔄 GETTING CURRENT USER');
      print('🌐 URL: $baseUrl/api/auth/me');
      print('🔑 Using token: ${_token != null ? "YES (${_token!.substring(0, 30)}...)" : "NO"}');
      
      if (_token == null || _token!.isEmpty) {
        print('❌ ERROR: No authentication token available');
        return {
          'success': false,
          'error': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: _headers,
      );

      print('📥 HTTP Status: ${response.statusCode}');
      print('📥 Response length: ${response.body.length} characters');
      
      // Parse JSON
      Map<String, dynamic> data = jsonDecode(response.body);
      print('📊 Response keys: ${data.keys.toList()}');

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ USER FETCH SUCCESS');
        print('=' * 50);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        print('❌ ERROR: Failed to fetch user');
        print('❌ Server message: ${data['error']}');
        
        // If token is invalid, clear it
        if (response.statusCode == 401) {
          print('⚠️ Token invalid, clearing...');
          await clearToken();
        }
        
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch user',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('💥 EXCEPTION: $e');
      print('=' * 50);
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      print('=' * 50);
      print('🔄 LOGOUT STARTED');
      
      // Try to call server logout
      if (_token != null && _token!.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: _headers,
        );
        print('📥 Logout HTTP Status: ${response.statusCode}');
      }
      
      // Always clear local data
      await clearToken();
      
      print('✅ LOGOUT COMPLETE');
      print('=' * 50);
      
      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      // Still clear local data even if server call fails
      await clearToken();
      print('⚠️ Logout server call failed, but local data cleared: $e');
      
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('=' * 50);
      print('🔄 FORGOT PASSWORD');
      print('📤 Email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim()}),
      );

      print('📥 HTTP Status: ${response.statusCode}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ PASSWORD RESET EMAIL SENT');
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset email sent',
        };
      } else {
        print('❌ ERROR: Failed to send reset email');
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to send reset email',
        };
      }
    } catch (e) {
      print('💥 EXCEPTION: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Helper to get user data from SharedPreferences
  Future<Map<String, dynamic>?> getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null && userDataString.isNotEmpty) {
        return jsonDecode(userDataString);
      }
    } catch (e) {
      print('❌ Error loading saved user data: $e');
    }
    return null;
  }

  // Validate token format
  bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    
    // Basic JWT token validation (starts with eyJ and has 3 parts)
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    // Check if it looks like a JWT
    if (!token.startsWith('eyJ')) return false;
    
    return true;
  }

  // Check if we need to refresh token (basic implementation)
  Future<bool> checkTokenValidity() async {
    if (_token == null || _token!.isEmpty) return false;
    
    if (!isTokenValid(_token)) {
      print('⚠️ Token format is invalid');
      await clearToken();
      return false;
    }
    
    return true;
  }
}


// In ApiService class, add these methods:

// Get user profile from backend
Future<Map<String, dynamic>> getUserProfile(String userId) async {
  try {
    print('🔄 Getting user profile for: $userId');
    print('🌐 URL: $baseUrl/api/users/$userId');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: _headers,
    );

    print('📥 Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'success': true,
        'profile': data,
      };
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to fetch profile',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Get profile error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// Update user profile
Future<Map<String, dynamic>> updateUserProfile({
  required String name,
  String? phone,
  String? bio,
  String? location,
  String? gardenName,
  String? gardenSize,
  String? profileImageUrl,
}) async {
  try {
    print('🔄 Updating user profile');
    print('🌐 URL: $baseUrl/api/users/update');
    
    final Map<String, dynamic> updateData = {
      'name': name,
    };
    
    if (phone != null) updateData['phone'] = phone;
    if (bio != null) updateData['bio'] = bio;
    if (location != null) updateData['location'] = location;
    if (gardenName != null) updateData['garden_name'] = gardenName;
    if (gardenSize != null) updateData['garden_size'] = gardenSize;
    if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;
    
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/update'),
      headers: _headers,
      body: jsonEncode(updateData),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response: ${response.body}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      // Update local user data
      final prefs = await SharedPreferences.getInstance();
      final currentUserData = await getSavedUserData();
      
      if (currentUserData != null) {
        // Merge updates
        final updatedUser = {...currentUserData, ...updateData};
        await prefs.setString('user_data', jsonEncode(updatedUser));
        print('✅ User data updated locally');
      }
      
      return {
        'success': true,
        'user': data['user'],
        'message': data['message'] ?? 'Profile updated successfully',
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to update profile',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Update profile error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// Get user's sharing history
Future<Map<String, dynamic>> getSharingHistory() async {
  try {
    print('🔄 Getting sharing history');
    print('🌐 URL: $baseUrl/api/users/sharing-history');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/sharing-history'),
      headers: _headers,
    );

    print('📥 Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'success': true,
        'history': data['history'] ?? [],
        'stats': data['stats'] ?? {},
      };
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to fetch sharing history',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Get sharing history error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// Get user's garden crops
Future<Map<String, dynamic>> getUserGardenCrops() async {
  try {
    print('🔄 Getting user garden crops');
    print('🌐 URL: $baseUrl/api/users/garden-crops');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/garden-crops'),
      headers: _headers,
    );

    print('📥 Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'success': true,
        'crops': data['crops'] ?? [],
      };
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to fetch garden crops',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Get garden crops error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();

//   // Update this to your backend URL
//   // For development: http://localhost:5000
//   // For Flutter web/emulator: http://10.0.2.2:5000 (Android emulator)
//   // For physical device: use your computer's IP address
//   static const String baseUrl = 'https://foodsharingbackend.onrender.com'; // Change as needed
  
//   String? _token;

//   // Headers for API requests
//   Map<String, String> get _headers {
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
    
//     if (_token != null) {
//       headers['Authorization'] = 'Bearer $_token';
//     }
    
//     return headers;
//   }

//   // Initialize token from shared preferences
//   Future<void> initialize() async {
//     await _loadToken();
//   }

//   // Load token from shared preferences
//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('auth_token');
//   }

//   // Save token to shared preferences
//   Future<void> _saveToken(String token) async {
//     _token = token;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('auth_token', token);
//   }

//   // Clear token (logout)
//   Future<void> clearToken() async {
//     _token = null;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auth_token');
//   }

//   // Check if user is logged in
//   bool get isLoggedIn => _token != null;

//   // Get current token
//   String? get token => _token;

//   // Login user
//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'password': password,
//         }),
//       );

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         // Save token and user data
//         await _saveToken(data['token']);
        
//         // Save user data to shared preferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user_data', jsonEncode(data['user']));
        
//         return {
//           'success': true,
//           'token': data['token'],
//           'user': data['user'],
//           'message': data['message'] ?? 'Login successful',
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Login failed',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Register user
//   Future<Map<String, dynamic>> register({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'password': password,
//           'name': name,
//           'phone': phone,
//         }),
//       );

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 201 && data['success'] == true) {
//         // Save token and user data
//         await _saveToken(data['token']);
        
//         // Save user data to shared preferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user_data', jsonEncode(data['user']));
        
//         return {
//           'success': true,
//           'token': data['token'],
//           'user': data['user'],
//           'message': data['message'] ?? 'Registration successful',
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Registration failed',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Get current user profile
//   Future<Map<String, dynamic>> getCurrentUser() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/auth/me'),
//         headers: _headers,
//       );

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         return {
//           'success': true,
//           'user': data['user'],
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to fetch user',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Logout user
//   Future<Map<String, dynamic>> logout() async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/logout'),
//         headers: _headers,
//       );

//       // Clear local token regardless of server response
//       await clearToken();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('user_data');

//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'message': 'Logged out successfully',
//         };
//       } else {
//         return {
//           'success': false,
//           'error': 'Logout failed',
//         };
//       }
//     } catch (e) {
//       // Still clear local data even if server call fails
//       await clearToken();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('user_data');
      
//       return {
//         'success': true,
//         'message': 'Logged out locally',
//       };
//     }
//   }

//   // Forgot password (you'll need to implement this endpoint in backend)
//   Future<Map<String, dynamic>> forgotPassword(String email) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/forgot-password'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email}),
//       );

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'message': data['message'] ?? 'Password reset email sent',
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to send reset email',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Helper method to handle API errors
//   String getErrorMessage(dynamic error) {
//     if (error is String) return error;
//     if (error is Map && error['error'] != null) return error['error'].toString();
//     return 'An unexpected error occurred';
//   }
// }
