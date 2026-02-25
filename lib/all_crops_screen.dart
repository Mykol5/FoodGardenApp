import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'update_crop_status_screen.dart';
import 'add_new_crop.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class AllCropsScreen extends StatefulWidget {
  final List<dynamic>? initialCrops;
  
  const AllCropsScreen({Key? key, this.initialCrops}) : super(key: key);

  @override
  State<AllCropsScreen> createState() => _AllCropsScreenState();
}

class _AllCropsScreenState extends State<AllCropsScreen> {
  final ApiService _apiService = ApiService();
  
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _allCrops = [];
  List<dynamic> _filteredCrops = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  
  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Vegetables', 'value': 'vegetable'},
    {'label': 'Fruits', 'value': 'fruit'},
    {'label': 'Herbs', 'value': 'herb'},
    {'label': 'Flowers', 'value': 'flower'},
    {'label': 'Other', 'value': 'other'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeCrops();
    _searchController.addListener(_filterCrops);
  }

  void _initializeCrops() {
    if (widget.initialCrops != null && widget.initialCrops!.isNotEmpty) {
      setState(() {
        _allCrops = widget.initialCrops!;
        _filteredCrops = _allCrops;
        _isLoading = false;
      });
    } else {
      _loadCrops();
    }
  }

  Future<void> _loadCrops({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cropsResult = await _apiService.getUserCrops();
      
      if (cropsResult['success'] == true) {
        setState(() {
          _allCrops = cropsResult['crops'] ?? [];
          _filteredCrops = _allCrops;
        });
      }
    } catch (e) {
      print('❌ Error loading crops: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load crops'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCrops() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    await _loadCrops(forceRefresh: true);

    setState(() {
      _isRefreshing = false;
    });
  }

  void _filterCrops() {
    final query = _searchController.text.toLowerCase();
    final filterValue = _filters[_selectedFilterIndex]['value'];

    setState(() {
      _filteredCrops = _allCrops.where((crop) {
        // Apply search filter
        final matchesSearch = query.isEmpty || 
            (crop['name']?.toString().toLowerCase().contains(query) ?? false) ||
            (crop['variety']?.toString().toLowerCase().contains(query) ?? false);

        // Apply category filter
        final matchesCategory = filterValue == 'all' || 
            crop['category'] == filterValue;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _updateFilter(int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
    _filterCrops();
  }

  String _getStatusColor(String status) {
    switch (status) {
      case 'harvest':
        return '#E59866';
      case 'fruiting':
        return '#39AC86';
      case 'flowering':
        return '#E59866';
      case 'vegetative':
        return '#4299E1';
      default:
        return '#808080';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'seedling':
        return 'Seedling';
      case 'vegetative':
        return 'Vegetative';
      case 'flowering':
        return 'Flowering';
      case 'fruiting':
        return 'Fruiting';
      case 'harvest':
        return 'Ready to Harvest';
      case 'dormant':
        return 'Dormant';
      default:
        return status.capitalize();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCrops);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(isDarkMode),
            
            // Search Bar
            _buildSearchBar(isDarkMode),
            
            // Filter Chips
            _buildFilterChips(isDarkMode),
            
            // Crops List
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(isDarkMode)
                  : _filteredCrops.isEmpty
                      ? _buildEmptyState(isDarkMode)
                      : RefreshIndicator(
                          onRefresh: _refreshCrops,
                          color: const Color(0xFF19E6A2),
                          backgroundColor: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCrops.length,
                            itemBuilder: (context, index) {
                              final crop = _filteredCrops[index];
                              return _buildCropListItem(context, crop, isDarkMode);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddNewCropScreen(),
            ),
          );
          
          if (result != null) {
            // Crop was added, refresh the list
            await _refreshCrops();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Crop added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        backgroundColor: const Color(0xFF19E6A2),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTopBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF11211C).withOpacity(0.8)
            : const Color(0xFFF6F8F7).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? const Color(0xFF1A2B26) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
              size: 20,
            ),
          ),
          
          // Title with refresh indicator
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'My Crops List',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
                    ),
                  ),
                  if (_isRefreshing) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF19E6A2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Crop count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF19E6A2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_filteredCrops.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF19E6A2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(
                Icons.search,
                color: Color(0xFF4E977F),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search your crops',
                  hintStyle: const TextStyle(color: Color(0xFF4E977F)),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
                  fontSize: 16,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  _filterCrops();
                },
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF4E977F),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilterIndex == index;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: isSelected
                  ? const Color(0xFF19E6A2)
                  : (isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => _updateFilter(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFE5E7EB),
                          ),
                  ),
                  child: Text(
                    filter['label'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode ? const Color(0xFFA0B8AF) : const Color(0xFF0E1B17)),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: const Color(0xFF19E6A2),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your crops...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : const Color(0xFF4E977F),
            ),
          ),
        ],
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
              Icons.eco,
              size: 80,
              color: const Color(0xFF19E6A2).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No crops found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedFilterIndex != 0
                  ? 'Try adjusting your search or filters'
                  : 'Add your first crop to get started!',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : const Color(0xFF4E977F),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddNewCropScreen(),
                  ),
                );
                
                if (result != null) {
                  await _refreshCrops();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF19E6A2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Add Your First Crop',
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

  Widget _buildCropListItem(
    BuildContext context,
    Map<String, dynamic> crop,
    bool isDarkMode,
  ) {
    final name = crop['name'] ?? 'Unnamed Crop';
    final status = crop['status'] ?? 'seedling';
    final variety = crop['variety'] ?? 'Unknown';
    final category = crop['category'] ?? 'vegetable';
    final progress = (crop['progress'] as num?)?.toDouble() ?? 0.0;
    final imageUrl = crop['image_url'];
    final quantity = crop['quantity'] ?? 1;
    final quantityUnit = crop['quantity_unit'] ?? 'plants';
    final plantingDate = crop['planting_date'] != null
        ? DateTime.parse(crop['planting_date'])
        : null;
    
    final dateStr = plantingDate != null
        ? '${_getMonthAbbr(plantingDate.month)} ${plantingDate.day}'
        : 'Not set';
    
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UpdateCropStatusScreen(
              cropName: name,
              cropImage: imageUrl ?? '',
              currentStatus: status,
            ),
          ),
        );
        
        if (result == true) {
          // Crop was updated, refresh the list
          await _refreshCrops();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFF0F2F1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Crop Image
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF19E6A2).withOpacity(0.1),
                image: imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.eco,
                        color: Color(0xFF19E6A2),
                        size: 32,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Crop Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(int.parse(statusColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity $quantityUnit',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(int.parse(statusColor.replaceFirst('#', '0xFF'))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(int.parse(statusColor.replaceFirst('#', '0xFF'))),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.capitalize()} • $variety',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF4E977F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Planted: $dateStr',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode ? Colors.white38 : const Color(0xFF808080),
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress and Chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFF0F2F1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF19E6A2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFA0B8AF) : const Color(0xFF0E1B17),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF4E977F),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// Helper extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'update_crop_status_screen.dart';
// import 'add_new_crop.dart';
// import '../services/api_service.dart';
// import '../providers/auth_provider.dart';

