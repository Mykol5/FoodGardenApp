// edit_profile_screen.dart
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _gardenNameController = TextEditingController();
  final TextEditingController _gardenSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial values
    _fullNameController.text = 'Elena Rivers';
    _bioController.text = 'Urban gardener and zero-waste advocate. Love sharing heirloom seeds and composting tips! 🌿✨';
    _locationController.text = 'Portland, OR';
    _gardenNameController.text = 'The Sunny Patch';
    _gardenSizeController.text = '120';
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
                      color: Color(0xFF19E6A2),
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
              padding: const EdgeInsets.only(bottom: 120), // Space for bottom button
              child: Column(
                children: [
                  // Profile Photo Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    child: Column(
                      children: [
                        // Profile Picture with Camera Button
                        GestureDetector(
                          onTap: () {
                            // Handle photo change
                          },
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
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuD6UxixynWk6qTgVwJECbnv6FPn9ijX15LNqb5v_nEPe1P4OGYQUv8VL-gQxmeQK5rUeu8BR24bu-nFfRZv9TRiTvF-RDxf0OpDWzb8w2QSirjVQifybWjEsnFJG6l5vqt3fSbOR70zzZ5-1tZdxk8YZdBlkBCugK3iPrus2h3D6N7-ZLfYG-9fW9ZNAtlrxTNKUtyWexue_LERuRbABo2fAVt6rIO-MWzp78wzH-WveMpq_usfjVSC3Efl6Vf5xA747FfmM9tjT1si',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              
                              // Camera Icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF19E6A2),
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
                                child: const Icon(
                                  Icons.photo_camera,
                                  color: Color(0xFF1A1A1A),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Change Photo Button
                        GestureDetector(
                          onTap: () {
                            // Handle photo change
                          },
                          child: Text(
                            'Change Photo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF19E6A2),
                            ),
                          ),
                        ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Full Name',
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
                              child: TextField(
                                controller: _fullNameController,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Your full name',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Bio Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? const Color(0xFFE5E7E6) : const Color(0xFF374151),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minHeight: 128),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF2A3A35) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF3A4A45) : const Color(0xFFE5E7E6),
                                ),
                              ),
                              child: TextField(
                                controller: _bioController,
                                maxLines: 5,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Tell the community about your sustainable journey...',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Location Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Location',
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
                              child: Stack(
                                children: [
                                  TextField(
                                    controller: _locationController,
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
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF19E6A2).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.my_location,
                                            size: 16,
                                            color: Color(0xFF19E6A2),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Current',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF19E6A2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                            'GARDEN DETAILS',
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      'Garden Name',
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
                                    child: TextField(
                                      controller: _gardenNameController,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Backyard Oasis',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Garden Size
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      'Garden Size (sq ft)',
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
                                    child: TextField(
                                      controller: _gardenSizeController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. 100',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                      ),
                                    ),
                                  ),
                                ],
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
                        Container(
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
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 80), // Space for bottom button
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
            color: const Color(0xFF19E6A2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19E6A2).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
