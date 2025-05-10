import 'dart:ui';

abstract class ColorTemplate {
  // Primary colors
  Color get primary;
  Color get primaryLight;
  Color get primaryDark;

  // Secondary colors
  Color get secondary;
  Color get secondaryLight;
  Color get accent;

  // Text colors
  Color get textPrimary;
  Color get textSecondary;
  Color get textOnPrimary;
  Color get textOnDark;
  Color get textOnLight;

  // Background colors
  Color get background;
  Color get backgroundDark;
  Color get surface;

  // UI elements
  Color get cardBackground;
  Color get cardDarkBackground;
  Color get divider;
  Color get dividerDark;

  // Status colors
  Color get success;
  Color get warning;
  Color get error;
  Color get info;

  // Disabled states
  Color get disabled;
  Color get disabledDark;
}
