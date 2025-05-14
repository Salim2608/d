import 'package:darlink/models/message.dart';

import 'package:darlink/shared/widgets/chat_widget/audio_waveform.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: const NetworkImage(
                            'https://randomuser.me/api/portraits/men/32.jpg'),
                        radius: 16,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF1A1A2E), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Flexible(
                child: Container(
                  padding: message.isVoiceMessage
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                      : const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? Colors.deepPurple
                        : const Color(
                            0xFF2C2C44), // Changed from blue to violet
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: message.isVoiceMessage
                      ? _buildVoiceMessage()
                      : Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              if (message.isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _buildMessageStatus(),
                ),
            ],
          ),
          if (showTime)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8, left: 8),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage() {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Text(
            '${message.voiceDuration!.inMinutes}:${(message.voiceDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: CustomPaint(
                  painter: AudioWaveformPainter(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple, // Changed to violet
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    switch (message.status) {
      case MessageStatus.sending:
        return Container(
          width: 16,
          height: 16,
          padding: const EdgeInsets.all(2),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey[400],
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 16,
          color: Colors.grey[400],
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey[400],
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.deepPurple, // Changed from blue to violet
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}
