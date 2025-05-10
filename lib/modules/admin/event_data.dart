import 'package:flutter/material.dart';

// Placeholder for pending events - in a real app, this would likely come from a backend
// Making this accessible to both _EventsPageState and PendingEventsPage's state
List<Map<String, String>> _pendingEvents = [
  {
    'id': 'pending_event1',
    'title': 'Community Cleanup Drive',
    'date': 'June 05, 2025',
    'location': 'City Park',
    'description':
        'Volunteer event to clean up the local park. Pending approval.',
    'image': 'https://via.placeholder.com/400x220.png?text=Pending+Event+1'
  },
  {
    'id': 'pending_event2',
    'title': 'Summer Music Festival - Call for Artists',
    'date': 'July 10-12, 2025',
    'location': 'Downtown Plaza',
    'description':
        'Seeking local bands and artists for our annual summer festival. Submit your application!',
    'image': 'https://via.placeholder.com/400x220.png?text=Pending+Event+2'
  },
];

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late List<Map<String, String>> _approvedEvents;

  @override
  void initState() {
    super.initState();
    _approvedEvents = [
      {
        'id': '1',
        'title': 'Book Fair',
        'date': 'May 15, 2025',
        'location': 'Beirut, Biel',
        'description':
            'Come explore thousands of books from international and local publishers.',
        'image':
            'https://www.globaltimes.cn/Portals/0/attachment/2022/2022-11-13/1bc337f2-f660-4614-b897-58bf1498a6e5.jpeg'
      },
      {
        'id': '2',
        'title': 'Anything Goes Bel Arabi - Award Winning Broadway Musical',
        'date': 'May 18, 2025',
        'location': 'Casino du Liban',
        'description':
            'Enjoy a spectacular Broadway musical performed entirely in Arabic.',
        'image':
            'https://cdn.ticketingboxoffice.com/uploadImages/ProducersEventsPics/Producers-Events-T-1405-638715148217700146.jpg'
      },
    ];
  }

  // Removed _addEvent and _editEvent methods

  void _deleteApprovedEvent(String eventId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Confirm Deletion',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          content: const Text('Are you sure you want to delete this event?',
              style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style:
                      TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text('Delete',
                  style: TextStyle(
                      color: Colors.redAccent, fontFamily: 'Poppins')),
              onPressed: () {
                setState(() {
                  _approvedEvents
                      .removeWhere((event) => event['id'] == eventId);
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Event deleted'),
                      duration: Duration(seconds: 2)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _handleApprovePendingEvent(String eventId) {
    setState(() {
      Map<String, String>? eventToApprove;
      int pendingIndex = _pendingEvents.indexWhere((e) => e['id'] == eventId);
      if (pendingIndex != -1) {
        eventToApprove = _pendingEvents.removeAt(pendingIndex);
        _approvedEvents.add(eventToApprove); // Add to approved list
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Event approved and moved to main list'),
          duration: Duration(seconds: 2)),
    );
  }

  void _handleRejectPendingEvent(String eventId) {
    setState(() {
      _pendingEvents.removeWhere((event) => event['id'] == eventId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Event rejected and removed from pending'),
          duration: Duration(seconds: 2)),
    );
  }

  void _showPendingEvents() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PendingEventsPage(
                initialPendingEvents: List.from(_pendingEvents), // Pass a copy
                onApprove: _handleApprovePendingEvent,
                onReject: _handleRejectPendingEvent,
              )),
    );
    setState(() {}); // Refresh to update pending count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Manage Events',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.pending_actions, color: Colors.orangeAccent),
            label: Text('Pending (${_pendingEvents.length})',
                style: TextStyle(
                    color: Colors.orangeAccent, fontFamily: 'Poppins')),
            onPressed: _showPendingEvents,
            style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
          ),
          // Removed Add Event IconButton
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _approvedEvents.isEmpty
            ? Center(
                child: Text(
                  'No approved events found.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontFamily: 'Poppins'),
                ),
              )
            : ListView.builder(
                itemCount: _approvedEvents.length,
                itemBuilder: (context, index) {
                  final event = _approvedEvents[index];
                  return EventCard(
                    title: event['title']!,
                    date: event['date']!,
                    location: event['location']!,
                    imageUrl: event['image']!,
                    eventData: event,
                    // Removed onEdit callback
                    onDelete: () => _deleteApprovedEvent(event['id']!),
                  );
                },
              ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final Map<String, String> eventData;
  // Removed onEdit callback
  final VoidCallback onDelete;

  const EventCard({
    Key? key,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.eventData,
    // Removed onEdit parameter
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: '${eventData['id']}_image',
                child: Image.network(
                  imageUrl,
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
                    'assets/images/placeholder.jpg',
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
                      title,
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
                        Text(date,
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
                            location,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Removed Edit Button
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.redAccent),
                  label: const Text('Delete',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontFamily: 'Poppins',
                          fontSize: 13)),
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailPage extends StatelessWidget {
  final Map<String, String> event;
  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String heroTag = '${event['id']}_image';
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(event['title'] ?? 'Event Details',
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: heroTag,
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
                                color: Colors.white70,
                                fontFamily: 'Poppins')))),
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
                              color: Colors.white)));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['title'] ?? '',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(event['date'] ?? '',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                            fontSize: 14))
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(event['location'] ?? '',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Poppins',
                                fontSize: 14)))
                  ]),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 10),
                  Text(event['description'] ?? 'No description available.',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EditEventPage is removed as per requirements (no add/edit for approved events from this page)

class PendingEventsPage extends StatefulWidget {
  final List<Map<String, String>> initialPendingEvents;
  final Function(String) onApprove;
  final Function(String) onReject;

  const PendingEventsPage({
    Key? key,
    required this.initialPendingEvents,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  State<PendingEventsPage> createState() => _PendingEventsPageState();
}

class _PendingEventsPageState extends State<PendingEventsPage> {
  late List<Map<String, String>> _pagePendingEvents;

  @override
  void initState() {
    super.initState();
    _pagePendingEvents = List.from(widget.initialPendingEvents);
  }

  void _approve(String eventId) {
    widget.onApprove(eventId);
    setState(() {
      _pagePendingEvents.removeWhere((e) => e['id'] == eventId);
    });
  }

  void _reject(String eventId) {
    widget.onReject(eventId);
    setState(() {
      _pagePendingEvents.removeWhere((e) => e['id'] == eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Pending Events',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _pagePendingEvents.isEmpty
          ? Center(
              child: Text(
                'No pending events.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: 'Poppins'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _pagePendingEvents.length,
              itemBuilder: (context, index) {
                final event = _pagePendingEvents[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(event['image'] ?? ''),
                      onBackgroundImageError: (exception, stackTrace) {},
                      backgroundColor: Colors.grey[700],
                      child: event['image'] == null ||
                              event['image']!.isEmpty ||
                              !event['image']!.startsWith('http')
                          ? const Icon(Icons.event_note, color: Colors.white54)
                          : null,
                    ),
                    title: Text(event['title'] ?? 'No Title',
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        '${event['date'] ?? 'No Date'} - ${event['location'] ?? 'No Location'}\n${event['description'] ?? ''}',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                            fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.check_circle_outline,
                                color: Colors.greenAccent),
                            tooltip: 'Approve',
                            onPressed: () {
                              _approve(event['id']!);
                            }),
                        IconButton(
                            icon: Icon(Icons.cancel_outlined,
                                color: Colors.redAccent),
                            tooltip: 'Reject',
                            onPressed: () {
                              _reject(event['id']!);
                            }),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EventDetailPage(event: event)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// --- Edit Event Page (Restored for Event Manager Profile) ---
class EditEventPage extends StatefulWidget {
  final Map<String, String>? initialEvent;
  final Function(Map<String, String>) onSave;

  const EditEventPage({Key? key, this.initialEvent, required this.onSave})
      : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialEvent?["title"] ?? "");
    _dateController =
        TextEditingController(text: widget.initialEvent?["date"] ?? "");
    _locationController =
        TextEditingController(text: widget.initialEvent?["location"] ?? "");
    _descriptionController =
        TextEditingController(text: widget.initialEvent?["description"] ?? "");
    _imageController =
        TextEditingController(text: widget.initialEvent?["image"] ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final eventData = {
        "id": widget.initialEvent?["id"] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        "title": _titleController.text,
        "date": _dateController.text,
        "location": _locationController.text,
        "description": _descriptionController.text,
        "image": _imageController.text,
      };
      widget.onSave(eventData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          widget.initialEvent == null ? "Add New Event" : "Edit Event",
          style: const TextStyle(color: Colors.white, fontFamily: "Poppins"),
        ),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: "Save Event",
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField(_titleController, "Title"),
              _buildTextFormField(_dateController, "Date (e.g., May 30, 2025)"),
              _buildTextFormField(_locationController, "Location"),
              _buildTextFormField(_descriptionController, "Description",
                  maxLines: 4),
              _buildTextFormField(_imageController, "Image URL"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF3B82F6), // Using a blue color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.initialEvent == null ? "Add Event" : "Save Changes",
                  style: const TextStyle(
                      fontSize: 16, fontFamily: "Poppins", color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontFamily: "Poppins"),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.white70, fontFamily: "Poppins"),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white38),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color(0xFF3B82F6)), // Blue focus border
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: const Color(0xFF1E293B).withOpacity(0.7),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a $label";
          }
          if (label == "Image URL") {
            Uri? uri = Uri.tryParse(value);
            if (uri == null ||
                !uri.isAbsolute ||
                (!uri.scheme.startsWith("http"))) {
              return "Please enter a valid HTTP/HTTPS URL";
            }
          }
          return null;
        },
      ),
    );
  }
}
