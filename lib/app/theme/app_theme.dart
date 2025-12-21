import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---------------------------
  // LIGHT THEME (your existing)
  // ---------------------------
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blueAccent,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      scaffoldBackgroundColor: Colors.grey[50],
    );
  }

  // ---------------------------
  // DARK THEME
  // ---------------------------
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  // ---------------------------
  // PINK MODE (cute, modern)
  // ---------------------------
  static ThemeData pink() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.pink,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      scaffoldBackgroundColor: const Color(0xFFFFF4F8),
    );
  }
}