// class AllCropsScreen extends StatefulWidget {
//   final List<dynamic>? initialCrops;
  
//   const AllCropsScreen({Key? key, this.initialCrops}) : super(key: key);

//   @override
//   State<AllCropsScreen> createState() => _AllCropsScreenState();
// }

// class _AllCropsScreenState extends State<AllCropsScreen> {
//   final ApiService _apiService = ApiService();
  
//   int _selectedFilterIndex = 0;
//   final TextEditingController _searchController = TextEditingController();
  
//   List<dynamic> _allCrops = [];
//   List<dynamic> _filteredCrops = [];
//   bool _isLoading = true;
//   bool _isRefreshing = false;
  
//   final List<Map<String, dynamic>> _filters = [
//     {'label': 'All', 'value': 'all'},
//     {'label': 'Vegetables', 'value': 'vegetable'},
//     {'label': 'Fruits', 'value': 'fruit'},
//     {'label': 'Herbs', 'value': 'herb'},
//     {'label': 'Flowers', 'value': 'flower'},
//     {'label': 'Other', 'value': 'other'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeCrops();
//     _searchController.addListener(_filterCrops);
//   }

//   void _initializeCrops() {
//     if (widget.initialCrops != null && widget.initialCrops!.isNotEmpty) {
//       setState(() {
//         _allCrops = widget.initialCrops!;
//         _filteredCrops = _allCrops;
//         _isLoading = false;
//       });
//     } else {
//       _loadCrops();
//     }
//   }

