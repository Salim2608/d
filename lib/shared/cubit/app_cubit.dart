import 'package:darlink/constants/colors/theme_template_manger.dart';
import 'package:darlink/shared/cubit/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCubit extends Cubit<AppCubitState> {
  AppCubit() : super(AppInitialState()) {
    // Load saved theme when app starts
    loadSavedTheme();
  }

  static AppCubit get(context) => BlocProvider.of(context);

  // Current theme color (defaults to 'green' if not set)
  String _currentColor = 'green';

  String get currentColor => _currentColor;

  // Method to change the theme
  Future<void> changeTheme(String themeName) async {
    // Convert to lowercase to match theme keys
    final normalizedThemeName = themeName.toLowerCase();

    // Only proceed if the theme is valid and different from current
    if (ThemeTemplateManager.availableThemes.contains(normalizedThemeName) &&
        _currentColor != normalizedThemeName) {
      // Update the theme in ThemeTemplateManager
      ThemeTemplateManager.setTheme(normalizedThemeName);

      // Update the current color in cubit
      _currentColor = normalizedThemeName;

      // Save the theme preference
      await _saveThemePreference(normalizedThemeName);

      // Emit new state to notify listeners of theme change
      emit(AppThemeChangedState(normalizedThemeName));

      // Emit refresh state to force UI rebuild
      Future.delayed(Duration(milliseconds: 100), () {
        emit(AppRefreshState());
      });
    }
  }

  // Load the saved theme from SharedPreferences
  Future<void> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('app_theme') ?? 'green';

      // If saved theme exists and is valid, use it
      if (ThemeTemplateManager.availableThemes.contains(savedTheme)) {
        // Set theme in manager first
        ThemeTemplateManager.setTheme(savedTheme);
        // Update current color
        _currentColor = savedTheme;
        // Emit state change
        emit(AppThemeChangedState(savedTheme));
      }
    } catch (e) {
      print('Error loading saved theme: $e');
      // Fallback to default theme in case of error
      ThemeTemplateManager.setTheme('green');
      _currentColor = 'green';
    }
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(String themeName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme', themeName);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  // Force full app refresh
  void forceRefresh() {
    emit(AppRefreshState());
  }
}
