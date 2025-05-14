import 'dart:convert';
import 'package:darlink/models/notification_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const _prefsKey = 'notification_preferences';

  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);

    if (jsonString != null) {
      return NotificationPreferences.fromJson(jsonDecode(jsonString));
    } else {
      final defaultPrefs = NotificationPreferences(
        generalNotifications: true,
        newPropertyAlerts: true,
        messagesFromSellers: true,
        priceDropAlerts: false,
        muteAllNotifications: false,
      );
      await savePreferences(defaultPrefs);
      return defaultPrefs;
    }
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(preferences.toJson());
    await prefs.setString(_prefsKey, jsonString);
  }
}