//   Future<void> _loadCrops({bool forceRefresh = false}) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final cropsResult = await _apiService.getUserCrops();
      
//       if (cropsResult['success'] == true) {
//         setState(() {
//           _allCrops = cropsResult['crops'] ?? [];
//           _filteredCrops = _allCrops;
//         });
//       }
//     } catch (e) {
//       print('❌ Error loading crops: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load crops'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshCrops() async {
//     if (_isRefreshing) return;

//     setState(() {
//       _isRefreshing = true;
//     });

//     await _loadCrops(forceRefresh: true);

//     setState(() {
//       _isRefreshing = false;
//     });
//   }

//   void _filterCrops() {
//     final query = _searchController.text.toLowerCase();
//     final filterValue = _filters[_selectedFilterIndex]['value'];

//     setState(() {
//       _filteredCrops = _allCrops.where((crop) {
//         // Apply search filter
//         final matchesSearch = query.isEmpty || 
//             (crop['name']?.toString().toLowerCase().contains(query) ?? false) ||
//             (crop['variety']?.toString().toLowerCase().contains(query) ?? false);

//         // Apply category filter
//         final matchesCategory = filterValue == 'all' || 
//             crop['category'] == filterValue;

//         return matchesSearch && matchesCategory;
//       }).toList();
//     });
//   }

//   void _updateFilter(int index) {
//     setState(() {
//       _selectedFilterIndex = index;
//     });
//     _filterCrops();
//   }

//   String _getStatusColor(String status) {
//     switch (status) {
//       case 'harvest':
//         return '#E59866';
//       case 'fruiting':
//         return '#39AC86';
//       case 'flowering':
//         return '#E59866';
//       case 'vegetative':
//         return '#4299E1';
//       default:
//         return '#808080';
//     }
//   }

//   String _getStatusLabel(String status) {
//     switch (status) {
//       case 'seedling':
//         return 'Seedling';
//       case 'vegetative':
//         return 'Vegetative';
//       case 'flowering':
//         return 'Flowering';
//       case 'fruiting':
//         return 'Fruiting';
//       case 'harvest':
//         return 'Ready to Harvest';
//       case 'dormant':
//         return 'Dormant';
//       default:
//         return status.capitalize();
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterCrops);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDarkMode ? const Color(0xFF11211C) : const Color(0xFFF6F8F7),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top App Bar
//             _buildTopBar(isDarkMode),
            
//             // Search Bar
//             _buildSearchBar(isDarkMode),
            
//             // Filter Chips
//             _buildFilterChips(isDarkMode),
            
//             // Crops List
//             Expanded(
//               child: _isLoading
//                   ? _buildLoadingState(isDarkMode)
//                   : _filteredCrops.isEmpty
//                       ? _buildEmptyState(isDarkMode)
//                       : RefreshIndicator(
//                           onRefresh: _refreshCrops,
//                           color: const Color(0xFF19E6A2),
//                           backgroundColor: isDarkMode ? const Color(0xFF2C3A35) : Colors.white,
//                           child: ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: _filteredCrops.length,
//                             itemBuilder: (context, index) {
//                               final crop = _filteredCrops[index];
//                               return _buildCropListItem(context, crop, isDarkMode);
//                             },
//                           ),
//                         ),
//             ),
//           ],
//         ),
//       ),
      
//       // Floating Action Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => const AddNewCropScreen(),
//             ),
//           );
          
