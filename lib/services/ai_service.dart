import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  // Use Google's Gemini API (free tier available)
  static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY'; // Get from https://makersuite.google.com/app/apikey
  static const String _geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Local training data storage
  List<Map<String, String>> _trainingData = [];
  
  Future<void> initialize() async {
    await _loadTrainingData();
  }
  
  Future<void> _loadTrainingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('ai_training_data');
      if (dataString != null) {
        _trainingData = List<Map<String, String>>.from(jsonDecode(dataString));
        print('✅ Loaded ${_trainingData.length} training examples');
      }
    } catch (e) {
      print('Error loading training data: $e');
    }
  }
  
  Future<void> _saveTrainingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_training_data', jsonEncode(_trainingData));
    } catch (e) {
      print('Error saving training data: $e');
    }
  }
  
  Future<void> trainWithData(String qaText) async {
    // Add to training data
    _trainingData.add({'text': qaText});
    
    // Keep only last 1000 examples to avoid storage issues
    if (_trainingData.length > 1000) {
      _trainingData = _trainingData.sublist(_trainingData.length - 1000);
    }
    
    await _saveTrainingData();
    print('✅ Trained AI with new data. Total: ${_trainingData.length} examples');
  }
  
  Future<String> askQuestion(String question) async {
    try {
      // Build context from training data
      String context = _buildContextFromTraining();
      
      final prompt = '''
You are an expert gardening assistant. Use the following Q&A examples to help answer questions about crops, gardening, pests, soil, and farming.

Training Examples:
$context

Now answer this gardening question: $question

Provide helpful, practical advice based on real gardening knowledge. If you don't know something, be honest.
''';
      
      final response = await http.post(
        Uri.parse('$_geminiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['candidates'][0]['content']['parts'][0]['text'];
        return answer;
      } else {
        // Fallback to local response if API fails
        return _getLocalResponse(question);
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return _getLocalResponse(question);
    }
  }
  
  Future<String> suggestAnswer(String question) async {
    try {
      String context = _buildContextFromTraining();
      
      final prompt = '''
You are an expert gardening assistant. Based on these Q&A examples:
$context

Suggest a helpful answer for this gardening question: "$question"

Provide a concise, practical answer that would help the gardener.
''';
      
      final response = await http.post(
        Uri.parse('$_geminiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['candidates'][0]['content']['parts'][0]['text'];
        return answer;
      } else {
        return _getLocalSuggestion(question);
      }
    } catch (e) {
      print('Error getting suggestion: $e');
      return _getLocalSuggestion(question);
    }
  }
  
  String _buildContextFromTraining() {
    if (_trainingData.isEmpty) {
      return 'No examples yet. Use general gardening knowledge.';
    }
    
    // Use last 20 examples for context
    final recentExamples = _trainingData.length > 20 
        ? _trainingData.sublist(_trainingData.length - 20)
        : _trainingData;
    
    return recentExamples.map((e) => e['text']).join('\n\n');
  }
  
  String _getLocalResponse(String question) {
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('tomato')) {
      return 'Tomatoes need 6-8 hours of sunlight daily, well-draining soil, and consistent watering. Water at the base to prevent leaf diseases.';
    } else if (lowerQuestion.contains('water')) {
      return 'Most vegetables need 1-1.5 inches of water per week. Water deeply in the morning to reduce evaporation.';
    } else if (lowerQuestion.contains('pest')) {
      return 'For common pests, try neem oil or insecticidal soap. Encourage beneficial insects like ladybugs.';
    } else if (lowerQuestion.contains('soil')) {
      return 'Good garden soil should be rich in organic matter, well-draining, and have pH between 6.0-7.0. Add compost annually.';
    } else if (lowerQuestion.contains('fertilizer')) {
      return 'Use balanced fertilizer (10-10-10) for vegetables. Organic options include compost, manure, and fish emulsion.';
    } else {
      return 'For best gardening results, ensure proper sunlight, water, soil quality, and pest management. What specific crop are you growing?';
    }
  }
  
  String _getLocalSuggestion(String question) {
    return 'Based on similar questions in our community, you might want to consider:\n\n${_getLocalResponse(question)}\n\nWould you like more specific advice?';
  }
}
