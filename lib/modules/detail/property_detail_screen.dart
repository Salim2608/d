import 'dart:typed_data';
import 'dart:convert';

import 'package:darlink/models/property.dart';
import 'package:darlink/shared/widgets/map/Virtual_tour.dart';
import 'package:darlink/shared/widgets/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../../constants/Database_url.dart' as mg;
import '../authentication/login_screen.dart' as lg;
import '../navigation/proprty_transaction.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  _PropertyDetailsScreenState createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool amenitiesExpanded = false;
  bool interiorExpanded = false;
  bool constructionExpanded = false;
  bool isSaved = false;
  bool isLoadingSave = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    try {
      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      var collection = db.collection("user");

      var user = await collection.findOne(
          mongo.where.eq('Email', lg.usermail),
      );

      if (user != null && user['whishlist'] != null) {
        setState(() {
          isSaved = (user['whishlist'] as List).contains(widget.property.id);
        });
      }
    } catch (e) {
      print('Error checking saved status: $e');
    }
  }

  Image base64ToImage(String base64String) {
    return Image.memory(
      base64.decode(base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String),
      errorBuilder: (_, __, ___) => const Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colors.onPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Property Details',
          style: textTheme.titleLarge?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: colors.onPrimary,
            ),
            onPressed: () => _toggleSaveProperty(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyCard(theme, colors, textTheme),
            _buildAgentCard(theme, colors, textTheme),
            _buildExpandableSection(
              theme,
              colors,
              textTheme,
              'Amenities',
              widget.property.amenities,
              amenitiesExpanded,
                  () => setState(() => amenitiesExpanded = !amenitiesExpanded),
            ),
            _buildExpandableSection(
              theme,
              colors,
              textTheme,
              'Interior Details',
              widget.property.interiorDetails,
              interiorExpanded,
                  () => setState(() => interiorExpanded = !interiorExpanded),
            ),
            _buildLocationSection(theme, colors, textTheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: _showTransactionInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.secondary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Transaction Info',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSecondary,
                  ),
                ),
              ),
            ),
            _buildSaveButton(theme, colors),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSaveProperty() async {
    setState(() => isLoadingSave = true);
    try {
      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      var collection = db.collection("user");

      var updateOperation = isSaved
          ? mongo.modify.pull('whishlist', widget.property.id)
          : mongo.modify.push('whishlist', widget.property.id);

      await collection.update(
        mongo.where.eq('Email', lg.usermail),
        updateOperation,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved
              ? 'Removed from wishlist'
              : 'Added to wishlist'),
        ),
      );

      setState(() => isSaved = !isSaved);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error updating wishlist: $e');
    } finally {
      setState(() => isLoadingSave = false);
    }
  }

  void _showTransactionInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyTransaction(
          price: widget.property.price.toString(),
          owner: widget.property.ownerName,
          title: widget.property.title,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(
      ThemeData theme, ColorScheme colors, TextTheme textTheme) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const ExampleScreen3(title: 'Virtual Tour'),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.memory(
                  base64Decode(widget.property.imageUrl[0]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colors.surfaceVariant,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.property.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '\$${widget.property.price.toStringAsFixed(0)}',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: colors.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.property.address,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.property.area} sqft',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeatureChip(
                      icon: Icons.bed,
                      label: '${widget.property.bedrooms} Beds',
                      color: colors.primary,
                      theme: theme,
                    ),
                    _buildFeatureChip(
                      icon: Icons.bathtub,
                      label: '${widget.property.bathrooms} Baths',
                      color: colors.primary,
                      theme: theme,
                    ),
                    _buildFeatureChip(
                      icon: Icons.kitchen,
                      label: '${widget.property.kitchens} Kitchen',
                      color: colors.primary,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(
      ThemeData theme, ColorScheme colors, TextTheme textTheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.primary.withOpacity(0.1),
              child: Text(
                widget.property.ownerName.substring(0, 1),
                style: textTheme.titleLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.property.ownerName,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
      ThemeData theme,
      ColorScheme colors,
      TextTheme textTheme,
      String title,
      List<String> items,
      bool isExpanded,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: colors.onSurface.withOpacity(0.6),
            ),
            onTap: onTap,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items
                    .map((item) => Chip(
                  backgroundColor: colors.surfaceVariant,
                  label: Text(item, style: textTheme.bodyMedium),
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(
      ThemeData theme, ColorScheme colors, TextTheme textTheme) {
    final LatLng propertyLatLng = LatLng(widget.property.lang, widget.property.lat);

    final Marker propertyMarker = Marker(
      markerId: const MarkerId('propertyMarker'),
      position: propertyLatLng,
      infoWindow: InfoWindow(title: widget.property.title),
    );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Location',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: propertyLatLng,
                  zoom: 7,
                ),
                markers: {propertyMarker},
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: isLoadingSave ? null : _toggleSaveProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSaved ? colors.secondary : colors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoadingSave
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          isSaved ? 'PROPERTY SAVED' : 'SAVE THIS PROPERTY',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }
}