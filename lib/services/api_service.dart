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

  // PUBLIC GETTERS - FIXED NAMES
  String get apiBaseUrl => ApiService.baseUrl;  // Changed from 'baseUrl' to 'apiBaseUrl'
  
  Map<String, String> get headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  
  String? get token => _token;

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

  // For web - convert image to base64
// For web - upload image as base64
Future<Map<String, dynamic>> uploadImageWeb(String base64Image, String fileName) async {
  try {
    print('🔄 Uploading image via web (base64)...');
    print('📤 Base64 length: ${base64Image.length}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/crops/upload-image-web'), // Note the new endpoint
      headers: headers,
      body: jsonEncode({
        'image': base64Image,
        'fileName': fileName,
      }),
    );

    print('📥 Upload response status: ${response.statusCode}');
    print('📥 Upload response body: ${response.body}');

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'imageUrl': data['imageUrl'],
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to upload image',
      };
    }
  } catch (e) {
    print('❌ Upload image error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// For profile image upload (web version)
// For profile image upload (web version)
Future<Map<String, dynamic>> uploadProfileImageWeb(String base64Image, String fileName) async {
  try {
    print('🔄 Uploading profile image via web...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/profile/upload-image-web'),
      headers: headers,
      body: jsonEncode({
        'image': base64Image,
        'fileName': fileName,
      }),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Update local user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUserData = await getSavedUserData();
      
      if (currentUserData != null) {
        // Update the profile_image_url in the saved user data
        final updatedUser = {
          ...currentUserData,
          'profile_image_url': data['imageUrl'],
        };
        await prefs.setString('user_data', jsonEncode(updatedUser));
        print('✅ User profile image updated locally');
      }
      
      return {
        'success': true,
        'imageUrl': data['imageUrl'],
        'user': data['user'], // Make sure your backend returns the updated user
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to upload image',
      };
    }
  } catch (e) {
    print('❌ Upload error: $e');
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
        headers: headers,
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

  // ============ PROFILE METHODS ============

  // Get user profile data (with stats, gardens, crops)
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('🔄 Getting user profile');
      print('🌐 URL: $baseUrl/api/profile');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'profile': data['profile'],
        };
      } else {
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
// Update user profile
// Update user profile
Future<Map<String, dynamic>> updateUserProfile({
  String? name,
  String? bio,
  String? location,
  String? gardenName,
  String? gardenSize,
}) async {
  try {
    print('🔄 Updating user profile');
    print('🌐 URL: $baseUrl/api/profile');
    
    final Map<String, dynamic> updateData = {};
    
    if (name != null) updateData['name'] = name;
    if (bio != null) updateData['bio'] = bio;
    if (location != null) updateData['location'] = location;
    if (gardenName != null) updateData['garden_name'] = gardenName;
    if (gardenSize != null) updateData['garden_size'] = gardenSize;
    
    final response = await http.put(
      Uri.parse('$baseUrl/api/profile'),
      headers: headers,
      body: jsonEncode(updateData),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    if (response.statusCode == 200 && data['success'] == true) {
      // Update local user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUserData = await getSavedUserData();
      
      if (currentUserData != null) {
        // Merge updates
        final updatedUser = {...currentUserData, ...updateData};
        
        // Also update profile_image_url if it was changed in another request
        if (data['user'] != null && data['user']['profile_image_url'] != null) {
          updatedUser['profile_image_url'] = data['user']['profile_image_url'];
        }
        
        await prefs.setString('user_data', jsonEncode(updatedUser));
        print('✅ User data updated locally');
        
        return {
          'success': true,
          'user': updatedUser,
          'message': data['message'] ?? 'Profile updated successfully',
        };
      } else {
        // If no current user data, just return the API response
        return {
          'success': true,
          'user': data['user'] ?? updateData,
          'message': data['message'] ?? 'Profile updated successfully',
        };
      }
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


  // Upload crop image
Future<Map<String, dynamic>> uploadCropImage(String imagePath) async {
  try {
    print('🔄 Uploading crop image...');
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/crops/upload-image'),
    );
    
    // Add headers
    request.headers.addAll(headers);
    
    // Add file
    final file = await http.MultipartFile.fromPath('image', imagePath);
    request.files.add(file);
    
    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'imageUrl': data['imageUrl'],
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to upload image',
      };
    }
  } catch (e) {
    print('❌ Upload crop image error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}
  

  

  // Get impact stats
  Future<Map<String, dynamic>> getImpactStats() async {
    try {
      print('🔄 Getting impact stats');
      print('🌐 URL: $baseUrl/api/profile/stats/impact');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile/stats/impact'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'impact': data['impact'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch impact stats',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Get impact stats error: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // ============ GARDEN & CROPS METHODS ============

  // Get user's crops
  Future<Map<String, dynamic>> getUserCrops() async {
    try {
      print('🔄 Getting user crops');
      print('🌐 URL: $baseUrl/api/crops');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/crops'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'crops': data['crops'] ?? [],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch crops',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Get crops error: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Get user's gardens
  Future<Map<String, dynamic>> getUserGardens() async {
    try {
      print('🔄 Getting user gardens');
      print('🌐 URL: $baseUrl/api/gardens');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/gardens'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'gardens': data['gardens'] ?? [],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch gardens',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Get gardens error: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // ============ OTHER METHODS ============

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      print('=' * 50);
      print('🔄 LOGOUT STARTED');
      
      // Try to call server logout
      if (_token != null && _token!.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: headers,
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



  // Get all available shared items
Future<Map<String, dynamic>> getSharedItems() async {
  try {
    print('🔄 Getting shared items');
    print('🌐 URL: $baseUrl/api/shared-items');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/shared-items'),
      headers: headers,
    );

    print('📥 Response status: ${response.statusCode}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'items': data['items'] ?? [],
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to fetch shared items',
      };
    }
  } catch (e) {
    print('❌ Get shared items error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}



  

// ============ SHARED ITEMS METHODS ============

// Get all available shared items
Future<Map<String, dynamic>> getSharedItems() async {
  try {
    print('🔄 Getting shared items');
    print('🌐 URL: $baseUrl/api/shared-items');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/shared-items'),
      headers: headers,
    );

    print('📥 Response status: ${response.statusCode}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'items': data['items'] ?? [],
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to fetch shared items',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Get shared items error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// Get user's shared items
Future<Map<String, dynamic>> getMySharedItems() async {
  try {
    print('🔄 Getting my shared items');
    print('🌐 URL: $baseUrl/api/shared-items/my-items');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/shared-items/my-items'),
      headers: headers,
    );

    print('📥 Response status: ${response.statusCode}');
    
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'items': data['items'] ?? [],
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to fetch your shared items',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Get my shared items error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// Create new shared item
Future<Map<String, dynamic>> createSharedItem(Map<String, dynamic> itemData) async {
  try {
    print('🔄 Creating shared item');
    print('📤 Data: $itemData');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/shared-items'),
      headers: headers,
      body: jsonEncode(itemData),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {
        'success': true,
        'message': data['message'] ?? 'Item shared successfully',
        'item': data['item'],
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to share item',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Create shared item error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// Update shared item status
Future<Map<String, dynamic>> updateSharedItemStatus(String itemId, String status) async {
  try {
    print('🔄 Updating shared item $itemId status to $status');
    
    final response = await http.put(
      Uri.parse('$baseUrl/api/shared-items/$itemId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'message': data['message'] ?? 'Status updated successfully',
        'item': data['item'],
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to update status',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Update shared item error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}

// Delete shared item
Future<Map<String, dynamic>> deleteSharedItem(String itemId) async {
  try {
    print('🔄 Deleting shared item $itemId');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/api/shared-items/$itemId'),
      headers: headers,
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'message': data['message'] ?? 'Item deleted successfully',
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to delete item',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('❌ Delete shared item error: $e');
    return {
      'success': false,
      'error': 'Connection error: $e',
    };
  }
}





  

  // ============ HTTP METHODS ============

  // Generic HTTP GET method
  Future<Map<String, dynamic>> httpGet(String endpoint) async {
    try {
      print('🔄 GET $endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ HTTP GET error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Generic HTTP POST method
  Future<Map<String, dynamic>> httpPost(String endpoint, Map<String, dynamic> data) async {
    try {
      print('🔄 POST $endpoint');
      print('📤 Data: $data');
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ HTTP POST error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Generic HTTP PUT method
  Future<Map<String, dynamic>> httpPut(String endpoint, Map<String, dynamic> data) async {
    try {
      print('🔄 PUT $endpoint');
      print('📤 Data: $data');
      
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ HTTP PUT error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Generic HTTP DELETE method
  Future<Map<String, dynamic>> httpDelete(String endpoint) async {
    try {
      print('🔄 DELETE $endpoint');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ HTTP DELETE error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();

//   // IMPORTANT: Uncomment the one you're using
//   static const String baseUrl = 'https://foodsharingbackend.onrender.com'; // Production
//   // static const String baseUrl = 'http://localhost:5000'; // Local development
//   // static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  
//   String? _token;
//   bool _isInitialized = false;

//   // Get headers for authenticated requests
//   Map<String, String> get _headers {
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//     };
    
//     if (_token != null && _token!.isNotEmpty) {
//       headers['Authorization'] = 'Bearer $_token';
//     }
    
//     return headers;
//   }

//   // Initialize - must be called at app startup
//   Future<void> initialize() async {
//     if (_isInitialized) return;
    
//     print('🔄 Initializing ApiService...');
//     await _loadToken();
//     _isInitialized = true;
    
//     print('✅ ApiService initialized');
//     print('🔑 Token loaded: ${_token != null ? "YES (${_token!.substring(0, 30)}...)" : "NO"}');
//   }

//   // Load token from shared preferences
//   Future<void> _loadToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _token = prefs.getString('auth_token');
      
//       if (_token != null) {
//         print('📁 Loaded token from storage: ${_token!.substring(0, 30)}...');
//       } else {
//         print('📁 No token found in storage');
//       }
//     } catch (e) {
//       print('❌ Error loading token: $e');
//       _token = null;
//     }
//   }

//   // Save token to shared preferences
//   Future<void> _saveToken(String token) async {
//     try {
//       _token = token;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('auth_token', token);
//       print('💾 Token saved to storage: ${token.substring(0, 30)}...');
//     } catch (e) {
//       print('❌ Error saving token: $e');
//     }
//   }

//   // Clear token (logout)
//   Future<void> clearToken() async {
//     try {
//       print('🗑️ Clearing token...');
//       _token = null;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('auth_token');
//       await prefs.remove('user_data');
//       print('✅ Token cleared');
//     } catch (e) {
//       print('❌ Error clearing token: $e');
//     }
//   }

//   // Check if user is logged in
//   bool get isLoggedIn => _token != null && _token!.isNotEmpty;

//   // Get current token
//   String? get token => _token;

//   // ============ AUTH METHODS ============

//   // Login user
//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       print('=' * 50);
//       print('🔄 LOGIN STARTED');
//       print('📤 Email: $email');
//       print('🌐 URL: $baseUrl/api/auth/login');
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email.trim(),
//           'password': password,
//         }),
//       );

//       print('📥 HTTP Status: ${response.statusCode}');
//       print('📥 Response length: ${response.body.length} characters');
      
//       // Debug: Show response preview
//       if (response.body.length > 200) {
//         print('📥 Response preview: ${response.body.substring(0, 200)}...');
//       } else {
//         print('📥 Response: ${response.body}');
//       }

//       // Handle empty response
//       if (response.body.isEmpty) {
//         print('❌ ERROR: Empty response from server');
//         return {
//           'success': false,
//           'error': 'Server returned empty response',
//           'statusCode': response.statusCode,
//         };
//       }

//       // Parse JSON
//       Map<String, dynamic> data;
//       try {
//         data = jsonDecode(response.body);
//         print('✅ JSON parsed successfully');
//         print('📊 Response keys: ${data.keys.toList()}');
//       } catch (e) {
//         print('❌ JSON Parse Error: $e');
//         print('❌ Raw response: ${response.body}');
//         return {
//           'success': false,
//           'error': 'Invalid JSON response from server: $e',
//           'statusCode': response.statusCode,
//         };
//       }

//       // Handle successful login (200)
//       if (response.statusCode == 200) {
//         // Check for token in response
//         final token = data['token'];
        
//         if (token != null && token is String && token.isNotEmpty) {
//           print('✅ Token found: ${token.substring(0, 50)}...');
          
//           // Save token
//           await _saveToken(token);
          
//           // Save user data
//           if (data['user'] != null) {
//             try {
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.setString('user_data', jsonEncode(data['user']));
//               print('✅ User data saved');
//             } catch (e) {
//               print('⚠️ Warning: Could not save user data: $e');
//             }
//           }
          
//           print('✅ LOGIN SUCCESS');
//           print('=' * 50);
          
//           return {
//             'success': true,
//             'token': token,
//             'user': data['user'],
//             'message': data['message'] ?? 'Login successful',
//           };
//         } else {
//           print('❌ ERROR: Token missing or invalid in response');
//           print('❌ Token value: $token');
//           return {
//             'success': false,
//             'error': 'Authentication token missing from server response',
//             'responseData': data,
//             'statusCode': response.statusCode,
//           };
//         }
//       } 
//       // Handle error responses
//       else {
//         print('❌ ERROR: Server returned status ${response.statusCode}');
//         final errorMessage = data['error'] ?? 
//                            data['message'] ?? 
//                            'Login failed with status ${response.statusCode}';
        
//         return {
//           'success': false,
//           'error': errorMessage,
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('💥 EXCEPTION: $e');
//       print('=' * 50);
//       return {
//         'success': false,
//         'error': 'Network error: $e',
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
//       print('=' * 50);
//       print('🔄 REGISTRATION STARTED');
//       print('📤 Email: $email, Name: $name');
//       print('🌐 URL: $baseUrl/api/auth/register');
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email.trim(),
//           'password': password,
//           'name': name.trim(),
//           'phone': phone.trim(),
//         }),
//       );

//       print('📥 HTTP Status: ${response.statusCode}');
//       print('📥 Response length: ${response.body.length} characters');
      
//       // Parse JSON
//       Map<String, dynamic> data = jsonDecode(response.body);
//       print('📊 Response keys: ${data.keys.toList()}');

//       // Handle successful registration (201)
//       if (response.statusCode == 201) {
//         final token = data['token'];
        
//         if (token != null && token is String && token.isNotEmpty) {
//           print('✅ Token found: ${token.substring(0, 50)}...');
          
//           // Save token
//           await _saveToken(token);
          
//           // Save user data
//           if (data['user'] != null) {
//             try {
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.setString('user_data', jsonEncode(data['user']));
//               print('✅ User data saved');
//             } catch (e) {
//               print('⚠️ Warning: Could not save user data: $e');
//             }
//           }
          
//           print('✅ REGISTRATION SUCCESS');
//           print('=' * 50);
          
//           return {
//             'success': true,
//             'token': token,
//             'user': data['user'],
//             'message': data['message'] ?? 'Registration successful',
//           };
//         } else {
//           print('❌ ERROR: Token missing in registration response');
//           return {
//             'success': false,
//             'error': 'Authentication token missing from server response',
//             'responseData': data,
//           };
//         }
//       } else {
//         print('❌ ERROR: Registration failed');
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Registration failed',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('💥 EXCEPTION: $e');
//       print('=' * 50);
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Get current user profile
//   Future<Map<String, dynamic>> getCurrentUser() async {
//     try {
//       print('=' * 50);
//       print('🔄 GETTING CURRENT USER');
//       print('🌐 URL: $baseUrl/api/auth/me');
//       print('🔑 Using token: ${_token != null ? "YES (${_token!.substring(0, 30)}...)" : "NO"}');
      
//       if (_token == null || _token!.isEmpty) {
//         print('❌ ERROR: No authentication token available');
//         return {
//           'success': false,
//           'error': 'Not authenticated',
//         };
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/api/auth/me'),
//         headers: _headers,
//       );

//       print('📥 HTTP Status: ${response.statusCode}');
//       print('📥 Response length: ${response.body.length} characters');
      
//       // Parse JSON
//       Map<String, dynamic> data = jsonDecode(response.body);
//       print('📊 Response keys: ${data.keys.toList()}');

//       if (response.statusCode == 200 && data['success'] == true) {
//         print('✅ USER FETCH SUCCESS');
//         print('=' * 50);
//         return {
//           'success': true,
//           'user': data['user'],
//         };
//       } else {
//         print('❌ ERROR: Failed to fetch user');
//         print('❌ Server message: ${data['error']}');
        
//         // If token is invalid, clear it
//         if (response.statusCode == 401) {
//           print('⚠️ Token invalid, clearing...');
//           await clearToken();
//         }
        
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to fetch user',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('💥 EXCEPTION: $e');
//       print('=' * 50);
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // ============ PROFILE METHODS ============

//   // Get user profile data (with stats, gardens, crops)
//   Future<Map<String, dynamic>> getUserProfile() async {
//     try {
//       print('🔄 Getting user profile');
//       print('🌐 URL: $baseUrl/api/profile');
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: _headers,
//       );

//       print('📥 Response status: ${response.statusCode}');
//       print('📥 Response body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         return {
//           'success': true,
//           'profile': data['profile'],
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to fetch profile',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('❌ Get profile error: $e');
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Update user profile
//   Future<Map<String, dynamic>> updateUserProfile({
//     String? name,
//     String? bio,
//     String? location,
//     String? gardenName,
//     String? gardenSize,
//   }) async {
//     try {
//       print('🔄 Updating user profile');
//       print('🌐 URL: $baseUrl/api/profile');
      
//       final Map<String, dynamic> updateData = {};
      
//       if (name != null) updateData['name'] = name;
//       if (bio != null) updateData['bio'] = bio;
//       if (location != null) updateData['location'] = location;
//       if (gardenName != null) updateData['garden_name'] = gardenName;
//       if (gardenSize != null) updateData['garden_size'] = gardenSize;
      
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: _headers,
//         body: jsonEncode(updateData),
//       );

//       print('📥 Response status: ${response.statusCode}');
//       print('📥 Response body: ${response.body}');
      
//       final Map<String, dynamic> data = jsonDecode(response.body);
      
//       if (response.statusCode == 200 && data['success'] == true) {
//         // Update local user data in SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         final currentUserData = await getSavedUserData();
        
//         if (currentUserData != null) {
//           // Merge updates
//           final updatedUser = {...currentUserData, ...updateData};
//           await prefs.setString('user_data', jsonEncode(updatedUser));
//           print('✅ User data updated locally');
//         }
        
//         return {
//           'success': true,
//           'user': data['user'],
//           'message': data['message'] ?? 'Profile updated successfully',
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to update profile',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('❌ Update profile error: $e');
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Get impact stats
//   Future<Map<String, dynamic>> getImpactStats() async {
//     try {
//       print('🔄 Getting impact stats');
//       print('🌐 URL: $baseUrl/api/profile/stats/impact');
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile/stats/impact'),
//         headers: _headers,
//       );

//       print('📥 Response status: ${response.statusCode}');
      
//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         return {
//           'success': true,
//           'impact': data['impact'] ?? {},
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to fetch impact stats',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('❌ Get impact stats error: $e');
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // ============ GARDEN & CROPS METHODS ============

//   // Get user's crops
//   Future<Map<String, dynamic>> getUserCrops() async {
//     try {
//       print('🔄 Getting user crops');
//       print('🌐 URL: $baseUrl/api/crops');
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/crops'),
//         headers: _headers,
//       );

//       print('📥 Response status: ${response.statusCode}');
      
//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         return {
//           'success': true,
//           'crops': data['crops'] ?? [],
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to fetch crops',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('❌ Get crops error: $e');
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Get user's gardens
//   Future<Map<String, dynamic>> getUserGardens() async {
//     try {
//       print('🔄 Getting user gardens');
//       print('🌐 URL: $baseUrl/api/gardens');
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/gardens'),
//         headers: _headers,
//       );

//       print('📥 Response status: ${response.statusCode}');
      
//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         return {
//           'success': true,
//           'gardens': data['gardens'] ?? [],
//         };
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to fetch gardens',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       print('❌ Get gardens error: $e');
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // ============ OTHER METHODS ============

//   // Logout user
//   Future<Map<String, dynamic>> logout() async {
//     try {
//       print('=' * 50);
//       print('🔄 LOGOUT STARTED');
      
//       // Try to call server logout
//       if (_token != null && _token!.isNotEmpty) {
//         final response = await http.post(
//           Uri.parse('$baseUrl/api/auth/logout'),
//           headers: _headers,
//         );
//         print('📥 Logout HTTP Status: ${response.statusCode}');
//       }
      
//       // Always clear local data
//       await clearToken();
      
//       print('✅ LOGOUT COMPLETE');
//       print('=' * 50);
      
//       return {
//         'success': true,
//         'message': 'Logged out successfully',
//       };
//     } catch (e) {
//       // Still clear local data even if server call fails
//       await clearToken();
//       print('⚠️ Logout server call failed, but local data cleared: $e');
      
//       return {
//         'success': true,
//         'message': 'Logged out locally',
//       };
//     }
//   }

//   // Forgot password
//   Future<Map<String, dynamic>> forgotPassword(String email) async {
//     try {
//       print('=' * 50);
//       print('🔄 FORGOT PASSWORD');
//       print('📤 Email: $email');
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/forgot-password'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email.trim()}),
//       );

//       print('📥 HTTP Status: ${response.statusCode}');
      
//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         print('✅ PASSWORD RESET EMAIL SENT');
//         return {
//           'success': true,
//           'message': data['message'] ?? 'Password reset email sent',
//         };
//       } else {
//         print('❌ ERROR: Failed to send reset email');
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Failed to send reset email',
//         };
//       }
//     } catch (e) {
//       print('💥 EXCEPTION: $e');
//       return {
//         'success': false,
//         'error': 'Connection error: $e',
//       };
//     }
//   }

//   // Helper to get user data from SharedPreferences
//   Future<Map<String, dynamic>?> getSavedUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userDataString = prefs.getString('user_data');
      
//       if (userDataString != null && userDataString.isNotEmpty) {
//         return jsonDecode(userDataString);
//       }
//     } catch (e) {
//       print('❌ Error loading saved user data: $e');
//     }
//     return null;
//   }

//   // Validate token format
//   bool isTokenValid(String? token) {
//     if (token == null || token.isEmpty) return false;
    
//     // Basic JWT token validation (starts with eyJ and has 3 parts)
//     final parts = token.split('.');
//     if (parts.length != 3) return false;
    
//     // Check if it looks like a JWT
//     if (!token.startsWith('eyJ')) return false;
    
//     return true;
//   }

//   // Check if we need to refresh token (basic implementation)
//   Future<bool> checkTokenValidity() async {
//     if (_token == null || _token!.isEmpty) return false;
    
//     if (!isTokenValid(_token)) {
//       print('⚠️ Token format is invalid');
//       await clearToken();
//       return false;
//     }
    
//     return true;
//   }
// }
