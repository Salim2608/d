import 'dart:convert';
import 'package:darlink/constants/colors/app_color.dart';
import 'package:darlink/modules/loading/event_load_screen.dart';
import 'package:darlink/modules/upload/announce_event_screen.dart';
import 'package:darlink/modules/detail/event_detail_screen.dart';
import 'package:darlink/shared/widgets/card/event_card.dart';
import 'package:darlink/shared/widgets/function.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:darlink/constants/Database_url.dart' as mg;

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventsPage> {
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

  Future<void> _deleteEvent(dynamic eventId) async {
    try {
      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      var collection = db.collection("Event");

      mongo.ObjectId objectId;

      // Handle both String and ObjectId cases
      if (eventId is String) {
        // If it's a string, check if it's already in ObjectId("...") format
        if (eventId.startsWith('ObjectId("') && eventId.endsWith('")')) {
          final hexString = eventId.substring(9, eventId.length - 2);
          objectId = mongo.ObjectId.parse(hexString);
        } else {
          // Assume it's a plain hex string
          objectId = mongo.ObjectId.parse(eventId);
        }
      } else if (eventId is mongo.ObjectId) {
        objectId = eventId;
      } else {
        throw ArgumentError('Invalid eventId type');
      }

      await collection.deleteOne(mongo.where.id(objectId));

      setState(() {
        events.removeWhere((event) {
          if (event['_id'] is mongo.ObjectId) {
            return event['_id'] == objectId;
          } else if (event['_id'] is String) {
            return event['_id'] == objectId.toHexString() ||
                event['_id'] == 'ObjectId("${objectId.toHexString()}")';
          }
          return false;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: ${e.toString()}')),
      );
    }
  }

  Widget _buildImageWidget(String imageData) {
    if (imageData.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey[200],
        child: const Icon(Icons.event, size: 50, color: Colors.grey),
      );
    }

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
          'Event managment',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.headlineMedium?.color),
      ),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: EventLoadScreen())
            : RefreshIndicator(
                onRefresh: _fetchEvents,
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final imageData = event['image']?.toString() ?? '';
                    final eventId = event['_id'];

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
                                'title': event['Event Name']?.toString() ??
                                    'No Title',
                                'date': event['date']?.toString() ?? 'No Date',
                                'location': event['location'] != null
                                    ? '${event['location']['latitude']}, ${event['location']['longitude']}'
                                    : 'No Location',
                                'description':
                                    event['description']?.toString() ??
                                        'No Description',
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
                              Hero(
                                tag: 'event-image-${eventId.toString()}',
                                child: _buildImageWidget(imageData),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['Event Name']?.toString() ??
                                          'No Title',
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
                                          formatDateString(
                                              event['date']?.toString()),
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
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final confirmed = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Confirm Delete'),
                                          content: Text(
                                              'Are you sure you want to delete this event?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        await _deleteEvent(eventId);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Delete Event'),
                                  ),
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
    );
  }
}
