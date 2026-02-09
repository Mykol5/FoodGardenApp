import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class CropsService {
  static final CropsService _instance = CropsService._internal();
  factory CropsService() => _instance;
  CropsService._internal();

  final ApiService _apiService = ApiService();

  // Create a new crop
  Future<Map<String, dynamic>> createCrop(Map<String, dynamic> cropData) async {
    try {
      print('🔄 Creating new crop...');
      print('📤 Data: $cropData');
      
      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}/api/crops'),
        headers: _apiService._headers,
        body: json.encode(cropData),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        print('✅ Crop created successfully');
        return {
          'success': true,
          'message': data['message'] ?? 'Crop created successfully',
          'crop': data['crop'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to create crop',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Create crop error: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Update crop
  Future<Map<String, dynamic>> updateCrop(String cropId, Map<String, dynamic> cropData) async {
    try {
      print('🔄 Updating crop $cropId...');
      print('📤 Data: $cropData');
      
      final response = await http.put(
        Uri.parse('${_apiService.baseUrl}/api/crops/$cropId'),
        headers: _apiService._headers,
        body: json.encode(cropData),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Crop updated successfully');
        return {
          'success': true,
          'message': data['message'] ?? 'Crop updated successfully',
          'crop': data['crop'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to update crop',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Update crop error: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Get user's gardens
  Future<List<Map<String, dynamic>>> getUserGardens() async {
    try {
      print('🔄 Getting user gardens...');
      
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/api/gardens'),
        headers: _apiService._headers,
      );

      print('📥 Response status: ${response.statusCode}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Gardens fetched successfully');
        return List<Map<String, dynamic>>.from(data['gardens'] ?? []);
      } else {
        print('❌ Failed to fetch gardens: ${data['error']}');
        return [];
      }
    } catch (e) {
      print('❌ Get gardens error: $e');
      return [];
    }
  }

  // Get crops by garden
  Future<List<Map<String, dynamic>>> getCropsByGarden(String gardenId) async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/api/crops/garden/$gardenId'),
        headers: _apiService._headers,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['crops'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Get garden crops error: $e');
      return [];
    }
  }

  // Get single crop
  Future<Map<String, dynamic>> getCrop(String cropId) async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/api/crops/$cropId'),
        headers: _apiService._headers,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'crop': data['crop'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch crop',
        };
      }
    } catch (e) {
      print('❌ Get crop error: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  // Delete crop
  Future<Map<String, dynamic>> deleteCrop(String cropId) async {
    try {
      final response = await http.delete(
        Uri.parse('${_apiService.baseUrl}/api/crops/$cropId'),
        headers: _apiService._headers,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Crop deleted successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to delete crop',
        };
      }
    } catch (e) {
      print('❌ Delete crop error: $e');
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }
}




// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class CropsService {
//   static const String baseUrl = 'https://foodsharingbackend.onrender.com/api'; // Update with your actual backend URL

//   static Future<Map<String, String>> _getHeaders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
    
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   // Create a new crop
//   static Future<Map<String, dynamic>> createCrop(Map<String, dynamic> cropData) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.post(
//         Uri.parse('$baseUrl/crops'),
//         headers: headers,
//         body: json.encode(cropData),
//       );

//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to create crop: ${response.body}');
//       }
//     } catch (e) {
//       print('Create crop error: $e');
//       rethrow;
//     }
//   }

//   // Get gardens for the current user
//   static Future<List<dynamic>> getUserGardens() async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.get(
//         Uri.parse('$baseUrl/gardens'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['gardens'] ?? [];
//       } else {
//         throw Exception('Failed to fetch gardens: ${response.body}');
//       }
//     } catch (e) {
//       print('Get gardens error: $e');
//       rethrow;
//     }
//   }

//   // Update crop
//   static Future<Map<String, dynamic>> updateCrop(String cropId, Map<String, dynamic> cropData) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.put(
//         Uri.parse('$baseUrl/crops/$cropId'),
//         headers: headers,
//         body: json.encode(cropData),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to update crop: ${response.body}');
//       }
//     } catch (e) {
//       print('Update crop error: $e');
//       rethrow;
//     }
//   }
// }
