class Contact {
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String? typingStatus;

  Contact({
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
    this.typingStatus,
  });
}
