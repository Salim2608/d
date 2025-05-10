import 'package:flutter/material.dart';

class RecordingUI extends StatelessWidget {
  final Duration recordingDuration;
  final VoidCallback onDeletePressed;
  final VoidCallback onSendPressed;

  const RecordingUI({
    super.key,
    required this.recordingDuration,
    required this.onDeletePressed,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF2C2C44),
      child: Row(
        children: [
          const Icon(
            Icons.mic,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recording...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${recordingDuration.inMinutes.toString().padLeft(2, '0')}:${(recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: onDeletePressed,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: onSendPressed,
          ),
        ],
      ),
    );
  }
}
