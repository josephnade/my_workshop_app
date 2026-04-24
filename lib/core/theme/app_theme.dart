import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

sealed class AppTheme {
  static const _borderRadius = 16.0;
  static const _elevation = 0.0;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1,
      titleLarge: AppTextStyles.heading2,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: _elevation,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading2,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: _elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.heading1.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: AppTextStyles.heading2.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.textPrimaryDark),
      bodySmall: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: _elevation,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  );
}
