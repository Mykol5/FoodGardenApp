import 'package:flutter/material.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _itemNameController = TextEditingController();
  final _pickupInstructionsController = TextEditingController();
  int _quantity = 3;
  String _selectedCategory = 'Vegetables';
  
  final List<String> categories = ['Vegetables', 'Fruits', 'Herbs', 'Seeds'];

  @override
  void dispose() {
    _itemNameController.dispose();
    _pickupInstructionsController.dispose();
    super.dispose();
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? const Color(0xFF212C28).withOpacity(0.8)
                          : const Color(0xFFF9F8F6).withOpacity(0.8),
                    ),
                    child: Row(
                      children: [
                        // Close Button
                        Container(
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
                  ),

                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Hero Photo Uploader
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39AC86).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF39AC86).withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF39AC86).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Icon(
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
                                'Add up to 3 photos of your produce to attract neighbors',
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

                        const SizedBox(height: 24),

                        // Produce Details Card
                        Container(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Item Name',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 56,
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
                                      controller: _itemNameController,
                                      decoration: InputDecoration(
                                        hintText: 'e.g. Heirloom Roma Tomatoes',
                                        hintStyle: TextStyle(
                                          color: const Color(0xFF5C8A7A).withOpacity(0.6),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                                            label: Text(
                                              category,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected 
                                                    ? Colors.white 
                                                    : (isDarkMode ? Colors.white : const Color(0xFF101816)),
                                              ),
                                            ),
                                            selected: isSelected,
                                            selectedColor: const Color(0xFF39AC86),
                                            backgroundColor: isDarkMode 
                                                ? const Color(0xFF212C28) 
                                                : const Color(0xFFEAF1EE),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
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
                        ),

                        const SizedBox(height: 16),

                        // Quantity & Logistics Card
                        Container(
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
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
                                          color: const Color(0xFF5C8A7A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDarkMode 
                                          ? const Color(0xFF212C28) 
                                          : const Color(0xFFF9F8F6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
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
                                        // Quantity Display
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                '$_quantity',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'lbs',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: const Color(0xFF5C8A7A),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
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
                        ),

                        const SizedBox(height: 16),

                        // Sustainability Tip
                        Container(
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
                        ),

                        const SizedBox(height: 100), // Space for sticky button
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom CTA
            Positioned(
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Handle post to marketplace
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
            ),
          ],
        ),
      ),
    );
  }
}
