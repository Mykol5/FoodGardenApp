import 'package:flutter/material.dart';

class AddNewCropScreen extends StatefulWidget {
  const AddNewCropScreen({Key? key}) : super(key: key);

  @override
  State<AddNewCropScreen> createState() => _AddNewCropScreenState();
}

class _AddNewCropScreenState extends State<AddNewCropScreen> {
  int _selectedCategoryIndex = 0;
  bool _isOutdoor = true;
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Vegetable',
      'icon': Icons.eco,
      'color': Color(0xFF39AC86),
    },
    {
      'name': 'Fruit',
      'icon': Icons.restaurant,
      'color': Color(0xFF5C8A7A),
    },
    {
      'name': 'Herb',
      'icon': Icons.spa,
      'color': Color(0xFF5C8A7A),
    },
    {
      'name': 'Flower',
      'icon': Icons.local_florist,
      'color': Color(0xFF5C8A7A),
    },
  ];

  @override
  void dispose() {
    _varietyController.dispose();
    _notesController.dispose();
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
                        'Add New Crop',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Color(0xFF101816),
                        ),
                      ),
                    ),
                  ),
                  
                  // Save Button
                  TextButton(
                    onPressed: () {
                      // TODO: Implement save functionality
                      Navigator.pop(context);
                    },
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
                padding: EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Environment Toggle
                    _buildEnvironmentToggle(isDarkMode),
                    
                    // Category Section
                    _buildCategorySection(isDarkMode),
                    
                    // Crop Variety Input
                    _buildVarietyInput(isDarkMode),
                    
                    // Timeline Section
                    _buildTimelineSection(isDarkMode),
                    
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
              onTap: () {
                // TODO: Implement add to garden functionality
                Navigator.pop(context);
              },
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
                      'Add to My Garden',
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

  Widget _buildEnvironmentToggle(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(4),
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
              child: Material(
                color: _isOutdoor ? Color(0xFF39AC86) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => setState(() => _isOutdoor = true),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Outdoor Garden',
                        style: TextStyle(
                          color: _isOutdoor ? Colors.white : Color(0xFF5C8A7A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: Material(
                color: !_isOutdoor ? Color(0xFF39AC86) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => setState(() => _isOutdoor = false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Indoor Planter',
                        style: TextStyle(
                          color: !_isOutdoor ? Colors.white : Color(0xFF5C8A7A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          SizedBox(height: 4),
          Text(
            'What are you planting today?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5C8A7A),
            ),
          ),
          SizedBox(height: 16),
          
          // Category Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
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
                    padding: EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF39AC86)
                                : (isDarkMode ? Color(0xFF3A4A44) : Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category['icon'],
                            color: isSelected ? Colors.white : category['color'],
                            size: 24,
                          ),
                        ),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 16,
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
            'Crop Variety',
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
                        hintText: 'e.g. Cherry Belle Radish',
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
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.edit,
                    color: Color(0xFF39AC86).withOpacity(0.4),
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
            subtitle: 'May 12, 2024',
            showAutoBadge: false,
          ),
          
          SizedBox(height: 12),
          
          // Expected Harvest Card
          _buildTimelineCard(
            isDarkMode,
            icon: Icons.thermostat_auto,
            iconColor: Color(0xFFE59866),
            title: 'Expected Harvest',
            subtitle: 'Estimated July 15',
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
    required String subtitle,
    required bool showAutoBadge,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2D3A35) : Colors.white,
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
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Color(0xFF101816),
                        fontStyle: showAutoBadge ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (showAutoBadge) ...[
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
    );
  }

  Widget _buildNotesSection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes & Soil Type',
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
                hintText: 'Adding extra compost, high drainage...',
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
