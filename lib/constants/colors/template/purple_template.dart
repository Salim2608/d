// Purple template
import 'dart:ui';

import 'package:darlink/constants/colors/colors_template.dart';

class PurpleTemplate implements ColorTemplate {
  @override
  Color get primary => Color(0xFF9C27B0); // Deep Purple
  @override
  Color get primaryLight => Color(0xFFD05CE3);
  @override
  Color get primaryDark => Color(0xFF6A0080);

  @override
  Color get secondary => Color(0xFF7B1FA2); // Accent Purple
  @override
  Color get secondaryLight => Color(0xFFBA68C8);

  @override
  Color get accent => Color(0xFFFFFFFF);

  @override
  Color get textPrimary => Color(0xFF212121);
  @override
  Color get textSecondary => Color(0xFF757575);

  @override
  Color get textOnPrimary => Color(0xFFFFFFFF);
  @override
  Color get textOnDark => Color(0xFFFFFFFF);
  @override
  Color get textOnLight => Color(0xFF000000);

  @override
  Color get background => Color(0xFFF3E5F5); // Light lavender background
  @override
  Color get backgroundDark => Color(0xFF4A148C);

  @override
  Color get surface => Color(0xFFF8EAF6); // Subtle purple-tinted white

  @override
  Color get cardBackground => Color(0xFFFFFFFF);
  @override
  Color get cardDarkBackground => Color(0xFF6A1B9A);

  @override
  Color get divider => Color(0xFFE1BEE7);
  @override
  Color get dividerDark => Color(0xFF8E24AA);

  @override
  Color get success => Color(0xFF66BB6A);
  @override
  Color get warning => Color(0xFFFFA000);
  @override
  Color get error => Color(0xFFD32F2F);
  @override
  Color get info => Color(0xFF1976D2);

  @override
  Color get disabled => Color(0xFFE1BEE7);
  @override
  Color get disabledDark => Color(0xFF7B1FA2);
}
