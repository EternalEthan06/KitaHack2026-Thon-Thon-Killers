import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF00C896); // Vibrant Teal-Green (SDG)
  static const Color primaryDark = Color(0xFF00957A);
  static const Color secondary = Color(0xFF6C63FF); // Purple accent
  static const Color background = Color(0xFF0A0E1A); // Deep dark blue
  static const Color surface = Color(0xFF141926); // Card surface
  static const Color surfaceVariant = Color(0xFF1E2535);
  static const Color onBackground = Color(0xFFF0F4FF);
  static const Color onSurface = Color(0xFFD0D8F0);
  static const Color onSurfaceMuted = Color(0xFF7B8DB0);
  static const Color error = Color(0xFFFF5C7A);
  static const Color warning = Color(0xFFFFB547);
  static const Color success = Color(0xFF00C896);

  // SDG Goal Colours (all 17)
  static const sdgColors = [
    Color(0xFFE5243B), // SDG 1 No Poverty
    Color(0xFFDDA63A), // SDG 2 Zero Hunger
    Color(0xFF4C9F38), // SDG 3 Good Health
    Color(0xFFC5192D), // SDG 4 Quality Education
    Color(0xFFFF3A21), // SDG 5 Gender Equality
    Color(0xFF26BDE2), // SDG 6 Clean Water
    Color(0xFFFCC30B), // SDG 7 Affordable Energy
    Color(0xFFA21942), // SDG 8 Decent Work
    Color(0xFFFD6925), // SDG 9 Industry
    Color(0xFFDD1367), // SDG 10 Reduced Inequalities
    Color(0xFFFD9D24), // SDG 11 Sustainable Cities
    Color(0xFFBF8B2E), // SDG 12 Responsible Consumption
    Color(0xFF3F7E44), // SDG 13 Climate Action
    Color(0xFF0A97D9), // SDG 14 Life Below Water
    Color(0xFF56C02B), // SDG 15 Life on Land
    Color(0xFF00689D), // SDG 16 Peace & Justice
    Color(0xFF19486A), // SDG 17 Partnerships
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: onSurfaceMuted),
        labelStyle: const TextStyle(color: onSurfaceMuted),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: onBackground,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: onBackground,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: onBackground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: onBackground,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: onSurface,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: onSurface,
          fontSize: 13,
        ),
        labelSmall: TextStyle(
          color: onSurfaceMuted,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceVariant,
        thickness: 1,
      ),
    );
  }
}
