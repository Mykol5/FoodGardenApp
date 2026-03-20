import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'dart:convert';

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
  bool _isLoading = true;
  bool _isRefreshing = false;
  
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _filteredChats = [];
  
  final ApiService _apiService = ApiService();
  WebSocketChannel? _channel;
  bool _isConnected = false;

  // WebSocket server URL
  static const String webSocketUrl = 'wss://foodsharingbackend.onrender.com';

  @override
  void initState() {
    super.initState();
    _loadChats();
    _connectWebSocket();
    
    // Auto-open chat if coming from product details
    _checkForDirectMessage();
  }

  void _connectWebSocket() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (token == null) {
        print('No token available for WebSocket connection');
        return;
      }
      
      // _channel = WebSocketChannel.connect(
      //   Uri.parse('$webSocketUrl/ws/user?token=$token'),
      // );

      _channel = WebSocketChannel.connect(
        Uri.parse('$webSocketUrl/ws?token=$token'),
      );

      _channel!.stream.listen(
        (message) {
          _handleIncomingNotification(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          setState(() {
            _isConnected = false;
          });
        },
        onDone: () {
          setState(() {
            _isConnected = false;
          });
          // Attempt to reconnect after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _connectWebSocket();
          });
        },
      );

      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _handleIncomingNotification(String message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'new_message') {
        _refreshChats();
        
        // Show local notification
        _showMessageNotification(data);
      } else if (data['type'] == 'status_update') {
        _refreshChats();
      } else if (data['type'] == 'user_status') {
        // Handle user online/offline status updates
        setState(() {});
      }
    } catch (e) {
      print('Error handling notification: $e');
    }
  }

  void _showMessageNotification(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New message from ${data['senderName'] ?? 'someone'}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            _navigateToChat(
              chatId: data['chatId'],
              userName: data['senderName'] ?? 'User',
              userImage: data['senderImage'] ?? '',
              itemName: data['itemName'] ?? 'Produce',
              productId: data['productId'],
              productStatus: data['productStatus'],
              quantity: data['quantity'] ?? 0,
              recipientId: data['senderId'],
            );
          },
        ),
        backgroundColor: const Color(0xFF29A366),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.getUserChats();
      if (result['success'] == true) {
        setState(() {
          _chats = List<Map<String, dynamic>>.from(result['chats'] ?? []);
          _applyFilters();
        });
      }
    } catch (e) {
      print('Error loading chats: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshChats() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final result = await _apiService.getUserChats();
      if (result['success'] == true) {
        setState(() {
          _chats = List<Map<String, dynamic>>.from(result['chats'] ?? []);
          _applyFilters();
        });
      }
    } catch (e) {
      print('Error refreshing chats: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_chats);
    
    // Apply status filter
    if (_selectedStatusFilter != 'All') {
      filtered = filtered.where((chat) => 
        chat['status'] == _selectedStatusFilter
      ).toList();
    }
    
    // Apply tab filter (Buying/Selling)
    if (_selectedTabIndex == 1) { // Buying
      filtered = filtered.where((chat) => 
        chat['isBuyer'] == true
      ).toList();
    } else if (_selectedTabIndex == 2) { // Selling
      filtered = filtered.where((chat) => 
        chat['isSeller'] == true
      ).toList();
    }
    
    setState(() {
      _filteredChats = filtered;
    });
  }

  Future<void> _checkForDirectMessage() async {
    if (widget.recipientId != null && widget.recipientName != null) {
      // Small delay to ensure the screen is fully built
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        await _navigateToChat(
          recipientId: widget.recipientId!,
          userName: widget.recipientName!,
          userImage: widget.recipientImage ?? '',
          itemName: widget.productName ?? 'Produce',
          productId: widget.productId,
          productStatus: widget.productStatus,
          quantity: widget.productQuantity ?? 0,
        );
      }
    }
  }

  Future<void> _navigateToChat({
    String? chatId,
    required String userName,
    String userImage = '',
    required String itemName,
    String? recipientId,
    String? productId,
    String? productStatus,
    int quantity = 0,
  }) async {
    String targetChatId;
    
    // If we don't have a chatId but have recipientId, create/get the chat
    if (chatId == null && recipientId != null) {
      try {
        final result = await _apiService.createOrGetChat(
          recipientId: recipientId,
          productId: productId,
        );
        
        if (result['success'] == true) {
          targetChatId = result['chat']['id'];
        } else {
          throw Exception(result['error'] ?? 'Failed to create chat');
        }
      } catch (e) {
        print('Error creating chat: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start chat: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    } else if (chatId != null) {
      targetChatId = chatId;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot start chat: Missing recipient information'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            itemName: itemName,
            userName: userName,
            userImage: userImage,
            productId: productId,
            productStatus: productStatus,
            quantity: quantity,
            recipientId: recipientId ?? '',
            chatId: targetChatId,
          ),
        ),
      );
      
      // Refresh chats when returning from chat
      _refreshChats();
    }
  }

  int _getUnreadCount() {
    int count = 0;
    for (var chat in _chats) {
      final unread = chat['unreadCount'];
      if (unread != null) {
        count += unread as int;
      }
    }
    return count;
  }

  Color _getStatusColor(String status) {
    switch(status) {
      case 'In Progress':
        return const Color(0xFFFFC300);
      case 'Claimed':
        return const Color(0xFF29A366);
      case 'Completed':
        return const Color(0xFF668799);
      default:
        return const Color(0xFF29A366);
    }
  }

  String _formatTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${time.day}/${time.month}';
      } else {
        return '${time.day}/${time.month}/${time.year}';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _getUnreadCount();
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF18251B) : const Color(0xFFFAFAF9),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Connection Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _isConnected ? const Color(0xFF29A366) : Colors.red,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Main FAB for new message
          FloatingActionButton(
            onPressed: () {
              _showNewMessageDialog(context);
            },
            backgroundColor: const Color(0xFF29A366),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          // Status Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2E23) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
        child: RefreshIndicator(
          onRefresh: _refreshChats,
          color: const Color(0xFF29A366),
          child: Column(
            children: [
              // Top App Bar
              Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF18251B).withOpacity(0.8)
                      : const Color(0xFFFAFAF9).withOpacity(0.8),
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
                            color: const Color(0xFF29A366),
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
                                color: isDarkMode ? Colors.white : const Color(0xFF101914),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoading 
                                  ? 'Loading...'
                                  : '$unreadCount unread · ${_filteredChats.length} ${_selectedStatusFilter == 'All' ? 'total' : _selectedStatusFilter.toLowerCase()}',
                              style: const TextStyle(
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
                        color: const Color(0xFF29A366).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showSearchDialog(context);
                        },
                        icon: const Icon(
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF253529) : const Color(0xFFF0F4F2),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF29A366)))
                    : _filteredChats.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredChats.length,
                            itemBuilder: (context, index) {
                              final chat = _filteredChats[index];
                              return _buildChatCard(
                                context,
                                chat: chat,
                                isDarkMode: isDarkMode,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: const Color(0xFF29A366).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF101914),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatusFilter == 'All'
                  ? 'Start a conversation by claiming some produce!'
                  : 'No ${_selectedStatusFilter.toLowerCase()} messages',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : const Color(0xFF5C8A7A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to home screen to find produce
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29A366),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Find Produce to Share',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? const Color(0xFF29A366) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedStatusFilter = label;
              _applyFilters();
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF578E73),
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
            ? (isDarkMode ? const Color(0xFF101914) : Colors.white)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
              _applyFilters();
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
                      ? const Color(0xFF29A366)
                      : const Color(0xFF578E73),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildChatCard(
  //   BuildContext context, {
  //   required Map<String, dynamic> chat,
  //   required bool isDarkMode,
  // }) {
  //   final statusColor = _getStatusColor(chat['status'] ?? 'Available');
  //   final unreadCount = chat['unreadCount'] ?? 0;
  //   final lastMessage = chat['lastMessage'] ?? {};
  //   final lastMessageText = lastMessage['text'] ?? 'No messages yet';
  //   final lastMessageTime = lastMessage['timestamp'] != null
  //       ? _formatTime(lastMessage['timestamp'])
  //       : '';
    
  //   final otherUser = chat['otherUser'] ?? {};
  //   final otherUserName = otherUser['name'] ?? 'User';
  //   final otherUserImage = otherUser['image'] ?? '';
    
  //   return GestureDetector(
  //     onTap: () {
  //       _navigateToChat(
  //         chatId: chat['id'],
  //         userName: otherUserName,
  //         userImage: otherUserImage,
  //         itemName: chat['itemName'] ?? 'Produce',
  //         productId: chat['productId'],
  //         productStatus: chat['status'],
  //         quantity: chat['quantity'] ?? 0,
  //         recipientId: otherUser['id'],
  //       );
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 12),
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: isDarkMode ? const Color(0xFF1F2E23) : Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: unreadCount > 0
  //               ? const Color(0xFF29A366).withOpacity(0.5)
  //               : (isDarkMode ? const Color(0xFF2D3F32) : const Color(0xFFE8EEEB)),
  //           width: unreadCount > 0 ? 2 : 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 20,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // User Avatar with Status Indicator
  //           Stack(
  //             children: [
  //               Container(
  //                 width: 56,
  //                 height: 56,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   border: Border.all(
  //                     color: statusColor,
  //                     width: 3,
  //                   ),
  //                   image: otherUserImage.isNotEmpty
  //                       ? DecorationImage(
  //                           image: NetworkImage(otherUserImage),
  //                           fit: BoxFit.cover,
  //                         )
  //                       : null,
  //                   color: statusColor.withOpacity(0.1),
  //                 ),
  //                 child: otherUserImage.isEmpty
  //                     ? Center(
  //                         child: Text(
  //                           otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
  //                           style: TextStyle(
  //                             color: statusColor,
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       )
  //                     : null,
  //               ),
  //               if (chat['quantity'] != null && chat['quantity'] > 0)
  //                 Positioned(
  //                   bottom: 0,
  //                   right: 0,
  //                   child: Container(
  //                     padding: const EdgeInsets.all(2),
  //                     decoration: const BoxDecoration(
  //                       color: Colors.white,
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: Container(
  //                       width: 12,
  //                       height: 12,
  //                       decoration: const BoxDecoration(
  //                         color: Color(0xFF29A366),
  //                         shape: BoxShape.circle,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               if (unreadCount > 0)
  //                 Positioned(
  //                   top: 0,
  //                   right: 0,
  //                   child: Container(
  //                     width: 20,
  //                     height: 20,
  //                     decoration: BoxDecoration(
  //                       color: Colors.red,
  //                       shape: BoxShape.circle,
  //                       border: Border.all(
  //                         color: isDarkMode ? const Color(0xFF1F2E23) : Colors.white,
  //                         width: 2,
  //                       ),
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         unreadCount > 9 ? '9+' : '$unreadCount',
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //             ],
  //           ),
  //           const SizedBox(width: 16),
            
  //           // Chat Details
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         chat['itemName'] ?? 'Produce',
  //                         style: const TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.bold,
  //                           color: Color(0xFF29A366),
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                       decoration: BoxDecoration(
  //                         color: statusColor.withOpacity(0.15),
  //                         borderRadius: BorderRadius.circular(12),
  //                         border: Border.all(
  //                           color: statusColor.withOpacity(0.2),
  //                         ),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           if (chat['quantity'] != null && chat['quantity'] > 0)
  //                             Padding(
  //                               padding: const EdgeInsets.only(right: 4),
  //                               child: Text(
  //                                 '${chat['quantity']} ${chat['quantityUnit'] ?? 'pcs'} •',
  //                                 style: TextStyle(
  //                                   fontSize: 8,
  //                                   color: statusColor,
  //                                 ),
  //                               ),
  //                             ),
  //                           Text(
  //                             chat['status'] ?? 'Available',
  //                             style: TextStyle(
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.bold,
  //                               color: statusColor,
  //                               letterSpacing: 0.5,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   otherUserName,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                     color: isDarkMode ? Colors.white : const Color(0xFF101914),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   lastMessageText,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: unreadCount > 0 
  //                         ? (isDarkMode ? Colors.white : const Color(0xFF101914))
  //                         : const Color(0xFF578E73),
  //                     fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
  //                     height: 1.4,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
            
  //           // Time
  //           Padding(
  //             padding: const EdgeInsets.only(left: 8),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Text(
  //                   lastMessageTime,
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
  //                     color: unreadCount > 0
  //                         ? const Color(0xFF29A366)
  //                         : const Color(0xFF578E73).withOpacity(0.6),
  //                   ),
  //                 ),
  //                 if (chat['quantity'] == 0)
  //                   Container(
  //                     margin: const EdgeInsets.only(top: 4),
  //                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF668799).withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(4),
  //                     ),
  //                     child: const Text(
  //                       'Claimed',
  //                       style: TextStyle(
  //                         fontSize: 8,
  //                         fontWeight: FontWeight.bold,
  //                         color: Color(0xFF668799),
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  Widget _buildChatCard(
  BuildContext context, {
  required Map<String, dynamic> chat,
  required bool isDarkMode,
}) {
  final statusColor = _getStatusColor(chat['status'] ?? 'Available');
  final unreadCount = chat['unreadCount'] ?? 0;
  final lastMessage = chat['lastMessage'] ?? {};
  final lastMessageText = lastMessage['text']?.toString() ?? 'No messages yet';
  
  String lastMessageTime = '';
  if (lastMessage['timestamp'] != null) {
    final timestamp = lastMessage['timestamp'].toString();
    if (timestamp.isNotEmpty) {
      lastMessageTime = _formatTime(timestamp);
    }
  }
  
  final otherUser = chat['otherUser'] ?? {};
  final otherUserName = otherUser['name']?.toString() ?? 'User';
  final otherUserImage = otherUser['image']?.toString() ?? '';
  
  return GestureDetector(
    onTap: () {
      _navigateToChat(
        chatId: chat['id']?.toString(),
        userName: otherUserName,
        userImage: otherUserImage,
        itemName: chat['itemName']?.toString() ?? 'Produce',
        productId: chat['productId']?.toString(),
        productStatus: chat['status']?.toString(),
        quantity: chat['quantity'] ?? 0,
        recipientId: otherUser['id']?.toString(),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2E23) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unreadCount > 0
              ? const Color(0xFF29A366).withOpacity(0.5)
              : (isDarkMode ? const Color(0xFF2D3F32) : const Color(0xFFE8EEEB)),
          width: unreadCount > 0 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
                    color: statusColor,
                    width: 3,
                  ),
                  image: otherUserImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(otherUserImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: statusColor.withOpacity(0.1),
                ),
                child: otherUserImage.isEmpty
                    ? Center(
                        child: Text(
                          otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              if (chat['quantity'] != null && chat['quantity'] > 0)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF29A366),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              if (unreadCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF1F2E23) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
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
                        chat['itemName']?.toString() ?? 'Produce',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF29A366),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (chat['quantity'] != null && chat['quantity'] > 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                '${chat['quantity']} ${chat['quantityUnit'] ?? 'pcs'} •',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          Text(
                            chat['status']?.toString() ?? 'Available',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  otherUserName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF101914),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastMessageText,
                  style: TextStyle(
                    fontSize: 14,
                    color: unreadCount > 0 
                        ? (isDarkMode ? Colors.white : const Color(0xFF101914))
                        : const Color(0xFF578E73),
                    fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
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
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lastMessageTime,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                    color: unreadCount > 0
                        ? const Color(0xFF29A366)
                        : const Color(0xFF578E73).withOpacity(0.6),
                  ),
                ),
                if (chat['quantity'] == 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF668799).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
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
  

  void _showNewMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: const Text('Select a product to start a conversation'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to home to find products
              Navigator.pop(context);
            },
            child: const Text('Find Products'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Messages'),
        content: const Text('Search functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
