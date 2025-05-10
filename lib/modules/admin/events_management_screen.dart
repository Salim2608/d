import 'dart:math';

import 'package:darlink/shared/widgets/card/event_card.dart';
import 'package:flutter/material.dart';

// Sample data (keep or replace as needed)
final List<Map<String, String>> sampleManagedEvents = [
  {
    'id': '1',
    'title': 'Book Fair',
    'date': 'May 15, 2025',
    'location': 'Beirut, Biel',
    'description': 'Come explore thousands of books...',
    'image':
        'https://www.globaltimes.cn/Portals/0/attachment/2022/2022-11-13/1bc337f2-f660-4614-b897-58bf1498a6e5.jpeg'
  },
  {
    'id': '3',
    'title': 'Let\'s Walk in a Brighter Beirut',
    'date': 'May 26, 2025',
    'location': 'Corniche Ain El Mraisseh',
    'description': 'Join us for a walk...',
    'image':
        'https://images-ihjoz-com.s3.amazonaws.com/events/cover/6964/event_cover_WhatsApp_Image_2023-04-27_at_12.18.09_PM.jpg'
  },
];

@override
Widget build(BuildContext context) {
  return Card(
    elevation: 6,
    margin: const EdgeInsets.only(bottom: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    clipBehavior: Clip.antiAlias,
    color: const Color(0xFF1E293B),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(
              event: {
                'id': '1',
                'title': 'Book Fair',
                'date': 'May 15, 2025',
                'location': 'Beirut, Biel',
                'description': 'Come explore thousands of books...',
                'image':
                    'https://www.globaltimes.cn/Portals/0/attachment/2022/2022-11-13/1bc337f2-f660-4614-b897-58bf1498a6e5.jpeg'
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: 100,
                //tag: '${eventData['id']}_image',
                child: Image.network(
                  "imageUrl",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white70)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.jpg', // Use local placeholder
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.7)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "here must be a title ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text("21/12/2023",
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Poppins')),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Here must be a location",
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Poppins'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// EventDetailPage remains the same as before (or use the one from events_page.dart)
class EventDetailPage extends StatelessWidget {
  final Map<String, String> event;
  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(event['title'] ?? 'Event Details',
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: '${event['id']}_image',
              child: Image.network(
                event['image'] ?? '',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: const Color(0xFF1E293B),
                  child: const Center(
                      child: Text('Image not available',
                          style: TextStyle(
                              color: Colors.white70, fontFamily: 'Poppins'))),
                ),
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: const Color(0xFF1E293B),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event['title'] ?? '',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(event['date'] ?? '',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(event['location'] ?? '',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                            fontSize: 14))),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            Text(
              'Description',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            Text(
              event['description'] ?? 'No description available.',
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class EventManagerProfilePage extends StatelessWidget {
  final String managerName = 'Ahmad Nasser';
  final String managerEmail = 'ahmad.nasser@events.com';
  final String managerAvatarUrl = 'assets/images/black.png';
  final List<Map<String, String>> managedEvents = sampleManagedEvents;

  EventManagerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryBgColor = Color(0xFF0F172A);
    const Color secondaryBgColor = Color(0xFF1E293B);
    const Color accentColorBlue = Color(0xFF3B82F6);
    const Color accentColorBrown = Color(0xFF8B5A2B);
    const Color accentColorGreen = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        title: const Text(
          'Event Manager Profile',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: secondaryBgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align items vertically
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[800],
                backgroundImage: AssetImage(managerAvatarUrl),
                onBackgroundImageError: (exception, stackTrace) {},
                child: managerAvatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                // Use Expanded to prevent overflow if name is long
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for Name (Edit Button Removed)
                    Text(
                      managerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      overflow: TextOverflow.ellipsis, // Handle long names
                    ),
                    const SizedBox(height: 4),
                    Text(
                      managerEmail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons (Message, Schedule, Call)
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
                icon: Icons.schedule,
                label: 'Schedule',
                color: accentColorBrown,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule action tapped')));
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

          // Managed Events Section
          const Text(
            'Managed Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          if (managedEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'No events managed by this user.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: managedEvents.length,
              itemBuilder: (context, index) {
                final event = managedEvents[index];
                return EventCard(
                  title: event['title']!,
                  date: event['date']!,
                  location: event['location']!,
                  imageData: "asdfasdf",
                );
              },
            ),
          const SizedBox(height: 20), // Add some bottom padding
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
        width: MediaQuery.of(context).size.width /
            3.5, // Adjusted width for three buttons
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
