import 'package:flutter/material.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  int _selectedSegment = 0; // 0 = Gardening Tips, 1 = Local Events
  final _searchController = TextEditingController();

  final List<String> filterChips = ['All', 'Soil Health', 'Pest Control', 'Seasonal'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              // Top Navigation Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF212C28).withOpacity(0.8)
                      : const Color(0xFFF9F8F6).withOpacity(0.8),
                ),
                child: Column(
                  children: [
                    // Menu, Title, Search
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Menu Button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.white.withOpacity(0.1) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
                            ),
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
                        // Title
                        const Text(
                          'Resources & Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Search Button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.white.withOpacity(0.1) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
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
                            Icons.search,
                            color: isDarkMode ? Colors.white : const Color(0xFF101816),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Segmented Control
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Gardening Tips Button
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
                                      ? (isDarkMode 
                                          ? const Color(0xFF39AC86) 
                                          : Colors.white)
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
                                    'Gardening Tips',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedSegment == 0
                                          ? (isDarkMode 
                                              ? Colors.white 
                                              : const Color(0xFF39AC86))
                                          : const Color(0xFF39AC86).withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Local Events Button
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
                                      ? (isDarkMode 
                                          ? const Color(0xFF39AC86) 
                                          : Colors.white)
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
                                    'Local Events',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedSegment == 1
                                          ? (isDarkMode 
                                              ? Colors.white 
                                              : const Color(0xFF39AC86))
                                          : const Color(0xFF39AC86).withOpacity(0.6),
                                    ),
                                  ),
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

              // Filter Chips
              SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filterChips.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        right: index < filterChips.length - 1 ? 12 : 0,
                      ),
                      child: ChoiceChip(
                        label: index == 0
                            ? Text(
                                filterChips[index],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (index == 1)
                                    const Icon(
                                      Icons.filter_list,
                                      size: 16,
                                      color: Color(0xFF101816),
                                    ),
                                  if (index == 1) const SizedBox(width: 4),
                                  Text(
                                    filterChips[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                    ),
                                  ),
                                ],
                              ),
                        selected: index == 0,
                        selectedColor: const Color(0xFF39AC86),
                        backgroundColor: isDarkMode 
                            ? Colors.white.withOpacity(0.1) 
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            // Handle filter selection
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Featured Guide
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Image
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAXAX1I46k61AOCovIp_hrDsmbE5d-N0tuyQjhRiWKyR2fJuAyA44qyWZlOnUhoMSmg60iHxyQ7ErcAhymhbMOTaj6r-erSM1rjLE1D86huPlZDqoIIdEVo2dOxKqDrJ5wD3ToP3p26XH7uG1UeuZR2iEueUBlqLnnqTGg9tFeV2dMEmsoqHqq0S7m1xTec74pf3G0Ovkq6E3FO0WnXHtyP8pS39sOk6FJO3JV7iifGTuJjtLyQ-9_gOvIhp-Ut9yhKEQYHTz-DI45r',
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Sunshine Tips Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4D35E),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'SUNSHINE TIPS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF101816),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Featured Article
                                Text(
                                  'Featured Article',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode 
                                        ? const Color(0xFF39AC86).withOpacity(0.7)
                                        : const Color(0xFF5C8A7A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Title
                            const Text(
                              'Maximizing Your Small-Space Harvest',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Description
                            Text(
                              'Learn how to grow more in less space with these simple vertical gardening and succession planting techniques.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode 
                                    ? Colors.white70 
                                    : const Color(0xFF5C8A7A),
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 20),
                            // Bottom Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Reading Time & Level
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Color(0xFF39AC86),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '8 min read • Beginner',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode 
                                            ? Colors.white70 
                                            : const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                                // Read More Button
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39AC86),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF39AC86).withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Read More',
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
                ),
              ),

              // Recent Guides Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Guides',
                      style: TextStyle(
                        fontSize: 20,
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

              // Horizontal Scroll Cards
              SizedBox(
                height: 240,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Tip Card 1: Composting
                    _buildGuideCard(
                      context,
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDHSud5v1649-tFffgWe3o9sGh2ooGmjaCuvpyQ66Bh3XNVTtewuBpxmq5PkspPCXKynLksjtf2YY9pTS3FfJ-QM4GeTf4sH1IJRKh3vc-ydYVaOS6pcte8NlSZauRyvze5omzlk3ZmqroJEvu7JTClokpP196hBIhl0rZZFuLqBtqBLiq6NnpNw0K92AvlrXgH7m0VLqtr_TYBKPMDbd8YLV7DE5BsyHiRRKf6zzuBqjudpW-aXetMsTRVH8k__MYdrn4m6NWeSROL',
                      category: 'Soil Health',
                      title: 'The Magic of Composting at Home',
                      readTime: '5 min read',
                      level: 'Expert',
                    ),
                    const SizedBox(width: 16),
                    // Tip Card 2: Pest Control
                    _buildGuideCard(
                      context,
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDl25sdQRzZrEePymEPFDlCnilCsLjZwg5w6HgwJ0HLx09D4vYzKHaR0ytf89rnYE1t25fX0susCqzwR4QhNLVSccS8V6VVMFA6APnltCwBLXkiUnjI92MkhQC3pe_xoktnx8Lb7aHxvQWLyc6z7ddpgdDWpsuyyiXA0yco2ty9gcOmH2eq-TdufRfXppklwl8ezcwDDeIvS1Z-HFn0omstPXklgTTODySF_iEFB_LkejWBCSn6J3NpBPExtFvaRnUA4VQ85pXrJzuB',
                      category: 'Pest Control',
                      title: 'Natural Predators in the Garden',
                      readTime: '12 min read',
                      level: 'Intermediate',
                    ),
                  ],
                ),
              ),

              // Local Events Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Happening Soon',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.event_available,
                          color: const Color(0xFF39AC86),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Event Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.05) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Date Badge
                          Container(
                            width: 80,
                            height: 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE59866).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'OCT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE59866),
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '14',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE59866),
                                    height: 0.9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Event Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Heirloom Tomato Seed Saving Workshop',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Location
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Color(0xFF666666),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Central Community Garden',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode 
                                            ? Colors.white70 
                                            : const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Bottom Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '12 Neighbors attending',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: const Color(0xFF39AC86),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE59866),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE59866).withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'RSVP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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
                    ),
                    const SizedBox(height: 16),
                    // Map Snippet
                    Container(
                      height: 128,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuC5DTPBo_NjgERRHu1BcCoix-A6xKsjWrn_eaMGY7QS6E0wqdVd-JdQT3pNZP6Q4ezop2q_VBPUMwibcSAtnOWloO2Bj25OhWw7AAth3DAgp0YFJyFdaBM-Z30mpHb_BXYOw22B2LBdgJEY5kwmbGedeYcfaXS1PVQV8PDy9OgwbIhFea6xQZjiOfziD6gZ_K3qwIPgmDfiS2jUyYReQaLR55NivpfuCIBdJ5FJbYQH9pY5-fttpAq9fwwBEfEeCFDWGuC9zalKWzXA',
                          ),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Event Indicator
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39AC86),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '3 events near you this week',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      // Floating Action Button
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF39AC86),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF39AC86).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required String imageUrl,
    required String category,
    required String title,
    required String readTime,
    required String level,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.white.withOpacity(0.05) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
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
          // Image
          Container(
            height: 144,
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
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF39AC86),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Read time and level
                Row(
                  children: [
                    Text(
                      readTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
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
