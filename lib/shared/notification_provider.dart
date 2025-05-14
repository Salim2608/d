import 'package:darlink/models/notification_preferences.dart';
import 'package:darlink/shared/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  late NotificationPreferences _preferences;

  NotificationPreferences get preferences => _preferences;

  bool get isLoaded => _isLoaded;
  bool _isLoaded = false;

  Future<void> loadPreferences() async {
    _preferences = await _service.loadPreferences();
    _isLoaded = true;
    notifyListeners();
  }

  void updatePreference(String key, bool value) {
    switch (key) {
      case 'general':
        _preferences.generalNotifications = value;
        break;
      case 'property':
        _preferences.newPropertyAlerts = value;
        break;
      case 'messages':
        _preferences.messagesFromSellers = value;
        break;
      case 'priceDrop':
        _preferences.priceDropAlerts = value;
        break;
      case 'muteAll':
        _preferences.muteAllNotifications = value;
        break;
    }

    _service.savePreferences(_preferences);
    notifyListeners();
  }
}
