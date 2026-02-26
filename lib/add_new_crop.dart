import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_sharing_app/services/api_service.dart';
import 'package:http/http.dart' as http;

class AddNewCropScreen extends StatefulWidget {
  final String? gardenId;
  final Map<String, dynamic>? existingCrop;
  
  const AddNewCropScreen({
    Key? key,
    this.gardenId,
    this.existingCrop,
  }) : super(key: key);

  @override
  State<AddNewCropScreen> createState() => _AddNewCropScreenState();
}

class _AddNewCropScreenState extends State<AddNewCropScreen> {
  int _selectedCategoryIndex = 0;
  String? _selectedGardenId;
  List<Map<String, dynamic>> _gardens = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _loadGardensError = false;
  
  // Image related variables
  File? _selectedImage;
  bool _isUploadingImage = false;
  
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _cropNameController = TextEditingController();
  
  DateTime? _plantingDate;
  DateTime? _expectedHarvestDate;
  int _progress = 0;
  String _status = 'seedling';
  int _quantity = 1;
  String _quantityUnit = 'plants';
  
  final ApiService _apiService = ApiService();
  
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Vegetable',
      'value': 'vegetable',
      'icon': Icons.eco,
      'color': Color(0xFF39AC86),
    },
    {
      'name': 'Fruit',
      'value': 'fruit',
      'icon': Icons.restaurant,
      'color': Color(0xFF5C8A7A),
    },
    {
      'name': 'Herb',
      'value': 'herb',
      'icon': Icons.spa,
      'color': Color(0xFF5C8A7A),
    },
    {
      'name': 'Flower',
      'value': 'flower',
      'icon': Icons.local_florist,
      'color': Color(0xFF5C8A7A),
    },
    {
      'name': 'Other',
      'value': 'other',
      'icon': Icons.category,
      'color': Color(0xFF5C8A7A),
    },
  ];

  final List<Map<String, dynamic>> _statusOptions = [
    {'name': 'Seedling', 'value': 'seedling'},
    {'name': 'Vegetative', 'value': 'vegetative'},
    {'name': 'Flowering', 'value': 'flowering'},
    {'name': 'Fruiting', 'value': 'fruiting'},
    {'name': 'Harvest', 'value': 'harvest'},
    {'name': 'Dormant', 'value': 'dormant'},
  ];

  final List<String> _quantityUnits = ['plants', 'seeds', 'kg', 'g', 'lb', 'oz', 'units'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingCrop != null;
    
    // Initialize quantity controller
    _quantityController.text = '1';
    
    // Load data
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadGardens();
    
    if (_isEditMode && widget.existingCrop != null) {
      _populateExistingCrop();
    } else if (widget.gardenId != null) {
      _selectedGardenId = widget.gardenId;
    }
  }

  void _populateExistingCrop() {
    final crop = widget.existingCrop!;
    
    _cropNameController.text = crop['name'] ?? '';
    
    // Find category index
    final categoryValue = crop['category'] ?? 'vegetable';
    final categoryIndex = _categories.indexWhere((cat) => cat['value'] == categoryValue);
    if (categoryIndex != -1) {
      _selectedCategoryIndex = categoryIndex;
    }
    
    _varietyController.text = crop['variety'] ?? '';
    _notesController.text = crop['notes'] ?? '';
    _status = crop['status'] ?? 'seedling';
    _progress = crop['progress'] ?? 0;
    _selectedGardenId = crop['garden_id'];
    _quantity = crop['quantity'] ?? 1;
    _quantityController.text = _quantity.toString();
    _quantityUnit = crop['quantity_unit'] ?? 'plants';
    
    if (crop['planting_date'] != null) {
      _plantingDate = DateTime.parse(crop['planting_date']);
    }
    
    if (crop['expected_harvest'] != null) {
      _expectedHarvestDate = DateTime.parse(crop['expected_harvest']);
    }
    
    setState(() {});
  }

  Future<void> _loadGardens() async {
    if (!_apiService.isLoggedIn) {
      setState(() {
        _loadGardensError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadGardensError = false;
    });

    try {
      final result = await _apiService.getUserGardens();
      
      if (result['success'] == true) {
        setState(() {
          _gardens = List<Map<String, dynamic>>.from(result['gardens'] ?? []);
          
          // If no garden is selected yet and we have gardens, select the first one
          if (_selectedGardenId == null && _gardens.isNotEmpty) {
            _selectedGardenId = _gardens[0]['id'];
          }
        });
      } else {
        setState(() {
          _loadGardensError = true;
        });
      }
    } catch (e) {
      print('Error loading gardens: $e');
      setState(() {
        _loadGardensError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPlantingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _plantingDate) {
      setState(() {
        _plantingDate = picked;
        
        // Auto-calculate harvest date (30 days after planting)
        if (_expectedHarvestDate == null) {
          _expectedHarvestDate = picked.add(Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedHarvestDate ?? (_plantingDate?.add(Duration(days: 30)) ?? DateTime.now().add(Duration(days: 30))),
      firstDate: _plantingDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _expectedHarvestDate) {
      setState(() {
        _expectedHarvestDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    
    setState(() {
      _isUploadingImage = true;
    });
    
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/crops/upload-image'),
      );
      
      // Add headers
      request.headers.addAll(_apiService.headers);
      
      // Add file
      final file = await http.MultipartFile.fromPath('image', _selectedImage!.path);
      request.files.add(file);
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Upload response status: ${response.statusCode}');
      print('📥 Upload response body: ${response.body}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return data['imageUrl'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Failed to upload image'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (e) {
      print('❌ Upload image error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveCrop() async {
    // Validation
    if (_cropNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a crop name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedGardenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a garden'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_quantityController.text.trim().isEmpty) {
      _quantityController.text = '1';
    }

    // Validate quantity is a number
    final quantityValue = int.tryParse(_quantityController.text.trim());
    if (quantityValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid quantity number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null && _selectedImage != null) {
          // Image upload failed but user selected an image
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final cropData = {
        'garden_id': _selectedGardenId,
        'name': _cropNameController.text.trim(),
        'category': _categories[_selectedCategoryIndex]['value'],
        'variety': _varietyController.text.trim().isEmpty ? null : _varietyController.text.trim(),
        'planting_date': _plantingDate?.toIso8601String().split('T')[0],
        'expected_harvest': _expectedHarvestDate?.toIso8601String().split('T')[0],
        'status': _status,
        'progress': _progress,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'quantity': quantityValue,
        'quantity_unit': _quantityUnit.isEmpty ? null : _quantityUnit,
        'image_url': imageUrl, // Add the uploaded image URL
        'is_shared': false,
      };

      print('🔄 Saving crop data: $cropData');

      Map<String, dynamic> response;
      
      if (_isEditMode) {
        // Update existing crop
        final url = '${ApiService.baseUrl}/api/crops/${widget.existingCrop!['id']}';
        print('📤 PUT to: $url');
        
        final httpResponse = await http.put(
          Uri.parse(url),
          headers: _apiService.headers,
          body: jsonEncode(cropData),
        );
        
        response = jsonDecode(httpResponse.body);
        print('📥 Update response: $response');
      } else {
        // Create new crop
        final url = '${ApiService.baseUrl}/api/crops';
        print('📤 POST to: $url');
        
        final httpResponse = await http.post(
          Uri.parse(url),
          headers: _apiService.headers,
          body: jsonEncode(cropData),
        );
        
        response = jsonDecode(httpResponse.body);
        print('📥 Create response: $response');
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Crop saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait a bit before popping to show the success message
        await Future.delayed(Duration(milliseconds: 800));
        
        Navigator.pop(context, response['crop'] ?? true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to save crop'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Save crop error: $e');
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

  Future<void> _retryLoadGardens() async {
    await _loadGardens();
  }

  @override
  void dispose() {
    _varietyController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _cropNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF212C28) : Color(0xFFF9F8F6),
      body: SafeArea(
        bottom: false,
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
                        _isEditMode ? 'Edit Crop' : 'Add New Crop',
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
                          onPressed: _saveCrop,
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
              child: _isLoading && _gardens.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39AC86)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading gardens...',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Color(0xFF5C8A7A),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _loadGardensError
                      ? _buildErrorState(isDarkMode)
                      : SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Crop Name Input
                              _buildCropNameInput(isDarkMode),
                              
                              // Garden Selection
                              _buildGardenSelection(isDarkMode),
                              
                              // Image Picker
                              _buildImagePicker(isDarkMode),
                              
                              // Category Section
                              _buildCategorySection(isDarkMode),
                              
                              // Crop Variety Input
                              _buildVarietyInput(isDarkMode),
                              
                              // Timeline Section
                              _buildTimelineSection(isDarkMode),
                              
                              // Status and Progress
                              _buildStatusSection(isDarkMode),
                              
                              // Quantity Section
                              _buildQuantitySection(isDarkMode),
                              
                              // Notes Section
                              _buildNotesSection(isDarkMode),
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
              onTap: _isLoading ? null : _saveCrop,
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
                      _isEditMode ? 'Update Crop' : 'Add to My Garden',
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

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load gardens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Color(0xFF101816),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Color(0xFF5C8A7A),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retryLoadGardens,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF39AC86),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropNameInput(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Name *',
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: TextField(
                      controller: _cropNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Tomatoes, Basil, Carrots',
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
      ),
    );
  }

  Widget _buildGardenSelection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Garden *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Color(0xFF101816),
            ),
          ),
          SizedBox(height: 8),
          if (_gardens.isEmpty && !_isLoading)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
                ),
              ),
              child: Center(
                child: Text(
                  'No gardens found. Please create a garden first.',
                  style: TextStyle(
                    color: Color(0xFF5C8A7A),
                  ),
                ),
              ),
            )
          else if (_gardens.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGardenId,
                  isExpanded: true,
                  dropdownColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Color(0xFF101816),
                    fontSize: 16,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  items: _gardens.map((garden) {
                    return DropdownMenuItem<String>(
                      value: garden['id'],
                      child: Text(garden['name']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGardenId = newValue;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Image (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Color(0xFF101816),
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _isUploadingImage ? null : _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
                ),
              ),
              child: _selectedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : (_isUploadingImage
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39AC86)),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Uploading...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5C8A7A),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: Color(0xFF39AC86).withOpacity(0.5),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5C8A7A),
                              ),
                            ),
                          ],
                        ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF101816),
            ),
          ),
          SizedBox(height: 16),
          
          // Category Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategoryIndex == index;
              
              return Material(
                color: isSelected
                    ? Color(0xFF39AC86).withOpacity(0.05)
                    : (isDarkMode ? Color(0xFF2D3A35) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF39AC86)
                            : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF39AC86)
                                : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category['icon'],
                            color: isSelected ? Colors.white : category['color'],
                            size: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          category['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Color(0xFF39AC86)
                                : (isDarkMode ? Colors.white : Color(0xFF101816)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVarietyInput(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Variety (Optional)',
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: TextField(
                      controller: _varietyController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Cherry Belle Radish, Roma Tomato',
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
      ),
    );
  }

  Widget _buildTimelineSection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF101816),
            ),
          ),
          SizedBox(height: 16),
          
          // Planting Date Card
          _buildTimelineCard(
            isDarkMode,
            icon: Icons.calendar_today,
            iconColor: Color(0xFF39AC86),
            title: 'Planting Date',
            date: _plantingDate,
            onTap: _selectPlantingDate,
            showAutoBadge: false,
          ),
          
          SizedBox(height: 12),
          
          // Expected Harvest Card
          _buildTimelineCard(
            isDarkMode,
            icon: Icons.thermostat_auto,
            iconColor: Color(0xFFE59866),
            title: 'Expected Harvest',
            date: _expectedHarvestDate,
            onTap: _selectHarvestDate,
            showAutoBadge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    bool isDarkMode, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
    required bool showAutoBadge,
  }) {
    final dateText = date != null 
        ? DateFormat('MMM dd, yyyy').format(date)
        : 'Select date';

    return Material(
      color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C8A7A),
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          dateText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Color(0xFF101816),
                            fontStyle: showAutoBadge && date == null ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                        if (showAutoBadge && date == null) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFE59866).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'AUTO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE59866),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Color(0xFF5C8A7A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status & Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF101816),
            ),
          ),
          SizedBox(height: 16),
          
          // Status Selection
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((status) {
              final isSelected = _status == status['value'];
              return ChoiceChip(
                label: Text(status['name']),
                selected: isSelected,
                selectedColor: Color(0xFF39AC86),
                backgroundColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Color(0xFF101816)),
                ),
                onSelected: (selected) {
                  setState(() {
                    _status = status['value'];
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Color(0xFF39AC86) : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 16),
          
          // Progress Slider
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Color(0xFF101816),
                      ),
                    ),
                    Text(
                      '$_progress%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF39AC86),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Slider(
                  value: _progress.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 10,
                  activeColor: Color(0xFF39AC86),
                  inactiveColor: Color(0xFF5C8A7A).withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      _progress = value.round();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF101816),
            ),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              // Quantity Input
              Expanded(
                child: Container(
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
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Quantity',
                              hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Color(0xFF101816),
                              fontSize: 16,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _quantity = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Unit Dropdown
              Container(
                width: 120,
                height: 56,
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _quantityUnit,
                    isExpanded: true,
                    dropdownColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Color(0xFF101816),
                      fontSize: 16,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    items: _quantityUnits.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _quantityUnit = newValue ?? 'plants';
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes & Additional Info (Optional)',
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
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Soil type, special care instructions, location in garden...',
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
    );
  }
}