//           if (result != null) {
//             // Crop was added, refresh the list
//             await _refreshCrops();
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Crop added successfully!'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             }
//           }
//         },
//         backgroundColor: const Color(0xFF19E6A2),
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//           size: 28,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }

//   Widget _buildTopBar(bool isDarkMode) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: isDarkMode 
//             ? const Color(0xFF11211C).withOpacity(0.8)
//             : const Color(0xFFF6F8F7).withOpacity(0.8),
//         border: Border(
//           bottom: BorderSide(
//             color: isDarkMode ? const Color(0xFF1A2B26) : const Color(0xFFE5E7EB),
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Back Button
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
//               size: 20,
//             ),
//           ),
          
//           // Title with refresh indicator
//           Expanded(
//             child: Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'My Crops List',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
//                     ),
//                   ),
//                   if (_isRefreshing) ...[
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: const Color(0xFF19E6A2),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
          
//           // Crop count
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: const Color(0xFF19E6A2).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               '${_filteredCrops.length}',
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF19E6A2),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(bool isDarkMode) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Container(
//         height: 48,
//         decoration: BoxDecoration(
//           color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(left: 16),
//               child: Icon(
//                 Icons.search,
//                 color: Color(0xFF4E977F),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search your crops',
//                   hintStyle: const TextStyle(color: Color(0xFF4E977F)),
//                   border: InputBorder.none,
//                 ),
//                 style: TextStyle(
//                   color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             if (_searchController.text.isNotEmpty)
//               IconButton(
//                 onPressed: () {
//                   _searchController.clear();
//                   _filterCrops();
//                 },
//                 icon: const Icon(
//                   Icons.clear,
//                   color: Color(0xFF4E977F),
//                   size: 18,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChips(bool isDarkMode) {
//     return SizedBox(
//       height: 40,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: _filters.length,
//         itemBuilder: (context, index) {
//           final filter = _filters[index];
//           final isSelected = _selectedFilterIndex == index;
          
//           return Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: Material(
//               color: isSelected
//                   ? const Color(0xFF19E6A2)
//                   : (isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white),
//               borderRadius: BorderRadius.circular(20),
//               child: InkWell(
//                 onTap: () => _updateFilter(index),
//                 borderRadius: BorderRadius.circular(20),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     border: isSelected
//                         ? null
//                         : Border.all(
//                             color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFE5E7EB),
//                           ),
//                   ),
//                   child: Text(
//                     filter['label'],
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: isSelected
//                           ? Colors.white
//                           : (isDarkMode ? const Color(0xFFA0B8AF) : const Color(0xFF0E1B17)),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingState(bool isDarkMode) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             color: const Color(0xFF19E6A2),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading your crops...',
//             style: TextStyle(
//               color: isDarkMode ? Colors.white70 : const Color(0xFF4E977F),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(bool isDarkMode) {
//     return Center(
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.eco,
//               size: 80,
//               color: const Color(0xFF19E6A2).withOpacity(0.3),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No crops found',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _searchController.text.isNotEmpty || _selectedFilterIndex != 0
//                   ? 'Try adjusting your search or filters'
//                   : 'Add your first crop to get started!',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: isDarkMode ? Colors.white70 : const Color(0xFF4E977F),
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () async {
//                 final result = await Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const AddNewCropScreen(),
//                   ),
//                 );
                
//                 if (result != null) {
//                   await _refreshCrops();
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF19E6A2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               ),
//               child: const Text(
//                 'Add Your First Crop',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCropListItem(
//     BuildContext context,
//     Map<String, dynamic> crop,
//     bool isDarkMode,
//   ) {
//     final name = crop['name'] ?? 'Unnamed Crop';
//     final status = crop['status'] ?? 'seedling';
//     final variety = crop['variety'] ?? 'Unknown';
//     final category = crop['category'] ?? 'vegetable';
//     final progress = (crop['progress'] as num?)?.toDouble() ?? 0.0;
//     final imageUrl = crop['image_url'];
//     final quantity = crop['quantity'] ?? 1;
//     final quantityUnit = crop['quantity_unit'] ?? 'plants';
//     final plantingDate = crop['planting_date'] != null
//         ? DateTime.parse(crop['planting_date'])
//         : null;
    
//     final dateStr = plantingDate != null
//         ? '${_getMonthAbbr(plantingDate.month)} ${plantingDate.day}'
//         : 'Not set';
    
//     final statusColor = _getStatusColor(status);
//     final statusLabel = _getStatusLabel(status);

//     return GestureDetector(
//       onTap: () async {
//         final result = await Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => UpdateCropStatusScreen(
//               cropData: crop,
//             ),
//           ),
//         );
        
//         if (result == true) {
//           // Crop was updated, refresh the list
//           await _refreshCrops();
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFF0F2F1),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Crop Image
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: const Color(0xFF19E6A2).withOpacity(0.1),
//                 image: imageUrl != null
//                     ? DecorationImage(
//                         image: NetworkImage(imageUrl),
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//               ),
//               child: imageUrl == null
//                   ? const Center(
//                       child: Icon(
//                         Icons.eco,
//                         color: Color(0xFF19E6A2),
//                         size: 32,
//                       ),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 16),
            
