import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get nightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.nightBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.nightGoldPrimary,
        secondary: AppColors.nightOrangeAccent,
        surface: AppColors.nightSurface,
        background: AppColors.nightBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.nightBackground,
        elevation: 0,
        titleTextStyle: AppColors.nightPrimaryText  != null
            ? AppTypography.displaySmall.copyWith(
                color: AppColors.nightPrimaryText,
              )
            : AppTypography.displaySmall,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayXl.copyWith(
          color: AppColors.nightPrimaryText,
        ),
        displayMedium: AppTypography.displayLg.copyWith(
          color: AppColors.nightPrimaryText,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.nightPrimaryText,
        ),
        bodyLarge: AppTypography.bodyLg.copyWith(
          color: AppColors.nightPrimaryText,
        ),
        bodyMedium: AppTypography.bodyMd.copyWith(
          color: AppColors.nightPrimaryText,
        ),
        labelLarge: AppTypography.labelLg.copyWith(
          color: AppColors.nightPrimaryText,
        ),
        labelSmall: AppTypography.labelSm.copyWith(
          color: AppColors.nightSecondaryText,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.nightSecondaryText,
        ),
      ),
    );
  }

  static ThemeData get parchmentTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.parchmentBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.parchmentGoldPrimary,
        secondary: AppColors.parchmentOrangeAccent,
        surface: AppColors.parchmentSurface,
        background: AppColors.parchmentBackground,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayXl.copyWith(
          color: AppColors.parchmentPrimaryText,
        ),
        displayMedium: AppTypography.displayLg.copyWith(
          color: AppColors.parchmentPrimaryText,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.parchmentPrimaryText,
        ),
        bodyLarge: AppTypography.bodyLg.copyWith(
          color: AppColors.parchmentPrimaryText,
        ),
        bodyMedium: AppTypography.bodyMd.copyWith(
          color: AppColors.parchmentPrimaryText,
        ),
        labelLarge: AppTypography.labelLg.copyWith(
          color: AppColors.parchmentPrimaryText,
        ),
        labelSmall: AppTypography.labelSm.copyWith(
          color: AppColors.parchmentSecondaryText,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.parchmentSecondaryText,
        ),
      ),
    );
  }

  static ThemeData get silverTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.silverBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.silverGoldPrimary,
        secondary: AppColors.silverOrangeAccent,
        surface: AppColors.silverSurface,
        background: AppColors.silverBackground,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayXl.copyWith(
          color: AppColors.silverPrimaryText,
        ),
        displayMedium: AppTypography.displayLg.copyWith(
          color: AppColors.silverPrimaryText,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.silverPrimaryText,
        ),
        bodyLarge: AppTypography.bodyLg.copyWith(
          color: AppColors.silverPrimaryText,
        ),
        bodyMedium: AppTypography.bodyMd.copyWith(
          color: AppColors.silverPrimaryText,
        ),
        labelLarge: AppTypography.labelLg.copyWith(
          color: AppColors.silverPrimaryText,
        ),
        labelSmall: AppTypography.labelSm.copyWith(
          color: AppColors.silverSecondaryText,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.silverSecondaryText,
        ),
      ),
    );
  }
}