// // add new crops

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:food_sharing_app/services/api_service.dart';
// import 'package:http/http.dart' as http;

// class AddNewCropScreen extends StatefulWidget {
//   final String? gardenId;
//   final Map<String, dynamic>? existingCrop;
  
//   const AddNewCropScreen({
//     Key? key,
//     this.gardenId,
//     this.existingCrop,
//   }) : super(key: key);

//   @override
//   State<AddNewCropScreen> createState() => _AddNewCropScreenState();
// }

// class _AddNewCropScreenState extends State<AddNewCropScreen> {
//   int _selectedCategoryIndex = 0;
//   String? _selectedGardenId;
//   List<Map<String, dynamic>> _gardens = [];
//   bool _isLoading = false;
//   bool _isEditMode = false;
//   bool _loadGardensError = false;
  
//   final TextEditingController _varietyController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _cropNameController = TextEditingController();
  
//   DateTime? _plantingDate;
//   DateTime? _expectedHarvestDate;
//   int _progress = 0;
//   String _status = 'seedling';
//   int _quantity = 1;
//   String _quantityUnit = 'plants';
  
//   final ApiService _apiService = ApiService();
  
//   final List<Map<String, dynamic>> _categories = [
//     {
//       'name': 'Vegetable',
//       'value': 'vegetable',
//       'icon': Icons.eco,
//       'color': Color(0xFF39AC86),
//     },
//     {
//       'name': 'Fruit',
//       'value': 'fruit',
//       'icon': Icons.restaurant,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Herb',
//       'value': 'herb',
//       'icon': Icons.spa,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Flower',
//       'value': 'flower',
//       'icon': Icons.local_florist,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Other',
//       'value': 'other',
//       'icon': Icons.category,
//       'color': Color(0xFF5C8A7A),
//     },
//   ];

