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
  // SAFE EXTRACTION with null checks
  final String name = crop['name']?.toString() ?? 'Unnamed Crop';
  final String status = crop['status']?.toString() ?? 'seedling';
  final String variety = crop['variety']?.toString() ?? 'Unknown';
  final String category = crop['category']?.toString() ?? 'vegetable';
  final double progress = (crop['progress'] as num?)?.toDouble() ?? 0.0;
  final String? imageUrl = crop['image_url']?.toString();
  final int quantity = (crop['quantity'] as num?)?.toInt() ?? 1;
  final String quantityUnit = crop['quantity_unit']?.toString() ?? 'plants';
  
  DateTime? plantingDate;
  try {
    plantingDate = crop['planting_date'] != null 
        ? DateTime.parse(crop['planting_date']) 
        : null;
  } catch (e) {
    plantingDate = null;
  }
  
  final String dateStr = plantingDate != null
      ? '${_getMonthAbbr(plantingDate.month)} ${plantingDate.day}'
      : 'Not set';
  
  final String statusColor = _getStatusColor(status);
  final String statusLabel = _getStatusLabel(status);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDarkMode ? const Color(0xFF2A3A35) : const Color(0xFFF0F2F1),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SIMPLE IMAGE CONTAINER
        Container(
          width: 72,
          height: 72,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF19E6A2).withOpacity(0.1),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? _buildNetworkImage(imageUrl)
              : const Center(
                  child: Icon(
                    Icons.eco,
                    color: Color(0xFF19E6A2),
                    size: 32,
                  ),
                ),
        ),
        
        // DETAILS
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse(statusColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 2),
              Text(
                '${_capitalize(category)} • $variety',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF4E977F),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Planted: $dateStr',
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkMode ? Colors.white38 : const Color(0xFF808080),
                ),
              ),
              const SizedBox(height: 8),
              
              // PROGRESS BAR
              Row(
                children: [
                  Expanded(
                    child: Container(
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
            ],
          ),
        ),
        
        // CHEVRON
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(
            Icons.chevron_right,
            color: const Color(0xFF4E977F),
            size: 20,
          ),
        ),
      ],
    ),
  );
}

Widget _buildNetworkImage(String imageUrl) {
  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    width: 72,
    height: 72,
    errorBuilder: (context, error, stackTrace) {
      print('❌ Image error: $error');
      return Container(
        color: const Color(0xFF19E6A2).withOpacity(0.1),
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: Color(0xFF19E6A2),
            size: 32,
          ),
        ),
      );
    },
  );
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}

// Helper extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}



