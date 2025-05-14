import 'package:flutter/material.dart';

class ClientViewPage extends StatefulWidget {
  final String clientName = 'Mouniro';
  final String clientEmail = 'Mouniro@gmail.com';
  final String clientAvatarUrl = 'assets/images/mouniro_avatar.png';

  const ClientViewPage({Key? key}) : super(key: key);

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
