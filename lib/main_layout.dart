// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'garden_screen.dart';
import 'share_screen.dart';
import 'guides_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  // Define your screens here
  final List<Widget> _screens = [
    const HomeScreen(),      // Index 0
    const GardenScreen(),    // Index 1
    const ShareScreen(),     // Index 2
    const GuidesScreen(),    // Index 3
    const ProfileScreen(),   // Index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // Current Screen
      body: _screens[_selectedIndex],
      
      // Floating Action Button (only on Home and Share screens)
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 2)
          ? FloatingActionButton(
              onPressed: () {
                // Handle FAB tap based on current screen
                if (_selectedIndex == 0) {
                  // Home screen - add new produce
                } else if (_selectedIndex == 2) {
                  // Share screen - share something
                }
              },
              backgroundColor: const Color(0xFF39AC86),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF212C28).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: isDarkMode ? const Color(0xFF3A4A44) : const Color(0xFFE5E7EB),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.home,
              label: 'Home',
              index: 0,
            ),
            _buildBottomNavItem(
              icon: Icons.eco,
              label: 'Garden',
              index: 1,
            ),
            _buildBottomNavItem(
              icon: Icons.handshake,
              label: 'Share',
              index: 2,
            ),
            _buildBottomNavItem(
              icon: Icons.menu_book,
              label: 'Guides',
              index: 3,
            ),
            _buildBottomNavItem(
              icon: Icons.person,
              label: 'Profile',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected 
                ? const Color(0xFF39AC86)
                : (isDarkMode ? const Color(0xFF5C8A7A) : const Color(0xFF5C8A7A)),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: isSelected 
                  ? const Color(0xFF39AC86)
                  : (isDarkMode ? const Color(0xFF5C8A7A) : const Color(0xFF5C8A7A)),
            ),
          ),
        ],
      ),
    );
  }
}
