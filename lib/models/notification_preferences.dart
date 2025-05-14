class NotificationPreferences {
  bool generalNotifications;
  bool newPropertyAlerts;
  bool messagesFromSellers;
  bool priceDropAlerts;
  bool muteAllNotifications;

  NotificationPreferences({
    required this.generalNotifications,
    required this.newPropertyAlerts,
    required this.messagesFromSellers,
    required this.priceDropAlerts,
    required this.muteAllNotifications,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      generalNotifications: json['generalNotifications'],
      newPropertyAlerts: json['newPropertyAlerts'],
      messagesFromSellers: json['messagesFromSellers'],
      priceDropAlerts: json['priceDropAlerts'],
      muteAllNotifications: json['muteAllNotifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalNotifications': generalNotifications,
      'newPropertyAlerts': newPropertyAlerts,
      'messagesFromSellers': messagesFromSellers,
      'priceDropAlerts': priceDropAlerts,
      'muteAllNotifications': muteAllNotifications,
    };
  }
}
