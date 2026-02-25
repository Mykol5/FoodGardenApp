import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_sharing_app/services/api_service.dart';
import 'package:http/http.dart' as http;

class AddGardenScreen extends StatefulWidget {
  final Map<String, dynamic>? existingGarden;
  
  const AddGardenScreen({
    Key? key,
    this.existingGarden,
  }) : super(key: key);

  @override
  State<AddGardenScreen> createState() => _AddGardenScreenState();
}

class _AddGardenScreenState extends State<AddGardenScreen> {
  bool _isEditMode = false;
  bool _isLoading = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedType = 'outdoor';
  String _selectedSize = 'medium';
  
  final List<Map<String, dynamic>> _gardenTypes = [
    {'name': 'Outdoor', 'value': 'outdoor', 'icon': Icons.wb_sunny},
    {'name': 'Indoor', 'value': 'indoor', 'icon': Icons.home},
    {'name': 'Greenhouse', 'value': 'greenhouse', 'icon': Icons.grass},
    {'name': 'Community', 'value': 'community', 'icon': Icons.people},
  ];
  
  final List<Map<String, dynamic>> _gardenSizes = [
    {'name': 'Small', 'value': 'small', 'icon': Icons.crop_square},
    {'name': 'Medium', 'value': 'medium', 'icon': Icons.crop_7_5},
    {'name': 'Large', 'value': 'large', 'icon': Icons.crop_16_9},
  ];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingGarden != null;
    
    if (_isEditMode && widget.existingGarden != null) {
      _populateExistingGarden();
    }
  }

  void _populateExistingGarden() {
    final garden = widget.existingGarden!;
    
    _nameController.text = garden['name'] ?? '';
    _locationController.text = garden['location'] ?? '';
    _descriptionController.text = garden['description'] ?? '';
    _selectedType = garden['type'] ?? 'outdoor';
    _selectedSize = garden['size'] ?? 'medium';
    
    setState(() {});
  }

  Future<void> _saveGarden() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a garden name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final gardenData = {
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        'type': _selectedType,
        'size': _selectedSize,
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      };

      print('🔄 Saving garden data: $gardenData');

      Map<String, dynamic> response;
      
      if (_isEditMode) {
        // Update existing garden
        final url = '${ApiService.baseUrl}/api/gardens/${widget.existingGarden!['id']}';
        print('📤 PUT to: $url');
        
        final httpResponse = await http.put(
          Uri.parse(url),
          headers: _apiService.headers,
          body: jsonEncode(gardenData),
        );
        
        response = jsonDecode(httpResponse.body);
        print('📥 Update response: $response');
      } else {
        // Create new garden
        final url = '${ApiService.baseUrl}/api/gardens';
        print('📤 POST to: $url');
        
        final httpResponse = await http.post(
          Uri.parse(url),
          headers: _apiService.headers,
          body: jsonEncode(gardenData),
        );
        
        response = jsonDecode(httpResponse.body);
        print('📥 Create response: $response');
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Garden saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait a bit before popping
        await Future.delayed(Duration(milliseconds: 800));
        
        Navigator.pop(context, response['garden'] ?? true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to save garden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Save garden error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF212C28) : Color(0xFFF9F8F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Color(0xFF212C28).withOpacity(0.8)
                    : Color(0xFFF9F8F6).withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Close Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Color(0xFF39AC86),
                      size: 24,
                    ),
                  ),
                  
                  // Title
                  Expanded(
                    child: Center(
                      child: Text(
                        _isEditMode ? 'Edit Garden' : 'Add New Garden',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Color(0xFF101816),
                        ),
                      ),
                    ),
                  ),
                  
                  // Save Button
                  _isLoading
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39AC86)),
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: _saveGarden,
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Color(0xFF39AC86),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Garden Name Input
                    _buildInputField(
                      isDarkMode,
                      label: 'Garden Name *',
                      hint: 'e.g. My Backyard Garden',
                      controller: _nameController,
                      icon: Icons.eco,
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Garden Type Selection
                    Text(
                      'Garden Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Color(0xFF101816),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Type Options
                    Row(
                      children: _gardenTypes.map((type) {
                        final isSelected = _selectedType == type['value'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedType = type['value'];
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: type == _gardenTypes.last ? 0 : 8),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF39AC86)
                                    : (isDarkMode ? Color(0xFF2D3A35) : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF39AC86)
                                      : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    type['icon'],
                                    color: isSelected ? Colors.white : Color(0xFF5C8A7A),
                                    size: 20,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    type['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Color(0xFF5C8A7A)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Garden Size Selection
                    Text(
                      'Garden Size',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Color(0xFF101816),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Size Options
                    Row(
                      children: _gardenSizes.map((size) {
                        final isSelected = _selectedSize == size['value'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSize = size['value'];
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: size == _gardenSizes.last ? 0 : 8),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF39AC86)
                                    : (isDarkMode ? Color(0xFF2D3A35) : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF39AC86)
                                      : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    size['icon'],
                                    color: isSelected ? Colors.white : Color(0xFF5C8A7A),
                                    size: 20,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    size['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Color(0xFF5C8A7A)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Location Input
                    _buildInputField(
                      isDarkMode,
                      label: 'Location (Optional)',
                      hint: 'e.g. Backyard, Balcony, Community Plot',
                      controller: _locationController,
                      icon: Icons.location_on,
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Description Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Color(0xFF101816),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
                            ),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Describe your garden, soil type, sun exposure...',
                              hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Color(0xFF101816),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom CTA Button
      bottomSheet: Container(
        color: isDarkMode 
            ? Color(0xFF212C28).withOpacity(0.9)
            : Color(0xFFF9F8F6).withOpacity(0.9),
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF39AC86).withOpacity(0.2),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Color(0xFF39AC86),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _isLoading ? null : _saveGarden,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_task,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _isEditMode ? 'Update Garden' : 'Create Garden',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    bool isDarkMode, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Color(0xFF101816),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  icon,
                  color: Color(0xFF39AC86).withOpacity(0.5),
                  size: 20,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12, right: 16),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Color(0xFF101816),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