//   final List<Map<String, dynamic>> _statusOptions = [
//     {'name': 'Seedling', 'value': 'seedling'},
//     {'name': 'Vegetative', 'value': 'vegetative'},
//     {'name': 'Flowering', 'value': 'flowering'},
//     {'name': 'Fruiting', 'value': 'fruiting'},
//     {'name': 'Harvest', 'value': 'harvest'},
//     {'name': 'Dormant', 'value': 'dormant'},
//   ];

//   final List<String> _quantityUnits = ['plants', 'seeds', 'kg', 'g', 'lb', 'oz', 'units'];

//   @override
//   void initState() {
//     super.initState();
//     _isEditMode = widget.existingCrop != null;
    
//     // Initialize quantity controller
//     _quantityController.text = '1';
    
//     // Load data
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     await _loadGardens();
    
//     if (_isEditMode && widget.existingCrop != null) {
//       _populateExistingCrop();
//     } else if (widget.gardenId != null) {
//       _selectedGardenId = widget.gardenId;
//     }
//   }

//   void _populateExistingCrop() {
//     final crop = widget.existingCrop!;
    
//     _cropNameController.text = crop['name'] ?? '';
    
//     // Find category index
//     final categoryValue = crop['category'] ?? 'vegetable';
//     final categoryIndex = _categories.indexWhere((cat) => cat['value'] == categoryValue);
//     if (categoryIndex != -1) {
//       _selectedCategoryIndex = categoryIndex;
//     }
    
//     _varietyController.text = crop['variety'] ?? '';
//     _notesController.text = crop['notes'] ?? '';
//     _status = crop['status'] ?? 'seedling';
//     _progress = crop['progress'] ?? 0;
//     _selectedGardenId = crop['garden_id'];
//     _quantity = crop['quantity'] ?? 1;
//     _quantityController.text = _quantity.toString();
//     _quantityUnit = crop['quantity_unit'] ?? 'plants';
    
//     if (crop['planting_date'] != null) {
//       _plantingDate = DateTime.parse(crop['planting_date']);
//     }
    
//     if (crop['expected_harvest'] != null) {
//       _expectedHarvestDate = DateTime.parse(crop['expected_harvest']);
//     }
    
//     setState(() {});
//   }

//   Future<void> _loadGardens() async {
//     if (!_apiService.isLoggedIn) {
//       setState(() {
//         _loadGardensError = true;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _loadGardensError = false;
//     });

//     try {
//       final result = await _apiService.getUserGardens();
      
//       if (result['success'] == true) {
//         setState(() {
//           _gardens = List<Map<String, dynamic>>.from(result['gardens'] ?? []);
          
//           // If no garden is selected yet and we have gardens, select the first one
//           if (_selectedGardenId == null && _gardens.isNotEmpty) {
//             _selectedGardenId = _gardens[0]['id'];
//           }
//         });
//       } else {
//         setState(() {
//           _loadGardensError = true;
//         });
//       }
//     } catch (e) {
//       print('Error loading gardens: $e');
//       setState(() {
//         _loadGardensError = true;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _selectPlantingDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _plantingDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
    
//     if (picked != null && picked != _plantingDate) {
//       setState(() {
//         _plantingDate = picked;
        
//         // Auto-calculate harvest date (30 days after planting)
//         if (_expectedHarvestDate == null) {
//           _expectedHarvestDate = picked.add(Duration(days: 30));
//         }
//       });
//     }
//   }

//   Future<void> _selectHarvestDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _expectedHarvestDate ?? (_plantingDate?.add(Duration(days: 30)) ?? DateTime.now().add(Duration(days: 30))),
//       firstDate: _plantingDate ?? DateTime.now(),
//       lastDate: DateTime(2100),
//     );
    
//     if (picked != null && picked != _expectedHarvestDate) {
//       setState(() {
//         _expectedHarvestDate = picked;
//       });
//     }
//   }

//   // Future<void> _saveCrop() async {
//   //   // Validation
//   //   if (_cropNameController.text.trim().isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Please enter a crop name'),
//   //         backgroundColor: Colors.orange,
//   //       ),
//   //     );
//   //     return;
//   //   }

//   //   if (_selectedGardenId == null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Please select a garden'),
//   //         backgroundColor: Colors.orange,
//   //       ),
//   //     );
//   //     return;
//   //   }

//   //   if (_quantityController.text.trim().isEmpty) {
//   //     _quantityController.text = '1';
//   //   }

//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     final cropData = {
//   //       'garden_id': _selectedGardenId,
//   //       'name': _cropNameController.text.trim(),
//   //       'category': _categories[_selectedCategoryIndex]['value'],
//   //       'variety': _varietyController.text.trim().isEmpty ? null : _varietyController.text.trim(),
//   //       'planting_date': _plantingDate?.toIso8601String().split('T')[0],
//   //       'expected_harvest': _expectedHarvestDate?.toIso8601String().split('T')[0],
//   //       'status': _status,
//   //       'progress': _progress,
//   //       'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
//   //       'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
//   //       'quantity_unit': _quantityUnit.isEmpty ? null : _quantityUnit,
//   //       'is_shared': false,
//   //     };

//   //     print('🔄 Saving crop data: $cropData');

//   //     Map<String, dynamic> response;
      
//   //     if (_isEditMode) {
//   //       // Update existing crop
//   //       // final url = '${ApiService.baseUrl}/api/crops/${widget.existingCrop!['id']}';
//   //       final url = '${_apiService.apiBaseUrl}/api/crops/${widget.existingCrop!['id']}';
//   //       print('📤 PUT to: $url');
        
//   //       final httpResponse = await http.put(
//   //         Uri.parse(url),
//   //         headers: _apiService.headers,
//   //         body: jsonEncode(cropData),
//   //       );
        
//   //       response = jsonDecode(httpResponse.body);
//   //       print('📥 Update response: $response');
//   //     } else {
//   //       // Create new crop
//   //       // final url = '${ApiService.baseUrl}/api/crops';
//   //       final url = '${_apiService.apiBaseUrl}/api/crops';
//   //       print('📤 POST to: $url');
        
