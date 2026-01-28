import 'package:flutter/material.dart';

class UpdateCropStatusScreen extends StatefulWidget {
  final String cropName;
  final String cropImage;
  final String currentStatus;
  
  const UpdateCropStatusScreen({
    Key? key,
    required this.cropName,
    required this.cropImage,
    required this.currentStatus,
  }) : super(key: key);

  @override
  State<UpdateCropStatusScreen> createState() => _UpdateCropStatusScreenState();
}

class _UpdateCropStatusScreenState extends State<UpdateCropStatusScreen> {
  int _selectedStageIndex = 1; // Default to "Veg" stage
  final TextEditingController _notesController = TextEditingController();
  
  final List<String> _growthStages = [
    'Seedling',
    'Veg',
    'Flower',
    'Fruit',
    'Harvest',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF11211C) : Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Color(0xFF11211C).withOpacity(0.8)
                    : Color(0xFFF6F8F7).withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Color(0xFF1A2B26) : Color(0xFFE5E7EB),
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
                      color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                      size: 24,
                    ),
                  ),
                  
                  // Title
                  Expanded(
                    child: Center(
                      child: Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                        ),
                      ),
                    ),
                  ),
                  
                  // Save Button
                  TextButton(
                    onPressed: () {
                      // TODO: Save status update
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFF19E6A2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Plant Summary
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Color(0xFF2A3A35) : Color(0xFFF0F2F1),
                  ),
                ),
                child: Row(
                  children: [
                    // Crop Image
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.cropImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    
                    // Crop Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cropName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Backyard Plot A • Row 3',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF19E6A2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Growth Stage Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Growth Stage',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Growth Stage Segments
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black.withOpacity(0.3) : Color(0xFFF0F2F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: List.generate(_growthStages.length, (index) {
                        final isSelected = _selectedStageIndex == index;
                        
                        return Expanded(
                          child: Material(
                            color: isSelected
                                ? (isDarkMode ? Colors.grey[800] : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedStageIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    _growthStages[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Color(0xFF19E6A2)
                                          : (isDarkMode ? Color(0xFFA0B8AF) : Color(0xFF666666)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Current Stage Chip
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF19E6A2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFF19E6A2).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Current Stage: ${_growthStages[_selectedStageIndex]}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF19E6A2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Growth Notes Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Growth Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? Color(0xFF2A3A35) : Color(0xFFF0F2F1),
                      ),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'How does the plant look today? Mention watering, pests, or new leaves...',
                        hintStyle: TextStyle(color: Color(0xFF4E977F)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Photo Upload Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visual Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: [
                      // Add Photo Button
                      Material(
                        color: Color(0xFF19E6A2).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            // TODO: Add photo functionality
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF19E6A2).withOpacity(0.3),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  color: Color(0xFF19E6A2),
                                  size: 36,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    color: Color(0xFF19E6A2),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Previous Photo
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDd-Ifl1Kkx8axliY3mdlQu52Q3_YY0r5YFEyLt1MNEWuo62NnpMZ9EI_zEo607H-TJpYsRgnm2UaYJ61TD8asmYllhY2gNUN6gzYT2dDvqBhofAkC-yKcMi7v_o4GfiLZBD8cGHYnI2u4P_D0Sepj54xq1YaM-d4KpNaD8Ppyvi-WnEWVN4fkQSB8hDtH7grJN-SeiwWo-Ams11v45J39MFBb0uvYk155x5WNa2zvUkiQ3pcPLQmaClWLXLfrpl3jlt9mfcPLK-S4O'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Date Badge
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Yesterday',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Delete Button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
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

            Spacer(),
            
            // Confirm Button
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF19E6A2).withOpacity(0.2),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Color(0xFF19E6A2),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      // TODO: Confirm status update
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
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Confirm Status Update',
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
          ],
        ),
      ),
    );
  }
}
