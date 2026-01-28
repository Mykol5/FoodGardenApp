import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedTabIndex = 0;
  
  final List<Map<String, dynamic>> _chats = [
    {
      'id': 1,
      'itemName': 'Heirloom Tomatoes',
      'userName': 'Sarah L.',
      'message': 'I can drop them off at the community center tomorrow morning! Does 10am work?',
      'time': '2m ago',
      'status': 'In Progress',
      'statusColor': Color(0xFFFFC300),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDAeiZhBqBG3a1zX72JWhmhJsVjDtUgNG8XWCZO2D5BkIthh6g9py4-HwGoOJI1csYa2J2GmkR5vdaahuxrnaTZxdRR6AwjwU18Sf9zj0nbBDOXSyRHVOcR0Q68t4vhV9y4ATAXWt9v5F21PvNSQoytILLWmKsLBF0Wk2bhCNv9D_hu6c2Ia1RikGwPXgzkKnbYhYageO67wjHpPcxfLT3p-lNNPEUTW69w3kOXgeUuTwKHZ8s2CGbKJLIm0u66igY5b-cFbCf2NU2U',
    },
    {
      'id': 2,
      'itemName': 'Organic Kale',
      'userName': 'Mike R.',
      'message': 'Thanks for the greens! They look amazing. My family is going to love the salad tonight.',
      'time': '1h ago',
      'status': 'Claimed',
      'statusColor': Color(0xFF668799),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuByN05TsDrR5x8_y4vYNTMqtKbnQPUl1ScoIloxIYDv56TrHfzYNtWPAQi1LEkt-ZrmGlV18-RSGQ-0JHRBGcfvE_iSyyDWcre2mBJX_KhrXp25ZSfYzhxsCTK4HeNfB6RZ_i5zlyNLj5idD7SXRQg1tGgJ7heJbNDqY5791ijcOJjht4HWh-ykhkUEcTAIg_FoNIKavFMSaqhd4hqWWhZfb1SjL3N8GTvOQh-00MMxFI_JBueLOUUCIaz-XMb86o3I7ZTwHwtZIp4R',
    },
    {
      'id': 3,
      'itemName': 'Fresh Basil',
      'userName': 'Jenny K.',
      'message': 'Are the seeds organic as well? I\'m trying to keep my whole terrace plot certified.',
      'time': '3h ago',
      'status': 'In Progress',
      'statusColor': Color(0xFFFFC300),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC5qQHY0c1hvVpCTY1DLXjvKUWXEPA059WI2-Pa7BAcd3A20q2w-gT-UduMr79c-3oU9DlXEd5oR0eGtlbsjHumMMSOo7vZid7xwlrOI_XJdAAZoH0bNLUbdxpDOvERbmJuW51KcpC1lusMOmmrro9EzKK1-SHCc2WuzzmEdKKerouMaSbYrc8nhsBRhU4XuCA0zDL6wLoIqTQqahBgnbVVwflLVUrgqeahT5eYHpDDzTxeGmyWHSLTPcsNDCQkghQB263NKObJ5suE',
    },
    {
      'id': 4,
      'itemName': 'Bell Peppers',
      'userName': 'David W.',
      'message': 'Perfect, see you next harvest!',
      'time': 'Yesterday',
      'status': 'Completed',
      'statusColor': Color(0xFF668799),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDIsECW3jVaGjzIPTs97wsgjeWbMqq5YRNZNxa3tedBZKjtf4WrT3eVQRKTm7HImTvVesHLeRz5aZ--rntj15CdXJguHD3WSFUdorWc43YRqd5ZdQL-QSrH-BoLkujS__rvl3zO95WMqQTU21IoUVkhprTCrfrWOZJ1gBimbA10uCwgF7QOubot5CXaTGKmvjRxskQhNjzhk4ymiqSjrTFL9Wd1N8jwLGPeYkIaruKyYKXDOhHdE_4iwk9A4_42M2NtY3ChjZ6RwCAA',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF18251B) : Color(0xFFFAFAF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Color(0xFF18251B).withOpacity(0.8)
                    : Color(0xFFFAFAF9).withOpacity(0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Color(0xFF101914),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '4 active conversations',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF578E73),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF29A366).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: Start new conversation
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Color(0xFF29A366),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF253529) : Color(0xFFF0F4F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTabButton('All', 0, isDarkMode),
                    _buildTabButton('Buying', 1, isDarkMode),
                    _buildTabButton('Selling', 2, isDarkMode),
                  ],
                ),
              ),
            ),

            // Chat List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _buildChatCard(
                    context,
                    chat: chat,
                    isDarkMode: isDarkMode,
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Color(0xFF18251B).withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Color(0xFF2D3F32) : Color(0xFFE8EEEB),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // My Garden
            _buildNavItem(
              Icons.local_florist,
              'My Garden',
              false,
              isDarkMode,
            ),
            
            // Discover
            _buildNavItem(
              Icons.explore,
              'Discover',
              false,
              isDarkMode,
            ),
            
            // Messages (Active)
            _buildNavItem(
              Icons.chat_bubble,
              'Messages',
              true,
              isDarkMode,
            ),
            
            // Profile
            _buildNavItem(
              Icons.person,
              'Profile',
              false,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, bool isDarkMode) {
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: Material(
        color: isSelected
            ? (isDarkMode ? Color(0xFF101914) : Colors.white)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Color(0xFF29A366)
                      : Color(0xFF578E73),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatCard(
    BuildContext context, {
    required Map<String, dynamic> chat,
    required bool isDarkMode,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              itemName: chat['itemName'],
              userName: chat['userName'],
              userImage: chat['userImage'],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1F2E23) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Color(0xFF2D3F32) : Color(0xFFE8EEEB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar with Online Indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Color(0xFF1F2E23) : Colors.white,
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(chat['userImage']),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (index == 0) // Show online indicator only for first chat
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFF29A366),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Color(0xFF1F2E23) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            
            // Chat Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['itemName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF29A366),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: chat['statusColor'].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: chat['statusColor'].withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          chat['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: chat['statusColor'],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    chat['userName'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Color(0xFF101914),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    chat['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF578E73),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Time
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                chat['time'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF578E73).withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Icon(
              icon,
              color: isActive ? Color(0xFF29A366) : Color(0xFF578E73),
              size: 28,
            ),
            if (isActive && label == 'Messages') // Show notification dot
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Color(0xFF18251B) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? Color(0xFF29A366) : Color(0xFF578E73),
          ),
        ),
      ],
    );
  }
}
