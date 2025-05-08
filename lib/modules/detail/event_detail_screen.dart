import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, String> event;

  const EventDetailPage({super.key, required this.event});

  Widget _buildImageWidget() {
    final imageData = event['image'] ?? '';

    if (imageData.isEmpty) {
      return _buildPlaceholder();
    }

    if (imageData.startsWith('http')) {
      return Hero(
        tag: imageData,
        child: Image.network(
          imageData,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    } else {
      try {
        return Hero(
          tag: imageData,
          child: Image.memory(
            base64Decode(imageData),
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('No image available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  LatLng? _parseLocation() {
    final location = event['location'];
    if (location == null || location.isEmpty) return null;

    try {
      final parts = location.split(',');
      if (parts.length != 2) return null;

      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());

      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = _parseLocation();

    // Create marker set
    final Set<Marker> markers = {};
    if (location != null) {
      markers.add(
        Marker(
          markerId: MarkerId('event_location'),
          position: location,
          infoWindow: InfoWindow(title: event['title'] ?? 'Event Location'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['title'] ?? 'Event Details',
          style: theme.textTheme.headlineMedium,
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.headlineMedium?.color),
      ),
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with Hero animation
            _buildImageWidget(),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Untitled Event',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date row
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: theme.textTheme.bodyMedium?.color),
                      const SizedBox(width: 8),
                      Text(
                        event['date'] ?? 'Date not specified',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location row
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: theme.textTheme.bodyMedium?.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event['location'] ?? 'Location not specified',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Google Map Section
                  if (location != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Location Map',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: location,
                            zoom: 9,
                          ),
                          markers: markers,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          onMapCreated: (controller) {
                            // Optional: Can store controller if needed
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Price row (if available)
                  if (event['price'] != null && event['price']!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            color: theme.textTheme.bodyMedium?.color),
                        const SizedBox(width: 8),
                        Text(
                          event['price']!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Description section
                  Text(
                    'Description',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event['description'] ?? 'No description available.',
                    style: theme.textTheme.bodyLarge,
                  ),

                  // Celebrity info (if available)
                  if (event['celeb'] != null && event['celeb']!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Featured Celebrity',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event['celeb']!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}