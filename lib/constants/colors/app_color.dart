import 'dart:ui';

import 'package:darlink/constants/colors/theme_template_manger.dart';

class AppColors {
  // Primary colors
  static Color get primary => ThemeTemplateManager.currentTemplate.primary;
  static Color get primaryLight =>
      ThemeTemplateManager.currentTemplate.primaryLight;
  static Color get primaryDark =>
      ThemeTemplateManager.currentTemplate.primaryDark;

  // Secondary colors
  static Color get secondary => ThemeTemplateManager.currentTemplate.secondary;
  static Color get secondaryLight =>
      ThemeTemplateManager.currentTemplate.secondaryLight;
  static Color get accent => ThemeTemplateManager.currentTemplate.accent;

  // Text colors
  static Color get textPrimary =>
      ThemeTemplateManager.currentTemplate.textPrimary;
  static Color get textSecondary =>
      ThemeTemplateManager.currentTemplate.textSecondary;
  static Color get textOnPrimary =>
      ThemeTemplateManager.currentTemplate.textOnPrimary;
  static Color get textOnDark =>
      ThemeTemplateManager.currentTemplate.textOnDark;
  static Color get textOnLight =>
      ThemeTemplateManager.currentTemplate.textOnLight;

  // Background colors
  static Color get background =>
      ThemeTemplateManager.currentTemplate.background;
  static Color get backgroundDark =>
      ThemeTemplateManager.currentTemplate.backgroundDark;
  static Color get surface => ThemeTemplateManager.currentTemplate.surface;

  // UI elements
  static Color get cardBackground =>
      ThemeTemplateManager.currentTemplate.cardBackground;
  static Color get cardDarkBackground =>
      ThemeTemplateManager.currentTemplate.cardDarkBackground;
  static Color get divider => ThemeTemplateManager.currentTemplate.divider;
  static Color get dividerDark =>
      ThemeTemplateManager.currentTemplate.dividerDark;

  // Status colors
  static Color get success => ThemeTemplateManager.currentTemplate.success;
  static Color get warning => ThemeTemplateManager.currentTemplate.warning;
  static Color get error => ThemeTemplateManager.currentTemplate.error;
  static Color get info => ThemeTemplateManager.currentTemplate.info;

  // Disabled states
  static Color get disabled => ThemeTemplateManager.currentTemplate.disabled;
  static Color get disabledDark =>
      ThemeTemplateManager.currentTemplate.disabledDark;
}
