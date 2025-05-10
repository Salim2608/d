import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class map_page extends StatefulWidget {
  const map_page({super.key});

  @override
  State<map_page> createState() => _map_page_State();
}

class _map_page_State extends State<map_page> {
  static const LatLng location = LatLng(37.4223, -122.0848);

  // Define a set of markers
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('locationMarker'),
      position: location,
      infoWindow: InfoWindow(title: 'Location'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: location, zoom: 13),
        markers: _markers,
      ),
    );
  }
}
