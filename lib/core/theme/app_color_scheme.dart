import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AppThemePalette { slateSage, midnight, paperInk, terracotta }

class AppColorScheme {
  const AppColorScheme({
    required this.palette,
    required this.name,
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.mutedText,
    required this.period,
    required this.fertile,
    required this.ovulation,
  });

  final AppThemePalette palette;
  final String name;
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color mutedText;
  final Color period;
  final Color fertile;
  final Color ovulation;

  static const slateSage = AppColorScheme(
    palette: AppThemePalette.slateSage,
    name: 'Slate & Sage',
    background: AppColors.slateBackground,
    surface: AppColors.slateSurface,
    primary: AppColors.slatePrimary,
    secondary: AppColors.slateSecondary,
    accent: AppColors.slateAccent,
    text: AppColors.slateText,
    mutedText: AppColors.slateMutedText,
    period: AppColors.periodPink,
    fertile: AppColors.fertilePurple,
    ovulation: AppColors.ovulationBlue,
  );

  static const midnight = AppColorScheme(
    palette: AppThemePalette.midnight,
    name: 'Midnight',
    background: AppColors.midnightBackground,
    surface: AppColors.midnightSurface,
    primary: AppColors.midnightViolet,
    secondary: AppColors.midnightAmber,
    accent: AppColors.midnightAmber,
    text: Color(0xFFF3F4F6),
    mutedText: Color(0xFFA4ADB8),
    period: AppColors.periodPink,
    fertile: AppColors.fertilePurple,
    ovulation: AppColors.ovulationBlue,
  );

  static const paperInk = AppColorScheme(
    palette: AppThemePalette.paperInk,
    name: 'Paper & Ink',
    background: AppColors.paperBackground,
    surface: Color(0xFFFFFCF6),
    primary: AppColors.paperInk,
    secondary: AppColors.paperLine,
    accent: AppColors.slatePrimary,
    text: AppColors.paperInk,
    mutedText: Color(0xFF756D62),
    period: AppColors.periodPink,
    fertile: AppColors.fertilePurple,
    ovulation: AppColors.ovulationBlue,
  );

  static const terracotta = AppColorScheme(
    palette: AppThemePalette.terracotta,
    name: 'Terracotta',
    background: AppColors.terracottaBackground,
    surface: Color(0xFFFFFCF8),
    primary: AppColors.terracottaClay,
    secondary: AppColors.terracottaOchre,
    accent: AppColors.slatePrimary,
    text: Color(0xFF332B28),
    mutedText: Color(0xFF7C6B63),
    period: AppColors.periodPink,
    fertile: AppColors.fertilePurple,
    ovulation: AppColors.ovulationBlue,
  );

  static const values = [slateSage, midnight, paperInk, terracotta];
}
