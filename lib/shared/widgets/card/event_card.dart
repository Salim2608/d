import 'dart:convert';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imageData; // Can be either URL or base64 string
  final bool isBase64Image; // Flag to determine image type

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.imageData,
    this.isBase64Image = false, // Default to URL
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine the image widget based on image type
    Widget _buildImageWidget() {
      if (imageData.isEmpty) {
        return _buildPlaceholder(theme);
      }

      if (isBase64Image) {
        try {
          return Image.memory(
            base64Decode(imageData),
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
          );
        } catch (e) {
          return _buildPlaceholder(theme);
        }
      } else {
        return FadeInImage.assetNetwork(
          placeholder: 'assets/images/placeholder.jpg',
          image: imageData,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
        );
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: theme.cardTheme.color,
      child: Stack(
        children: [
          // Background image with hero animation
          Hero(
            tag: imageData.isNotEmpty ? imageData : 'placeholder_$title',
            child: _buildImageWidget(),
          ),

          // Gradient overlay
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Event information
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event title
                Text(
                  title.isNotEmpty ? title.toUpperCase() : 'NO TITLE',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Date and location row
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      date.isNotEmpty ? date : 'No date specified',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location.isNotEmpty
                            ? location
                            : 'Location not specified',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
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
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      height: 220,
      color: theme.colorScheme.surface,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 48, color: theme.colorScheme.onSurface),
          const SizedBox(height: 8),
          Text('Image not available', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}