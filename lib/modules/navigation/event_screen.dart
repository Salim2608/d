import 'dart:convert';
import 'package:darlink/modules/upload/announce_event_screen.dart';
import 'package:darlink/modules/detail/event_detail_screen.dart';
import 'package:darlink/shared/widgets/card/event_card.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:darlink/constants/Database_url.dart' as mg;

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final eventData = await collect_info_Events();
      setState(() {
        events = eventData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: ${e.toString()}')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> collect_info_Events() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("Event");
    var eventdata = await collection.find().toList();
    return eventdata;
  }

  Widget _buildImageWidget(String imageData) {
    if (imageData.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey[200],
        child: const Icon(Icons.event, size: 50, color: Colors.grey),
      );
    }

    // Check if the image is a URL (starts with http) or base64
    if (imageData.startsWith('http')) {
      return Image.network(
        imageData,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      try {
        return Image.memory(
          base64Decode(imageData),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 220,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Could not load image', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode
            ? theme.colorScheme.surface
            : theme.colorScheme.primary.withOpacity(0.2),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.headlineMedium?.color),
      ),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchEvents,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final imageData = event['image']?.toString() ?? '';

              return AnimatedContainer(
                duration: Duration(milliseconds: 500 + index * 100),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: {
                          'title': event['Event Name']?.toString() ?? 'No Title',
                          'date': event['date']?.toString() ?? 'No Date',
                          'location': event['location'] != null
                              ? '${event['location']['latitude']}, ${event['location']['longitude']}'
                              : 'No Location',
                          'description': event['description']?.toString() ?? 'No Description',
                          'image': imageData,
                          'price': event['price']?.toString() ?? 'Free',
                          'celeb': event['celeb']?.toString() ?? '',
                        }),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Hero animation for smooth transition
                        Hero(
                          tag: 'event-image-${event['_id']}',
                          child: _buildImageWidget(imageData),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['Event Name']?.toString() ?? 'No Title',
                                style: theme.textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    event['date']?.toString() ?? 'No Date',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event['location'] != null
                                          ? '${event['location']['latitude']}, ${event['location']['longitude']}'
                                          : 'No Location',
                                      style: theme.textTheme.bodyMedium,
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
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnnouceEventScreen()),
          ).then((_) => _fetchEvents());
        },
        child: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}