//             // Crop Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           name,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: isDarkMode ? Colors.white : const Color(0xFF0E1B17),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Color(int.parse(statusColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           '$quantity $quantityUnit',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             color: Color(int.parse(statusColor.replaceFirst('#', '0xFF'))),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     statusLabel,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Color(int.parse(statusColor.replaceFirst('#', '0xFF'))),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${category.capitalize()} • $variety',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: const Color(0xFF4E977F),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Planted: $dateStr',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: isDarkMode ? Colors.white38 : const Color(0xFF808080),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Progress and Chevron
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFF0F2F1),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       child: FractionallySizedBox(
//                         alignment: Alignment.centerLeft,
//                         widthFactor: progress / 100,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF19E6A2),
//                             borderRadius: BorderRadius.circular(3),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${progress.toInt()}%',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: isDarkMode ? const Color(0xFFA0B8AF) : const Color(0xFF0E1B17),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Icon(
//                   Icons.chevron_right,
//                   color: Color(0xFF4E977F),
//                   size: 20,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getMonthAbbr(int month) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return months[month - 1];
//   }
// }

// // Helper extension for string capitalization
// extension StringExtension on String {
//   String capitalize() {
//     if (isEmpty) return this;
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }



// import 'package:flutter/material.dart';
// import 'update_crop_status_screen.dart';

// class AllCropsScreen extends StatefulWidget {
//   const AllCropsScreen({Key? key}) : super(key: key);

//   @override
//   State<AllCropsScreen> createState() => _AllCropsScreenState();
// }

// class _AllCropsScreenState extends State<AllCropsScreen> {
//   int _selectedFilterIndex = 0;
//   final TextEditingController _searchController = TextEditingController();
  
//   final List<Map<String, dynamic>> _filters = [
//     {'label': 'All', 'selected': true},
//     {'label': 'Vegetables', 'selected': false},
//     {'label': 'Fruits', 'selected': false},
//     {'label': 'Herbs', 'selected': false},
//   ];
  
