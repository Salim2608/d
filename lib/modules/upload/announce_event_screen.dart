import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../../constants/Database_url.dart' as mg;

class AnnouceEventScreen extends StatefulWidget {
  @override
  _AnnouceEventScreenState createState() => _AnnouceEventScreenState();
}

class _AnnouceEventScreenState extends State<AnnouceEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _celebrityController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  DateTime? _selectedDate;
  File? _image;
  var _imageString;
  LatLng? _selectedLocation;

  // Google Maps controller and initial position
  GoogleMapController? _mapController;
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.8880651, 35.5039614),
    zoom: 7,
  );

  // To handle map gesture recognition
  bool _isMapInteracting = false;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Create a new DateTime without time components to avoid timezone issues
      final localDate = DateTime(picked.year, picked.month, picked.day);
      setState(() => _selectedDate = localDate);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      Uint8List imageBytes = await File(picked.path).readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        _image = File(picked.path);
        _imageString = base64Image;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Announce an Event"),
        backgroundColor: Colors.green[800],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (_isMapInteracting) return true;
          return false;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_eventNameController, "Event Name"),
                  _buildTextField(_descriptionController, "Description"),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: _selectedDate == null
                              ? "Select Date"
                              : DateFormat.yMMMd().format(_selectedDate!),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                      _celebrityController, "Celebrity in Attendance"),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text("Upload Image"),
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                    ),
                  ),
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(_image!, height: 100),
                    ),
                  _buildTextField(_ticketPriceController, "Ticket Price",
                      isNumber: true),
                  SizedBox(height: 20),

                  // Google Maps Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Event Location",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 200,
                            child: Listener(
                              onPointerDown: (_) => setState(() => _isMapInteracting = true),
                              onPointerUp: (_) => setState(() => _isMapInteracting = false),
                              onPointerCancel: (_) => setState(() => _isMapInteracting = false),
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: _initialPosition,
                                onTap: _onMapTap,
                                markers: _selectedLocation != null
                                    ? {
                                  Marker(
                                    markerId: MarkerId('selectedLocation'),
                                    position: _selectedLocation!,
                                  ),
                                }
                                    : {},
                                myLocationEnabled: false,
                                myLocationButtonEnabled: false,
                                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                                  Factory<OneSequenceGestureRecognizer>(
                                        () => EagerGestureRecognizer(),
                                  ),
                                },
                              ),
                            ),
                          ),
                          if (_selectedLocation != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Selected Location: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a location on the map')),
                          );
                          return;
                        }

                        var db = await mongo.Db.create(mg.mongo_url);
                        await db.open();
                        var collection = db.collection("Event");

                        await collection.insert({
                          'Event Name': _eventNameController.text,
                          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!), // Store as formatted string
                          'price': _ticketPriceController.text,
                          'location': {
                            'latitude': _selectedLocation!.latitude,
                            'longitude': _selectedLocation!.longitude,
                          },
                          'description': _descriptionController.text,
                          'image': _imageString,
                          'celeb': _celebrityController.text,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Event announced successfully!')),
                        );

                        Navigator.pop(context); // Return to previous screen
                      }
                    },
                    child: Text("Announce"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}