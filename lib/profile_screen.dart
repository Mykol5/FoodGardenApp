// profile_screen.dart
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Share functionality method
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Share Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Share options
                Column(
                  children: [
                    _buildShareOption(
                      context,
                      icon: Icons.copy,
                      label: 'Copy Profile Link',
                      onTap: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile link copied to clipboard'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    
                    _buildShareOption(
                      context,
                      icon: Icons.message,
                      label: 'Share via Message',
                      onTap: () {
                        // Share via messaging
                        Navigator.pop(context);
                      },
                    ),
                    
                    _buildShareOption(
                      context,
                      icon: Icons.more_horiz,
                      label: 'More Options',
                      onTap: () {
                        // Open system share sheet
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Cancel button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? const Color(0xFF3A4A45).withOpacity(0.5)
                            : const Color(0xFFF9F8F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Helper method for share options
  Widget _buildShareOption(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : const Color(0xFFF0F2F1),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF39AC86),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF212C28).withOpacity(0.8)
                      : const Color(0xFFF9F8F6).withOpacity(0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Color(0xFF39AC86),
                        ),
                      ),
                    ),
                    // Title
                    const Text(
                      'Sustainability Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Settings button
                    GestureDetector(
                      onTap: () {
                        // Handle settings tap
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Profile Header Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(64),
                            border: Border.all(
                              color: const Color(0xFF39AC86).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCFoFY1UF5bL-8ZbOF5mhXmzBcLybFmbiGSFNfj_lW16i0SK5Av-JHLXlZo6Kc9jwSmcbbfF-eAVRrYI1w9X_xHcZ2ngBxtnSmmpMic0LSz0tZZGHq5UesNkgRw-Sxg6HQ7BWvRPWmOzbbLo2Y_MKdeP_9s3TOn30nQXRhCjSt-ysd7Fn0RVjDBtgAKyR-QPL_4zAY_LIBBB_3DLNBs_y-Wdkjootz8dRgvRS31gysqa6_ze1WfYZc0CBMs-VQZAUvKNPedp6UFgHPQ',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Plant badge
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD49D45),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name and Location
                    const Text(
                      'Alex Rivers',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Badges and Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39AC86).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF39AC86).withOpacity(0.2),
                            ),
                          ),
                          child: const Text(
                            'Master Gardener',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF39AC86),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF5C8A7A),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Portland, OR',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5C8A7A),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Bio
                    const Text(
                      'Sharing the harvest from my urban permaculture garden. Focused on native pollinators.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5C8A7A),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        // Edit Profile Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF39AC86),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF39AC86).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Share Button
                        GestureDetector(
                          onTap: () {
                            _showShareOptions(context);
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF39AC86).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF39AC86).withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Color(0xFF39AC86),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Impact Summary Dashboard
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Shared
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.eco,
                              color: const Color(0xFFD49D45),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '15',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'kg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'SHARED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C8A7A),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '+2kg',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF39AC86),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Helped
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.group,
                              color: const Color(0xFF39AC86),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '4',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'HELPED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C8A7A),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '+1',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF39AC86),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Saved
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.co2,
                              color: const Color(0xFF3B82F6),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '12',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'kg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'SAVED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C8A7A),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '+3kg',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF39AC86),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Active Garden Crops
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Garden Crops',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'View Garden',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF39AC86),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Crop Card 1: Heirloom Tomatoes
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBKA_XUbQOHB2Q_TLrbZZh4Bs-a29SjPZwBq_oR9Iufo0JYqAntErNAah0Yeb2lJExnqCwFRPK9MBEnOMfikdQYf4MwQTzdfINO8ccpZAQrqEGEPBbkeHx6FhxgPumbkMCz5s4Y9V-L5eVVXNFbjKI7A9nh_gVfB9Q8TYGGdcCzkcufBGI6CrK3EFJ3dQn-DUwWgnTjI1zJ_L7VQApnKFm6ym357PVsHw2NgMOwglkQxx3VOkCBzgxWmT1t4ESRvK53-ppEB0WhQvDi',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Heirloom Tomatoes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF39AC86).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '75%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF39AC86),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '12 days to harvest',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5C8A7A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39AC86).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: 0.75,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF39AC86),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Crop Card 2: Curly Kale
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB3MM_tbvVNjKbA_yZq3l5HwS8CH_fBjqZ926YpE5pgCXfyR9BFE215V9ZLhGs7pZO9NYz1Kj3SvtVCVR6lr1QTxH-9YFxQvWFCGv_F_MDyF8S-blD0Nr98EBbAg4bjaOm8IcG7xBg420_GIv_36CqrcO_O2bmt5VO_hOHNmQ_adwIUUia1Zj-lICv12Rt57OcU0JfqU5ptvuXXN7kgBL9v5yf4va0v7fv5KWpbSFUOwYZSvL0JVL9Bh6vj7WIndZOVoS7Q5Z5ki93o',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Curly Kale',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF39AC86).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '40%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF39AC86),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '28 days to harvest',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5C8A7A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39AC86).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: 0.4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF39AC86),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Sharing History
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sharing History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF5C8A7A),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // History Item 1
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCs_zbmBxuNEZX6j3IPjUnWW7V0Hoazk3ZhGpplh-ZbXC45rXFAx8tuMB3rEJl6b3-7s_XEA_LO6aDnc5TuMeRSFyqAsJNrEqi5A7wew75zB1yRl_Ba32ddP1QlS-Lcy_ClSBlXuWUu9Z-PNiTPZBEorFcFXZkq1ZbNXdcLBY1IxCbkM6lnPfWuKBmAKkIZlKY6oezQoc_HGgiRM71QMoZXpKD0Jsk9ImEq4mCfHHlxCBHT13TCXd3lotUu57tEgqVjj7n1mhYdNEhC',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '3 Bunches of Radishes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Shared with Sarah M. • 2 days ago',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF5C8A7A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF39AC86),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    
                    // History Item 2
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDmrl9lptd6f4UGkCMda9EEuNhxPLJ_Dilzez5IhJZOEUEcf9hB6JiQOcwwvwiaEPD7LRPsz304JuYLqiL3H9MF4QzJFQ_Hc7LVieT1mNFANWT4GbxhHaUN6T5CXeHqkdcHCrmt8Ja2sYF8hhqVxuYo2HS1fyECdVlD7FWP0_Avj0Y4yM7fxfu6Y34x6In7vA1tfddzm8DJzc96gBl51WhrjpuWYBFgHxDF0j86-_bUpavA1_nrBw18YWL-fzbmUO415J7zLP1UL_4k',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '1kg Alpine Strawberries',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Community Drop-off • 1 week ago',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF5C8A7A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF39AC86),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Community Footprint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39AC86).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF39AC86).withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF39AC86),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Community Footprint',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Top 5% of gardeners in Portland this month.',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF5C8A7A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF39AC86),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}











