import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CropsService {
  static const String baseUrl = 'http://localhost:3000/api'; // Update with your actual backend URL

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create a new crop
  static Future<Map<String, dynamic>> createCrop(Map<String, dynamic> cropData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/crops'),
        headers: headers,
        body: json.encode(cropData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create crop: ${response.body}');
      }
    } catch (e) {
      print('Create crop error: $e');
      rethrow;
    }
  }

  // Get gardens for the current user
  static Future<List<dynamic>> getUserGardens() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/gardens'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['gardens'] ?? [];
      } else {
        throw Exception('Failed to fetch gardens: ${response.body}');
      }
    } catch (e) {
      print('Get gardens error: $e');
      rethrow;
    }
  }

  // Update crop
  static Future<Map<String, dynamic>> updateCrop(String cropId, Map<String, dynamic> cropData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/crops/$cropId'),
        headers: headers,
        body: json.encode(cropData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update crop: ${response.body}');
      }
    } catch (e) {
      print('Update crop error: $e');
      rethrow;
    }
  }
}
