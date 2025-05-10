// Blue template
import 'dart:ui';

import 'package:darlink/constants/colors/colors_template.dart';

class BlueTemplate implements ColorTemplate {
  @override
  Color get primary => Color(0xFF2196F3);
  @override
  Color get primaryLight => Color(0xFF64B5F6);
  @override
  Color get primaryDark => Color(0xFF1565C0);
  @override
  Color get secondary => Color(0xFF03A9F4);
  @override
  Color get secondaryLight => Color(0xFF4FC3F7);
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
  Color get background => Color(0xFFE3F2FD);
  @override
  Color get backgroundDark => Color(0xFF0D47A1);
  @override
  Color get surface => Color(0xFFE1F5FE);
  @override
  Color get cardBackground => Color(0xFFFFFFFF);
  @override
  Color get cardDarkBackground => Color(0xFF1565C0);
  @override
  Color get divider => Color(0xFFBBDEFB);
  @override
  Color get dividerDark => Color(0xFF1976D2);
  @override
  Color get success => Color(0xFF388E3C);
  @override
  Color get warning => Color(0xFFFFA000);
  @override
  Color get error => Color(0xFFD32F2F);
  @override
  Color get info => Color(0xFF1976D2);
  @override
  Color get disabled => Color(0xFFBBDEFB);
  @override
  Color get disabledDark => Color(0xFF1976D2);
}
