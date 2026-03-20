import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  int _selectedSegment = 0; // 0 = Zone Map, 1 = Community Q&A
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  // Hardiness Zones Data (USDA Zones)
  final Map<String, ZoneInfo> _hardinessZones = {
    'Zone 1': ZoneInfo(
      name: 'Zone 1',
      tempRange: 'Below -50°F',
      color: Color(0xFF2C3E5C),
      description: 'Extreme cold, very short growing season',
      suitableCrops: ['Potatoes', 'Kale', 'Carrots', 'Turnips'],
    ),
    'Zone 2': ZoneInfo(
      name: 'Zone 2',
      tempRange: '-50°F to -40°F',
      color: Color(0xFF3E5A8A),
      description: 'Very cold, short growing season',
      suitableCrops: ['Potatoes', 'Cabbage', 'Peas', 'Radishes'],
    ),
    'Zone 3': ZoneInfo(
      name: 'Zone 3',
      tempRange: '-40°F to -30°F',
      color: Color(0xFF4F7AB3),
      description: 'Cold winters, moderate summers',
      suitableCrops: ['Broccoli', 'Cauliflower', 'Lettuce', 'Spinach'],
    ),
    'Zone 4': ZoneInfo(
      name: 'Zone 4',
      tempRange: '-30°F to -20°F',
      color: Color(0xFF609CD9),
      description: 'Cold climate, good for hardy vegetables',
      suitableCrops: ['Tomatoes', 'Peppers', 'Beans', 'Corn'],
    ),
    'Zone 5': ZoneInfo(
      name: 'Zone 5',
      tempRange: '-20°F to -10°F',
      color: Color(0xFF71BDFF),
      description: 'Temperate, diverse growing options',
      suitableCrops: ['Apples', 'Cherries', 'Peaches', 'Grapes'],
    ),
    'Zone 6': ZoneInfo(
      name: 'Zone 6',
      tempRange: '-10°F to 0°F',
      color: Color(0xFF8ACC66),
      description: 'Mild winters, long growing season',
      suitableCrops: ['Strawberries', 'Blueberries', 'Raspberries'],
    ),
    'Zone 7': ZoneInfo(
      name: 'Zone 7',
      tempRange: '0°F to 10°F',
      color: Color(0xFFA5D95E),
      description: 'Warm, excellent for fruit trees',
      suitableCrops: ['Citrus', 'Figs', 'Pomegranates', 'Olives'],
    ),
    'Zone 8': ZoneInfo(
      name: 'Zone 8',
      tempRange: '10°F to 20°F',
      color: Color(0xFFBFF055),
      description: 'Warm, subtropical plants thrive',
      suitableCrops: ['Avocados', 'Bananas', 'Mangoes', 'Papayas'],
    ),
    'Zone 9': ZoneInfo(
      name: 'Zone 9',
      tempRange: '20°F to 30°F',
      color: Color(0xFFD9FF4C),
      description: 'Hot, year-round growing possible',
      suitableCrops: ['Tomatoes', 'Eggplant', 'Okra', 'Sweet Potatoes'],
    ),
    'Zone 10': ZoneInfo(
      name: 'Zone 10',
      tempRange: '30°F to 40°F',
      color: Color(0xFFF2F242),
      description: 'Tropical, year-round gardening',
      suitableCrops: ['Pineapples', 'Coconuts', 'Tropical Fruits'],
    ),
  };

  LatLng? _userLocation;
  String? _userZone;
  bool _isLoadingLocation = true;
  GoogleMapController? _mapController;
  WebSocketChannel? _channel;
  List<QuestionPost> _questions = [];
  bool _isLoadingQuestions = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Vegetables', 'Fruits', 'Herbs', 'Pests', 'Soil', 'Watering'];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadQuestions();
    _connectWebSocket();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _userZone = _getZoneFromCoordinates(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  String _getZoneFromCoordinates(double lat, double lng) {
    // Simplified zone detection based on latitude
    // In a real app, you'd use a more sophisticated API
    if (lat > 60) return 'Zone 1';
    if (lat > 55) return 'Zone 2';
    if (lat > 50) return 'Zone 3';
    if (lat > 45) return 'Zone 4';
    if (lat > 40) return 'Zone 5';
    if (lat > 35) return 'Zone 6';
    if (lat > 30) return 'Zone 7';
    if (lat > 25) return 'Zone 8';
    if (lat > 20) return 'Zone 9';
    return 'Zone 10';
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_userLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 5),
      );
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
    });

    try {
      final result = await _apiService.getCropQuestions();
      if (result['success'] == true) {
        setState(() {
          _questions = List<QuestionPost>.from(
            result['questions'].map((q) => QuestionPost.fromJson(q))
          );
        });
      }
    } catch (e) {
      print('Error loading questions: $e');
      // Add sample data for demo
      _loadSampleQuestions();
    } finally {
      setState(() {
        _isLoadingQuestions = false;
      });
    }
  }

  void _loadSampleQuestions() {
    _questions = [
      QuestionPost(
        id: '1',
        title: 'Why are my tomato leaves turning yellow?',
        description: 'The lower leaves on my tomato plants are turning yellow with brown spots. What could be causing this?',
        category: 'Vegetables',
        author: 'Sarah M.',
        authorImage: '',
        answers: 3,
        likes: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        solved: false,
      ),
      QuestionPost(
        id: '2',
        title: 'Best organic pest control for aphids?',
        description: 'My rose bushes are covered in aphids. Looking for natural solutions without chemicals.',
        category: 'Pests',
        author: 'Michael K.',
        authorImage: '',
        answers: 5,
        likes: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        solved: true,
      ),
      QuestionPost(
        id: '3',
        title: 'How often should I water herbs in containers?',
        description: 'Growing basil, mint, and rosemary in pots. Not sure about the watering schedule.',
        category: 'Herbs',
        author: 'Emma L.',
        authorImage: '',
        answers: 4,
        likes: 9,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        solved: false,
      ),
    ];
  }

  void _connectWebSocket() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (token == null) return;
      
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://foodsharingbackend.onrender.com/ws/questions?token=$token'),
      );

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'new_question') {
            _addNewQuestion(data['question']);
          } else if (data['type'] == 'new_answer') {
            _updateQuestionWithAnswer(data['questionId'], data['answer']);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
      );
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  void _addNewQuestion(Map<String, dynamic> questionData) {
    setState(() {
      _questions.insert(0, QuestionPost.fromJson(questionData));
    });
  }

  void _updateQuestionWithAnswer(String questionId, Map<String, dynamic> answerData) {
    setState(() {
      final index = _questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _questions[index].answers += 1;
      }
    });
  }

  Future<void> _postQuestion() async {
    if (_questionController.text.trim().isEmpty) return;

    final question = QuestionPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _questionController.text.trim(),
      description: '',
      category: _selectedCategory,
      author: 'You',
      authorImage: '',
      answers: 0,
      likes: 0,
      createdAt: DateTime.now(),
      solved: false,
    );

    setState(() {
      _questions.insert(0, question);
      _questionController.clear();
    });

    try {
      await _apiService.postCropQuestion({
        'title': question.title,
        'category': _selectedCategory,
      });
    } catch (e) {
      print('Error posting question: $e');
    }
  }

  void _showQuestionDetail(QuestionPost question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuestionDetailSheet(
        question: question,
        onAnswerAdded: () {
          _refreshQuestions();
        },
      ),
    );
  }

  void _refreshQuestions() {
    _loadQuestions();
  }

  List<QuestionPost> get _filteredQuestions {
    if (_selectedCategory == 'All') {
      return _questions;
    }
    return _questions.where((q) => q.category == _selectedCategory).toList();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _searchController.dispose();
    _replyController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopBar(isDarkMode),
            
            // Segmented Control
            _buildSegmentedControl(isDarkMode),
            
            // Search Bar (only for Q&A)
            if (_selectedSegment == 1) _buildSearchBar(isDarkMode),
            
            // Main Content
            Expanded(
              child: _selectedSegment == 0
                  ? _buildZoneMapSection(isDarkMode)
                  : _buildCommunitySection(isDarkMode),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedSegment == 1
          ? FloatingActionButton(
              onPressed: () {
                _showAskQuestionDialog();
              },
              backgroundColor: const Color(0xFF39AC86),
              child: const Icon(Icons.question_answer, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTopBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF212C28).withOpacity(0.8)
            : const Color(0xFFF9F8F6).withOpacity(0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu,
              color: Color(0xFF39AC86),
              size: 20,
            ),
          ),
          const Text(
            'Garden Community',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications,
              color: isDarkMode ? Colors.white : const Color(0xFF101816),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF39AC86).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSegment = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedSegment == 0
                      ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedSegment == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Hardiness Zones',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedSegment == 0
                          ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
                          : const Color(0xFF39AC86).withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSegment = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedSegment == 1
                      ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedSegment == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Community Q&A',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedSegment == 1
                          ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
                          : const Color(0xFF39AC86).withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: Color(0xFF39AC86), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF101816),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneMapSection(bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // User Location Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF39AC86),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Hardiness Zone',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF5C8A7A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingLocation ? 'Detecting...' : (_userZone ?? 'Not detected'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_userZone != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _hardinessZones[_userZone]?.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _userZone!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _hardinessZones[_userZone]?.color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_userZone != null)
                  Text(
                    _hardinessZones[_userZone]?.description ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF5C8A7A),
                    ),
                  ),
              ],
            ),
          ),

          // Interactive Map
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _userLocation ?? const LatLng(39.8283, -98.5795),
                  zoom: 4,
                ),
                markers: {
                  if (_userLocation != null)
                    Marker(
                      markerId: const MarkerId('user-location'),
                      position: _userLocation!,
                      infoWindow: const InfoWindow(
                        title: 'Your Location',
                        snippet: 'Tap to see your hardiness zone',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                    ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
            ),
          ),

          // Zone Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hardiness Zones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _hardinessZones.keys.length,
                  itemBuilder: (context, index) {
                    final zoneName = _hardinessZones.keys.elementAt(index);
                    final zone = _hardinessZones[zoneName]!;
                    return _buildZoneCard(zone, zoneName == _userZone, isDarkMode);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(ZoneInfo zone, bool isUserZone, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUserZone
            ? zone.color.withOpacity(0.2)
            : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUserZone ? zone.color : Colors.black.withOpacity(0.05),
          width: isUserZone ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                zone.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: zone.color,
                ),
              ),
              if (isUserZone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39AC86),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'YOUR ZONE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            zone.tempRange,
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Best crops:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: zone.color,
            ),
          ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: zone.suitableCrops.take(3).map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: zone.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  crop,
                  style: TextStyle(
                    fontSize: 8,
                    color: zone.color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection(bool isDarkMode) {
    return Column(
      children: [
        // Category Filter
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: const Color(0xFF39AC86),
                  backgroundColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF101816)),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        ),
        
        // Questions List
        Expanded(
          child: _isLoadingQuestions
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF39AC86)))
              : _filteredQuestions.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredQuestions.length,
                      itemBuilder: (context, index) {
                        final question = _filteredQuestions[index];
                        return _buildQuestionCard(question, isDarkMode);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionPost question, bool isDarkMode) {
    final timeAgo = _getTimeAgo(question.createdAt);
    
    return GestureDetector(
      onTap: () => _showQuestionDetail(question),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: question.solved ? const Color(0xFF39AC86) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39AC86).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      question.author[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF39AC86),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.author,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF101816),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF5C8A7A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39AC86).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF39AC86),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF101816),
              ),
            ),
            if (question.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                question.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF5C8A7A),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 14,
                  color: const Color(0xFF5C8A7A),
                ),
                const SizedBox(width: 4),
                Text(
                  '${question.answers} answers',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF5C8A7A),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.thumb_up_outlined,
                  size: 14,
                  color: const Color(0xFF5C8A7A),
                ),
                const SizedBox(width: 4),
                Text(
                  '${question.likes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF5C8A7A),
                  ),
                ),
                if (question.solved) ...[
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Color(0xFF39AC86),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Solved',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF39AC86),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.question_answer,
            size: 80,
            color: const Color(0xFF39AC86).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No questions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF101816),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to ask a question!',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF5C8A7A),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _showAskQuestionDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF39AC86),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Ask a Question',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAskQuestionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask a Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.where((c) => c != 'All').map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'Vegetables';
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Your Question',
                hintText: 'What would you like to ask the community?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _postQuestion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF39AC86),
            ),
            child: const Text('Post Question'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} years ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class ZoneInfo {
  final String name;
  final String tempRange;
  final Color color;
  final String description;
  final List<String> suitableCrops;

  ZoneInfo({
    required this.name,
    required this.tempRange,
    required this.color,
    required this.description,
    required this.suitableCrops,
  });
}

