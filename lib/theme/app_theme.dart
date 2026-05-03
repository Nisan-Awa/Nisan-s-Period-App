import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Slate & Sage - Default Theme
  static const Color primarySlate = Color(0xFF5E6D7E);
  static const Color backgroundLight = Color(0xFFF7F9FA);
  static const Color sageGreen = Color(0xFF8F9E8B);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  static ThemeData get slateAndSage {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primarySlate,
      colorScheme: const ColorScheme.light(
        primary: primarySlate,
        secondary: sageGreen,
        surface: surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: textPrimary),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primarySlate,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primarySlate,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
      ),
    );
  }
}
