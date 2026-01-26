// lib/screens/product_details_screen.dart
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  child: Image.network(
                    widget.productData['imageUrl'] ?? 
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDpxtSHzBQyEV3GHn4NJkaTgBDJvhkEmCPE_fYJKhG9nq3CdJ8RU3QCqpXLtCOQ0icow0WTwxn7XXJ8jSbNHXkXZMVCyyETaL_dqDF1qohnoQyLQCJNBbBZzouqvthS4kIwmme_0n_kylD71ANsa-Skd2viP8puRco7WpiL_tDd4IaJGiS7hwFo3XL2PzoEIb37olQn2rW5s9WWiek2L7tIkKyg_AWACHrxMui4OL7w74QJq0LtcyXVlPEXyZ64Nk_redTn5MvsYrCs',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFF39AC86).withOpacity(0.1));
                    },
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
                        // Status and Quantity
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
                              child: const Text(
                                'Freshly Harvested',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF39AC86),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Text(
                              '2 lbs left',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE59866),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          widget.productData['title'] ?? 'Sun-Ripened Roma Tomatoes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF101816),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tags
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

                        // Divider
                        Divider(
                          color: isDarkMode 
                              ? const Color(0xFF3A4A44) 
                              : const Color(0xFFF0F2F1),
                        ),

                        const SizedBox(height: 20),

                        // User Info
                        Row(
                          children: [
                            // User Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF39AC86).withOpacity(0.3),
                                  width: 2,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCS0jHPAmw5dMiQaK1bHEZcrto0FpYkJLEnjT6LV8uSWLCo5bUsK60px9QgtiDoQ7yPHK7w7ZLGMwlKDmnn8PX5PpG5K7SY6xFwWaSe7ljAu0ns8mkSx2Az9A3XRjE3qkuMtqijirhcDe9nsCmNsqRAImmu_F3q-uHlfHgf7wXW7wQ0zmONoWgpqAPLNkkFAa8REN8_t8Uev_HVtzsn_tTVH7jKyA28BKdKkyR_ix0nHaW9a294rw968H5orwER4gi6femx3_NxRZWC',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Elena Garden-Seed',
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

                            // Message Button
                            Container(
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
                        'These Romas were grown in my south-facing backyard patch using compost from our neighborhood program. They\'ve had plenty of sun this week and are perfectly firm, ideal for sauces or fresh salads. Harvested just this morning at 7:00 AM!',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode 
                              ? const Color(0xFFA1B8B0) 
                              : const Color(0xFF5C8A7A),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sustainability Impact
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
                                  Text(
                                    'Sourcing this locally saves ~1.2kg of CO2 transport emissions.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF39AC86).withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Location Section
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
                          Text(
                            '0.8 miles away',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF5C8A7A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Map Section
                      Container(
                        height: 192,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDtlT2mJesD7s8iX89R_GPiN-_w_IGgXPVjnWvUrZj_6Nwx_20exmpachCfDSvdOMx7J8lYB_zFjvSZLzDumUk1LdOIsWFx76qzPf6-MvlJ5pnmVht1QtCAS9E8tu5A06KJbtyepYPiWYZ_9gSOTnrqqvO5W9v-FvxnPn27jYZm4YoqWnLqTC8bajTveD1PGER-wilGvZnP_UdAwrKE1FZpNkosFWfv8se-Xqj2k8gF08nkPGIugtDI0iSy-t2XDy7a-e6O8dhsVYy_',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Pin Marker
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF39AC86),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF39AC86).withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.eco,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: -4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF39AC86),
                                      borderRadius: BorderRadius.circular(1),
                                      transform: Matrix4.rotationZ(45 * 3.1415926535 / 180),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Open in Maps Button
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? Colors.black.withOpacity(0.7) 
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.open_in_new,
                                  color: Color(0xFF39AC86),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom button
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
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.5)
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF39AC86),
                        size: 20,
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    'Produce Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Share Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? Colors.black.withOpacity(0.5)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Color(0xFF39AC86),
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
                  // Price/Contribution
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

                  // Claim Button
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF39AC86).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
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
