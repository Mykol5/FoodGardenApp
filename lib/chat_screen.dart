import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String itemName;
  final String userName;
  final String userImage;
  
  const ChatScreen({
    Key? key,
    required this.itemName,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'text': 'Hi! I\'ve just harvested the tomatoes. They are in a wooden crate by the white fence. Help yourself!',
      'isMe': false,
      'time': '2:14 PM',
      'userName': 'Elena (Gardener)',
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAdPHnwnHUI18gefKHIHNMB_aEGbFy_Cij0jU0ZG26mdH0KE2LoZW1Q6gVoh9Sh8hQeCBBjpv4re6y9y9Z5LJlLLe730zp6B8Wmdtuk9SgFF_ONFCZer10S5PMQZ-aEBaxHgca1607mCNMy94gegz8Ubc_ka_xbQn8GG92VASXwcNHhx35R86cz7hww3eOQ0dWD3RLONlA0MpuFGBAOzNS--BB-83CoHeEYKLT0X7sDsJyN5lOgkxaLyslSUzyxGRrlOqMkFj80UCzc',
    },
    {
      'id': 2,
      'text': 'Perfect timing! I\'m about 10 minutes away. Is there anything else you\'d like me to clear out? 🌿',
      'isMe': true,
      'time': '2:15 PM',
      'isRead': true,
    },
    {
      'id': 3,
      'text': 'Actually, I have some fresh basil too. I tucked it inside the crate so it stays out of the sun.',
      'isMe': false,
      'time': '2:16 PM',
      'userName': 'Elena (Gardener)',
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMEJVj2IOFnpcYJhHj38lJfO9xDQPtr2fJhVH2D5trBaYygs9lwco3frg0gYpNr2ywUacyBM_gZjpDK27Lbok9_9m7yRrRvicvRdGNfIS7nEjoA3tpyeNw9b6X1vby2oTtk6TKpRdKfAhUb90i0Fpaq_9azVKtd__E-EmsB38SD6s8FhjuMWOjIp2xvFG_3wZA4yuj4-5GedVhz3URKClYuKhfV3x7uWqhgFKnm00A5_uPHH3zNfn8Rby2F-n5hUCIjJiI_MYDUTgq',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF201712) : Color(0xFFF6F5F3),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Color(0xFF201712).withOpacity(0.8)
                    : Color(0xFFF6F5F3).withOpacity(0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F),
                      size: 20,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Gardener Chat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Active Claim',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC35822),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: More options
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      color: isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Produce Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF333333) : Color(0xFFFBF9F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFFC35822).withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBv4kobyLKCZCjnbR5WXOpOJ04bxBrznnV9fRzOCOnHK_2m72HzRB9uCgnzamD_1CZCFZJP7QmHc-rP_VNipSsmdI7VBlL1jNcqsWkV0JtS8o8qwxwMGf-vDxKZ_zS_Q355QrWHfZ-ylNaGEhjAktGPlblKMA6aE7KjGU7cHvsYHhWmgBDBEmZQL6dRWsdKeSIB2c1HqnkQyGBjhd_xa35mICN6qAsG6-zFNqimLnWjNA_y1jXrYit7y8PWN10rkfv7llmSo-y_UZ8u'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Color(0xFFC35822).withOpacity(0.05),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.itemName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ready for pickup',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFC35822),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFC35822),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFC35822).withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Claimed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chat Messages
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Today Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0xFFC35822).withOpacity(0.1),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: (isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F)).withOpacity(0.4),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0xFFC35822).withOpacity(0.1),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Messages
                  ..._messages.map((message) {
                    return _buildMessageBubble(message, isDarkMode);
                  }).toList(),
                ],
              ),
            ),

            // Message Input
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Photo Button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFC35822).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Add photo
                          },
                          icon: Icon(
                            Icons.add_a_photo,
                            color: Color(0xFFC35822),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(width: 12),
                      
                      // Location Button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFC4D3BB).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Share location
                          },
                          icon: Icon(
                            Icons.location_on,
                            color: (isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F)).withOpacity(0.7),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(width: 12),
                      
                      // Message Input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? Color(0xFF333333) : Color(0xFFFBF9F8),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      hintStyle: TextStyle(
                                        color: (isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F)).withOpacity(0.3),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      color: isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                margin: EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFC35822),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFC35822).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (_messageController.text.isNotEmpty) {
                                      // TODO: Send message
                                      _messageController.clear();
                                    }
                                  },
                                  icon: Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  
                  // Home Indicator
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDarkMode) {
    final isMe = message['isMe'] == true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(message['userImage']),
                backgroundColor: Colors.transparent,
              ),
            ),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message['userName'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC35822),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Color(0xFFC4D3BB).withOpacity(isDarkMode ? 0.2 : 1)
                        : Color(0xFFC35822),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                      bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe
                          ? (isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F))
                          : Color(0xFFFBF9F8),
                      height: 1.4,
                    ),
                  ),
                ),
                
                if (isMe && message['isRead'] == true)
                  Padding(
                    padding: EdgeInsets.only(right: 8, top: 4),
                    child: Text(
                      'Read ${message['time']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: (isDarkMode ? Color(0xFFFBF9F8) : Color(0xFF3D2B1F)).withOpacity(0.4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          if (isMe)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBCbsLE69S5DmBN2cgdz6jDYi-NkzS3r1Ia17D_iXPwBwqb1sK6-_CxRiKd1jqEs8SFsTvfAdGNrIfjtsQU0pxzIdVAGS59fckxmwpa02PrYa6a2AItNUm3N1qSziKh_9EkfLvKFkB9HbuFzBhCwrI-xWkZxiaKFaaFtEAodff81dY6UOuUrcUXzKv8mr5HVDiFWIlBNQVFdwcAKrIiDnBg8H257_-0ltgJGGeKlv0s4TD_ZrTDjoouDiRF_RSeHzOXpx9mEs_ColbQ'),
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }
}
