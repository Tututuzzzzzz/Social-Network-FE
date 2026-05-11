import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.light.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.light.primary,
      surface: AppColors.light.scaffold,
      onPrimary: AppColors.light.appBarForeground,
      onSurface: AppColors.light.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.light.scaffold,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.light.appBar,
      foregroundColor: AppColors.light.appBarForeground,
      elevation: 0,
    ),
    useMaterial3: true,
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dark.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.dark.primary,
      surface: AppColors.dark.scaffold,
      onPrimary: AppColors.dark.appBarForeground,
      onSurface: AppColors.dark.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.dark.scaffold,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark.appBar,
      foregroundColor: AppColors.dark.appBarForeground,
      elevation: 0,
    ),
    useMaterial3: true,
  );
}
