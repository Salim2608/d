import 'package:flutter/material.dart';

// PropertyCard is now simplified as wishlist functionality is removed.
// If this card is used elsewhere and needs interaction, it might need to be refactored.
class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> propertyData;

  const PropertyCard({
    super.key,
    required this.propertyData,
    // Removed onRemove callback
  });

  @override
  Widget build(BuildContext context) {
    const Color cardBgColor = Color(0xFF1E293B);
    const Color priceColor = Color(0xFFE11D48);
    const Color detailIconColor = Color(0xFFF59E0B);
    const Color detailTextColor = Colors.white70;
    const Color titleColor = Colors.white;
    const Color addressColor = Colors.white70;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      color: cardBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            propertyData['image'] ?? 'assets/placeholder.jpg',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[800],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[800],
              child: const Center(
                  child: Icon(Icons.broken_image,
                      color: Colors.white54, size: 40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        propertyData['title'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      propertyData['price'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: priceColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: addressColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        propertyData['address'] ?? 'N/A',
                        style: const TextStyle(
                            color: addressColor,
                            fontSize: 12,
                            fontFamily: 'Poppins'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(Icons.square_foot, detailIconColor,
                        propertyData['sqft'] ?? 'N/A', detailTextColor),
                    _buildDetailItem(Icons.king_bed, detailIconColor,
                        '${propertyData['beds'] ?? '?'}', detailTextColor),
                    _buildDetailItem(Icons.bathtub, detailIconColor,
                        '${propertyData['baths'] ?? '?'}', detailTextColor),
                    _buildDetailItem(Icons.directions_car, detailIconColor,
                        '${propertyData['parking'] ?? '?'}', detailTextColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // Removed Stack and Positioned IconButton for delete/remove from wishlist
    );
  }

  Widget _buildDetailItem(
      IconData icon, Color iconColor, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style:
              TextStyle(color: textColor, fontSize: 12, fontFamily: 'Poppins'),
        ),
      ],
    );
  }
}

class PropertyDetailPage extends StatelessWidget {
  final Map<String, dynamic> property;
  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(property['title'] ?? 'Property Details',
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Details for ${property['title'] ?? 'this property'}. Address: ${property['address'] ?? 'N/A'}.',
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
        ),
      ),
    );
  }
}

// Renamed class from ClientWishlistPage to ClientViewPage
class ClientViewPage extends StatefulWidget {
  final String clientName = 'Mouniro';
  final String clientEmail = 'Mouniro@gmail.com';
  final String clientAvatarUrl = 'assets/images/mouniro_avatar.png';

  const ClientViewPage({super.key});

  @override
  State<ClientViewPage> createState() => _ClientViewPageState();
}

// Renamed state class from _ClientWishlistPageState to _ClientViewPageState
class _ClientViewPageState extends State<ClientViewPage> {
  // All wishlist related variables and methods were previously removed.

  @override
  Widget build(BuildContext context) {
    const Color primaryBgColor = Color(0xFF0F172A);
    const Color secondaryBgColor = Color(0xFF1E293B);
    const Color accentColorBlue = Color(0xFF3B82F6);
    // const Color accentColorBrown = Color(0xFF8B5A2B); // No longer used
    const Color accentColorGreen = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        title: const Text(
          'Client Profile',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[800],
                child:
                    const Icon(Icons.person, size: 40, color: Colors.white70),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.clientEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                icon: Icons.message,
                label: 'Message',
                color: accentColorBlue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message action tapped')));
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.call,
                label: 'Call',
                color: accentColorGreen,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Call action tapped')));
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'About',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: secondaryBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'I would like to buy/rent properties...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.8,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