//   final List<Map<String, dynamic>> _crops = [
//     {
//       'name': 'Roma Tomato',
//       'status': 'Flowering',
//       'variety': 'Heirloom',
//       'date': 'Oct 12',
//       'progress': 0.65,
//       'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA9N54TsJaVZHQ5lGgO1_sKQ9711QIsnF1mDO5s993Mx7xVyQSSxeTqZfqZDDVjHKEqn9aZWWV2F9zwhDBUZfB7__DoMwpnfMrmTViTlmsTVHyxMGHTJrazlLjqy5Mf-PamFm-_ClET52cXbhTlA6C-uvY8DOGSqgOk9UGnfIvP3Ka2_D0PfZtJt4b3Y_z5PA_z6W8HxCGX2XDF-NsdTBMociTlH8Av66M3osybrKbxC-ayVD9USOX0TZ99Y2dCh4CdiXyUhuS-rTAV',
//     },
//     {
//       'name': 'Sweet Basil',
//       'status': 'Seedling',
//       'variety': 'Genovese',
//       'date': 'Nov 02',
//       'progress': 0.20,
//       'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCDoThPMZBjkVCmF3O43MG852mu0Bu7gizrW76bWAKr9S67HVx5mBYbPiJ8c0tUAZ5aKXkz4KhXq04EmZugiAe0Bdo33gdb-Cy58CxREiJS41UebG6RYKTbSJGbbyxwwYgWgnrh_j0weD39fAhSjmmogDpO74Wqh7Jnef2MoZVpBDj0DtUwrhoEjHpkBiLwrgl9S_fJ-EdrMckBONi1Mxe3-B5HYXRiwT3sdQV_kxS6FtE6e8uSjZML3mn8qEBFEB7kcCSmM5l6UYD6',
//     },
//     {
//       'name': 'Nantes Carrot',
//       'status': 'Fruiting',
//       'variety': 'Early Coreless',
//       'date': 'Sep 15',
//       'progress': 0.85,
//       'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD69RpDJ2bnteXZ3QCc1v5Ph2Dn9hlO0XXfCel6Y7csW2yF8bL2zT9NQ-e3L94cfcbfhM-RjEHdfll4eDeaPZ9RVkihBBQXBGXS2oN2uIg1NBwdcTihHFNZVF072U92Js6jK4SXuYgSGIQeKGJPq5czdTpzGBVX4pMqMJZ70Sy6-zOLxbWkgfHO-Zem8D3tsK9FvU9su7tLsX_q8s3abjz2KYl_H0hdmpmd-4cKv6_yPdEbUcPMTDL4PxVmC9YtuVIFmRDaxl6QsGGr',
//     },
//     {
//       'name': 'Curly Kale',
//       'status': 'Vegetative',
//       'variety': 'Lacinato',
//       'date': 'Oct 28',
//       'progress': 0.45,
//       'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAbEinNx21fIZOVTiRQNeotVHrfLMnQ2T7GUJJwxO6RYzakfaNSnuLIKr8frx0b3z5zVaquUAsr6yDnuDKjK-DbcnFj96Z5qeIkxbBA1UqX9tC1w0gTaxFPf6FLGOFGgJxuujLYgDx3Cu2e_LNHcEotu3wlNXUZBGfTXs_o-FP5O2aitUVtjiGJhEqIpPRiCpxR5vq9bw_V-R4M5L86JGn9CwucV6jbeFlZwk1zKHPTGapNUByoBJyr0wkob5e1TydeQEBAZYgNIBpJ',
//     },
//   ];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDarkMode ? Color(0xFF11211C) : Color(0xFFF6F8F7),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top App Bar
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: isDarkMode 
//                     ? Color(0xFF11211C).withOpacity(0.8)
//                     : Color(0xFFF6F8F7).withOpacity(0.8),
//                 border: Border(
//                   bottom: BorderSide(
//                     color: isDarkMode ? Color(0xFF1A2B26) : Color(0xFFE5E7EB),
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Back Button
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(
//                       Icons.arrow_back_ios,
//                       color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
//                       size: 20,
//                     ),
//                   ),
                  
//                   // Title
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         'My Crops List',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   // Add Button
//                   IconButton(
//                     onPressed: () {
//                       // TODO: Navigate to add crop screen
//                     },
//                     icon: Icon(
//                       Icons.add_circle,
//                       color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
//                       size: 24,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Search Bar
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(left: 16),
//                       child: Icon(
//                         Icons.search,
//                         color: Color(0xFF4E977F),
//                         size: 20,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search your crops',
//                           hintStyle: TextStyle(color: Color(0xFF4E977F)),
//                           border: InputBorder.none,
//                         ),
//                         style: TextStyle(
//                           color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Filter Chips
//             SizedBox(
//               height: 40,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: _filters.length,
//                 itemBuilder: (context, index) {
//                   final filter = _filters[index];
//                   final isSelected = _selectedFilterIndex == index;
                  
//                   return Padding(
//                     padding: EdgeInsets.only(right: 12),
//                     child: Material(
//                       color: isSelected
//                           ? Color(0xFF19E6A2)
//                           : (isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white),
//                       borderRadius: BorderRadius.circular(20),
//                       child: InkWell(
//                         onTap: () {
//                           setState(() {
//                             _selectedFilterIndex = index;
//                           });
//                         },
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             border: isSelected
//                                 ? null
//                                 : Border.all(
//                                     color: isDarkMode ? Color(0xFF2A3A35) : Color(0xFFE5E7EB),
//                                   ),
//                           ),
//                           child: Text(
//                             filter['label'],
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: isSelected
//                                   ? Colors.white
//                                   : (isDarkMode ? Color(0xFFA0B8AF) : Color(0xFF0E1B17)),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Crops List
//             Expanded(
//               child: ListView.builder(
//                 padding: EdgeInsets.all(16),
//                 itemCount: _crops.length,
//                 itemBuilder: (context, index) {
//                   final crop = _crops[index];
                  
//                   return _buildCropListItem(
//                     context,
//                     name: crop['name'],
//                     status: crop['status'],
//                     variety: crop['variety'],
//                     date: crop['date'],
//                     progress: crop['progress'],
//                     imageUrl: crop['image'],
//                     isDarkMode: isDarkMode,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
      
//       // Bottom Navigation Bar
//       bottomNavigationBar: Container(
//         height: 64,
//         decoration: BoxDecoration(
//           color: isDarkMode 
//               ? Colors.black.withOpacity(0.8)
//               : Colors.white.withOpacity(0.8),
//           border: Border(
//             top: BorderSide(
//               color: isDarkMode ? Color(0xFF2A3A35) : Color(0xFFE5E7EB),
//             ),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // My Crops
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.local_florist,
//                   color: Color(0xFF19E6A2),
//                   size: 24,
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'My Crops',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF19E6A2),
//                   ),
//                 ),
//               ],
//             ),
            
