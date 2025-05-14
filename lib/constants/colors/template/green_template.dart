// Green template
import 'dart:ui';

import 'package:darlink/constants/colors/colors_template.dart';

class GreenTemplate implements ColorTemplate {
  @override
  Color get primary => Color(0xFF4CAF50);
  @override
  Color get primaryLight => Color(0xFF81C784);
  @override
  Color get primaryDark => Color(0xFF2E7D32);
  @override
  Color get secondary => Color(0xFF8BC34A);
  @override
  Color get secondaryLight => Color(0xFFAED581);
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
  Color get background => Color(0xFFF1F8E9);
  @override
  Color get backgroundDark => Color(0xFF1B5E20);
  @override
  Color get surface => Color(0xFFF9FBE7);
  @override
  Color get cardBackground => Color(0xFFFFFFFF);
  @override
  Color get cardDarkBackground => Color(0xFF2E7D32);
  @override
  Color get divider => Color(0xFFDCEDC8);
  @override
  Color get dividerDark => Color(0xFF388E3C);
  @override
  Color get success => Color(0xFF388E3C);
  @override
  Color get warning => Color(0xFFFFA000);
  @override
  Color get error => Color(0xFFD32F2F);
  @override
  Color get info => Color(0xFF1976D2);
  @override
  Color get disabled => Color(0xFFC8E6C9);
  @override
  Color get disabledDark => Color(0xFF689F38);
}
