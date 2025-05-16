import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/Database_url.dart' as mg;
import '../../constants/colors/app_color.dart';

class AnnouceEventScreen extends StatefulWidget {
  const AnnouceEventScreen({super.key});

  @override
  _AnnouceEventScreenState createState() => _AnnouceEventScreenState();
}

class _AnnouceEventScreenState extends State<AnnouceEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _celebrityController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  File? _image;
  String? _imageBase64;
  LatLng? _selectedLocation;

  GoogleMapController? _mapController;
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.8880651, 35.5039614),
    zoom: 7,
  );

  bool _isMapInteracting = false;

  Future<void> _pickDate(bool isStartDate) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          // If end date is before start date or not set, update it to be same as start date
          if (_endDate == null || _endDate!.isBefore(date)) {
            _endDate = date.add(Duration(days: 1));
          }
        } else {
          // Ensure end date is not before start date
          if (_startDate != null && date.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('End date cannot be before start date')),
            );
            return;
          }
          _endDate = date;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
          // If end time is not set, set it to one hour after start time
          if (_endTime == null) {
            int newHour = (time.hour + 1) % 24;
            _endTime = TimeOfDay(hour: newHour, minute: time.minute);
          }
        } else {
          // Validate that end time is after start time if on same day
          if (_startTime != null &&
              _startDate != null &&
              _endDate != null &&
              _startDate!.year == _endDate!.year &&
              _startDate!.month == _endDate!.month &&
              _startDate!.day == _endDate!.day) {
            if (time.hour < _startTime!.hour ||
                (time.hour == _startTime!.hour &&
                    time.minute < _startTime!.minute)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                    Text('End time must be after start time on same day')),
              );
              return;
            }
          }
          _endTime = time;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Image Source'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Row(
                children: [
                  Icon(Icons.camera_alt, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Camera'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Row(
                children: [
                  Icon(Icons.photo_library, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Gallery'),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked != null) {
        final bytes = await File(picked.path).readAsBytes();
        setState(() {
          _image = File(picked.path);
          _imageBase64 = base64Encode(bytes);
        });
      }
    }
  }

  void _deleteImage() {
    setState(() {
      _image = null;
      _imageBase64 = null;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  String _formatTimeOfDay(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return 'Select Time';
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Announce an Event",
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: theme.appBarTheme.elevation,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  _buildTextField(_eventNameController, "Event Name", theme),

                  // Address Field
                  _buildTextField(
                      _addressController, "Address Location", theme),

                  // Description with more space
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      maxLines: 5, // Increased space for description
                      decoration: InputDecoration(
                        labelText: "Description",
                        alignLabelWithHint:
                        true, // Aligns the label with the first line
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColors.textOnDark
                              : AppColors.textPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.divider,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.divider,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 15),

                  // Date and Time section
                  Text(
                    "Event Schedule",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Start Date and Time Row
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: _buildDateField(
                          "Start Date",
                          _startDate == null
                              ? "Select Date"
                              : dateFormat.format(_startDate!),
                              () => _pickDate(true),
                          theme,
                        ),
                      ),
                      SizedBox(width: 10),
                      // Start Time
                      Expanded(
                        child: _buildTimeField(
                          "Start Time",
                          _formatTimeOfDay(_startTime),
                              () => _pickTime(true),
                          theme,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // End Date and Time Row
                  Row(
                    children: [
                      // End Date
                      Expanded(
                        child: _buildDateField(
                          "End Date",
                          _endDate == null
                              ? "Select Date"
                              : dateFormat.format(_endDate!),
                              () => _pickDate(false),
                          theme,
                        ),
                      ),
                      SizedBox(width: 10),
                      // End Time
                      Expanded(
                        child: _buildTimeField(
                          "End Time",
                          _formatTimeOfDay(_endTime),
                              () => _pickTime(false),
                          theme,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  _buildTextField(
                      _celebrityController, "Celebrity in Attendance", theme),
                  SizedBox(height: 15),

                  // Image Upload Section - Enhanced
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    color: isDark
                        ? AppColors.cardDarkBackground
                        : AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Event Image",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.image,
                                    color: AppColors.textOnDark),
                                label: Text(
                                  _image == null
                                      ? "Upload Image"
                                      : "Change Image",
                                  style: TextStyle(color: AppColors.textOnDark),
                                ),
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          if (_image != null) ...[
                            SizedBox(height: 15),
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height:
                                  200, // Increased height for image preview
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.dividerDark
                                          : AppColors.divider,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon:
                                    Icon(Icons.delete, color: Colors.white),
                                    onPressed: _deleteImage,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            SizedBox(height: 15),
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "No image selected",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Ticket Price with Dollar Sign
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _ticketPriceController,
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Ticket Price",
                      labelStyle: TextStyle(
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.textPrimary,
                      ),
                      prefixText: "\$ ",
                      prefixStyle: TextStyle(
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.textPrimary,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.divider,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.divider,
                        ),
                      ),
                    ),
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ticket price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  // Google Maps Section
                  Card(
                    elevation: 4,
                    color: isDark
                        ? AppColors.cardDarkBackground
                        : AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Event Location",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Tap on the map to select the exact location",
                            style: TextStyle(
                              color:
                              isDark ? Colors.grey[400] : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 250, // Increased map height
                            child: Listener(
                              onPointerDown: (_) =>
                                  setState(() => _isMapInteracting = true),
                              onPointerUp: (_) =>
                                  setState(() => _isMapInteracting = false),
                              onPointerCancel: (_) =>
                                  setState(() => _isMapInteracting = false),
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: _initialPosition,
                                onTap: _onMapTap,
                                markers: _selectedLocation != null
                                    ? {
                                  Marker(
                                    markerId:
                                    MarkerId('selectedLocation'),
                                    position: _selectedLocation!,
                                  ),
                                }
                                    : {},
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                gestureRecognizers: <Factory<
                                    OneSequenceGestureRecognizer>>{
                                  Factory<OneSequenceGestureRecognizer>(
                                        () => EagerGestureRecognizer(),
                                  ),
                                },
                              ),
                            ),
                          ),
                          if (_selectedLocation != null) ...[
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: AppColors.primary, size: 16),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "Location selected: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_startDate == null || _endDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please select both start and end dates')),
                            );
                            return;
                          }

                          if (_startTime == null || _endTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please select both start and end times')),
                            );
                            return;
                          }

                          if (_selectedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please select a location on the map')),
                            );
                            return;
                          }

                          // Combine date and time for start and end
                          final startDateTime = DateTime(
                            _startDate!.year,
                            _startDate!.month,
                            _startDate!.day,
                            _startTime!.hour,
                            _startTime!.minute,
                          );

                          final endDateTime = DateTime(
                            _endDate!.year,
                            _endDate!.month,
                            _endDate!.day,
                            _endTime!.hour,
                            _endTime!.minute,
                          );

                          var db = await mongo.Db.create(mg.mongo_url);
                          await db.open();
                          var collection = db.collection("Event");
                          await collection.insert({
                            'Event Name': _eventNameController.text,
                            'address': _addressController.text,
                            'date': startDateTime,
                            'price': _ticketPriceController.text,
                            'location': {
                              'latitude': _selectedLocation!.latitude,
                              'longitude': _selectedLocation!.longitude,
                            },
                            'description': _descriptionController.text,
                            'image': _imageBase64, // Using base64 string now
                            'celeb': _celebrityController.text,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Event announced successfully!')),
                          );

                          // Optional: Clear the form after submission
                          _formKey.currentState?.reset();
                          setState(() {
                            _image = null;
                            _imageBase64 = null;
                            _startDate = null;
                            _endDate = null;
                            _startTime = null;
                            _endTime = null;
                            _selectedLocation = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                        EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Announce Event",
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildTextField(
      TextEditingController controller, String label, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
          ),
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

  Widget _buildDateField(
      String label, String value, VoidCallback onTap, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color:
                    isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(
      String label, String value, VoidCallback onTap, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color:
                    isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}