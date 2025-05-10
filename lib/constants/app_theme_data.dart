import 'package:flutter/material.dart';
import 'package:darlink/constants/colors/app_color.dart';

class AppThemeData {
  // Theme persistence

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary),
        displayMedium: TextStyle(color: AppColors.textPrimary),
        displaySmall: TextStyle(color: AppColors.textPrimary),
        headlineMedium: TextStyle(color: AppColors.textPrimary),
        headlineSmall: TextStyle(color: AppColors.textPrimary),
        titleLarge: TextStyle(color: AppColors.textPrimary),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        titleMedium: TextStyle(color: AppColors.textSecondary),
        titleSmall: TextStyle(color: AppColors.textOnLight),
        bodySmall: TextStyle(color: AppColors.textOnLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.textOnDark),
        displayMedium: TextStyle(color: AppColors.textOnDark),
        displaySmall: TextStyle(color: AppColors.textOnDark),
        headlineMedium: TextStyle(color: AppColors.textOnDark),
        headlineSmall: TextStyle(color: AppColors.textOnDark),
        titleLarge: TextStyle(color: AppColors.textOnDark),
        bodyLarge: TextStyle(color: AppColors.textOnDark),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        titleMedium: TextStyle(color: AppColors.textSecondary),
        titleSmall: TextStyle(color: Color(0xFF757575)),
        bodySmall: TextStyle(color: Color(0xFF757575)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDarkBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnDark),
        titleTextStyle: TextStyle(
          color: AppColors.textOnDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
