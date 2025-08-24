// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // --- PLAYFUL PALETTE ---
  static const Color _primary = Color(0xFF6C63FF); // Bright Purple
  static const Color _secondary = Color(0xFF00BFA6); // Vibrant Teal
  static const Color _lightBg = Color(0xFFF2F2F7);
  static const Color _darkBg = Color(0xFF1C1C1E);
  static const Color _lightSurface = Colors.white;
  static const Color _darkSurface = Color(0xFF2C2C2E);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBg,
    primaryColor: _primary,
    textTheme: GoogleFonts.comicNeueTextTheme(
      ThemeData.light().textTheme,
    ), // Comic Neue is a great alternative
    colorScheme: const ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
      background: _lightBg,
      surface: _lightSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(), // Pill-shaped buttons
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBg,
    primaryColor: _secondary,
    textTheme: GoogleFonts.comicNeueTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: _secondary,
      secondary: _primary,
      background: _darkBg,
      surface: _darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _secondary,
        foregroundColor: _darkBg,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
