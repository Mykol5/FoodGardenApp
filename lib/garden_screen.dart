import 'package:flutter/material.dart';
import 'add_new_crop_screen.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF212C28).withOpacity(0.8)
                      : const Color(0xFFF9F8F6).withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? const Color(0xFF3A4A44) : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Garden Icon and Title
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Color(0xFF39AC86),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Garden',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Growth Phase: Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFF39AC86),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification and Add Buttons
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode 
                                  ? const Color(0xFF3A4A44) 
                                  : const Color(0xFFF0F2F1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),

// Then find the + button in the GardenScreen and update its onTap/onPressed:
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
      // Navigate to AddNewCropScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AddNewCropScreen(),
        ),
      );
    },
    icon: const Icon(
      Icons.add,
      color: Colors.white,
      size: 24,
    ),
    padding: EdgeInsets.zero, // Remove default padding
  ),
),
                      ],
                    ),
                  ],
                ),
              ),

              // Welcome Message
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Alex! ☀️',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your plants are thriving.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Active Crops
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF39AC86).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF39AC86).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF39AC86),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '12',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Healthy crops',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Harvest Ready
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE59866).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE59866).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HARVEST',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFFE59866),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '4',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ready now',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Shared This Week
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4299E1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4299E1).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SHARED',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF4299E1),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '2.5',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'kg',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'This week',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Crop List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Current Crops',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: Color(0xFF39AC86),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Crop Cards
              SizedBox(
                height: 320,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Crop Card 1: Lacinato Kale
                    _buildCropCard(
                      context,
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBsfbJsssiPyV7uZP4Kia8LOVX09Gef2fAYOT8vRZ9EFVs1pkCJ5QI1Wp2-D5LZFVVi3ti4gyyDMIWQ76Tj2M8WaN1JNN6CmC9PJna6Ix_Gw4tMbU5tAGvg522i-XXtn8t-AcXpWIEBbD95GQoy_AnEh2BmgJuuX4XT5_Pqe8kC4Q8eueBvKtIC0HWztI94Pa3laRrq304lSG4sbwEwCz6iPCInviBwHOgHVdDo5owRSIHudikm3GiSqqLmszbTva2t1tOrDGwXPn6l',
                      title: 'Lacinato Kale',
                      location: 'Patch A • Last watered 2h ago',
                      progress: 0.85,
                      progressColor: const Color(0xFF39AC86),
                      statusLabel: '85% READY',
                      statusColor: Colors.white,
                      statusBgColor: Colors.white.withOpacity(0.9),
                      buttonText: 'Quick Harvest',
                      buttonIcon: Icons.cut,
                      buttonEnabled: true,
                    ),
                    const SizedBox(width: 16),
                    // Crop Card 2: Bell Peppers
                    _buildCropCard(
                      context,
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBpH_btsaEKrhnNQBG01-GaTBID9y25rZFgiEpTNJKxVWUK0s8T8ocsJDd39IjxndyLdMzjiEH77ijZ7A0UF3m72wzRyM0B8iJytE3uvv3BnJ6WO4xfPWiQ2tdzMfmABQL6jppvz82fNS94pEsC8ovxvDfKl5_fPYZTucZVDeMBMHN-kVn5eIJ9FEk4eOBy6HGvyDTplwOg7Qg6r7KAuD2nt-KXwTM37toTnmvfQdGV5B1MeTcqKH92f0wKLLVO--ZbtyEP2xNN7_Ab',
                      title: 'Bell Peppers',
                      location: 'Greenhouse • Needs sun',
                      progress: 0.42,
                      progressColor: const Color(0xFFE59866),
                      statusLabel: 'FLOWERING',
                      statusColor: Colors.white,
                      statusBgColor: const Color(0xFFE59866).withOpacity(0.9),
                      buttonText: 'Developing',
                      buttonIcon: Icons.timer,
                      buttonEnabled: false,
                    ),
                    const SizedBox(width: 16),
                    // Crop Card 3: Strawberries
                    _buildCropCard(
                      context,
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAso4WCnofkS_kQNCGy33hrW_eQW1ko5Or7WxIbWD7ANVDeR22UDJBG5vUmetPel5mtpJqwOVER_7dZMEZ7Jgt52shnbREK00cdbIHgubnBsr07AoCUVQ5pXu9S0qTQb9fo2O63tWzsk7XgnI3jidMl7lSXsCqOuJjPqySL-04-vz9JgbTcjtGmiePujf7eZlsjSYPE2eI0G4qbJNC1dawYrhBJJnEiGUvk93ySpNsyt1KJzK1wdLIwLXPYiz0VufgF3S3Uk25UqLGu',
                      title: 'Strawberries',
                      location: 'Raised Bed 2 • Sprouting',
                      progress: 0.15,
                      progressColor: const Color(0xFF4299E1),
                      statusLabel: 'SEEDLING',
                      statusColor: Colors.white,
                      statusBgColor: Colors.grey.withOpacity(0.9),
                      buttonText: 'Keep Hydrated',
                      buttonIcon: Icons.water_drop,
                      buttonEnabled: false,
                    ),
                  ],
                ),
              ),

              // Productivity Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Productivity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Charts Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode 
                        ? const Color(0xFF3A4A44) 
                        : const Color(0xFFF0F2F1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL YIELD (KG)',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '15.4',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'kg',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  color: Color(0xFF39AC86),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '+12% vs last week',
                                  style: TextStyle(
                                    color: Color(0xFF39AC86),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39AC86).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'MAY 1 - MAY 7',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF39AC86),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Chart Bars
                    SizedBox(
                      height: 128,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar(0.6, 'M'),
                          _buildChartBar(0.3, 'T'),
                          _buildChartBar(0.45, 'W'),
                          _buildChartBar(0.8, 'T'),
                          _buildChartBar(0.55, 'F'),
                          _buildChartBar(0.9, 'S'),
                          _buildChartBar(0.7, 'S'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      // Secondary FAB for Harvest Log
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE59866),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE59866).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.inventory_2,
          color: Colors.white,
          size: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCropCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String location,
    required double progress,
    required Color progressColor,
    required String statusLabel,
    required Color statusColor,
    required Color statusBgColor,
    required String buttonText,
    required IconData buttonIcon,
    required bool buttonEnabled,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF3A4A44) 
              : const Color(0xFFF0F2F1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          SizedBox(
            height: 128,
            width: double.infinity,
            child: Stack(
              children: [
                // Crop Image
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                // Progress Bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF3A4A44) : const Color(0xFFF0F2F1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: buttonEnabled
                        ? const Color(0xFF39AC86)
                        : (isDarkMode ? const Color(0xFF3A4A44) : const Color(0xFFF0F2F1)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: buttonEnabled
                        ? [
                            BoxShadow(
                              color: const Color(0xFF39AC86).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        buttonIcon,
                        size: 16,
                        color: buttonEnabled ? Colors.white : const Color(0xFF999999),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: buttonEnabled ? Colors.white : const Color(0xFF999999),
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
    );
  }

  Widget _buildChartBar(double height, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: height * 80, // Scale height
          decoration: BoxDecoration(
            color: const Color(0xFF39AC86).withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF39AC86),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF999999),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