class QuestionPost {
  final String id;
  final String title;
  final String description;
  final String category;
  final String author;
  final String authorImage;
  int answers;
  int likes;
  final DateTime createdAt;
  bool solved;

  QuestionPost({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.author,
    required this.authorImage,
    required this.answers,
    required this.likes,
    required this.createdAt,
    required this.solved,
  });

  factory QuestionPost.fromJson(Map<String, dynamic> json) {
    return QuestionPost(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'],
      author: json['author'],
      authorImage: json['authorImage'] ?? '',
      answers: json['answers'] ?? 0,
      likes: json['likes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      solved: json['solved'] ?? false,
    );
  }
}

class _QuestionDetailSheet extends StatefulWidget {
  final QuestionPost question;
  final VoidCallback onAnswerAdded;

  const _QuestionDetailSheet({
    required this.question,
    required this.onAnswerAdded,
  });

  @override
  State<_QuestionDetailSheet> createState() => _QuestionDetailSheetState();
}

class _QuestionDetailSheetState extends State<_QuestionDetailSheet> {
  final TextEditingController _replyController = TextEditingController();
  final List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  void _loadAnswers() {
    // Load answers from API or use sample data
    _answers.addAll([
      {
        'id': '1',
        'author': 'GreenThumb99',
        'authorImage': '',
        'text': 'This looks like a common issue with overwatering. Try letting the soil dry out between waterings.',
        'likes': 5,
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'id': '2',
        'author': 'PlantDoctor',
        'authorImage': '',
        'text': 'Could also be a nitrogen deficiency. Add some compost or organic fertilizer.',
        'likes': 3,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)),
      },
    ]);
  }

  void _addAnswer() {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      _answers.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'author': 'You',
        'authorImage': '',
        'text': _replyController.text.trim(),
        'likes': 0,
        'createdAt': DateTime.now(),
      });
      widget.question.answers += 1;
      _replyController.clear();
    });
    widget.onAnswerAdded();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Question Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.question.author[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF39AC86),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.question.author,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF101816),
                            ),
                          ),
                          Text(
                            _getTimeAgo(widget.question.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF5C8A7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.question.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF39AC86),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.question.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF101816),
                  ),
                ),
                if (widget.question.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.question.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF5C8A7A),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Answers Section
          Expanded(
            child: _answers.isEmpty
                ? const Center(
                    child: Text(
                      'No answers yet. Be the first to help!',
                      style: TextStyle(color: Color(0xFF5C8A7A)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _answers.length,
                    itemBuilder: (context, index) {
                      final answer = _answers[index];
                      final timeAgo = answer['createdAt'] is DateTime
                          ? _getTimeAgo(answer['createdAt'])
                          : 'Just now';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39AC86).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      answer['author'][0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF39AC86),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        answer['author'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                        ),
                                      ),
                                      Text(
                                        timeAgo,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: const Color(0xFF5C8A7A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.thumb_up_outlined,
                                        size: 16,
                                      ),
                                      color: const Color(0xFF5C8A7A),
                                    ),
                                    Text(
                                      '${answer['likes']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF5C8A7A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              answer['text'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white70 : const Color(0xFF101816),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Reply Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A2A25) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.1) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _replyController,
                      decoration: const InputDecoration(
                        hintText: 'Write an answer...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39AC86),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _addAnswer,
                    icon: const Icon(Icons.send, size: 20, color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