// // profile_screen.dart
// import 'package:flutter/material.dart';
// import 'edit_profile_screen.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Top Navigation Bar
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: isDarkMode 
//                       ? const Color(0xFF212C28).withOpacity(0.8)
//                       : const Color(0xFFF9F8F6).withOpacity(0.8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Back button
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back_ios,
//                         size: 16,
//                         color: Color(0xFF39AC86),
//                       ),
//                     ),
//                     // Title
//                     const Text(
//                       'Sustainability Profile',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     // Settings button
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                       ),
//                       child: const Icon(
//                         Icons.settings,
//                         color: Colors.black87,
//                         size: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Profile Header Section
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//                 child: Column(
//                   children: [
//                     // Profile Picture
//                     Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         Container(
//                           width: 128,
//                           height: 128,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(64),
//                             border: Border.all(
//                               color: const Color(0xFF39AC86).withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(64),
//                             child: Image.network(
//                               'https://lh3.googleusercontent.com/aida-public/AB6AXuCFoFY1UF5bL-8ZbOF5mhXmzBcLybFmbiGSFNfj_lW16i0SK5Av-JHLXlZo6Kc9jwSmcbbfF-eAVRrYI1w9X_xHcZ2ngBxtnSmmpMic0LSz0tZZGHq5UesNkgRw-Sxg6HQ7BWvRPWmOzbbLo2Y_MKdeP_9s3TOn30nQXRhCjSt-ysd7Fn0RVjDBtgAKyR-QPL_4zAY_LIBBB_3DLNBs_y-Wdkjootz8dRgvRS31gysqa6_ze1WfYZc0CBMs-VQZAUvKNPedp6UFgHPQ',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         // Plant badge
//                         Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFD49D45),
//                             borderRadius: BorderRadius.circular(18),
//                             border: Border.all(
//                               color: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
//                               width: 4,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.eco,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Name and Location
//                     const Text(
//                       'Alex Rivers',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
                    