//             // Community
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.group,
//                   color: Color(0xFF4E977F),
//                   size: 24,
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Community',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF4E977F),
//                   ),
//                 ),
//               ],
//             ),
            
//             // Market
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.shopping_bag,
//                   color: Color(0xFF4E977F),
//                   size: 24,
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Market',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF4E977F),
//                   ),
//                 ),
//               ],
//             ),
            
//             // Profile
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.person,
//                   color: Color(0xFF4E977F),
//                   size: 24,
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Profile',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF4E977F),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
      
//       // Floating Action Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // TODO: Add new crop
//         },
//         backgroundColor: Color(0xFF19E6A2),
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//           size: 28,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }

//   Widget _buildCropListItem(
//     BuildContext context, {
//     required String name,
//     required String status,
//     required String variety,
//     required String date,
//     required double progress,
//     required String imageUrl,
//     required bool isDarkMode,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => UpdateCropStatusScreen(
//               cropName: name,
//               cropImage: imageUrl,
//               currentStatus: status,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isDarkMode ? Color(0xFF2A3A35) : Color(0xFFF0F2F1),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Crop Image
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: NetworkImage(imageUrl),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             SizedBox(width: 16),
            
//             // Crop Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: isDarkMode ? Colors.white : Color(0xFF0E1B17),
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     status,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF19E6A2),
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Variety: $variety • $date',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF4E977F),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Progress and Chevron
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: isDarkMode ? Color(0xFF2A3A35) : Color(0xFFF0F2F1),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       child: FractionallySizedBox(
//                         alignment: Alignment.centerLeft,
//                         widthFactor: progress,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Color(0xFF19E6A2),
//                             borderRadius: BorderRadius.circular(3),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       '${(progress * 100).toInt()}%',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: isDarkMode ? Color(0xFFA0B8AF) : Color(0xFF0E1B17),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 Icon(
//                   Icons.chevron_right,
//                   color: Color(0xFF4E977F),
//                   size: 20,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
