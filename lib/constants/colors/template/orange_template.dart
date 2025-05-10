// Orange template
import 'dart:ui';

import 'package:darlink/constants/colors/colors_template.dart';

class OrangeTemplate implements ColorTemplate {
  @override
  Color get primary => Color(0xFFFF9800); // Vivid orange
  @override
  Color get primaryLight => Color(0xFFFFC947); // Lighter orange
  @override
  Color get primaryDark => Color(0xFFF57C00); // Deeper orange

  @override
  Color get secondary => Color(0xFFFFA726); // Muted orange
  @override
  Color get secondaryLight => Color(0xFFFFD95A); // Light accent

  @override
  Color get accent => Color(0xFFFFFFFF); // Contrast white

  @override
  Color get textPrimary => Color(0xFF212121); // Standard dark text
  @override
  Color get textSecondary => Color(0xFF757575); // Secondary text

  @override
  Color get textOnPrimary => Color(0xFFFFFFFF); // For buttons, etc.
  @override
  Color get textOnDark => Color(0xFFFFFFFF);
  @override
  Color get textOnLight => Color(0xFF000000);

  @override
  Color get background => Color(0xFFFFF3E0); // Pale orange background
  @override
  Color get backgroundDark => Color(0xFFE65100); // Strong orange background

  @override
  Color get surface => Color(0xFFFFF8E1); // Soft surface color

  @override
  Color get cardBackground => Color(0xFFFFFFFF); // Cards on light mode
  @override
  Color get cardDarkBackground => Color(0xFFF57C00); // Cards on dark mode

  @override
  Color get divider => Color(0xFFFFE0B2); // Light divider
  @override
  Color get dividerDark => Color(0xFFFB8C00); // Dark divider

  @override
  Color get success => Color(0xFF43A047); // Green for success
  @override
  Color get warning => Color(0xFFFFA000); // Matches theme
  @override
  Color get error => Color(0xFFD32F2F); // Red for error
  @override
  Color get info => Color(0xFF1976D2); // Blue info

  @override
  Color get disabled => Color(0xFFFFE0B2); // Muted orange
  @override
  Color get disabledDark => Color(0xFFFB8C00); // Deep muted orange
}