//                     const SizedBox(height: 8),
                    
//                     // Badges and Location
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF39AC86).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: const Color(0xFF39AC86).withOpacity(0.2),
//                             ),
//                           ),
//                           child: const Text(
//                             'Master Gardener',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF39AC86),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(
//                           Icons.location_on,
//                           size: 16,
//                           color: Color(0xFF5C8A7A),
//                         ),
//                         const SizedBox(width: 4),
//                         const Text(
//                           'Portland, OR',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF5C8A7A),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Bio
//                     const Text(
//                       'Sharing the harvest from my urban permaculture garden. Focused on native pollinators.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF5C8A7A),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Action Buttons
//                     // Action Buttons
//                     Row(
//                       children: [
//                         // Edit Profile Button
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const EditProfileScreen()),
//                               );
//                             },
//                             child: Container(
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF39AC86),
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: const Color(0xFF39AC86).withOpacity(0.3),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   'Edit Profile',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
                        
//                         const SizedBox(width: 12),
                        
//                         // Share Button
//                         GestureDetector(
//                           onTap: () {
//                             // Handle share action
//                             // You can add share functionality here
//                             _showShareOptions(context);
//                           },
//                           child: Container(
//                             width: 48,
//                             height: 48,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF39AC86).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: const Color(0xFF39AC86).withOpacity(0.2),
//                               ),
//                             ),
//                             child: const Icon(
//                               Icons.share,
//                               color: Color(0xFF39AC86),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
              
