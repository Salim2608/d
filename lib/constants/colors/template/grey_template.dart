// Grey template
import 'dart:ui';

import 'package:darlink/constants/colors/colors_template.dart';

class GreyTemplate implements ColorTemplate {
  @override
  Color get primary => Color(0xFF9E9E9E); // Medium grey (Material Grey 500)
  @override
  Color get primaryLight => Color(0xFFCFCFCF); // Light grey
  @override
  Color get primaryDark => Color(0xFF616161); // Dark grey

  @override
  Color get secondary => Color(0xFF757575); // Subtle secondary grey
  @override
  Color get secondaryLight => Color(0xFFBDBDBD); // Softer grey

  @override
  Color get accent => Color(0xFF212121); // Dark accent for contrast

  @override
  Color get textPrimary => Color(0xFF212121); // Near-black for strong text
  @override
  Color get textSecondary => Color(0xFF616161); // Muted grey for secondary text

  @override
  Color get textOnPrimary => Color(0xFFFFFFFF); // White on grey buttons
  @override
  Color get textOnDark => Color(0xFFFFFFFF); // On darker greys
  @override
  Color get textOnLight => Color(0xFF000000); // On lighter surfaces

  @override
  Color get background => Color(0xFFF5F5F5); // Very light grey background
  @override
  Color get backgroundDark => Color(0xFF424242); // Dark grey background

  @override
  Color get surface => Color(0xFFE0E0E0); // Surface grey (e.g., for containers)

  @override
  Color get cardBackground => Color(0xFFFFFFFF); // Cards in light mode
  @override
  Color get cardDarkBackground => Color(0xFF616161); // Cards in dark mode

  @override
  Color get divider => Color(0xFFBDBDBD); // Standard divider
  @override
  Color get dividerDark => Color(0xFF757575); // More visible in dark mode

  @override
  Color get success => Color(0xFF43A047); // Green for success
  @override
  Color get warning => Color(0xFFFFA000); // Orange for warnings
  @override
  Color get error => Color(0xFFD32F2F); // Red for errors
  @override
  Color get info => Color(0xFF1976D2); // Blue for info

  @override
  Color get disabled => Color(0xFFE0E0E0); // Light muted
  @override
  Color get disabledDark => Color(0xFF9E9E9E); // Muted grey for dark mode
}
