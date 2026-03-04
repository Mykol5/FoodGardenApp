import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_details_screen.dart';
import 'messages_screen.dart';
import 'add_new_crop.dart';
import 'profile_screen.dart';
import 'providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final List<String> categories = ['All', 'Vegetables', 'Fruits', 'Herbs', 'Flowers'];
  bool _isLoading = false;
  
  // Drawer state
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF39AC86),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading your garden...',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
      // Side Drawer Menu
      drawer: Drawer(
        child: Container(
          color: isDarkMode ? const Color(0xFF1A2A25) : Colors.white,
          child: Column(
            children: [
              // Drawer Header with Profile Info
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF39AC86).withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFE5E7E6),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Profile Image in Drawer
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF39AC86),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: _buildDrawerProfileImage(currentUser),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User Info in Drawer
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?['name'] ?? 'Gardener',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF101816),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?['email'] ?? 'email@example.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF5C8A7A),
                            ),
                          ),
                          if (currentUser?['location'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: const Color(0xFF5C8A7A),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currentUser!['location']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF5C8A7A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Drawer Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.person_outline,
                      label: 'My Profile',
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.eco_outlined,
                      label: 'My Garden',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to garden screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Garden screen coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.message_outlined,
                      label: 'Messages',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MessagesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notifications coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings coming soon!'),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      thickness: 1,
                      height: 32,
                    ),
                    // Logout Button at Bottom
                    _buildDrawerItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _handleLogout(context);
                      },
                    ),
                  ],
                ),
              ),
              
              // App Version at Bottom
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF5C8A7A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? const Color(0xFF212C28).withOpacity(0.8)
                    : const Color(0xFFF9F8F6).withOpacity(0.8),
              ),
              child: Column(
                children: [
                  // User Profile and Notifications
                  Row(
                    children: [
                      // User Profile with Menu Drawer
                      GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF39AC86),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildProfileImage(currentUser),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode 
                                    ? const Color(0xFF39AC86).withOpacity(0.7)
                                    : const Color(0xFF5C8A7A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currentUser?['name']?.split(' ')[0] ?? 'Gardener'}! 🌿',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF101816),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Message Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MessagesScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.message_outlined,
                            color: const Color(0xFF39AC86),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Notification Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Notifications coming soon!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.black87,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Add Button
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF39AC86),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF39AC86).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddNewCropScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search Bar (rest of your code remains the same)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF3A4A44) : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search,
                          color: const Color(0xFF5C8A7A),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for produce, tools, or gardeners...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF5C8A7A),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              // Add search functionality here
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Filter options coming soon!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.tune,
                            color: const Color(0xFF39AC86),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Rest of your existing code (categories, welcome message, feed cards, etc.)
            // Category Chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(
                      right: index < categories.length - 1 ? 12 : 0,
                    ),
                    child: ChoiceChip(
                      label: Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w500,
                          color: index == 0 
                              ? Colors.white 
                              : (isDarkMode ? Colors.white : const Color(0xFF101816)),
                        ),
                      ),
                      selected: index == 0,
                      selectedColor: const Color(0xFF39AC86),
                      backgroundColor: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(
                          color: isDarkMode ? const Color(0xFF3A4A44) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          // Handle category selection
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Welcome Message for Returning User
            if (currentUser != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39AC86).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF39AC86).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.eco,
                        color: const Color(0xFF39AC86),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${currentUser['name']?.split(' ')[0] ?? 'Gardener'}!',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101816),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ready to share your harvest today?',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF5C8A7A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nearby Surplus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Map view coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.map_outlined,
                      color: Color(0xFF39AC86),
                      size: 18,
                    ),
                    label: const Text(
                      'See Map',
                      style: TextStyle(
                        color: Color(0xFF39AC86),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Feed Cards (rest of your existing code)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Card 1: Organic Heirloom Tomatoes
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              productData: {
                                'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDOiXZFHYurF9-Xuc-INxDFOto73Z5B90gDx-G89PNjw_qk87629cLWY0KazgEHeodB1OZAgXUSc-Pr3-13CpoS6t3eW0JfadUNHLz-D_wKxTEDZIronVL364IoXYMri_jxEbrEgZvwvd9_mKb_BXUV4dFTRiNJlc99E27u5e9F00npK0xWVCsNnab03Besay18_IwnHQ_cjrzPB6tlVNA6SNFs2Bj3A_5cQN2TZOQjfnvYUh8WOHfF7UIxv1RdnJYpEf-Yntr9Jhc7',
                                'title': 'Organic Heirloom Tomatoes',
                                'user': 'Sarah M.',
                                'distance': '0.2 MI AWAY',
                                'quantity': '2 lbs',
                                'quantityLabel': 'left',
                                'isVerified': true,
                                'statusLabel': 'NEW',
                                'description': 'Freshly picked heirloom tomatoes from organic garden',
                              },
                            ),
                          ),
                        );
                      },
                      child: _buildProduceCard(
                        context,
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDOiXZFHYurF9-Xuc-INxDFOto73Z5B90gDx-G89PNjw_qk87629cLWY0KazgEHeodB1OZAgXUSc-Pr3-13CpoS6t3eW0JfadUNHLz-D_wKxTEDZIronVL364IoXYMri_jxEbrEgZvwvd9_mKb_BXUV4dFTRiNJlc99E27u5e9F00npK0xWVCsNnab03Besay18_IwnHQ_cjrzPB6tlVNA6SNFs2Bj3A_5cQN2TZOQjfnvYUh8WOHfF7UIxv1RdnJYpEf-Yntr9Jhc7',
                        title: 'Organic Heirloom Tomatoes',
                        user: 'Sarah M.',
                        distance: '0.2 MI AWAY',
                        quantity: '2 lbs',
                        quantityLabel: 'left',
                        isVerified: true,
                        statusLabel: 'NEW',
                        statusColor: const Color(0xFFF4D35E),
                        avatars: [
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAADrkZeZw_qq1hsyL3MPYtxpsGUZKvUMW_o8Gsvu_7bMYrJgtwvMco_aPIkA-vz5hbtpcHyDkeqblh7ZpCYAoXmwgdy7enjOT2GGWOu4TD8mGGOZ33BiJm5t4z6NIurU0LJa_lO7EB8t6CBwO6AzB2s5XYYDKXwmuuhC1_yctiItPiRQ-__2HC3Ref4cP0jBZfUQsORsuLz3Sl1Fk_xm3bhVeb5fUhbVvvqGbAhE57nRzPYcdTVyWllf4CDK33ZctTtaINNA1E1T0o',
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuADjEd7DUMa1NC1zaZ-iY-BypgjEORCZgO-8YWtRQoQnD5cXB62IbhBft-fCimd7o1U0EeqzWgSLrcchDwUyG8A58m3VRziVSUuXQb04cWz1P6jE0sRlyUhTKzizHXtyZ6yiA2m5vm0cWXuTZV6Orx60YJy685MPB4nSAETmcTYPRM_AKIXaDsVzNjyXvJq6hItW5TppQG8LJh-RMm8D9n16KVcQhxpajX9_roJPCVtDnp4D2qQWs-IXDvn8abOUzRYe-kbBKX364Uk',
                        ],
                        extraCount: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card 2: Fresh Basil Bunches
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              productData: {
                                'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAkRVazco1KNCaQ_AXjXdZ3UMfC-WrdvXhF4xlgL_D6NroO10uruS0Q-cyoPqUyCWIlcrSJmdBIHOQJnN5vICnuN__qY2hqnLhf_C6cprXKjlwpKZzKhvplJ7V1L9fL5jZJDxE-xJJaDlb5BYuRIOa5FFtus25yyP_4g4f2Q9Uy-yVcn0r8qK1Br0Ihp80egN39DNbBgrzAjDCv80476ulzQ-3xa88P3r8lGfbnUnOANvTCMTMYdScnOtgcfoaaWZR4GmPUpcKbatLP',
                                'title': 'Fresh Basil Bunches',
                                'user': 'David K.',
                                'distance': '0.8 MI AWAY',
                                'quantity': '5',
                                'quantityLabel': 'avail',
                                'isVerified': false,
                                'description': 'Harvested this morning!',
                              },
                            ),
                          ),
                        );
                      },
                      child: _buildProduceCard(
                        context,
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAkRVazco1KNCaQ_AXjXdZ3UMfC-WrdvXhF4xlgL_D6NroO10uruS0Q-cyoPqUyCWIlcrSJmdBIHOQJnN5vICnuN__qY2hqnLhf_C6cprXKjlwpKZzKhvplJ7V1L9fL5jZJDxE-xJJaDlb5BYuRIOa5FFtus25yyP_4g4f2Q9Uy-yVcn0r8qK1Br0Ihp80egN39DNbBgrzAjDCv80476ulzQ-3xa88P3r8lGfbnUnOANvTCMTMYdScnOtgcfoaaWZR4GmPUpcKbatLP',
                        title: 'Fresh Basil Bunches',
                        user: 'David K.',
                        distance: '0.8 MI AWAY',
                        quantity: '5',
                        quantityLabel: 'avail',
                        isVerified: false,
                        description: '"Harvested this morning!"',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card 3: Excess Meyer Lemons
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              productData: {
                                'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCeSKjZdRXTWnEE6ZdQWRTYZXs3RtAJoYpDg-hTc3zgKNM4mnFj0F7Wk8M5_z6BVhCyRGi6Qr-FW-WoD2uLx9RgB-m9NBGw-A97MHEV4mpqtVhgFQ1O95mzuYWacuWgBOb_MiTgjWU8rWKvu-pvXxhpcY1Ph0h8Ja2fmBhGzVdKKUwcbsqtaVWZPAzp4_Pc-klJrCOV6Oi6Km-RGl31P9GV41KPtXg_Gi6L-q4klGxak8bmKAqqe5Ss0szwkxguGCjLpaoXiGSlvvD_',
                                'title': 'Excess Meyer Lemons',
                                'user': 'Elena G.',
                                'distance': '1.5 MI AWAY',
                                'quantity': 'Full',
                                'quantityLabel': 'basket',
                                'isVerified': true,
                                'statusLabel': 'ENDING SOON',
                                'description': 'Fresh Meyer lemons from backyard tree',
                              },
                            ),
                          ),
                        );
                      },
                      child: _buildProduceCard(
                        context,
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCeSKjZdRXTWnEE6ZdQWRTYZXs3RtAJoYpDg-hTc3zgKNM4mnFj0F7Wk8M5_z6BVhCyRGi6Qr-FW-WoD2uLx9RgB-m9NBGw-A97MHEV4mpqtVhgFQ1O95mzuYWacuWgBOb_MiTgjWU8rWKvu-pvXxhpcY1Ph0h8Ja2fmBhGzVdKKUwcbsqtaVWZPAzp4_Pc-klJrCOV6Oi6Km-RGl31P9GV41KPtXg_Gi6L-q4klGxak8bmKAqqe5Ss0szwkxguGCjLpaoXiGSlvvD_',
                        title: 'Excess Meyer Lemons',
                        user: 'Elena G.',
                        distance: '1.5 MI AWAY',
                        quantity: 'Full',
                        quantityLabel: 'basket',
                        isVerified: true,
                        statusLabel: 'ENDING SOON',
                        statusColor: const Color(0xFFE59866),
                        hasTimeInfo: true,
                        timeText: 'Pick up before 6 PM',
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddNewCropScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF39AC86),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper method to build drawer profile image
  Widget _buildDrawerProfileImage(Map<String, dynamic>? user) {
    final imageUrl = user?['profile_image_url'];
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF39AC86).withOpacity(0.1),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 30,
                color: Color(0xFF39AC86),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        color: const Color(0xFF39AC86).withOpacity(0.1),
        child: const Center(
          child: Icon(
            Icons.person,
            size: 30,
            color: Color(0xFF39AC86),
          ),
        ),
      );
    }
  }

  // Helper method to build profile image in header
  Widget _buildProfileImage(Map<String, dynamic>? user) {
    final imageUrl = user?['profile_image_url'];
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF39AC86).withOpacity(0.1),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 20,
                color: Color(0xFF39AC86),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        color: const Color(0xFF39AC86).withOpacity(0.1),
        child: const Center(
          child: Icon(
            Icons.person,
            size: 20,
            color: Color(0xFF39AC86),
          ),
        ),
      );
    }
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF5C8A7A),
    Color textColor = const Color(0xFF101816),
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor == const Color(0xFF5C8A7A) 
            ? (isDarkMode ? Colors.white70 : iconColor)
            : iconColor,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: textColor == const Color(0xFF101816)
              ? (isDarkMode ? Colors.white : textColor)
              : textColor,
        ),
      ),
      onTap: onTap,
    );
  }

  // Rest of your helper methods (_buildProduceCard, etc.) remain the same
  Widget _buildProduceCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String user,
    required String distance,
    required String quantity,
    required String quantityLabel,
    bool isVerified = false,
    String? statusLabel,
    Color? statusColor,
    List<String>? avatars,
    int? extraCount,
    String? description,
    bool hasTimeInfo = false,
    String? timeText,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF3A4A44).withOpacity(0.5)
              : const Color(0xFFE5E7EB).withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              // Distance Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? const Color(0xFF212C28).withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    distance,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF39AC86),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Status Badge
              if (statusLabel != null && statusColor != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor == const Color(0xFFE59866) 
                            ? Colors.white 
                            : const Color(0xFF101816),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (isVerified)
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFFE59866),
                                  size: 14,
                                ),
                              if (isVerified) const SizedBox(width: 4),
                              Text(
                                'Posted by $user',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF5C8A7A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          quantity,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF39AC86),
                          ),
                        ),
                        Text(
                          quantityLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF5C8A7A),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Divider(
                  color: isDarkMode ? const Color(0xFF3A4A44) : const Color(0xFFF0F2F1),
                  height: 1,
                ),
                
                const SizedBox(height: 16),
                
                // Bottom Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side
                    if (avatars != null && avatars.isNotEmpty)
                      Row(
                        children: [
                          ...avatars.take(2).map((avatar) {
                            return Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: -8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(avatar),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }),
                          if (extraCount != null && extraCount > 0)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                                  width: 2,
                                ),
                                color: const Color(0xFF39AC86).withOpacity(0.2),
                              ),
                              child: Center(
                                child: Text(
                                  '+$extraCount',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF39AC86),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    else if (description != null)
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF5C8A7A),
                        ),
                      )
                    else if (hasTimeInfo && timeText != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: Color(0xFF5C8A7A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5C8A7A),
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(),
                    
                    // Request Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF39AC86).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
