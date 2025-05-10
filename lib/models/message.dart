enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final bool isVoiceMessage;
  final Duration? voiceDuration;
  final bool isRead;
  final MessageStatus status;

  Message({
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.isVoiceMessage = false,
    this.voiceDuration,
    this.isRead = false,
    this.status = MessageStatus.sent,
  });
}
