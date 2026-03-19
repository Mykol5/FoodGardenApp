import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final String? recipientId;
  final String? recipientName;
  final String? recipientImage;
  final String? productId;
  final String? productName;
  final String? productStatus;
  final int? productQuantity;
  
  const MessagesScreen({
    Key? key,
    this.recipientId,
    this.recipientName,
    this.recipientImage,
    this.productId,
    this.productName,
    this.productStatus,
    this.productQuantity,
  }) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedTabIndex = 0;
  String _selectedStatusFilter = 'All';
  
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'itemName': 'Heirloom Tomatoes',
      'userName': 'Sarah L.',
      'message': 'I can drop them off at the community center tomorrow morning! Does 10am work?',
      'time': '2m ago',
      'status': 'In Progress',
      'statusColor': Color(0xFFFFC300),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDAeiZhBqBG3a1zX72JWhmhJsVjDtUgNG8XWCZO2D5BkIthh6g9py4-HwGoOJI1csYa2J2GmkR5vdaahuxrnaTZxdRR6AwjwU18Sf9zj0nbBDOXSyRHVOcR0Q68t4vhV9y4ATAXWt9v5F21PvNSQoytILLWmKsLBF0Wk2bhCNv9D_hu6c2Ia1RikGwPXgzkKnbYhYageO67wjHpPcxfLT3p-lNNPEUTW69w3kOXgeUuTwKHZ8s2CGbKJLIm0u66igY5b-cFbCf2NU2U',
      'unread': true,
      'productId': 'p1',
      'quantity': 2,
      'quantityUnit': 'lbs',
    },
    {
      'id': '2',
      'itemName': 'Organic Kale',
      'userName': 'Mike R.',
      'message': 'Thanks for the greens! They look amazing. My family is going to love the salad tonight.',
      'time': '1h ago',
      'status': 'Claimed',
      'statusColor': Color(0xFF668799),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuByN05TsDrR5x8_y4vYNTMqtKbnQPUl1ScoIloxIYDv56TrHfzYNtWPAQi1LEkt-ZrmGlV18-RSGQ-0JHRBGcfvE_iSyyDWcre2mBJX_KhrXp25ZSfYzhxsCTK4HeNfB6RZ_i5zlyNLj5idD7SXRQg1tGgJ7heJbNDqY5791ijcOJjht4HWh-ykhkUEcTAIg_FoNIKavFMSaqhd4hqWWhZfb1SjL3N8GTvOQh-00MMxFI_JBueLOUUCIaz-XMb86o3I7ZTwHwtZIp4R',
      'unread': false,
      'productId': 'p2',
      'quantity': 0,
      'quantityUnit': 'bunches',
    },
    {
      'id': '3',
      'itemName': 'Fresh Basil',
      'userName': 'Jenny K.',
      'message': 'Are the seeds organic as well? I\'m trying to keep my whole terrace plot certified.',
      'time': '3h ago',
      'status': 'In Progress',
      'statusColor': Color(0xFFFFC300),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC5qQHY0c1hvVpCTY1DLXjvKUWXEPA059WI2-Pa7BAcd3A20q2w-gT-UduMr79c-3oU9DlXEd5oR0eGtlbsjHumMMSOo7vZid7xwlrOI_XJdAAZoH0bNLUbdxpDOvERbmJuW51KcpC1lusMOmmrro9EzKK1-SHCc2WuzzmEdKKerouMaSbYrc8nhsBRhU4XuCA0zDL6wLoIqTQqahBgnbVVwflLVUrgqeahT5eYHpDDzTxeGmyWHSLTPcsNDCQkghQB263NKObJ5suE',
      'unread': true,
      'productId': 'p3',
      'quantity': 5,
      'quantityUnit': 'bunches',
    },
    {
      'id': '4',
      'itemName': 'Bell Peppers',
      'userName': 'David W.',
      'message': 'Perfect, see you next harvest!',
      'time': 'Yesterday',
      'status': 'Completed',
      'statusColor': Color(0xFF668799),
      'userImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDIsECW3jVaGjzIPTs97wsgjeWbMqq5YRNZNxa3tedBZKjtf4WrT3eVQRKTm7HImTvVesHLeRz5aZ--rntj15CdXJguHD3WSFUdorWc43YRqd5ZdQL-QSrH-BoLkujS__rvl3zO95WMqQTU21IoUVkhprTCrfrWOZJ1gBimbA10uCwgF7QOubot5CXaTGKmvjRxskQhNjzhk4ymiqSjrTFL9Wd1N8jwLGPeYkIaruKyYKXDOhHdE_4iwk9A4_42M2NtY3ChjZ6RwCAA',
      'unread': false,
      'productId': 'p4',
      'quantity': 0,
      'quantityUnit': 'pieces',
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    if (_selectedStatusFilter == 'All') return _chats;
    return _chats.where((chat) => chat['status'] == _selectedStatusFilter).toList();
  }

  int _getUnreadCount() {
    return _chats.where((chat) => chat['unread'] == true).length;
  }

  Color _getStatusColor(String status) {
    switch(status) {
      case 'In Progress':
        return Color(0xFFFFC300);
      case 'Claimed':
        return Color(0xFF29A366);
      case 'Completed':
        return Color(0xFF668799);
      default:
        return Color(0xFF29A366);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _getUnreadCount();
    
    // If we have a recipient from product details, auto-open chat
    if (widget.recipientId != null && widget.recipientName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              itemName: widget.productName ?? 'Produce',
              userName: widget.recipientName!,
              userImage: widget.recipientImage ?? '',
              productId: widget.productId,
              productStatus: widget.productStatus,
              quantity: widget.productQuantity ?? 0,
            ),
          ),
        ).then((_) {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      });
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF18251B) : Color(0xFFFAFAF9),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Main FAB for new message
          FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('New message feature coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            backgroundColor: Color(0xFF29A366),
            child: Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(height: 12),
          // Status Filter Chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF1F2E23) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusFilterChip('All', isDarkMode),
                _buildStatusFilterChip('In Progress', isDarkMode),
                _buildStatusFilterChip('Claimed', isDarkMode),
                _buildStatusFilterChip('Completed', isDarkMode),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.only(
                top: 16,
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
                  Row(
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF29A366),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            '$unreadCount unread · ${_filteredChats.length} ${_selectedStatusFilter == 'All' ? 'total' : _selectedStatusFilter.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF578E73),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Search button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF29A366).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Search coming soon!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.search,
                        color: Color(0xFF29A366),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs for Buying/Selling
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
              child: _filteredChats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Color(0xFF29A366).withOpacity(0.3),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No ${_selectedStatusFilter == 'All' ? '' : _selectedStatusFilter.toLowerCase()} messages',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Color(0xFF5C8A7A),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = _filteredChats[index];
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
    );
  }

  Widget _buildStatusFilterChip(String label, bool isDarkMode) {
    final isSelected = _selectedStatusFilter == label;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? Color(0xFF29A366) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedStatusFilter = label;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Color(0xFF578E73),
              ),
            ),
          ),
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
              productId: chat['productId'],
              productStatus: chat['status'],
              quantity: chat['quantity'],
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
            color: chat['unread'] == true
                ? Color(0xFF29A366).withOpacity(0.5)
                : (isDarkMode ? Color(0xFF2D3F32) : Color(0xFFE8EEEB)),
            width: chat['unread'] == true ? 2 : 1,
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
            // User Avatar with Status Indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getStatusColor(chat['status']),
                      width: 3,
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
                if (chat['quantity'] > 0)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFF29A366),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                if (chat['unread'] == true)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Color(0xFF1F2E23) : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
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
                      Expanded(
                        child: Text(
                          chat['itemName'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF29A366),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (chat['quantity'] > 0)
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Text(
                                  '${chat['quantity']} ${chat['quantityUnit']} •',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: chat['statusColor'],
                                  ),
                                ),
                              ),
                            Text(
                              chat['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: chat['statusColor'],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    chat['time'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF578E73).withOpacity(0.6),
                    ),
                  ),
                  if (chat['quantity'] == 0)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF668799).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Claimed',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF668799),
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
}
