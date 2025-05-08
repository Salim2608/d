import 'package:darlink/models/property.dart';
import 'package:darlink/shared/widgets/map/Virtual_tour.dart';
import 'package:darlink/shared/widgets/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
            onPressed: () => setState(() => isSaved = !isSaved),
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
            _buildSaveButton(theme, colors),
            const SizedBox(height: 24),
          ],
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
          // Property Image with Virtual Tour
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ExampleScreen1(title: 'Virtual Tour'),
                ),
              );
            },
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  widget.property.imageUrl,
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
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.ownerName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                          label: Text(
                            item,
                            style: textTheme.bodyMedium,
                          ),
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
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => map_page()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: const LatLng(37.4223, -122.0848),
                      zoom: 14,
                    ),
                    markers: {_marker}, // set of markers
                  ),
                ),
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
        onPressed: () => setState(() => isSaved = !isSaved),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSaved ? colors.secondary : colors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
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

final Marker _marker = Marker(
  markerId: MarkerId('initialMarker'),
  position: LatLng(37.4223, -122.0848),
  infoWindow: InfoWindow(title: 'Marker Title'),
);
