import 'package:flutter/material.dart';

class AttachmentOptions extends StatelessWidget {
  final Animation<double> animation;

  const AttachmentOptions({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF23233A),
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(Icons.photo, Colors.purple, 'Gallery'),
                _buildAttachmentOption(Icons.camera_alt, Colors.pink, 'Camera'),
                _buildAttachmentOption(
                    Icons.insert_drive_file, Colors.amber, 'Document'),
                _buildAttachmentOption(
                    Icons.location_on, Colors.green, 'Location'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
