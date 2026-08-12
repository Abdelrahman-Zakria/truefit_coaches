import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFDC143C);
  static const Color surfaceDark = Color(0xFF111111);
  static const Color background = Color(0xFF000000);
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color borderGrey = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF9E9E9E);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryRed,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      surface: surfaceDark,
    ),
  );
}
