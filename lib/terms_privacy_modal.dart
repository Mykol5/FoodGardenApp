import 'package:flutter/material.dart';

class TermsPrivacyModal extends StatefulWidget {
  final VoidCallback onAccept;
  
  const TermsPrivacyModal({
    Key? key,
    required this.onAccept,
  }) : super(key: key);

  @override
  State<TermsPrivacyModal> createState() => _TermsPrivacyModalState();
}

class _TermsPrivacyModalState extends State<TermsPrivacyModal> {
  int _selectedTab = 0; // 0 = Terms, 1 = Privacy
  bool _hasReadTerms = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen for scroll to enable accept button
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Enable checkbox when user has scrolled to bottom
      if (currentScroll >= maxScroll - 100) {
        if (!_hasReadTerms) {
          setState(() {
            _hasReadTerms = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                color: isDarkMode ? Color(0xFF11211C) : Color(0xFFF6F8F7),
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Color(0xFF2A3D37) : Color(0xFFD0E7DF),
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
                        'Terms & Privacy Policy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                        ),
                      ),
                    ),
                  ),
                  
                  // Info Icon
                  IconButton(
                    onPressed: () {
                      // TODO: Show help/info
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Color(0xFF2A3D37) : Color(0xFFD0E7DF),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Terms of Use Tab
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 0 
                                  ? Color(0xFF19E6A2) 
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Terms of Use',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 0
                                  ? (isDarkMode ? Colors.white : Color(0xFF0E1B17))
                                  : Color(0xFF4E977F),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Privacy Policy Tab
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 1 
                                  ? Color(0xFF19E6A2) 
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 1
                                  ? (isDarkMode ? Colors.white : Color(0xFF0E1B17))
                                  : Color(0xFF4E977F),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTab == 0) ...[
                      // Terms of Use Content
                      _buildSection(
                        '1. Community Guidelines',
                        'Our food sharing platform is built on trust and sustainability. By using this app, you agree to share only safe, edible food items and maintain respectful interactions with other gardeners and community members.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '',
                        'Users are responsible for ensuring that any surplus produce shared is fresh, non-toxic, and handled with basic hygiene standards. We encourage transparency regarding growing methods (e.g., organic, use of fertilizers).',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '2. Data & Privacy',
                        'We value your privacy. The app collects location data specifically to facilitate local garden tracking and proximity-based food sharing. We do not sell your personal information to third parties.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '',
                        'Your garden\'s precise location is only visible to users within your approved sharing circle. General neighborhood locations are used for discovery purposes to minimize food waste and maximize local impact.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '3. Sustainability Mission',
                        'By joining our network, you are part of a movement to reduce food waste and strengthen community resilience. We reserve the right to remove listings or users that violate our core mission of sustainable and safe community sharing.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '4. Liability',
                        'While we strive to provide a safe platform, the app is not liable for the quality of food shared or any interactions that occur offline. Users are encouraged to meet in public places and use their best judgment.',
                        isDarkMode,
                      ),
                    ] else ...[
                      // Privacy Policy Content
                      _buildSection(
                        '1. Information We Collect',
                        'We collect information you provide directly to us, such as when you create an account, update your profile, share produce, or communicate with other gardeners. This includes your name, email address, phone number, and garden location.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '2. How We Use Your Information',
                        '• To provide and maintain our service\n• To notify you about changes to our service\n• To allow you to participate in interactive features\n• To provide customer support\n• To gather analysis to improve our service\n• To monitor the usage of our service\n• To detect, prevent and address technical issues',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '3. Location Data',
                        'We collect location data to enable local food sharing and garden tracking. Your precise location is only shared with users you approve for sharing. General location (neighborhood level) may be used for community matching.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '4. Data Security',
                        'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '5. Your Rights',
                        'You have the right to access, update, or delete your personal information. You can also object to processing of your data, request restriction of processing, or request data portability.',
                        isDarkMode,
                      ),
                      
                      _buildSection(
                        '6. Changes to This Policy',
                        'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "effective date" at the top.',
                        isDarkMode,
                      ),
                    ],
                    
                    // Scroll prompt
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF19E6A2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF19E6A2).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.keyboard_double_arrow_down,
                            color: Color(0xFF19E6A2),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please scroll to the end to accept the terms.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Extra space to ensure scrolling is needed
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            // Fixed Footer
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF11211C) : Color(0xFFF6F8F7),
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? Color(0xFF2A3D37) : Color(0xFFD0E7DF),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: _hasReadTerms,
                          onChanged: _hasReadTerms
                              ? (value) {
                                  setState(() {
                                    _hasReadTerms = value ?? false;
                                  });
                                }
                              : null,
                          activeColor: Color(0xFF19E6A2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I have read and agree to the ',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Color(0xFFA0B8AF) : Color(0xFF0E1B17),
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms of Use',
                                style: TextStyle(
                                  color: Color(0xFF19E6A2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFF19E6A2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Continue Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _hasReadTerms
                          ? [
                              BoxShadow(
                                color: Color(0xFF19E6A2).withOpacity(0.2),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: _hasReadTerms ? Color(0xFF19E6A2) : (isDarkMode ? Color(0xFF2A3D37) : Color(0xFFD0E7DF)),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _hasReadTerms
                            ? () {
                                widget.onAccept();
                                Navigator.pop(context);
                              }
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: _hasReadTerms 
                                    ? (isDarkMode ? Color(0xFF11211C) : Colors.white)
                                    : (isDarkMode ? Color(0xFF4E977F) : Color(0xFF8EB8A7)),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Color(0xFFA0B8AF) : Color(0xFF0E1B17),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
