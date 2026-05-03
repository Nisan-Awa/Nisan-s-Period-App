import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamWhite,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPink,
        primary: AppColors.primaryPink,
        secondary: AppColors.fertilePurple,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: Typography.material2021().black.apply(
        bodyColor: AppColors.deepText,
        displayColor: AppColors.deepText,
        fontFamily: 'Nunito',
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primaryPink,
        inactiveTrackColor: AppColors.lightRose,
        thumbColor: AppColors.primaryPink,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.midnightBackground,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.midnightViolet,
        primary: AppColors.midnightViolet,
        secondary: AppColors.midnightAmber,
        surface: AppColors.midnightSurface,
        brightness: Brightness.dark,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.midnightViolet,
        inactiveTrackColor: AppColors.midnightSurface,
        thumbColor: AppColors.midnightAmber,
      ),
    );
  }
}
