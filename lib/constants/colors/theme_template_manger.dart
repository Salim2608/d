import 'package:darlink/constants/colors/colors_template.dart';
import 'package:darlink/constants/colors/template/blue_template.dart';
import 'package:darlink/constants/colors/template/grey_template.dart';
import 'package:darlink/constants/colors/template/green_template.dart';
import 'package:darlink/constants/colors/template/orange_template.dart';
import 'package:darlink/constants/colors/template/purple_template.dart';
import 'package:darlink/constants/colors/template/redBlack_template.dart';
import 'package:flutter/foundation.dart';

class ThemeTemplateManager {
  // Define available templates - all lowercase keys
  static final _templates = {
    'green': GreenTemplate(),
    'red': RedBlackTemplate(),
    'blue': BlueTemplate(),
    'orange': OrangeTemplate(),
    'purple': PurpleTemplate(),
    'grey': GreyTemplate(),
  };

  // Default theme
  static String _currentTheme = "green";

  // Getter for current template
  static ColorTemplate get currentTemplate {
    final template = _templates[_currentTheme];
    if (template == null) {
      print("WARNING: Theme $_currentTheme not found, using default");
      return _templates['green']!;
    }
    return template;
  }

  // Method to set the current theme
  static void setTheme(String themeName) {
    // Always convert to lowercase for consistency
    final normalizedName = themeName.toLowerCase();

    if (_templates.containsKey(normalizedName)) {
      if (_currentTheme != normalizedName) {
        print('Changing theme from $_currentTheme to $normalizedName');
        _currentTheme = normalizedName;
      }
    } else {
      print(
          'Theme "$normalizedName" not found, available themes: ${availableThemes.join(", ")}');
      _currentTheme = 'green'; // Fallback to default
    }
  }

  // Get all available theme names
  static List<String> get availableThemes => _templates.keys.toList();

  // Get a specific template by name
  static ColorTemplate getTemplate(String name) {
    final normalizedName = name.toLowerCase();
    final template = _templates[normalizedName];
    if (template == null) {
      print("WARNING: Template $normalizedName not found, using default");
      return _templates['green']!;
    }
    return template;
  }

  // Debug method to print all themes
  static void printAvailableThemes() {
    print("Available themes: ${availableThemes.join(", ")}");
    print("Current theme: $_currentTheme");
  }
}
