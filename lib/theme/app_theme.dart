// THEME LOCK: light — source: domain signal (consumer emergency app, daytime use)
// Scaffold.backgroundColor = AppTheme.backgroundLight — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF009B74);
  static const Color primaryContainer = Color(0xFFCCF5EC);
  static const Color secondary = Color(0xFF1A1A2E);
  static const Color secondaryContainer = Color(0xFF2D2D44);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F7FA);
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color outlineLight = Color(0xFFE2E8F0);
  static const Color outlineVariantLight = Color(0xFFF1F5F9);

  // Dark surfaces
  static const Color surfaceDark = Color(0xFF1E2433);
  static const Color surfaceVariantDark = Color(0xFF252B3B);
  static const Color backgroundDark = Color(0xFF141822);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: secondary,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEEF2FF),
      onSecondaryContainer: secondary,
      surface: surfaceLight,
      onSurface: Color(0xFF1A1A2E),
      surfaceContainerHighest: surfaceVariantLight,
      onSurfaceVariant: Color(0xFF64748B),
      error: error,
      onError: Colors.white,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      shadow: Color(0x1A000000),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.dmSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: outlineLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariantLight,
      selectedColor: primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: outlineVariantLight,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF004D3A),
      onPrimaryContainer: Color(0xFFCCF5EC),
      secondary: Color(0xFF94A3B8),
      onSecondary: Colors.white,
      surface: surfaceDark,
      onSurface: Color(0xFFE2E8F0),
      surfaceContainerHighest: surfaceVariantDark,
      onSurfaceVariant: Color(0xFF94A3B8),
      error: Color(0xFFFC8181),
      onError: Colors.white,
      outline: Color(0xFF2D3748),
      outlineVariant: Color(0xFF1E2533),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.dmSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE2E8F0),
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE2E8F0),
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE2E8F0),
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE2E8F0),
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE2E8F0),
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE2E8F0),
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE2E8F0),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFCBD5E1),
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCBD5E1),
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCBD5E1),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE2E8F0),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFCBD5E1),
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8),
        ),
      ),
    ),
  );
}