//   //       final httpResponse = await http.post(
//   //         Uri.parse(url),
//   //         headers: _apiService.headers,
//   //         body: jsonEncode(cropData),
//   //       );
        
//   //       response = jsonDecode(httpResponse.body);
//   //       print('📥 Create response: $response');
//   //     }

//   //     if (response['success'] == true) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text(response['message'] ?? 'Crop saved successfully'),
//   //           backgroundColor: Colors.green,
//   //           duration: Duration(seconds: 2),
//   //         ),
//   //       );
        
//   //       // Wait a bit before popping to show the success message
//   //       await Future.delayed(Duration(milliseconds: 800));
        
//   //       Navigator.pop(context, response['crop'] ?? true);
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text(response['error'] ?? 'Failed to save crop'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     print('❌ Save crop error: $e');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Error: $e'),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }


//   Future<void> _saveCrop() async {
//   // Validation
//   if (_cropNameController.text.trim().isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Please enter a crop name'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//     return;
//   }

//   if (_selectedGardenId == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Please select a garden'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//     return;
//   }

//   if (_quantityController.text.trim().isEmpty) {
//     _quantityController.text = '1';
//   }

//   // Validate quantity is a number
//   final quantityValue = int.tryParse(_quantityController.text.trim());
//   if (quantityValue == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Please enter a valid quantity number'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//     return;
//   }

//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     final cropData = {
//       'garden_id': _selectedGardenId,
//       'name': _cropNameController.text.trim(),
//       'category': _categories[_selectedCategoryIndex]['value'],
//       'variety': _varietyController.text.trim().isEmpty ? null : _varietyController.text.trim(),
//       'planting_date': _plantingDate?.toIso8601String().split('T')[0],
//       'expected_harvest': _expectedHarvestDate?.toIso8601String().split('T')[0],
//       'status': _status,
//       'progress': _progress,
//       'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
//       'quantity': quantityValue, // Use validated value
//       'quantity_unit': _quantityUnit.isEmpty ? null : _quantityUnit,
//       'is_shared': false,
//     };

//     print('🔄 Saving crop data: $cropData');

//     Map<String, dynamic> response;
    
//     if (_isEditMode) {
//       // Update existing crop
//       final url = '${_apiService.apiBaseUrl}/api/crops/${widget.existingCrop!['id']}';
//       print('📤 PUT to: $url');
      
//       final httpResponse = await http.put(
//         Uri.parse(url),
//         headers: _apiService.headers,
//         body: jsonEncode(cropData),
//       );
      
//       response = jsonDecode(httpResponse.body);
//       print('📥 Update response: $response');
//     } else {
//       // Create new crop
//       final url = '${_apiService.apiBaseUrl}/api/crops';
//       print('📤 POST to: $url');
      
//       final httpResponse = await http.post(
//         Uri.parse(url),
//         headers: _apiService.headers,
//         body: jsonEncode(cropData),
//       );
      
//       response = jsonDecode(httpResponse.body);
//       print('📥 Create response: $response');
//     }

//     if (response['success'] == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response['message'] ?? 'Crop saved successfully'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//         ),
//       );
      
//       // Wait a bit before popping to show the success message
//       await Future.delayed(Duration(milliseconds: 800));
      
//       Navigator.pop(context, response['crop'] ?? true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response['error'] ?? 'Failed to save crop'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } catch (e) {
//     print('❌ Save crop error: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Error: $e'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

//   Future<void> _retryLoadGardens() async {
//     await _loadGardens();
//   }

//   @override
//   void dispose() {
//     _varietyController.dispose();
//     _notesController.dispose();
//     _quantityController.dispose();
//     _cropNameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDarkMode ? Color(0xFF212C28) : Color(0xFFF9F8F6),
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             // Top App Bar
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: isDarkMode 
//                     ? Color(0xFF212C28).withOpacity(0.8)
//                     : Color(0xFFF9F8F6).withOpacity(0.8),
//                 border: Border(
//                   bottom: BorderSide(
//                     color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFE5E7EB),
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Close Button
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(
//                       Icons.close,
//                       color: Color(0xFF39AC86),
//                       size: 24,
//                     ),
//                   ),
                  
//                   // Title
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         _isEditMode ? 'Edit Crop' : 'Add New Crop',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   // Save Button
//                   _isLoading
//                       ? Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           child: SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39AC86)),
//                             ),
//                           ),
//                         )
//                       : TextButton(
//                           onPressed: _saveCrop,
//                           child: Text(
//                             'Save',
//                             style: TextStyle(
//                               color: Color(0xFF39AC86),
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),

//             // Main Content
//             Expanded(
//               child: _isLoading && _gardens.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39AC86)),
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'Loading gardens...',
//                             style: TextStyle(
//                               color: isDarkMode ? Colors.white70 : Color(0xFF5C8A7A),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : _loadGardensError
//                       ? _buildErrorState(isDarkMode)
//                       : SingleChildScrollView(
//                           padding: EdgeInsets.only(bottom: 100),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Crop Name Input
//                               _buildCropNameInput(isDarkMode),
                              
//                               // Garden Selection
//                               _buildGardenSelection(isDarkMode),
                              
//                               // Category Section
//                               _buildCategorySection(isDarkMode),
                              
//                               // Crop Variety Input
//                               _buildVarietyInput(isDarkMode),
                              
//                               // Timeline Section
//                               _buildTimelineSection(isDarkMode),
                              
//                               // Status and Progress
//                               _buildStatusSection(isDarkMode),
                              
//                               // Quantity Section
//                               _buildQuantitySection(isDarkMode),
                              
//                               // Notes Section
//                               _buildNotesSection(isDarkMode),
//                             ],
//                           ),
//                         ),
//             ),
//           ],
//         ),
//       ),
      
//       // Bottom CTA Button
//       bottomSheet: Container(
//         color: isDarkMode 
//             ? Color(0xFF212C28).withOpacity(0.9)
//             : Color(0xFFF9F8F6).withOpacity(0.9),
//         padding: EdgeInsets.all(16),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFF39AC86).withOpacity(0.2),
//                 blurRadius: 16,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Material(
//             color: Color(0xFF39AC86),
//             borderRadius: BorderRadius.circular(12),
//             child: InkWell(
//               onTap: _isLoading ? null : _saveCrop,
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add_task,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       _isEditMode ? 'Update Crop' : 'Add to My Garden',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState(bool isDarkMode) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               color: Colors.orange,
//               size: 64,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Unable to load gardens',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: isDarkMode ? Colors.white : Color(0xFF101816),
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Please check your connection and try again',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: isDarkMode ? Colors.white70 : Color(0xFF5C8A7A),
//               ),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _retryLoadGardens,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF39AC86),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               ),
//               child: Text(
//                 'Try Again',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCropNameInput(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Crop Name *',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             height: 56,
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 16),
//                     child: TextField(
//                       controller: _cropNameController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g. Tomatoes, Basil, Carrots',
//                         hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                         border: InputBorder.none,
//                       ),
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGardenSelection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select Garden *',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           if (_gardens.isEmpty && !_isLoading)
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'No gardens found. Please create a garden first.',
//                   style: TextStyle(
//                     color: Color(0xFF5C8A7A),
//                   ),
//                 ),
//               ),
//             )
//           else if (_gardens.isNotEmpty)
//             Container(
//               decoration: BoxDecoration(
//                 color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                 ),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedGardenId,
//                   isExpanded: true,
//                   dropdownColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : Color(0xFF101816),
//                     fontSize: 16,
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   items: _gardens.map((garden) {
//                     return DropdownMenuItem<String>(
//                       value: garden['id'],
//                       child: Text(garden['name']),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedGardenId = newValue;
//                     });
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategorySection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select Category',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Category Grid
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 1,
//             ),
//             itemCount: _categories.length,
//             itemBuilder: (context, index) {
//               final category = _categories[index];
//               final isSelected = _selectedCategoryIndex == index;
              
//               return Material(
//                 color: isSelected
//                     ? Color(0xFF39AC86).withOpacity(0.05)
//                     : (isDarkMode ? Color(0xFF2D3A35) : Colors.white),
//                 borderRadius: BorderRadius.circular(12),
//                 child: InkWell(
//                   onTap: () => setState(() => _selectedCategoryIndex = index),
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected
//                             ? Color(0xFF39AC86)
//                             : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? Color(0xFF39AC86)
//                                 : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF5F5F5)),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             category['icon'],
//                             color: isSelected ? Colors.white : category['color'],
//                             size: 20,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           category['name'],
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? Color(0xFF39AC86)
//                                 : (isDarkMode ? Colors.white : Color(0xFF101816)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVarietyInput(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Crop Variety (Optional)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             height: 56,
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 16),
//                     child: TextField(
//                       controller: _varietyController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g. Cherry Belle Radish, Roma Tomato',
//                         hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                         border: InputBorder.none,
//                       ),
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimelineSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Timeline',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Planting Date Card
//           _buildTimelineCard(
//             isDarkMode,
//             icon: Icons.calendar_today,
//             iconColor: Color(0xFF39AC86),
//             title: 'Planting Date',
//             date: _plantingDate,
//             onTap: _selectPlantingDate,
//             showAutoBadge: false,
//           ),
          
//           SizedBox(height: 12),
          
//           // Expected Harvest Card
//           _buildTimelineCard(
//             isDarkMode,
//             icon: Icons.thermostat_auto,
//             iconColor: Color(0xFFE59866),
//             title: 'Expected Harvest',
//             date: _expectedHarvestDate,
//             onTap: _selectHarvestDate,
//             showAutoBadge: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimelineCard(
//     bool isDarkMode, {
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required DateTime? date,
//     required VoidCallback onTap,
//     required bool showAutoBadge,
//   }) {
//     final dateText = date != null 
//         ? DateFormat('MMM dd, yyyy').format(date)
//         : 'Select date';

//     return Material(
//       color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: iconColor,
//                   size: 20,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF5C8A7A),
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Row(
//                       children: [
//                         Text(
//                           dateText,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: isDarkMode ? Colors.white : Color(0xFF101816),
//                             fontStyle: showAutoBadge && date == null ? FontStyle.italic : FontStyle.normal,
//                           ),
//                         ),
//                         if (showAutoBadge && date == null) ...[
//                           SizedBox(width: 8),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFE59866).withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               'AUTO',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFFE59866),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right,
//                 color: Color(0xFF5C8A7A),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Status & Progress',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Status Selection
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _statusOptions.map((status) {
//               final isSelected = _status == status['value'];
//               return ChoiceChip(
//                 label: Text(status['name']),
//                 selected: isSelected,
//                 selectedColor: Color(0xFF39AC86),
//                 backgroundColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                 labelStyle: TextStyle(
//                   color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Color(0xFF101816)),
//                 ),
//                 onSelected: (selected) {
//                   setState(() {
//                     _status = status['value'];
//                   });
//                 },
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   side: BorderSide(
//                     color: isSelected ? Color(0xFF39AC86) : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
          
//           SizedBox(height: 16),
          
//           // Progress Slider
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Progress',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                       ),
//                     ),
//                     Text(
//                       '$_progress%',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF39AC86),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Slider(
//                   value: _progress.toDouble(),
//                   min: 0,
//                   max: 100,
//                   divisions: 10,
//                   activeColor: Color(0xFF39AC86),
//                   inactiveColor: Color(0xFF5C8A7A).withOpacity(0.3),
//                   onChanged: (value) {
//                     setState(() {
//                       _progress = value.round();
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuantitySection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quantity',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           Row(
//             children: [
//               // Quantity Input
//               Expanded(
//                 child: Container(
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: EdgeInsets.only(left: 16),
//                           child: TextField(
//                             controller: _quantityController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: 'Quantity',
//                               hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                               border: InputBorder.none,
//                             ),
//                             style: TextStyle(
//                               color: isDarkMode ? Colors.white : Color(0xFF101816),
//                               fontSize: 16,
//                             ),
//                             onChanged: (value) {
//                               setState(() {
//                                 _quantity = int.tryParse(value) ?? 1;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(width: 12),
              
//               // Unit Dropdown
//               Container(
//                 width: 120,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                   ),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _quantityUnit,
//                     isExpanded: true,
//                     dropdownColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                     style: TextStyle(
//                       color: isDarkMode ? Colors.white : Color(0xFF101816),
//                       fontSize: 16,
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     items: _quantityUnits.map((unit) {
//                       return DropdownMenuItem<String>(
//                         value: unit,
//                         child: Text(unit),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _quantityUnit = newValue ?? 'plants';
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotesSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Notes & Additional Info (Optional)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: TextField(
//               controller: _notesController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Soil type, special care instructions, location in garden...',
//                 hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.all(16),
//               ),
//               style: TextStyle(
//                 color: isDarkMode ? Colors.white : Color(0xFF101816),
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// // new add crops code
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:harvest_hub/services/crops_service.dart';

// class AddNewCropScreen extends StatefulWidget {
//   final String? gardenId;
//   final Map<String, dynamic>? existingCrop;
  
//   const AddNewCropScreen({
//     Key? key,
//     this.gardenId,
//     this.existingCrop,
//   }) : super(key: key);

//   @override
//   State<AddNewCropScreen> createState() => _AddNewCropScreenState();
// }

// class _AddNewCropScreenState extends State<AddNewCropScreen> {
//   int _selectedCategoryIndex = 0;
//   String? _selectedGardenId;
//   List<Map<String, dynamic>> _gardens = [];
//   bool _isLoading = false;
//   bool _isEditMode = false;
  
//   final TextEditingController _varietyController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _quantityUnitController = TextEditingController();
//   final TextEditingController _cropNameController = TextEditingController();
  
//   DateTime? _plantingDate;
//   DateTime? _expectedHarvestDate;
//   int _progress = 0;
//   String _status = 'seedling';
//   int _quantity = 1;
//   String? _quantityUnit;
  
//   final List<Map<String, dynamic>> _categories = [
//     {
//       'name': 'Vegetable',
//       'value': 'vegetable',
//       'icon': Icons.eco,
//       'color': Color(0xFF39AC86),
//     },
//     {
//       'name': 'Fruit',
//       'value': 'fruit',
//       'icon': Icons.restaurant,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Herb',
//       'value': 'herb',
//       'icon': Icons.spa,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Flower',
//       'value': 'flower',
//       'icon': Icons.local_florist,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Other',
//       'value': 'other',
//       'icon': Icons.category,
//       'color': Color(0xFF5C8A7A),
//     },
//   ];

//   final List<Map<String, dynamic>> _statusOptions = [
//     {'name': 'Seedling', 'value': 'seedling'},
//     {'name': 'Vegetative', 'value': 'vegetative'},
//     {'name': 'Flowering', 'value': 'flowering'},
//     {'name': 'Fruiting', 'value': 'fruiting'},
//     {'name': 'Harvest', 'value': 'harvest'},
//     {'name': 'Dormant', 'value': 'dormant'},
//   ];

//   final List<String> _quantityUnits = ['plants', 'seeds', 'kg', 'g', 'lb', 'oz', 'units'];

//   @override
//   void initState() {
//     super.initState();
//     _isEditMode = widget.existingCrop != null;
//     _loadGardens();
    
//     if (_isEditMode && widget.existingCrop != null) {
//       _populateExistingCrop();
//     } else if (widget.gardenId != null) {
//       _selectedGardenId = widget.gardenId;
//     }
    
//     // Set default quantity to 1
//     _quantityController.text = '1';
//   }

//   void _populateExistingCrop() {
//     final crop = widget.existingCrop!;
    
//     _cropNameController.text = crop['name'] ?? '';
    
//     // Find category index
//     final categoryValue = crop['category'] ?? 'vegetable';
//     final categoryIndex = _categories.indexWhere((cat) => cat['value'] == categoryValue);
//     if (categoryIndex != -1) {
//       _selectedCategoryIndex = categoryIndex;
//     }
    
//     _varietyController.text = crop['variety'] ?? '';
//     _notesController.text = crop['notes'] ?? '';
//     _status = crop['status'] ?? 'seedling';
//     _progress = crop['progress'] ?? 0;
//     _selectedGardenId = crop['garden_id'];
//     _quantity = crop['quantity'] ?? 1;
//     _quantityController.text = _quantity.toString();
//     _quantityUnit = crop['quantity_unit'];
//     _quantityUnitController.text = _quantityUnit ?? 'plants';
    
//     if (crop['planting_date'] != null) {
//       _plantingDate = DateTime.parse(crop['planting_date']);
//     }
    
//     if (crop['expected_harvest'] != null) {
//       _expectedHarvestDate = DateTime.parse(crop['expected_harvest']);
//     }
//   }

//   Future<void> _loadGardens() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final gardens = await CropsService.getUserGardens();
//       setState(() {
//         _gardens = List<Map<String, dynamic>>.from(gardens);
        
//         // If no garden is selected yet and we have gardens, select the first one
//         if (_selectedGardenId == null && _gardens.isNotEmpty) {
//           _selectedGardenId = _gardens[0]['id'];
//         }
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load gardens: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _selectPlantingDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _plantingDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
    
//     if (picked != null && picked != _plantingDate) {
//       setState(() {
//         _plantingDate = picked;
        
//         // Auto-calculate harvest date (30 days after planting)
//         if (_expectedHarvestDate == null) {
//           _expectedHarvestDate = picked.add(Duration(days: 30));
//         }
//       });
//     }
//   }

//   Future<void> _selectHarvestDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _expectedHarvestDate ?? (_plantingDate?.add(Duration(days: 30)) ?? DateTime.now().add(Duration(days: 30))),
//       firstDate: _plantingDate ?? DateTime.now(),
//       lastDate: DateTime(2100),
//     );
    
//     if (picked != null && picked != _expectedHarvestDate) {
//       setState(() {
//         _expectedHarvestDate = picked;
//       });
//     }
//   }

//   Future<void> _saveCrop() async {
//     // Validation
//     if (_cropNameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please enter a crop name'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     if (_selectedGardenId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please select a garden'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     if (_quantityController.text.trim().isEmpty) {
//       _quantityController.text = '1';
//     }

//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       final cropData = {
//         'garden_id': _selectedGardenId,
//         'name': _cropNameController.text.trim(),
//         'category': _categories[_selectedCategoryIndex]['value'],
//         'variety': _varietyController.text.trim().isEmpty ? null : _varietyController.text.trim(),
//         'planting_date': _plantingDate?.toIso8601String().split('T')[0],
//         'expected_harvest': _expectedHarvestDate?.toIso8601String().split('T')[0],
//         'status': _status,
//         'progress': _progress,
//         'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
//         'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
//         'quantity_unit': _quantityUnitController.text.trim().isEmpty ? null : _quantityUnitController.text.trim(),
//         'is_shared': false,
//       };

//       Map<String, dynamic> response;
      
//       if (_isEditMode) {
//         response = await CropsService.updateCrop(widget.existingCrop!['id'], cropData);
//       } else {
//         response = await CropsService.createCrop(cropData);
//       }

//       if (response['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response['message'] ?? 'Crop saved successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
        
//         // Wait a bit before popping to show the success message
//         await Future.delayed(Duration(milliseconds: 500));
        
//         Navigator.pop(context, response['crop'] ?? true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response['error'] ?? 'Failed to save crop'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _varietyController.dispose();
//     _notesController.dispose();
//     _quantityController.dispose();
//     _quantityUnitController.dispose();
//     _cropNameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDarkMode ? Color(0xFF212C28) : Color(0xFFF9F8F6),
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             // Top App Bar
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: isDarkMode 
//                     ? Color(0xFF212C28).withOpacity(0.8)
//                     : Color(0xFFF9F8F6).withOpacity(0.8),
//                 border: Border(
//                   bottom: BorderSide(
//                     color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFE5E7EB),
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Close Button
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(
//                       Icons.close,
//                       color: Color(0xFF39AC86),
//                       size: 24,
//                     ),
//                   ),
                  
//                   // Title
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         _isEditMode ? 'Edit Crop' : 'Add New Crop',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   // Save Button
//                   _isLoading
//                       ? Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           child: SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39AC86)),
//                             ),
//                           ),
//                         )
//                       : TextButton(
//                           onPressed: _saveCrop,
//                           child: Text(
//                             'Save',
//                             style: TextStyle(
//                               color: Color(0xFF39AC86),
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),

//             // Main Content
//             Expanded(
//               child: _isLoading && _gardens.isEmpty
//                   ? Center(child: CircularProgressIndicator())
//                   : SingleChildScrollView(
//                       padding: EdgeInsets.only(bottom: 100),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Crop Name Input
//                           _buildCropNameInput(isDarkMode),
                          
//                           // Garden Selection
//                           _buildGardenSelection(isDarkMode),
                          
//                           // Category Section
//                           _buildCategorySection(isDarkMode),
                          
//                           // Crop Variety Input
//                           _buildVarietyInput(isDarkMode),
                          
//                           // Timeline Section
//                           _buildTimelineSection(isDarkMode),
                          
//                           // Status and Progress
//                           _buildStatusSection(isDarkMode),
                          
//                           // Quantity Section
//                           _buildQuantitySection(isDarkMode),
                          
//                           // Notes Section
//                           _buildNotesSection(isDarkMode),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
      
//       // Bottom CTA Button
//       bottomSheet: Container(
//         color: isDarkMode 
//             ? Color(0xFF212C28).withOpacity(0.9)
//             : Color(0xFFF9F8F6).withOpacity(0.9),
//         padding: EdgeInsets.all(16),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFF39AC86).withOpacity(0.2),
//                 blurRadius: 16,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Material(
//             color: Color(0xFF39AC86),
//             borderRadius: BorderRadius.circular(12),
//             child: InkWell(
//               onTap: _isLoading ? null : _saveCrop,
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add_task,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       _isEditMode ? 'Update Crop' : 'Add to My Garden',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCropNameInput(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Crop Name',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             height: 56,
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 16),
//                     child: TextField(
//                       controller: _cropNameController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g. Tomatoes, Basil, Carrots',
//                         hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                         border: InputBorder.none,
//                       ),
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGardenSelection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select Garden',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           if (_gardens.isEmpty)
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'No gardens found. Please create a garden first.',
//                   style: TextStyle(
//                     color: Color(0xFF5C8A7A),
//                   ),
//                 ),
//               ),
//             )
//           else
//             Container(
//               decoration: BoxDecoration(
//                 color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                 ),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedGardenId,
//                   isExpanded: true,
//                   dropdownColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : Color(0xFF101816),
//                     fontSize: 16,
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   items: _gardens.map((garden) {
//                     return DropdownMenuItem<String>(
//                       value: garden['id'],
//                       child: Text(garden['name']),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedGardenId = newValue;
//                     });
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategorySection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select Category',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Category Grid
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 1,
//             ),
//             itemCount: _categories.length,
//             itemBuilder: (context, index) {
//               final category = _categories[index];
//               final isSelected = _selectedCategoryIndex == index;
              
//               return Material(
//                 color: isSelected
//                     ? Color(0xFF39AC86).withOpacity(0.05)
//                     : (isDarkMode ? Color(0xFF2D3A35) : Colors.white),
//                 borderRadius: BorderRadius.circular(12),
//                 child: InkWell(
//                   onTap: () => setState(() => _selectedCategoryIndex = index),
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected
//                             ? Color(0xFF39AC86)
//                             : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? Color(0xFF39AC86)
//                                 : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF5F5F5)),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             category['icon'],
//                             color: isSelected ? Colors.white : category['color'],
//                             size: 20,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           category['name'],
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? Color(0xFF39AC86)
//                                 : (isDarkMode ? Colors.white : Color(0xFF101816)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVarietyInput(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Crop Variety (Optional)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             height: 56,
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 16),
//                     child: TextField(
//                       controller: _varietyController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g. Cherry Belle Radish, Roma Tomato',
//                         hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                         border: InputBorder.none,
//                       ),
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimelineSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Timeline',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Planting Date Card
//           _buildTimelineCard(
//             isDarkMode,
//             icon: Icons.calendar_today,
//             iconColor: Color(0xFF39AC86),
//             title: 'Planting Date',
//             date: _plantingDate,
//             onTap: _selectPlantingDate,
//             showAutoBadge: false,
//           ),
          
//           SizedBox(height: 12),
          
//           // Expected Harvest Card
//           _buildTimelineCard(
//             isDarkMode,
//             icon: Icons.thermostat_auto,
//             iconColor: Color(0xFFE59866),
//             title: 'Expected Harvest',
//             date: _expectedHarvestDate,
//             onTap: _selectHarvestDate,
//             showAutoBadge: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimelineCard(
//     bool isDarkMode, {
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required DateTime? date,
//     required VoidCallback onTap,
//     required bool showAutoBadge,
//   }) {
//     final dateText = date != null 
//         ? DateFormat('MMM dd, yyyy').format(date)
//         : 'Select date';

//     return Material(
//       color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: iconColor,
//                   size: 20,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF5C8A7A),
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Row(
//                       children: [
//                         Text(
//                           dateText,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: isDarkMode ? Colors.white : Color(0xFF101816),
//                             fontStyle: showAutoBadge && date == null ? FontStyle.italic : FontStyle.normal,
//                           ),
//                         ),
//                         if (showAutoBadge && date == null) ...[
//                           SizedBox(width: 8),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFE59866).withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               'AUTO',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFFE59866),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right,
//                 color: Color(0xFF5C8A7A),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Status & Progress',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Status Selection
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _statusOptions.map((status) {
//               final isSelected = _status == status['value'];
//               return ChoiceChip(
//                 label: Text(status['name']),
//                 selected: isSelected,
//                 selectedColor: Color(0xFF39AC86),
//                 backgroundColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                 labelStyle: TextStyle(
//                   color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Color(0xFF101816)),
//                 ),
//                 onSelected: (selected) {
//                   setState(() {
//                     _status = status['value'];
//                   });
//                 },
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   side: BorderSide(
//                     color: isSelected ? Color(0xFF39AC86) : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
          
//           SizedBox(height: 16),
          
//           // Progress Slider
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Progress',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                       ),
//                     ),
//                     Text(
//                       '$_progress%',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF39AC86),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Slider(
//                   value: _progress.toDouble(),
//                   min: 0,
//                   max: 100,
//                   divisions: 10,
//                   activeColor: Color(0xFF39AC86),
//                   inactiveColor: Color(0xFF5C8A7A).withOpacity(0.3),
//                   onChanged: (value) {
//                     setState(() {
//                       _progress = value.round();
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuantitySection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quantity',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           Row(
//             children: [
//               // Quantity Input
//               Expanded(
//                 child: Container(
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: EdgeInsets.only(left: 16),
//                           child: TextField(
//                             controller: _quantityController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: 'Quantity',
//                               hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                               border: InputBorder.none,
//                             ),
//                             style: TextStyle(
//                               color: isDarkMode ? Colors.white : Color(0xFF101816),
//                               fontSize: 16,
//                             ),
//                             onChanged: (value) {
//                               _quantity = int.tryParse(value) ?? 1;
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(width: 12),
              
//               // Unit Dropdown
//               Container(
//                 width: 120,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//                   ),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _quantityUnitController.text.isEmpty ? 'plants' : _quantityUnitController.text,
//                     isExpanded: true,
//                     dropdownColor: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//                     style: TextStyle(
//                       color: isDarkMode ? Colors.white : Color(0xFF101816),
//                       fontSize: 16,
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     items: _quantityUnits.map((unit) {
//                       return DropdownMenuItem<String>(
//                         value: unit,
//                         child: Text(unit),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _quantityUnitController.text = newValue!;
//                         _quantityUnit = newValue;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotesSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Notes & Additional Info (Optional)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: TextField(
//               controller: _notesController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Soil type, special care instructions, location in garden...',
//                 hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.all(16),
//               ),
//               style: TextStyle(
//                 color: isDarkMode ? Colors.white : Color(0xFF101816),
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';

// class AddNewCropScreen extends StatefulWidget {
//   const AddNewCropScreen({Key? key}) : super(key: key);

//   @override
//   State<AddNewCropScreen> createState() => _AddNewCropScreenState();
// }

// class _AddNewCropScreenState extends State<AddNewCropScreen> {
//   int _selectedCategoryIndex = 0;
//   bool _isOutdoor = true;
//   final TextEditingController _varietyController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
  
//   final List<Map<String, dynamic>> _categories = [
//     {
//       'name': 'Vegetable',
//       'icon': Icons.eco,
//       'color': Color(0xFF39AC86),
//     },
//     {
//       'name': 'Fruit',
//       'icon': Icons.restaurant,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Herb',
//       'icon': Icons.spa,
//       'color': Color(0xFF5C8A7A),
//     },
//     {
//       'name': 'Flower',
//       'icon': Icons.local_florist,
//       'color': Color(0xFF5C8A7A),
//     },
//   ];

//   @override
//   void dispose() {
//     _varietyController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDarkMode ? Color(0xFF212C28) : Color(0xFFF9F8F6),
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             // Top App Bar
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: isDarkMode 
//                     ? Color(0xFF212C28).withOpacity(0.8)
//                     : Color(0xFFF9F8F6).withOpacity(0.8),
//                 border: Border(
//                   bottom: BorderSide(
//                     color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFE5E7EB),
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Close Button
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(
//                       Icons.close,
//                       color: Color(0xFF39AC86),
//                       size: 24,
//                     ),
//                   ),
                  
//                   // Title
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         'Add New Crop',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   // Save Button
//                   TextButton(
//                     onPressed: () {
//                       // TODO: Implement save functionality
//                       Navigator.pop(context);
//                     },
//                     child: Text(
//                       'Save',
//                       style: TextStyle(
//                         color: Color(0xFF39AC86),
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Main Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.only(bottom: 100),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Environment Toggle
//                     _buildEnvironmentToggle(isDarkMode),
                    
//                     // Category Section
//                     _buildCategorySection(isDarkMode),
                    
//                     // Crop Variety Input
//                     _buildVarietyInput(isDarkMode),
                    
//                     // Timeline Section
//                     _buildTimelineSection(isDarkMode),
                    
//                     // Notes Section
//                     _buildNotesSection(isDarkMode),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
      
//       // Bottom CTA Button
//       bottomSheet: Container(
//         color: isDarkMode 
//             ? Color(0xFF212C28).withOpacity(0.9)
//             : Color(0xFFF9F8F6).withOpacity(0.9),
//         padding: EdgeInsets.all(16),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFF39AC86).withOpacity(0.2),
//                 blurRadius: 16,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Material(
//             color: Color(0xFF39AC86),
//             borderRadius: BorderRadius.circular(12),
//             child: InkWell(
//               onTap: () {
//                 // TODO: Implement add to garden functionality
//                 Navigator.pop(context);
//               },
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add_task,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Add to My Garden',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEnvironmentToggle(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Container(
//         padding: EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//           ),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Material(
//                 color: _isOutdoor ? Color(0xFF39AC86) : Colors.transparent,
//                 borderRadius: BorderRadius.circular(8),
//                 child: InkWell(
//                   onTap: () => setState(() => _isOutdoor = true),
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     child: Center(
//                       child: Text(
//                         'Outdoor Garden',
//                         style: TextStyle(
//                           color: _isOutdoor ? Colors.white : Color(0xFF5C8A7A),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 4),
//             Expanded(
//               child: Material(
//                 color: !_isOutdoor ? Color(0xFF39AC86) : Colors.transparent,
//                 borderRadius: BorderRadius.circular(8),
//                 child: InkWell(
//                   onTap: () => setState(() => _isOutdoor = false),
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     child: Center(
//                       child: Text(
//                         'Indoor Planter',
//                         style: TextStyle(
//                           color: !_isOutdoor ? Colors.white : Color(0xFF5C8A7A),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategorySection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select Category',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             'What are you planting today?',
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF5C8A7A),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Category Grid
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 1.2,
//             ),
//             itemCount: _categories.length,
//             itemBuilder: (context, index) {
//               final category = _categories[index];
//               final isSelected = _selectedCategoryIndex == index;
              
//               return Material(
//                 color: isSelected
//                     ? Color(0xFF39AC86).withOpacity(0.05)
//                     : (isDarkMode ? Color(0xFF2D3A35) : Colors.white),
//                 borderRadius: BorderRadius.circular(12),
//                 child: InkWell(
//                   onTap: () => setState(() => _selectedCategoryIndex = index),
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected
//                             ? Color(0xFF39AC86)
//                             : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1)),
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? Color(0xFF39AC86)
//                                 : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF5F5F5)),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             category['icon'],
//                             color: isSelected ? Colors.white : category['color'],
//                             size: 24,
//                           ),
//                         ),
//                         Text(
//                           category['name'],
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? Color(0xFF39AC86)
//                                 : (isDarkMode ? Colors.white : Color(0xFF101816)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVarietyInput(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Crop Variety',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             height: 56,
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 16),
//                     child: TextField(
//                       controller: _varietyController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g. Cherry Belle Radish',
//                         hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                         border: InputBorder.none,
//                       ),
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(right: 16),
//                   child: Icon(
//                     Icons.edit,
//                     color: Color(0xFF39AC86).withOpacity(0.4),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimelineSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Timeline',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 16),
          
//           // Planting Date Card
//           _buildTimelineCard(
//             isDarkMode,
//             icon: Icons.calendar_today,
//             iconColor: Color(0xFF39AC86),
//             title: 'Planting Date',
//             subtitle: 'May 12, 2024',
//             showAutoBadge: false,
//           ),
          
//           SizedBox(height: 12),
          
//           // Expected Harvest Card
//           _buildTimelineCard(
//             isDarkMode,
//             icon: Icons.thermostat_auto,
//             iconColor: Color(0xFFE59866),
//             title: 'Expected Harvest',
//             subtitle: 'Estimated July 15',
//             showAutoBadge: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimelineCard(
//     bool isDarkMode, {
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required bool showAutoBadge,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               icon,
//               color: iconColor,
//               size: 20,
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF5C8A7A),
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Row(
//                   children: [
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: isDarkMode ? Colors.white : Color(0xFF101816),
//                         fontStyle: showAutoBadge ? FontStyle.italic : FontStyle.normal,
//                       ),
//                     ),
//                     if (showAutoBadge) ...[
//                       SizedBox(width: 8),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFE59866).withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           'AUTO',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFFE59866),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Icon(
//             Icons.chevron_right,
//             color: Color(0xFF5C8A7A),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotesSection(bool isDarkMode) {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Notes & Soil Type',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDarkMode ? Colors.white : Color(0xFF101816),
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             decoration: BoxDecoration(
//               color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF0F2F1),
//               ),
//             ),
//             child: TextField(
//               controller: _notesController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Adding extra compost, high drainage...',
//                 hintStyle: TextStyle(color: Color(0xFF5C8A7A)),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.all(16),
//               ),
//               style: TextStyle(
//                 color: isDarkMode ? Colors.white : Color(0xFF101816),
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
