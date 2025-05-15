import 'package:darlink/constants/app_theme_data.dart';
import 'package:darlink/constants/database_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:darlink/constants/colors/app_color.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:convert';
import '../../constants/Database_url.dart' as mg;
import '../../models/transaction page.dart';
import '../authentication/login_screen.dart' as lg;

void main() => runApp(MaterialApp(
      theme: AppThemeData.lightTheme,
      darkTheme: AppThemeData.darkTheme,
      themeMode: ThemeMode.system,
      home: PropertyUploadScreen(),
    ));

class PropertyUploadScreen extends StatefulWidget {
  const PropertyUploadScreen({super.key});

  @override
  State<PropertyUploadScreen> createState() => _PropertyUploadScreenState();
}

class _PropertyUploadScreenState extends State<PropertyUploadScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  bool _isMapInteracting = false;

  // Text controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController bedroomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  final TextEditingController kitchensController = TextEditingController();

  final TextEditingController priceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  var title="";

  // Property details
  String? selectedPropertyType;
  final List<String> propertyTypes = [
    'Land',
    'Chalet',
    'Apartment',
    'House',
    'Villa',
    'Commercial'
  ];

  // Amenities
  Map<String, bool> amenities = {
    'Swimming Pool': false,
    'Gym': false,
    'Parking': false,
    'Security': false,
    'Elevator': false,
    'Garden': false,
    'Balcony': false,
    'Air Conditioning': false
  };

  // Interior Details
  Map<String, bool> interiorDetails = {
    'Furnished': false,
    'Semi-Furnished': false,
    'Unfurnished': false,
    'Modular Kitchen': false,
    'Wooden Flooring': false,
    'Marble Flooring': false,
    'False Ceiling': false
  };

  // Map related variables
  late GoogleMapController mapController;
  LatLng selectedLocation =LatLng(33.8880651, 35.5039614); // Default location
  Set<Marker> markers = {};

  // Image related variables
  final ImagePicker _picker = ImagePicker();
  final List<File> _imageFiles = [];

  // Validation error flags
  bool _hasAmenityError = false;
  bool _hasInteriorError = false;
  bool _hasImageError = false;

  // Scroll controller to implement fade effect
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollOffset);

    // Initialize map marker
    markers.add(
      Marker(
        markerId: MarkerId('property_location'),
        position: selectedLocation,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            selectedLocation = newPosition;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollOffset);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollOffset() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        List<String> base64Images = [];
        for (var file in pickedFiles) {
          List<int> imageBytes = await File(file.path).readAsBytes();
          String base64String = base64Encode(imageBytes);
          base64Images.add(base64String);
        }

        setState(() {
          _imageFiles
              .addAll(pickedFiles.map((file) => File(file.path)).toList());
          _hasImageError = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<List<String>> _convertImageFilesToBase64(List<File> imageFiles) async {
    final List<String> base64Strings = [];

    for (final file in imageFiles) {
      try {
        // Read the file as bytes
        final bytes = await file.readAsBytes();

        // Convert bytes to base64 string
        final base64String = base64Encode(bytes);
        base64Strings.add(base64String);
      } catch (e) {
        debugPrint('Error converting image to base64: $e');
        // You can choose to add a placeholder or skip the file
        base64Strings.add(''); // Empty string as placeholder
      }
    }

    return base64Strings;
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
      _hasImageError = _imageFiles.isEmpty;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateMarkerPosition(LatLng position) {
    setState(() {
      selectedLocation = position;
      markers = {
        Marker(
          markerId: MarkerId('property_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              selectedLocation = newPosition;
            });
          },
        )
      };
    });
  }

  // Validate form data
  bool _validateForm() {
    bool isValid = _formKey.currentState?.validate() ?? false;

    // Check amenities
    bool hasAmenity = amenities.values.any((selected) => selected);
    setState(() {
      _hasAmenityError = !hasAmenity;
    });

    // Check interior details
    bool hasInterior = interiorDetails.values.any((selected) => selected);
    setState(() {
      _hasInteriorError = !hasInterior;
    });

    // Check images
    bool hasImages = _imageFiles.isNotEmpty;
    setState(() {
      _hasImageError = !hasImages;
    });

    return isValid && hasAmenity && hasInterior && hasImages;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Upload a Property',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.primary.withOpacity(0.08),
            ],
          ),
        ),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                        'Basic Information', colorScheme, textTheme),
                    const SizedBox(height: 20),
                    buildTextField(
                      "Property Title",
                      titleController,
                      validator: (value) => value == null || value.isEmpty
                          ? "Title is required"
                          : null,
                      prefixIcon: Icons.title_outlined,
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      "Address",
                      addressController,
                      validator: (value) => value == null || value.isEmpty
                          ? "Address is required"
                          : null,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),
                    buildDropdownField(
                      validator: (value) =>
                          value == null ? "Property type is required" : null,
                      prefixIcon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      "Price (\$)",
                      priceController,
                      isNumber: true,
                      validator: (value) => value == null || value.isEmpty
                          ? "Price is required"
                          : (double.tryParse(value) == null ||
                                  double.parse(value) <= 0)
                              ? "Enter a valid price"
                              : null,
                      prefixIcon: Icons.attach_money,
                    ),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                        'Property Details', colorScheme, textTheme),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            "Bedrooms",
                            bedroomsController,
                            isNumber: true,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : (int.tryParse(value) == null ||
                                        int.parse(value) <= 0)
                                    ? "Invalid"
                                    : null,
                            prefixIcon: Icons.king_bed_outlined,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: buildTextField(
                            "Bathrooms",
                            bathroomsController,
                            isNumber: true,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : (int.tryParse(value) == null ||
                                        int.parse(value) <= 0)
                                    ? "Invalid"
                                    : null,
                            prefixIcon: Icons.bathtub_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            "Kitchens",
                            kitchensController,
                            isNumber: true,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : (int.tryParse(value) == null ||
                                        int.parse(value) <= 0)
                                    ? "Invalid"
                                    : null,
                            prefixIcon: Icons.kitchen_outlined,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: buildTextField(
                            "Area (m²)",
                            areaController,
                            isNumber: true,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : (double.tryParse(value) == null ||
                                        double.parse(value) <= 0)
                                    ? "Invalid"
                                    : null,
                            prefixIcon: Icons.square_foot_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Amenities', colorScheme, textTheme),
                    if (_hasAmenityError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please select at least one amenity',
                          style:
                              TextStyle(color: colorScheme.error, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildAmenitiesSection(colorScheme),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                        'Interior Details', colorScheme, textTheme),
                    if (_hasInteriorError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please select at least one interior detail',
                          style:
                              TextStyle(color: colorScheme.error, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildInteriorDetailsSection(colorScheme),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                        'Property Location', colorScheme, textTheme),
                    const SizedBox(height: 20),
                    _buildMapSection(colorScheme),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                        'Property Images', colorScheme, textTheme),
                    if (_hasImageError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please upload at least one image',
                          style:
                              TextStyle(color: colorScheme.error, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildPhotosSection(colorScheme),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            // Bottom fade and button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.background.withOpacity(0.1),
                      colorScheme.background.withOpacity(0.9),
                      colorScheme.background,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: _buildSubmitButton(colorScheme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForSection(title),
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.67),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSection(String section) {
    switch (section) {
      case 'Basic Information':
        return Icons.info_outline;
      case 'Property Details':
        return Icons.house_outlined;
      case 'Amenities':
        return Icons.pool_outlined;
      case 'Interior Details':
        return Icons.chair_outlined;
      case 'Property Location':
        return Icons.location_on_outlined;
      case 'Property Images':
        return Icons.image_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.primary)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            width: 1.5,
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 2, color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1.5, color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 2, color: colorScheme.error),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16, vertical: maxLines > 1 ? 20 : 0),
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey[800]!.withOpacity(0.6)
            : Colors.grey[50]!.withOpacity(0.9),
      ),
    );
  }

  Widget buildDropdownField({
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Type of property",
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.primary)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            width: 1.5,
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 2, color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1.5, color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 2, color: colorScheme.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey[800]!.withOpacity(0.6)
            : Colors.grey[50]!.withOpacity(0.9),
      ),
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      validator: validator,
      value: selectedPropertyType,
      items: propertyTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (val) => setState(() => selectedPropertyType = val),
      icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
      isExpanded: true,
      dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
    );
  }

  Widget _buildAmenitiesSection(ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: _hasAmenityError
              ? colorScheme.error
              : Colors.grey.withOpacity(0.3),
          width: _hasAmenityError ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode
            ? Colors.grey[800]?.withOpacity(0.3)
            : Colors.grey[50]?.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: amenities.length,
          itemBuilder: (context, index) {
            String amenity = amenities.keys.elementAt(index);
            bool isSelected = amenities[amenity] ?? false;

            return _buildAmenityCard(
              amenity,
              isSelected,
              colorScheme,
              (value) {
                setState(() {
                  amenities[amenity] = value ?? false;
                  _hasAmenityError =
                      !amenities.values.any((selected) => selected);
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAmenityCard(String amenity, bool isSelected,
      ColorScheme colorScheme, Function(bool?) onChanged) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(isDarkMode ? 0.3 : 0.15)
              : isDarkMode
                  ? Colors.grey[700]
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primary
                      : isDarkMode
                          ? Colors.grey[600]
                          : Colors.grey[200],
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.grey.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  amenity,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteriorDetailsSection(ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: _hasInteriorError
              ? colorScheme.error
              : Colors.grey.withOpacity(0.3),
          width: _hasInteriorError ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode
            ? Colors.grey[800]?.withOpacity(0.3)
            : Colors.grey[50]?.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: interiorDetails.length,
          itemBuilder: (context, index) {
            String detail = interiorDetails.keys.elementAt(index);
            bool isSelected = interiorDetails[detail] ?? false;

            return _buildInteriorDetailCard(
              detail,
              isSelected,
              colorScheme,
              (value) {
                setState(() {
                  interiorDetails[detail] = value ?? false;
                  _hasInteriorError =
                      !interiorDetails.values.any((selected) => selected);
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInteriorDetailCard(String detail, bool isSelected,
      ColorScheme colorScheme, Function(bool?) onChanged) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(isDarkMode ? 0.3 : 0.15)
              : isDarkMode
                  ? Colors.grey[700]
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primary
                      : isDarkMode
                          ? Colors.grey[600]
                          : Colors.grey[200],
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.grey.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Listener(
      onPointerDown: (_) {
        // When touching the map, disable scrolling
        _scrollController.jumpTo(_scrollController.offset);
        setState(() {
          _isMapInteracting = true;
        });
      },
      onPointerUp: (_) {
        // When releasing touch, re-enable scrolling after a short delay
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {
            _isMapInteracting = false;
          });
        });
      },
      onPointerCancel: (_) {
        setState(() {
          _isMapInteracting = false;
        });
      },
      child: IgnorePointer(
        ignoring: _isMapInteracting,
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation,
                    zoom: 7,
                  ),
                  markers: markers,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  compassEnabled: false,
                  onTap: _updateMarkerPosition,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                    ),
                  },
                  onCameraMoveStarted: () {
                    setState(() {
                      _isMapInteracting = true;
                    });
                  },
                  onCameraIdle: () {
                    setState(() {
                      _isMapInteracting = false;
                    });
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.my_location, color: colorScheme.primary),
                      onPressed: () async {
                        // Here you would typically get current location
                        // For demo purposes we'll use a fixed location
                        final newPosition = LatLng(33.8880651, 35.5039614);
                        _updateMarkerPosition(newPosition);
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(newPosition, 16),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection(ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color:
              _hasImageError ? colorScheme.error : Colors.grey.withOpacity(0.3),
          width: _hasImageError ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode
            ? Colors.grey[800]?.withOpacity(0.3)
            : Colors.grey[50]?.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image picker button
          InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? colorScheme.primary.withOpacity(0.2)
                    : colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft:
                      _imageFiles.isEmpty ? Radius.circular(16) : Radius.zero,
                  bottomRight:
                      _imageFiles.isEmpty ? Radius.circular(16) : Radius.zero,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Select images',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Upload high-quality images of your property',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected images
          if (_imageFiles.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Selected Images (${_imageFiles.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFiles[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: () async {
        int id = await MongoDatabase.largest();
        id++;
setState(() {
  title=titleController.text;
});
        if (_validateForm()) {
          var db = await mongo.Db.create(mg.mongo_url);
          await db.open();
          var collection = db.collection("Property");
          await collection.insertOne({
            'Title': titleController.text,
            'Address': addressController.text,
            'Property_type': propertyTypes.toString(),
            'Price': priceController.text,
            'Bedroom': bedroomsController.text,
            'Bathroom': bathroomsController.text,
            'Kitchen': kitchensController.text,
            'Amenities': amenities.toString(),
            'Interior_details': interiorDetails.toString(),
            'location': {
              'latitude': selectedLocation!.latitude,
              'longitude': selectedLocation!.longitude,
            },
            'Image': await _convertImageFilesToBase64(_imageFiles),
            'ID': id,
            'Area': areaController.text,
            'Admit': false,
            'user':lg.username
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionPage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Property successfully uploaded!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),

          );
        } else {
          // Show validation error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fix the errors in the form'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Scroll to top to show errors
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: colorScheme.primary.withOpacity(0.5),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: Size(double.infinity, 60),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_rounded,
            size: 24,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Text(
            'Upload ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
