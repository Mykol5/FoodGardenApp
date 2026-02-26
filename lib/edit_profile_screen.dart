import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const EditProfileScreen({
    super.key,
    required this.userData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _gardenNameController = TextEditingController();
  final TextEditingController _gardenSizeController = TextEditingController();
  
  // Image related variables
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _currentProfileImageUrl;
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Set initial values from user data
    _fullNameController.text = widget.userData['name'] ?? '';
    _bioController.text = widget.userData['bio'] ?? '';
    _locationController.text = widget.userData['location'] ?? '';
    _gardenNameController.text = widget.userData['garden_name'] ?? '';
    _gardenSizeController.text = widget.userData['garden_size']?.toString() ?? '';
    _currentProfileImageUrl = widget.userData['profile_image_url'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _gardenNameController.dispose();
    _gardenSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/profile/upload-image'),
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
        setState(() {
          _currentProfileImageUrl = data['imageUrl'];
          _selectedImage = null; // Clear selected image after successful upload
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Failed to upload image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Upload image error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _removeProfileImage() async {
    if (_currentProfileImageUrl == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/api/profile/image'),
        headers: _apiService.headers,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _currentProfileImageUrl = null;
          _selectedImage = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo removed'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Failed to remove image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Remove image error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.isEmpty) {
      _showError('Full name is required');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // First upload image if selected
      if (_selectedImage != null) {
        await _uploadProfileImage();
      }

      // Then update profile data
      final result = await _apiService.updateUserProfile(
        name: _fullNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        gardenName: _gardenNameController.text.trim().isEmpty ? null : _gardenNameController.text.trim(),
        gardenSize: _gardenSizeController.text.trim().isEmpty ? null : _gardenSizeController.text.trim(),
      );

      if (result['success'] == true) {
        // Update local auth provider
        final authProvider = context.read<AuthProvider>();
        await authProvider.initialize(); // This will reload user data
        
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        _showError(result['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39AC86).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF39AC86),
                  ),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_currentProfileImageUrl != null || _selectedImage != null) ...[
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text(
                    'Remove Current Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7),
      body: Column(
        children: [
          // Top Navigation Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: BoxDecoration(
              color: (isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7)).withOpacity(0.8),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFE5E7E6),
                ),
              ),
            ),
            child: Row(
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Color(0xFF39AC86),
                    ),
                  ),
                ),
                
                // Title
                Expanded(
                  child: Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                
                // Placeholder to balance the layout
                const SizedBox(width: 40),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  // Profile Photo Section - UPDATED WITH IMAGE PICKER
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    child: Column(
                      children: [
                        // Profile Picture with Camera Button
                        GestureDetector(
                          onTap: _isUploadingImage ? null : _showImageOptions,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // Profile Image
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(64),
                                  border: Border.all(
                                    color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
                                    width: 4,
                                  ),
                                  image: _selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(_selectedImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : (_currentProfileImageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(_currentProfileImageUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                  color: _selectedImage == null && _currentProfileImageUrl == null
                                      ? const Color(0xFF39AC86).withOpacity(0.1)
                                      : null,
                                ),
                                child: _selectedImage == null && _currentProfileImageUrl == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 64,
                                          color: Color(0xFF39AC86),
                                        ),
                                      )
                                    : null,
                              ),
                              
                              // Camera/Upload Indicator
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _isUploadingImage 
                                      ? Colors.grey 
                                      : const Color(0xFF39AC86),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkMode ? const Color(0xFF11211C) : Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _isUploadingImage
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.photo_camera,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Change Photo Button
                        GestureDetector(
                          onTap: _isUploadingImage ? null : _showImageOptions,
                          child: Text(
                            _isUploadingImage ? 'Uploading...' : 'Change Photo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isUploadingImage 
                                  ? Colors.grey 
                                  : const Color(0xFF39AC86),
                            ),
                          ),
                        ),

                        if (_selectedImage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Photo selected (will upload when you save)',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF39AC86),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Personal Information Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 16),
                          child: Text(
                            'PERSONAL INFORMATION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B7280),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        
                        // Full Name Field
                        _buildTextField(
                          isDarkMode,
                          controller: _fullNameController,
                          label: 'Full Name *',
                          hint: 'Your full name',
                          enabled: !_isUploadingImage,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Bio Field
                        _buildTextField(
                          isDarkMode,
                          controller: _bioController,
                          label: 'Bio (Optional)',
                          hint: 'Tell the community about your sustainable journey...',
                          maxLines: 5,
                          enabled: !_isUploadingImage,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Location Field with Current Location Button
                        _buildLocationField(isDarkMode),
                      ],
                    ),
                  ),
                  
                  // Garden Details Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            'GARDEN DETAILS (OPTIONAL)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B7280),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        
                        Row(
                          children: [
                            // Garden Name
                            Expanded(
                              child: _buildTextField(
                                isDarkMode,
                                controller: _gardenNameController,
                                label: 'Garden Name',
                                hint: 'e.g. Backyard Oasis',
                                enabled: !_isUploadingImage,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Garden Size
                            Expanded(
                              child: _buildTextField(
                                isDarkMode,
                                controller: _gardenSizeController,
                                label: 'Garden Size (sq ft)',
                                hint: 'e.g. 100',
                                keyboardType: TextInputType.number,
                                enabled: !_isUploadingImage,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Danger Zone Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isUploadingImage ? null : _handleDeleteAccount,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? const Color(0xFF5A1A1A).withOpacity(0.1)
                                  : const Color(0xFFFEE2E2).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode 
                                    ? const Color(0xFF7F1D1D).withOpacity(0.3)
                                    : const Color(0xFFFECACA),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Save Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7),
              (isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7)).withOpacity(0.95),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          height: 56,
          decoration: BoxDecoration(
            color: (_isSaving || _isUploadingImage) 
                ? const Color(0xFF39AC86).withOpacity(0.7) 
                : const Color(0xFF39AC86),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF39AC86).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: (_isSaving || _isUploadingImage) ? null : _saveProfile,
            child: Center(
              child: (_isSaving || _isUploadingImage)
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
            ),
          ),
        ),
        Container(
          constraints: maxLines > 1 ? const BoxConstraints(minHeight: 128) : null,
          decoration: BoxDecoration(
            color: isDarkMode 
                ? (enabled ? const Color(0xFF2A3A35) : const Color(0xFF1A2A25))
                : (enabled ? Colors.white : const Color(0xFFF5F5F5)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode 
                  ? (enabled ? Colors.white : Colors.grey) 
                  : (enabled ? const Color(0xFF1A1A1A) : Colors.grey),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: enabled ? const Color(0xFF9CA3AF) : Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: maxLines > 1 ? 16 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Location (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  enabled: !_isUploadingImage,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'City, State',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(16, 18, 120, 18),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location detection coming soon'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39AC86).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.my_location,
                          size: 16,
                          color: Color(0xFF39AC86),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF39AC86),
                          ),
                        ),
                      ],
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

// Add these imports at the top





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/api_service.dart';
// import '../providers/auth_provider.dart';

// class EditProfileScreen extends StatefulWidget {
//   final Map<String, dynamic> userData;
  
//   const EditProfileScreen({
//     super.key,
//     required this.userData,
//   });

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _gardenNameController = TextEditingController();
//   final TextEditingController _gardenSizeController = TextEditingController();
  
//   final ApiService _apiService = ApiService();
//   bool _isLoading = false;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     // Set initial values from user data
//     _fullNameController.text = widget.userData['name'] ?? '';
//     _bioController.text = widget.userData['bio'] ?? '';
//     _locationController.text = widget.userData['location'] ?? '';
//     _gardenNameController.text = widget.userData['garden_name'] ?? '';
//     _gardenSizeController.text = widget.userData['garden_size']?.toString() ?? '';
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _bioController.dispose();
//     _locationController.dispose();
//     _gardenNameController.dispose();
//     _gardenSizeController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveProfile() async {
//     if (_fullNameController.text.isEmpty) {
//       _showError('Full name is required');
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final result = await _apiService.updateUserProfile(
//         name: _fullNameController.text.trim(),
//         bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
//         location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
//         gardenName: _gardenNameController.text.trim().isEmpty ? null : _gardenNameController.text.trim(),
//         gardenSize: _gardenSizeController.text.trim().isEmpty ? null : _gardenSizeController.text.trim(),
//       );

//       if (result['success'] == true) {
//         // Update local auth provider
//         final authProvider = context.read<AuthProvider>();
//         await authProvider.initialize(); // This will reload user data
        
//         if (mounted) {
//           Navigator.pop(context, true); // Return true to indicate success
//         }
//       } else {
//         _showError(result['error'] ?? 'Failed to update profile');
//       }
//     } catch (e) {
//       _showError('Error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   void _handleDeleteAccount() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Account'),
//         content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // TODO: Implement account deletion
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Account deletion feature coming soon'),
//                   backgroundColor: Colors.orange,
//                 ),
//               );
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7),
//       body: Column(
//         children: [
//           // Top Navigation Bar
//           Container(
//             padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
//             decoration: BoxDecoration(
//               color: (isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7)).withOpacity(0.8),
//               border: Border(
//                 bottom: BorderSide(
//                   color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFE5E7E6),
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 // Back Button
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
//                     ),
//                     child: const Icon(
//                       Icons.arrow_back_ios_new,
//                       size: 20,
//                       color: Color(0xFF39AC86), // Updated to match your theme
//                     ),
//                   ),
//                 ),
                
//                 // Title
//                 Expanded(
//                   child: Center(
//                     child: Text(
//                       'Edit Profile',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//                       ),
//                     ),
//                   ),
//                 ),
                
//                 // Placeholder to balance the layout
//                 const SizedBox(width: 40),
//               ],
//             ),
//           ),
          
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.only(bottom: 120), // Space for bottom button
//               child: Column(
//                 children: [
//                   // Profile Photo Section
//                   Container(
//                     padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
//                     child: Column(
//                       children: [
//                         // Profile Picture with Camera Button
//                         GestureDetector(
//                           onTap: () {
//                             // Handle photo change
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Profile photo upload coming soon'),
//                                 backgroundColor: Colors.orange,
//                               ),
//                             );
//                           },
//                           child: Stack(
//                             alignment: Alignment.bottomRight,
//                             children: [
//                               // Profile Image
//                               Container(
//                                 width: 128,
//                                 height: 128,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(64),
//                                   border: Border.all(
//                                     color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
//                                     width: 4,
//                                   ),
//                                   image: widget.userData['profile_image_url'] != null
//                                     ? DecorationImage(
//                                         image: NetworkImage(widget.userData['profile_image_url']!),
//                                         fit: BoxFit.cover,
//                                       )
//                                     : null,
//                                   color: widget.userData['profile_image_url'] == null
//                                     ? const Color(0xFF39AC86).withOpacity(0.1)
//                                     : null,
//                                 ),
//                                 child: widget.userData['profile_image_url'] == null
//                                   ? const Center(
//                                       child: Icon(
//                                         Icons.person,
//                                         size: 64,
//                                         color: Color(0xFF39AC86),
//                                       ),
//                                     )
//                                   : null,
//                               ),
                              
//                               // Camera Icon
//                               Container(
//                                 width: 40,
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF39AC86),
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(
//                                     color: isDarkMode ? const Color(0xFF11211C) : Colors.white,
//                                     width: 2,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.photo_camera,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
                        
//                         const SizedBox(height: 16),
                        
//                         // Change Photo Button
//                         GestureDetector(
//                           onTap: () {
//                             // Handle photo change
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Profile photo upload coming soon'),
//                                 backgroundColor: Colors.orange,
//                               ),
//                             );
//                           },
//                           child: Text(
//                             'Change Photo',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xFF39AC86),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Personal Information Section
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Section Title
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4, bottom: 12, top: 16),
//                           child: Text(
//                             'PERSONAL INFORMATION',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: const Color(0xFF6B7280),
//                               letterSpacing: 1,
//                             ),
//                           ),
//                         ),
                        
//                         // Full Name Field
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 4, bottom: 8),
//                               child: Text(
//                                 'Full Name *',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
//                                 ),
//                               ),
//                               child: TextField(
//                                 controller: _fullNameController,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//                                 ),
//                                 decoration: const InputDecoration(
//                                   hintText: 'Your full name',
//                                   hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
                        
//                         const SizedBox(height: 16),
                        
//                         // Bio Field
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 4, bottom: 8),
//                               child: Text(
//                                 'Bio (Optional)',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               constraints: const BoxConstraints(minHeight: 128),
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
//                                 ),
//                               ),
//                               child: TextField(
//                                 controller: _bioController,
//                                 maxLines: 5,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//                                 ),
//                                 decoration: const InputDecoration(
//                                   hintText: 'Tell the community about your sustainable journey...',
//                                   hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.all(16),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
                        
//                         const SizedBox(height: 16),
                        
//                         // Location Field
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 4, bottom: 8),
//                               child: Text(
//                                 'Location (Optional)',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
//                                 ),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   TextField(
//                                     controller: _locationController,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//                                     ),
//                                     decoration: const InputDecoration(
//                                       hintText: 'City, State',
//                                       hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
//                                       border: InputBorder.none,
//                                       contentPadding: EdgeInsets.fromLTRB(16, 18, 120, 18),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     right: 8,
//                                     top: 8,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         // Use current location
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           const SnackBar(
//                                             content: Text('Location detection coming soon'),
//                                             backgroundColor: Colors.orange,
//                                           ),
//                                         );
//                                       },
//                                       child: Container(
//                                         height: 40,
//                                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFF39AC86).withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(12),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             const Icon(
//                                               Icons.my_location,
//                                               size: 16,
//                                               color: Color(0xFF39AC86),
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Text(
//                                               'Current',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: const Color(0xFF39AC86),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Garden Details Section
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Section Title
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4, bottom: 12),
//                           child: Text(
//                             'GARDEN DETAILS (OPTIONAL)',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: const Color(0xFF6B7280),
//                               letterSpacing: 1,
//                             ),
//                           ),
//                         ),
                        
//                         Row(
//                           children: [
//                             // Garden Name
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(left: 4, bottom: 8),
//                                     child: Text(
//                                       'Garden Name',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 56,
//                                     decoration: BoxDecoration(
//                                       color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
//                                       borderRadius: BorderRadius.circular(16),
//                                       border: Border.all(
//                                         color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
//                                       ),
//                                     ),
//                                     child: TextField(
//                                       controller: _gardenNameController,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//                                       ),
//                                       decoration: const InputDecoration(
//                                         hintText: 'e.g. Backyard Oasis',
//                                         hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
//                                         border: InputBorder.none,
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
                            
//                             const SizedBox(width: 16),
                            
//                             // Garden Size
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(left: 4, bottom: 8),
//                                     child: Text(
//                                       'Garden Size (sq ft)',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 56,
//                                     decoration: BoxDecoration(
//                                       color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
//                                       borderRadius: BorderRadius.circular(16),
//                                       border: Border.all(
//                                         color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
//                                       ),
//                                     ),
//                                     child: TextField(
//                                       controller: _gardenSizeController,
//                                       keyboardType: TextInputType.number,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
//                                       ),
//                                       decoration: const InputDecoration(
//                                         hintText: 'e.g. 100',
//                                         hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
//                                         border: InputBorder.none,
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Danger Zone Section
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       children: [
//                         GestureDetector(
//                           onTap: _handleDeleteAccount,
//                           child: Container(
//                             width: double.infinity,
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: isDarkMode 
//                                   ? const Color(0xFF5A1A1A).withOpacity(0.1)
//                                   : const Color(0xFFFEE2E2).withOpacity(0.5),
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: isDarkMode 
//                                     ? const Color(0xFF7F1D1D).withOpacity(0.3)
//                                     : const Color(0xFFFECACA),
//                               ),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'Delete Account',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color(0xFFDC2626),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   const SizedBox(height: 80), // Space for bottom button
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
      
//       // Bottom Save Button
//       bottomSheet: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.bottomCenter,
//             end: Alignment.topCenter,
//             colors: [
//               isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7),
//               (isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7)).withOpacity(0.95),
//               Colors.transparent,
//             ],
//             stops: const [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 400),
//           height: 56,
//           decoration: BoxDecoration(
//             color: _isSaving ? const Color(0xFF39AC86).withOpacity(0.7) : const Color(0xFF39AC86),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF39AC86).withOpacity(0.4),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: GestureDetector(
//             onTap: _isSaving ? null : _saveProfile,
//             child: Center(
//               child: _isSaving
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Text(
//                       'Save Changes',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
