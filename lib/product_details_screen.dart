import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'messages_screen.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsScreen({
    super.key,
    required this.productData,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ApiService _apiService = ApiService();
  
  // Location related
  GoogleMapController? _mapController;
  LatLng? _pickupLocation;
  LatLng? _userLocation;
  double? _distanceInKm;
  bool _isLoadingLocation = true;
  String? _locationError;
  String? _locationAddress;
  
  // Product data
  late Map<String, dynamic> _productData;
  int _currentQuantity;
  bool _isClaiming = false;

  _ProductDetailsScreenState() : _currentQuantity = 0;

  @override
  void initState() {
    super.initState();
    _productData = widget.productData;
    _currentQuantity = _productData['quantity'] ?? 0;
    _initializeLocation();
    _getAddressFromCoordinates();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // Get pickup location from product data
    final latitude = _productData['latitude'];
    final longitude = _productData['longitude'];
    
    if (latitude != null && longitude != null) {
      setState(() {
        _pickupLocation = LatLng(latitude.toDouble(), longitude.toDouble());
      });
    }
    
    // Get user's current location
    await _getUserLocation();
  }

  Future<void> _getAddressFromCoordinates() async {
    final latitude = _productData['latitude'];
    final longitude = _productData['longitude'];
    
    if (latitude != null && longitude != null) {
      // You can use a geocoding service here
      // For now, use the location_text from database
      setState(() {
        _locationAddress = _productData['location_text'] ?? 'Pickup location';
      });
    }
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permissions are permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      if (_pickupLocation != null && _userLocation != null) {
        _calculateDistance();
        _animateCameraToShowBoth();
      } else if (_pickupLocation != null) {
        _animateCameraToPickup();
      }

    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _locationError = 'Could not get your location';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _calculateDistance() {
    if (_pickupLocation == null || _userLocation == null) return;

    double distanceInMeters = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      _pickupLocation!.latitude,
      _pickupLocation!.longitude,
    );

    setState(() {
      _distanceInKm = distanceInMeters / 1000;
    });
  }

  void _animateCameraToShowBoth() {
    if (_mapController == null) return;
    if (_pickupLocation == null || _userLocation == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _pickupLocation!.latitude < _userLocation!.latitude 
            ? _pickupLocation!.latitude 
            : _userLocation!.latitude,
        _pickupLocation!.longitude < _userLocation!.longitude 
            ? _pickupLocation!.longitude 
            : _userLocation!.longitude,
      ),
      northeast: LatLng(
        _pickupLocation!.latitude > _userLocation!.latitude 
            ? _pickupLocation!.latitude 
            : _userLocation!.latitude,
        _pickupLocation!.longitude > _userLocation!.longitude 
            ? _pickupLocation!.longitude 
            : _userLocation!.longitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _animateCameraToPickup() {
    if (_mapController == null || _pickupLocation == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(_pickupLocation!, 15),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_pickupLocation != null && _userLocation != null) {
      _animateCameraToShowBoth();
    } else if (_pickupLocation != null) {
      _animateCameraToPickup();
    }
  }

  Future<void> _openInMaps() async {
    if (_pickupLocation == null) return;

    final url = 'https://www.google.com/maps/search/?api=1&query=${_pickupLocation!.latitude},${_pickupLocation!.longitude}';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _claimItem() async {
    if (_currentQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is no longer available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isClaiming = true;
    });

    try {
      final newQuantity = _currentQuantity - 1;
      
      final result = await _apiService.updateSharedItemQuantity(
        _productData['id'],
        newQuantity,
      );

      if (result['success'] == true) {
        setState(() {
          _currentQuantity = newQuantity;
          _productData['quantity'] = newQuantity;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully claimed! ${newQuantity > 0 ? '$newQuantity left' : 'Last item claimed'}'),
            backgroundColor: Colors.green,
          ),
        );

        if (newQuantity == 0) {
          await _apiService.updateSharedItemStatus(
            _productData['id'],
            'claimed',
          );
        }
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isClaiming = false;
      });
    }
  }

  void _navigateToMessages() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final ownerId = _productData['user_id'];
    
    if (currentUser != null && ownerId != null) {
      if (currentUser['id'] == ownerId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is your own listing'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagesScreen(
            recipientId: ownerId,
            recipientName: _productData['users']?['name'] ?? 'Gardener',
            recipientImage: _productData['users']?['profile_image_url'],
            productId: _productData['id'],
            productName: _productData['name'],
            productStatus: _productData['status'],
            productQuantity: _currentQuantity,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to send messages'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _getDistanceText() {
    if (_distanceInKm == null) return 'Distance unknown';
    if (_distanceInKm! < 1) {
      return '${(_distanceInKm! * 1000).toStringAsFixed(0)} m away';
    }
    return '${_distanceInKm!.toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final imageUrl = _productData['image_url'] ?? 
                     (_productData['imageUrl'] ?? 
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuDpxtSHzBQyEV3GHn4NJkaTgBDJvhkEmCPE_fYJKhG9nq3CdJ8RU3QCqpXLtCOQ0icow0WTwxn7XXJ8jSbNHXkXZMVCyyETaL_dqDF1qohnoQyLQCJNBbBZzouqvthS4kIwmme_0n_kylD71ANsa-Skd2viP8puRco7WpiL_tDd4IaJGiS7hwFo3XL2PzoEIb37olQn2rW5s9WWiek2L7tIkKyg_AWACHrxMui4OL7w74QJq0LtcyXVlPEXyZ64Nk_redTn5MvsYrCs');
    
    final name = _productData['name'] ?? 'Fresh Produce';
    final description = _productData['description'] ?? 'Freshly harvested from a local garden.';
    final quantityUnit = _productData['quantity_unit'] ?? 'lbs';
    final itemLeftText = _currentQuantity == 0 ? 'Claimed' : '$_currentQuantity $quantityUnit left';
    
    final userData = _productData['users'] ?? {};
    final userName = userData['name'] ?? 'Local Gardener';
    final userImage = userData['profile_image_url'] ?? '';
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A2421) : const Color(0xFFF9F8F6),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero Image Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF39AC86).withOpacity(0.1),
                            child: const Center(
                              child: Icon(
                                Icons.eco,
                                size: 64,
                                color: Color(0xFF39AC86),
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Info Card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, -80, 16, 0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF25322E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDarkMode 
                          ? const Color(0xFF3A4A44) 
                          : const Color(0xFFF0F2F1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF39AC86).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _productData['status'] == 'available' && _currentQuantity > 0
                                    ? 'Freshly Harvested' 
                                    : _productData['status'] ?? 'Available',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF39AC86),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Text(
                              itemLeftText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _currentQuantity == 0 
                                    ? Colors.grey 
                                    : const Color(0xFFE59866),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF101816),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTag('Organic', Icons.eco),
                              const SizedBox(width: 8),
                              _buildTag('Pesticide Free', Icons.check_circle),
                              const SizedBox(width: 8),
                              _buildTag('Today', Icons.schedule),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Divider(
                          color: isDarkMode 
                              ? const Color(0xFF3A4A44) 
                              : const Color(0xFFF0F2F1),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: _navigateToMessages,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF39AC86).withOpacity(0.3),
                                    width: 2,
                                  ),
                                  image: userImage.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(userImage),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {},
                                        )
                                      : null,
                                ),
                                child: userImage.isEmpty 
                                    ? const Icon(Icons.person, color: Color(0xFF39AC86))
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode 
                                          ? Colors.white 
                                          : const Color(0xFF101816),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '4.9 ★ (120 shares)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF5C8A7A),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            GestureDetector(
                              onTap: _navigateToMessages,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? const Color(0xFF2D3A35) 
                                      : const Color(0xFFF9F8F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Message',
                                  style: TextStyle(
                                    color: Color(0xFF39AC86),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Description Section
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book,
                            color: Color(0xFF39AC86),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Garden Story',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF101816),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode 
                              ? const Color(0xFFA1B8B0) 
                              : const Color(0xFF5C8A7A),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF39AC86).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF39AC86).withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF39AC86).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.public,
                                color: Color(0xFF39AC86),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sustainability Impact',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF39AC86),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Sourcing this locally saves ~1.2kg of CO2 transport emissions.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF39AC86),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_productData['pickup_instructions'] != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE59866).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE59866).withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE59866).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFE59866),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pickup Instructions',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE59866),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _productData['pickup_instructions'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFE59866),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Location Section with Interactive Map
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF39AC86),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pickup Location',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode 
                                      ? Colors.white 
                                      : const Color(0xFF101816),
                                ),
                              ),
                            ],
                          ),
                          if (_distanceInKm != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF39AC86).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getDistanceText(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF39AC86),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Location Address
                      if (_locationAddress != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39AC86).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_city,
                                size: 16,
                                color: Color(0xFF39AC86),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _locationAddress!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5C8A7A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Interactive Map
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF39AC86).withOpacity(0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              if (_pickupLocation != null)
                                GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  initialCameraPosition: CameraPosition(
                                    target: _pickupLocation!,
                                    zoom: 14,
                                  ),
                                  markers: {
                                    if (_pickupLocation != null)
                                      Marker(
                                        markerId: const MarkerId('pickup-location'),
                                        position: _pickupLocation!,
                                        infoWindow: InfoWindow(
                                          title: 'Pickup Location',
                                          snippet: _locationAddress,
                                        ),
                                        icon: BitmapDescriptor.defaultMarkerWithHue(
                                          BitmapDescriptor.hueGreen,
                                        ),
                                      ),
                                    if (_userLocation != null)
                                      Marker(
                                        markerId: const MarkerId('user-location'),
                                        position: _userLocation!,
                                        infoWindow: const InfoWindow(
                                          title: 'Your Location',
                                        ),
                                        icon: BitmapDescriptor.defaultMarkerWithHue(
                                          BitmapDescriptor.hueBlue,
                                        ),
                                      ),
                                  },
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: false,
                                  zoomControlsEnabled: true,
                                  compassEnabled: true,
                                  mapToolbarEnabled: false,
                                )
                              else
                                Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text('Location not available'),
                                  ),
                                ),
                              
                              if (_isLoadingLocation)
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF39AC86),
                                    ),
                                  ),
                                ),

                              // Map Controls
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Column(
                                  children: [
                                    // Zoom In Button
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _mapController?.animateCamera(
                                            CameraUpdate.zoomIn(),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                          color: Color(0xFF39AC86),
                                          size: 20,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                    // Zoom Out Button
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _mapController?.animateCamera(
                                            CameraUpdate.zoomOut(),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Color(0xFF39AC86),
                                          size: 20,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                    // My Location Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: _getUserLocation,
                                        icon: const Icon(
                                          Icons.my_location,
                                          color: Color(0xFF39AC86),
                                          size: 20,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Open in Maps Button
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _openInMaps,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF39AC86),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.directions,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Get Directions',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_locationError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _locationError!,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // Sticky Back Button and Title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const Text(
                    'Produce Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF25322E) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDarkMode 
                        ? const Color(0xFF3A4A44) 
                        : const Color(0xFFF0F2F1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contribution',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C8A7A),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '\$0.00',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101816),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _currentQuantity == 0
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Claimed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _isClaiming ? null : _claimItem,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _isClaiming 
                                    ? Colors.grey 
                                    : const Color(0xFF39AC86),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isClaiming ? null : [
                                  BoxShadow(
                                    color: const Color(0xFF39AC86).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isClaiming
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_basket,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Claim Produce',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF39AC86).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF39AC86),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF39AC86),
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:provider/provider.dart';
// import 'messages_screen.dart';
// import 'providers/auth_provider.dart';
// import 'services/api_service.dart';

// class ProductDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> productData;

//   const ProductDetailsScreen({
//     super.key,
//     required this.productData,
//   });

//   @override
//   State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
// }

// class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
//   final ApiService _apiService = ApiService();
  
//   // Location related
//   GoogleMapController? _mapController;
//   LatLng? _pickupLocation;
//   LatLng? _userLocation;
//   double? _distanceInKm;
//   bool _isLoadingLocation = true;
//   String? _locationError;
  
//   // Product data
//   late Map<String, dynamic> _productData;
//   int _currentQuantity;
//   bool _isClaiming = false;
//   bool _isUpdating = false;

//   _ProductDetailsScreenState() : _currentQuantity = 0;

//   @override
//   void initState() {
//     super.initState();
//     _productData = widget.productData;
//     _currentQuantity = _productData['quantity'] ?? 0;
//     _initializeLocation();
//   }

//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeLocation() async {
//     // Get pickup location from product data
//     final latitude = _productData['latitude'];
//     final longitude = _productData['longitude'];
    
//     if (latitude != null && longitude != null) {
//       setState(() {
//         _pickupLocation = LatLng(latitude.toDouble(), longitude.toDouble());
//       });
//     }
    
//     // Get user's current location
//     await _getUserLocation();
//   }

//   Future<void> _getUserLocation() async {
//     setState(() {
//       _isLoadingLocation = true;
//       _locationError = null;
//     });

//     try {
//       // Check permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
      
//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _locationError = 'Location permissions are permanently denied';
//           _isLoadingLocation = false;
//         });
//         return;
//       }

//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );

//       setState(() {
//         _userLocation = LatLng(position.latitude, position.longitude);
//       });

//       // Calculate distance if both locations are available
//       if (_pickupLocation != null && _userLocation != null) {
//         _calculateDistance();
//       }

//       // Animate camera to show both locations
//       _animateCameraToShowBoth();

//     } catch (e) {
//       print('Error getting location: $e');
//       setState(() {
//         _locationError = 'Could not get your location';
//       });
//     } finally {
//       setState(() {
//         _isLoadingLocation = false;
//       });
//     }
//   }

//   void _calculateDistance() {
//     if (_pickupLocation == null || _userLocation == null) return;

//     double distanceInMeters = Geolocator.distanceBetween(
//       _userLocation!.latitude,
//       _userLocation!.longitude,
//       _pickupLocation!.latitude,
//       _pickupLocation!.longitude,
//     );

//     setState(() {
//       _distanceInKm = distanceInMeters / 1000;
//     });
//   }

//   void _animateCameraToShowBoth() {
//     if (_mapController == null) return;
//     if (_pickupLocation == null && _userLocation == null) return;

//     if (_pickupLocation != null && _userLocation != null) {
//       // Show both locations
//       LatLngBounds bounds = LatLngBounds(
//         southwest: LatLng(
//           _pickupLocation!.latitude < _userLocation!.latitude 
//               ? _pickupLocation!.latitude 
//               : _userLocation!.latitude,
//           _pickupLocation!.longitude < _userLocation!.longitude 
//               ? _pickupLocation!.longitude 
//               : _userLocation!.longitude,
//         ),
//         northeast: LatLng(
//           _pickupLocation!.latitude > _userLocation!.latitude 
//               ? _pickupLocation!.latitude 
//               : _userLocation!.latitude,
//           _pickupLocation!.longitude > _userLocation!.longitude 
//               ? _pickupLocation!.longitude 
//               : _userLocation!.longitude,
//         ),
//       );

//       _mapController!.animateCamera(
//         CameraUpdate.newLatLngBounds(bounds, 50),
//       );
//     } else if (_pickupLocation != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLngZoom(_pickupLocation!, 15),
//       );
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     _animateCameraToShowBoth();
//   }

//   Future<void> _openInMaps() async {
//     if (_pickupLocation == null) return;

//     final url = 'https://www.google.com/maps/search/?api=1&query=${_pickupLocation!.latitude},${_pickupLocation!.longitude}';
    
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Could not open maps'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _claimItem() async {
//     if (_currentQuantity <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('This item is no longer available'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isClaiming = true;
//     });

//     try {
//       // Update quantity in database
//       final newQuantity = _currentQuantity - 1;
      
//       // You'll need to add this method to your ApiService
//       final result = await _apiService.updateSharedItemQuantity(
//         _productData['id'],
//         newQuantity,
//       );

//       if (result['success'] == true) {
//         setState(() {
//           _currentQuantity = newQuantity;
//           _productData['quantity'] = newQuantity;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Successfully claimed! ${newQuantity > 0 ? '$newQuantity left' : 'Last item claimed'}'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // If no items left, you might want to update the status
//         if (newQuantity == 0) {
//           await _apiService.updateSharedItemStatus(
//             _productData['id'],
//             'claimed',
//           );
//         }
//       } else {
//         throw Exception(result['error']);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to claim: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isClaiming = false;
//       });
//     }
//   }

//   void _navigateToMessages() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final currentUser = authProvider.currentUser;
//     final ownerId = _productData['user_id'];
    
//     if (currentUser != null && ownerId != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MessagesScreen(
//             recipientId: ownerId,
//             recipientName: _productData['users']?['name'] ?? 'Gardener',
//             recipientImage: _productData['users']?['profile_image_url'],
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please login to send messages'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }

//   String _getDistanceText() {
//     if (_distanceInKm == null) return 'Distance unknown';
//     if (_distanceInKm! < 1) {
//       return '${(_distanceInKm! * 1000).toStringAsFixed(0)} m away';
//     }
//     return '${_distanceInKm!.toStringAsFixed(1)} km away';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     // Extract data safely with fallbacks
//     final imageUrl = _productData['image_url'] ?? 
//                      (_productData['imageUrl'] ?? 
//                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDpxtSHzBQyEV3GHn4NJkaTgBDJvhkEmCPE_fYJKhG9nq3CdJ8RU3QCqpXLtCOQ0icow0WTwxn7XXJ8jSbNHXkXZMVCyyETaL_dqDF1qohnoQyLQCJNBbBZzouqvthS4kIwmme_0n_kylD71ANsa-Skd2viP8puRco7WpiL_tDd4IaJGiS7hwFo3XL2PzoEIb37olQn2rW5s9WWiek2L7tIkKyg_AWACHrxMui4OL7w74QJq0LtcyXVlPEXyZ64Nk_redTn5MvsYrCs');
    
//     final name = _productData['name'] ?? 
//                  (_productData['title'] ?? 'Fresh Produce');
    
//     final description = _productData['description'] ?? 
//                        'Freshly harvested from a local garden.';
    
//     final quantityUnit = _productData['quantity_unit'] ?? 'lbs';
//     final itemLeftText = _currentQuantity == 0 
//         ? 'Claimed' 
//         : '$_currentQuantity $quantityUnit left';
    
//     final userData = _productData['users'] ?? {};
//     final userName = userData['name'] ?? 
//                      (_productData['user'] ?? 'Local Gardener');
//     final userImage = userData['profile_image_url'] ?? 
//                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCS0jHPAmw5dMiQaK1bHEZcrto0FpYkJLEnjT6LV8uSWLCo5bUsK60px9QgtiDoQ7yPHK7w7ZLGMwlKDmnn8PX5PpG5K7SY6xFwWaSe7ljAu0ns8mkSx2Az9A3XRjE3qkuMtqijirhcDe9nsCmNsqRAImmu_F3q-uHlfHgf7wXW7wQ0zmONoWgpqAPLNkkFAa8REN8_t8Uev_HVtzsn_tTVH7jKyA28BKdKkyR_ix0nHaW9a294rw968H5orwER4gi6femx3_NxRZWC';
    
//     final locationText = _productData['location_text'] ?? 
//                          (_productData['location'] ?? 'Nearby');

//     return Scaffold(
//       backgroundColor: isDarkMode ? const Color(0xFF1A2421) : const Color(0xFFF9F8F6),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Hero Image Section
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.45,
//                   width: double.infinity,
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: const Color(0xFF39AC86).withOpacity(0.1),
//                         child: const Center(
//                           child: Icon(
//                             Icons.eco,
//                             size: 64,
//                             color: Color(0xFF39AC86),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 // Floating Info Card
//                 Container(
//                   margin: const EdgeInsets.fromLTRB(16, -80, 16, 0),
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? const Color(0xFF25322E) : Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 20,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: isDarkMode 
//                           ? const Color(0xFF3A4A44) 
//                           : const Color(0xFFF0F2F1),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         // Status and Quantity
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF39AC86).withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 _productData['status'] == 'available' && _currentQuantity > 0
//                                     ? 'Freshly Harvested' 
//                                     : _productData['status'] ?? 'Available',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF39AC86),
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               itemLeftText,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: _currentQuantity == 0 
//                                     ? Colors.grey 
//                                     : const Color(0xFFE59866),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         // Title
//                         Text(
//                           name,
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                             height: 1.2,
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         // Tags
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Row(
//                             children: [
//                               _buildTag('Organic', Icons.eco),
//                               const SizedBox(width: 8),
//                               _buildTag('Pesticide Free', Icons.check_circle),
//                               const SizedBox(width: 8),
//                               _buildTag('Today', Icons.schedule),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 24),

//                         // Divider
//                         Divider(
//                           color: isDarkMode 
//                               ? const Color(0xFF3A4A44) 
//                               : const Color(0xFFF0F2F1),
//                         ),

//                         const SizedBox(height: 20),

//                         // User Info
//                         Row(
//                           children: [
//                             // User Avatar
//                             GestureDetector(
//                               onTap: _navigateToMessages,
//                               child: Container(
//                                 width: 48,
//                                 height: 48,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(24),
//                                   border: Border.all(
//                                     color: const Color(0xFF39AC86).withOpacity(0.3),
//                                     width: 2,
//                                   ),
//                                   image: DecorationImage(
//                                     image: NetworkImage(userImage),
//                                     fit: BoxFit.cover,
//                                     onError: (exception, stackTrace) {},
//                                   ),
//                                 ),
//                                 child: userImage.isEmpty ? const Icon(Icons.person) : null,
//                               ),
//                             ),

//                             const SizedBox(width: 12),

//                             // User Info
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     userName,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: isDarkMode 
//                                           ? Colors.white 
//                                           : const Color(0xFF101816),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   const Text(
//                                     '4.9 ★ (120 shares)',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Color(0xFF5C8A7A),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // Message Button
//                             GestureDetector(
//                               onTap: _navigateToMessages,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 10,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: isDarkMode 
//                                       ? const Color(0xFF2D3A35) 
//                                       : const Color(0xFFF9F8F6),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   'Message',
//                                   style: TextStyle(
//                                     color: Color(0xFF39AC86),
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Description Section
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.menu_book,
//                             color: Color(0xFF39AC86),
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Garden Story',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 16),

//                       Text(
//                         description,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: isDarkMode 
//                               ? const Color(0xFFA1B8B0) 
//                               : const Color(0xFF5C8A7A),
//                           height: 1.5,
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Sustainability Impact
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF39AC86).withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: const Color(0xFF39AC86).withOpacity(0.1),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF39AC86).withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Icon(
//                                 Icons.public,
//                                 color: Color(0xFF39AC86),
//                                 size: 20,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Sustainability Impact',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF39AC86),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Sourcing this locally saves ~1.2kg of CO2 transport emissions.',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: const Color(0xFF39AC86).withOpacity(0.8),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Pickup Instructions if available
//                       if (_productData['pickup_instructions'] != null) ...[
//                         const SizedBox(height: 20),
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFE59866).withOpacity(0.05),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: const Color(0xFFE59866).withOpacity(0.1),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 40,
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFE59866).withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: const Icon(
//                                   Icons.info_outline,
//                                   color: Color(0xFFE59866),
//                                   size: 20,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Pickup Instructions',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFFE59866),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       _productData['pickup_instructions'],
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: const Color(0xFFE59866).withOpacity(0.8),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Location Section
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               const Icon(
//                                 Icons.location_on,
//                                 color: Color(0xFF39AC86),
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Pickup Location',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: isDarkMode 
//                                       ? Colors.white 
//                                       : const Color(0xFF101816),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (_distanceInKm != null)
//                             Text(
//                               _getDistanceText(),
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xFF39AC86),
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                         ],
//                       ),

//                       const SizedBox(height: 8),

//                       // Location Text
//                       Text(
//                         locationText,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF5C8A7A),
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // Map Section
//                       Container(
//                         height: 250,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: const Color(0xFF39AC86).withOpacity(0.3),
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child: Stack(
//                             children: [
//                               // Real Google Map
//                               if (_pickupLocation != null)
//                                 GoogleMap(
//                                   onMapCreated: _onMapCreated,
//                                   initialCameraPosition: CameraPosition(
//                                     target: _pickupLocation!,
//                                     zoom: 14,
//                                   ),
//                                   markers: {
//                                     if (_pickupLocation != null)
//                                       Marker(
//                                         markerId: const MarkerId('pickup-location'),
//                                         position: _pickupLocation!,
//                                         infoWindow: const InfoWindow(
//                                           title: 'Pickup Location',
//                                         ),
//                                         icon: BitmapDescriptor.defaultMarkerWithHue(
//                                           BitmapDescriptor.hueGreen,
//                                         ),
//                                       ),
//                                     if (_userLocation != null)
//                                       Marker(
//                                         markerId: const MarkerId('user-location'),
//                                         position: _userLocation!,
//                                         infoWindow: const InfoWindow(
//                                           title: 'Your Location',
//                                         ),
//                                         icon: BitmapDescriptor.defaultMarkerWithHue(
//                                           BitmapDescriptor.hueBlue,
//                                         ),
//                                       ),
//                                   },
//                                   myLocationEnabled: true,
//                                   myLocationButtonEnabled: false,
//                                   zoomControlsEnabled: false,
//                                   compassEnabled: false,
//                                 )
//                               else
//                                 Container(
//                                   color: Colors.grey[300],
//                                   child: const Center(
//                                     child: Text('Location not available'),
//                                   ),
//                                 ),
                              
//                               // Loading indicator
//                               if (_isLoadingLocation)
//                                 Container(
//                                   color: Colors.black.withOpacity(0.3),
//                                   child: const Center(
//                                     child: CircularProgressIndicator(
//                                       color: Color(0xFF39AC86),
//                                     ),
//                                   ),
//                                 ),

//                               // Open in Maps Button
//                               Positioned(
//                                 bottom: 8,
//                                 right: 8,
//                                 child: GestureDetector(
//                                   onTap: _openInMaps,
//                                   child: Container(
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                       color: isDarkMode 
//                                           ? Colors.black.withOpacity(0.7) 
//                                           : Colors.white.withOpacity(0.9),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: const Icon(
//                                       Icons.open_in_new,
//                                       color: Color(0xFF39AC86),
//                                       size: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       if (_locationError != null) ...[
//                         const SizedBox(height: 8),
//                         Text(
//                           _locationError!,
//                           style: const TextStyle(
//                             color: Colors.orange,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),

//           // Sticky Back Button and Title
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.4),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Back Button
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: isDarkMode 
//                             ? Colors.black.withOpacity(0.5)
//                             : Colors.white.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back_ios_new,
//                         color: Color(0xFF39AC86),
//                         size: 20,
//                       ),
//                     ),
//                   ),

//                   // Title
//                   const Text(
//                     'Produce Details',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.5,
//                     ),
//                   ),

//                   // Share Button
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: isDarkMode 
//                           ? Colors.black.withOpacity(0.5)
//                           : Colors.white.withOpacity(0.8),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.share,
//                       color: Color(0xFF39AC86),
//                       size: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Sticky Bottom Button
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isDarkMode ? const Color(0xFF25322E) : Colors.white,
//                 border: Border(
//                   top: BorderSide(
//                     color: isDarkMode 
//                         ? const Color(0xFF3A4A44) 
//                         : const Color(0xFFF0F2F1),
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Price/Contribution
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Contribution',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF5C8A7A),
//                           letterSpacing: 1,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       const Text(
//                         '\$0.00',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF101816),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(width: 16),

//                   // Claim Button
//                   Expanded(
//                     child: _currentQuantity == 0
//                         ? Container(
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: Colors.grey,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'Claimed',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : GestureDetector(
//                             onTap: _isClaiming ? null : _claimItem,
//                             child: Container(
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: _isClaiming 
//                                     ? Colors.grey 
//                                     : const Color(0xFF39AC86),
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: _isClaiming ? null : [
//                                   BoxShadow(
//                                     color: const Color(0xFF39AC86).withOpacity(0.3),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Center(
//                                 child: _isClaiming
//                                     ? const SizedBox(
//                                         width: 24,
//                                         height: 24,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     : const Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.shopping_basket,
//                                             color: Colors.white,
//                                             size: 20,
//                                           ),
//                                           SizedBox(width: 8),
//                                           Text(
//                                             'Claim Produce',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                               ),
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTag(String text, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFF39AC86).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color(0xFF39AC86),
//             size: 16,
//           ),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF39AC86),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


