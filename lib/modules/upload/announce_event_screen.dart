import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/Database_url.dart' as mg;
import '../../constants/colors/app_color.dart';

class AnnounceEventScreen extends StatefulWidget {
  const AnnounceEventScreen({super.key});

  @override
  _AnnounceEventScreenState createState() => _AnnounceEventScreenState();
}

class _AnnounceEventScreenState extends State<AnnounceEventScreen> {
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
  LatLng? _selectedLocation;
  bool _scheduleExpanded = true;
  bool _locationExpanded = true;
  bool _detailsExpanded = false;

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
          if (_endDate == null || _endDate!.isBefore(date)) {
            _endDate = date.add(Duration(days: 1));
          }
        } else {
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
          if (_endTime == null) {
            int newHour = (time.hour + 1) % 24;
            _endTime = TimeOfDay(hour: newHour, minute: time.minute);
          }
        } else {
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
        setState(() => _image = File(picked.path));
      }
    }
  }

  void _deleteImage() {
    setState(() => _image = null);
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
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: colorScheme.onPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Announce an Event",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (_isMapInteracting) return true;
          return false;
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Event Card
                _buildEventMainCard(theme, colorScheme, textTheme),

                // Schedule Section
                _buildExpandableSection(
                  theme,
                  colorScheme,
                  textTheme,
                  'Event Schedule',
                  Icons.event,
                  _scheduleExpanded,
                  () => setState(() => _scheduleExpanded = !_scheduleExpanded),
                  _buildScheduleContent(
                      theme, colorScheme, textTheme, dateFormat),
                ),

                // Location Section
                _buildExpandableSection(
                  theme,
                  colorScheme,
                  textTheme,
                  'Event Location',
                  Icons.location_on,
                  _locationExpanded,
                  () => setState(() => _locationExpanded = !_locationExpanded),
                  _buildLocationContent(theme, colorScheme, textTheme),
                ),

                // Additional Details Section
                _buildExpandableSection(
                  theme,
                  colorScheme,
                  textTheme,
                  'Additional Details',
                  Icons.info_outline,
                  _detailsExpanded,
                  () => setState(() => _detailsExpanded = !_detailsExpanded),
                  _buildDetailsContent(theme, colorScheme, textTheme),
                ),

                // Submit Button
                _buildSubmitButton(theme, colorScheme, textTheme),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventMainCard(
      ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image Section
          InkWell(
            onTap: _pickImage,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: _image != null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: _deleteImage,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 200,
                      color: colorScheme.surfaceVariant,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Add Event Image",
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Event Title and Price
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title Field
                TextFormField(
                  controller: _eventNameController,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Event Name",
                    hintStyle: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event name';
                    }
                    return null;
                  },
                ),

                // Address Field with Icon
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                        decoration: InputDecoration(
                          hintText: "Address Location",
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Ticket Price Field
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money,
                          size: 16, color: colorScheme.primary),
                      SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                          controller: _ticketPriceController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                          decoration: InputDecoration(
                            hintText: "Ticket Price",
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String title,
    IconData icon,
    bool isExpanded,
    VoidCallback onTap,
    Widget content,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: colorScheme.primary),
            title: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            onTap: onTap,
          ),
          if (isExpanded) content,
        ],
      ),
    );
  }

  Widget _buildScheduleContent(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
    DateFormat dateFormat,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateTimeSelector(
                  theme,
                  colorScheme,
                  textTheme,
                  "Start Date",
                  _startDate == null
                      ? "Select Date"
                      : dateFormat.format(_startDate!),
                  Icons.calendar_today,
                  () => _pickDate(true),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildDateTimeSelector(
                  theme,
                  colorScheme,
                  textTheme,
                  "Start Time",
                  _formatTimeOfDay(_startTime),
                  Icons.access_time,
                  () => _pickTime(true),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeSelector(
                  theme,
                  colorScheme,
                  textTheme,
                  "End Date",
                  _endDate == null
                      ? "Select Date"
                      : dateFormat.format(_endDate!),
                  Icons.calendar_today,
                  () => _pickDate(false),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildDateTimeSelector(
                  theme,
                  colorScheme,
                  textTheme,
                  "End Time",
                  _formatTimeOfDay(_endTime),
                  Icons.access_time,
                  () => _pickTime(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: colorScheme.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationContent(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 200,
              child: Listener(
                onPointerDown: (_) => setState(() => _isMapInteracting = true),
                onPointerUp: (_) => setState(() => _isMapInteracting = false),
                onPointerCancel: (_) =>
                    setState(() => _isMapInteracting = false),
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
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
            ),
          ),
          if (_selectedLocation != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Location selected",
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 8),
            Text(
              "Tap on the map to select the event location",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsContent(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Field
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Event Description",
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Celebrity Field
          TextFormField(
            controller: _celebrityController,
            decoration: InputDecoration(
              labelText: "Celebrity in Attendance",
              prefixIcon: Icon(Icons.person, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Validate required fields
            if (_startDate == null || _endDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Please select both start and end dates')),
              );
              return;
            }

            if (_startTime == null || _endTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Please select both start and end times')),
              );
              return;
            }

            if (_selectedLocation == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a location on the map')),
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
              'startDateTime': startDateTime,
              'endDateTime': endDateTime,
              'price': _ticketPriceController.text,
              'location': {
                'latitude': _selectedLocation!.latitude,
                'longitude': _selectedLocation!.longitude,
              },
              'description': _descriptionController.text,
              'image': _image != null ? _image!.path : null,
              'celeb': _celebrityController.text,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Event announced successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Optional: Clear the form after submission
            _formKey.currentState?.reset();
            setState(() {
              _image = null;
              _startDate = null;
              _endDate = null;
              _startTime = null;
              _endTime = null;
              _selectedLocation = null;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          "Announce Event",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