//               // Impact Summary Dashboard
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     // Shared
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.eco,
//                               color: const Color(0xFFD49D45),
//                               size: 24,
//                             ),
//                             const SizedBox(height: 8),
//                             RichText(
//                               text: const TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: '15',
//                                     style: TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.w800,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: 'kg',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w400,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             const Text(
//                               'SHARED',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF5C8A7A),
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             const Text(
//                               '+2kg',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF39AC86),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(width: 12),
                    
//                     // Helped
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.group,
//                               color: const Color(0xFF39AC86),
//                               size: 24,
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               '4',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             const Text(
//                               'HELPED',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF5C8A7A),
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             const Text(
//                               '+1',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF39AC86),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(width: 12),
                    
//                     // Saved
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.co2,
//                               color: const Color(0xFF3B82F6),
//                               size: 24,
//                             ),
//                             const SizedBox(height: 8),
//                             RichText(
//                               text: const TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: '12',
//                                     style: TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.w800,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: 'kg',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w400,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             const Text(
//                               'SAVED',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF5C8A7A),
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             const Text(
//                               '+3kg',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF39AC86),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               // Active Garden Crops
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Active Garden Crops',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'View Garden',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF39AC86),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Crop Card 1: Heirloom Tomatoes
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 12),
//                       decoration: BoxDecoration(
//                         color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 64,
//                             height: 64,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               image: const DecorationImage(
//                                 image: NetworkImage(
//                                   'https://lh3.googleusercontent.com/aida-public/AB6AXuBKA_XUbQOHB2Q_TLrbZZh4Bs-a29SjPZwBq_oR9Iufo0JYqAntErNAah0Yeb2lJExnqCwFRPK9MBEnOMfikdQYf4MwQTzdfINO8ccpZAQrqEGEPBbkeHx6FhxgPumbkMCz5s4Y9V-L5eVVXNFbjKI7A9nh_gVfB9Q8TYGGdcCzkcufBGI6CrK3EFJ3dQn-DUwWgnTjI1zJ_L7VQApnKFm6ym357PVsHw2NgMOwglkQxx3VOkCBzgxWmT1t4ESRvK53-ppEB0WhQvDi',
//                                 ),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       'Heirloom Tomatoes',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF39AC86).withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: const Text(
//                                         '75%',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF39AC86),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 const Text(
//                                   '12 days to harvest',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Color(0xFF5C8A7A),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Container(
//                                   height: 6,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF39AC86).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(3),
//                                   ),
//                                   child: FractionallySizedBox(
//                                     widthFactor: 0.75,
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF39AC86),
//                                         borderRadius: BorderRadius.circular(3),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     // Crop Card 2: Curly Kale
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 64,
//                             height: 64,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               image: const DecorationImage(
//                                 image: NetworkImage(
//                                   'https://lh3.googleusercontent.com/aida-public/AB6AXuB3MM_tbvVNjKbA_yZq3l5HwS8CH_fBjqZ926YpE5pgCXfyR9BFE215V9ZLhGs7pZO9NYz1Kj3SvtVCVR6lr1QTxH-9YFxQvWFCGv_F_MDyF8S-blD0Nr98EBbAg4bjaOm8IcG7xBg420_GIv_36CqrcO_O2bmt5VO_hOHNmQ_adwIUUia1Zj-lICv12Rt57OcU0JfqU5ptvuXXN7kgBL9v5yf4va0v7fv5KWpbSFUOwYZSvL0JVL9Bh6vj7WIndZOVoS7Q5Z5ki93o',
//                                 ),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       'Curly Kale',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF39AC86).withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: const Text(
//                                         '40%',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF39AC86),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 const Text(
//                                   '28 days to harvest',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Color(0xFF5C8A7A),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Container(
//                                   height: 6,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF39AC86).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(3),
//                                   ),
//                                   child: FractionallySizedBox(
//                                     widthFactor: 0.4,
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF39AC86),
//                                         borderRadius: BorderRadius.circular(3),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 32),
              
//               // Sharing History
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Sharing History',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'See All',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: const Color(0xFF5C8A7A),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // History Item 1
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E3DF),
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 48,
//                                 height: 48,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   image: const DecorationImage(
//                                     image: NetworkImage(
//                                       'https://lh3.googleusercontent.com/aida-public/AB6AXuCs_zbmBxuNEZX6j3IPjUnWW7V0Hoazk3ZhGpplh-ZbXC45rXFAx8tuMB3rEJl6b3-7s_XEA_LO6aDnc5TuMeRSFyqAsJNrEqi5A7wew75zB1yRl_Ba32ddP1QlS-Lcy_ClSBlXuWUu9Z-PNiTPZBEorFcFXZkq1ZbNXdcLBY1IxCbkM6lnPfWuKBmAKkIZlKY6oezQoc_HGgiRM71QMoZXpKD0Jsk9ImEq4mCfHHlxCBHT13TCXd3lotUu57tEgqVjj7n1mhYdNEhC',
//                                     ),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     '3 Bunches of Radishes',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     'Shared with Sarah M. • 2 days ago',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: const Color(0xFF5C8A7A),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const Icon(
//                             Icons.check_circle,
//                             color: Color(0xFF39AC86),
//                             size: 24,
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     // History Item 2
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 48,
//                                 height: 48,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   image: const DecorationImage(
//                                     image: NetworkImage(
//                                       'https://lh3.googleusercontent.com/aida-public/AB6AXuDmrl9lptd6f4UGkCMda9EEuNhxPLJ_Dilzez5IhJZOEUEcf9hB6JiQOcwwvwiaEPD7LRPsz304JuYLqiL3H9MF4QzJFQ_Hc7LVieT1mNFANWT4GbxhHaUN6T5CXeHqkdcHCrmt8Ja2sYF8hhqVxuYo2HS1fyECdVlD7FWP0_Avj0Y4yM7fxfu6Y34x6In7vA1tfddzm8DJzc96gBl51WhrjpuWYBFgHxDF0j86-_bUpavA1_nrBw18YWL-fzbmUO415J7zLP1UL_4k',
//                                     ),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     '1kg Alpine Strawberries',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     'Community Drop-off • 1 week ago',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: const Color(0xFF5C8A7A),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const Icon(
//                             Icons.check_circle,
//                             color: Color(0xFF39AC86),
//                             size: 24,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               // Community Footprint
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF39AC86).withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFF39AC86).withOpacity(0.1),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF39AC86),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Icon(
//                           Icons.eco,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Community Footprint',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Top 5% of gardeners in Portland this month.',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: const Color(0xFF5C8A7A),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_ios,
//                         color: Color(0xFF39AC86),
//                         size: 16,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 100), // Space for bottom navigation
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
