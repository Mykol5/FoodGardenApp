import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class ShareScreen extends StatefulWidget {
  final Map<String, dynamic>? existingCrop; // Optional: pre-fill from a crop
  
  const ShareScreen({super.key, this.existingCrop});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _itemNameController = TextEditingController();
  final _pickupInstructionsController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int _quantity = 3;
  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'lbs';
  bool _isLoading = false;
  
  // Image related
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;
  
  final List<String> categories = ['Vegetables', 'Fruits', 'Herbs', 'Seeds', 'Other'];
  final List<String> units = ['lbs', 'kg', 'oz', 'pieces', 'bunches'];
  
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Pre-fill if coming from a crop
    if (widget.existingCrop != null) {
      _itemNameController.text = widget.existingCrop!['name'] ?? '';
      _selectedCategory = _capitalize(widget.existingCrop!['category'] ?? 'vegetable');
      _quantity = widget.existingCrop!['quantity'] ?? 3;
      _selectedUnit = widget.existingCrop!['quantity_unit'] ?? 'lbs';
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _pickupInstructionsController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
        _uploadedImageUrl = null; // Reset uploaded URL when new image selected
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null || _selectedImageBytes == null) return null;
    
    setState(() {
      _isUploadingImage = true;
    });
    
    try {
      final base64Image = base64Encode(_selectedImageBytes!);
      final fileName = _selectedImage!.name;

      final result = await _apiService.uploadImageWeb(base64Image, fileName);
      
      if (result['success'] == true) {
        final imageUrl = result['imageUrl'];
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        return imageUrl;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to upload image'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      print('❌ Upload image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _shareItem() async {
    // Validate
    if (_itemNameController.text.trim().isEmpty) {
      _showError('Please enter an item name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) {
          setState(() {
            _isLoading = false;
          });
          return; // Image upload failed
        }
      } else {
        imageUrl = _uploadedImageUrl; // Use previously uploaded image if any
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      final itemData = {
        'name': _itemNameController.text.trim(),
        'category': _selectedCategory.toLowerCase(),
        'quantity': _quantity,
        'quantity_unit': _selectedUnit,
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'pickup_instructions': _pickupInstructionsController.text.trim().isEmpty
            ? null
            : _pickupInstructionsController.text.trim(),
        'image_url': imageUrl,
        'location_text': user?['location'] ?? 'Unknown',
      };

      print('📤 Sharing item: $itemData');
      
      final result = await _apiService.createSharedItem(itemData);

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showError(result['error'] ?? 'Failed to share item');
      }
    } catch (e) {
      print('❌ Share error: $e');
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Top App Bar
                  _buildTopBar(isDarkMode),
                  
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Hero Photo Uploader
                        _buildImageUploader(isDarkMode),

                        const SizedBox(height: 24),

                        // Produce Details Card
                        _buildProduceDetailsCard(isDarkMode),

                        const SizedBox(height: 16),

                        // Quantity & Logistics Card
                        _buildLogisticsCard(isDarkMode),

                        const SizedBox(height: 16),

                        // Sustainability Tip
                        _buildSustainabilityTip(isDarkMode),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom CTA
            _buildBottomCTA(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF212C28).withOpacity(0.8)
            : const Color(0xFFF9F8F6).withOpacity(0.8),
      ),
      child: Row(
        children: [
          // Close Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.black87,
                size: 24,
              ),
            ),
          ),
          // Title
          Expanded(
            child: Center(
              child: Text(
                'Share Your Surplus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF101816),
                ),
              ),
            ),
          ),
          // Help Button
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Help',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF39AC86),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader(bool isDarkMode) {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickImage,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF39AC86).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF39AC86).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: _selectedImageBytes != null
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _selectedImageBytes!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImage = null;
                        _selectedImageBytes = null;
                        _uploadedImageUrl = null;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF39AC86).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: _isUploadingImage
                        ? const CircularProgressIndicator(color: Color(0xFF39AC86))
                        : const Icon(
                            Icons.eco,
                            color: Color(0xFF39AC86),
                            size: 48,
                          ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Capture the Harvest',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a photo of your produce to attract neighbors',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode 
                          ? const Color(0xFFA0C4B8) 
                          : const Color(0xFF5C8A7A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39AC86),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Upload Photo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProduceDetailsCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produce Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Item Name Field
          _buildTextField(
            isDarkMode,
            controller: _itemNameController,
            label: 'Item Name',
            hint: 'e.g. Heirloom Roma Tomatoes',
          ),

          const SizedBox(height: 16),

          // Description Field
          _buildTextField(
            isDarkMode,
            controller: _descriptionController,
            label: 'Description (Optional)',
            hint: 'Describe your produce...',
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Category Chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF101816),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;
                    
                    return Container(
                      margin: EdgeInsets.only(
                        right: index < categories.length - 1 ? 8 : 0,
                      ),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: const Color(0xFF39AC86),
                        backgroundColor: isDarkMode 
                            ? const Color(0xFF212C28) 
                            : const Color(0xFFEAF1EE),
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : (isDarkMode ? Colors.white : const Color(0xFF101816)),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quantity Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'How much can you share?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C8A7A),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Decrease Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_quantity > 1) _quantity--;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Color(0xFF39AC86),
                        size: 24,
                      ),
                    ),
                  ),
                  // Quantity Display with Unit Dropdown
                  Row(
                    children: [
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      DropdownButton<String>(
                        value: _selectedUnit,
                        items: units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                        underline: Container(),
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ],
                  ),
                  // Increase Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF39AC86),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Divider
          Divider(
            color: isDarkMode 
                ? Colors.white.withOpacity(0.05) 
                : const Color(0xFF39AC86).withOpacity(0.05),
            height: 1,
          ),

          const SizedBox(height: 16),

          // Pick-up Instructions
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pick-up Instructions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF101816),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF212C28) 
                      : const Color(0xFFF9F8F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF39AC86).withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: _pickupInstructionsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'e.g. Left in a basket on the porch bench. Help yourself!',
                    hintStyle: TextStyle(
                      color: const Color(0xFF5C8A7A).withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityTip(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE38B6D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE38B6D).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.eco,
            color: Color(0xFFE38B6D),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harvest Tip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE38B6D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "By sharing your surplus, you're preventing approximately 1.5kg of methane emissions from landfill waste!",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.8) 
                        : const Color(0xFF101816).withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(bool isDarkMode) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF212C28).withOpacity(0.8)
              : const Color(0xFFF9F8F6).withOpacity(0.8),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF39AC86).withOpacity(0.05),
            ),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _isLoading ? Colors.grey : const Color(0xFF39AC86),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isLoading ? null : _shareItem,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _isLoading
                    ? [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ]
                    : [
                        const Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Post to Marketplace',
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
    );
  }

  Widget _buildTextField(
    bool isDarkMode, {
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF101816),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF212C28) 
                : const Color(0xFFF9F8F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF39AC86).withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF5C8A7A).withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
