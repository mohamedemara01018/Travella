import 'package:flutter/material.dart';

class AppTheme {
  // ===================== CORE COLORS =====================

  // Primary Brand Blues (More premium & softer)
  static const Color primaryBlue = Color(0xFF4DA3FF);
  static const Color primaryBlueDark = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF93C5FD);

  // Accent (used for FABs, highlights)
  static const Color accentBlue = Color(0xFF38BDF8);

  // ===================== BACKGROUNDS =====================

  // Main background (deep futuristic dark)
  static const Color backgroundDark = Color(0xFF0B1220);

  // Cards & surfaces
  static const Color backgroundCard = Color(0xFF111A2E);
  static const Color backgroundCardLight = Color(0xFF1A2540);

  // ===================== TEXT =====================

  static const Color textPrimary = Color(0xFFE5E7EB); // soft white
  static const Color textSecondary = Color(0xFF9CA3AF); // muted gray
  static const Color textHint = Color(0xFF6B7280);

  // ===================== GRADIENTS =====================

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 49, 149, 255),
      Color.fromARGB(255, 37, 172, 235),
    ],
  );

  static const LinearGradient blueGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF93C5FD),
      Color(0xFF4DA3FF),
    ],
  );

  // ===================== DARK THEME =====================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryBlue,

    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: backgroundCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),

    fontFamily: 'Roboto',

    // ===================== APP BAR =====================
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),

    // ===================== CARDS =====================
    cardTheme: CardThemeData(
      color: backgroundCard,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // ===================== INPUTS =====================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundCardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.5,
        ),
      ),
      hintStyle: const TextStyle(color: textHint),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
    ),

    // ===================== BUTTONS =====================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentBlue,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ===================== FAB =====================
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentBlue,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // ===================== BOTTOM NAV =====================
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundCard,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ===================== TABS =====================
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryBlue,
      unselectedLabelColor: textSecondary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
