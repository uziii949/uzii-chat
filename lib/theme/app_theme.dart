import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();


  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary:          AppColors.primary,
        primaryContainer: AppColors.surfaceVariantLight,
        secondary:        AppColors.accent,
        surface:          AppColors.surfaceLight,
        error:            AppColors.error,
        onPrimary:        Colors.white,
        onSecondary:      Colors.white,
        onSurface:        AppColors.textPrimaryLight,
        onError:          Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor:        AppColors.surfaceLight,
        foregroundColor:        AppColors.textPrimaryLight,
        elevation:              0,
        scrolledUnderElevation: 1,
        shadowColor:            AppColors.divider,
        centerTitle:            false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor:                    Colors.transparent,
          statusBarIconBrightness:           Brightness.dark,
          systemNavigationBarColor:          AppColors.surfaceLight,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.headingLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryLight,
          size: 22,
        ),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   AppColors.surfaceVariantLight,
        hintStyle:   AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHintLight,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary, width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation:       0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle:       AppTextStyles.labelLarge,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color:     AppColors.divider,
        thickness: 0.5,
        space:     0,
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation:       4,
      ),
    );
  }


  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary:          AppColors.primary,
        primaryContainer: AppColors.surfaceVariantDark,
        secondary:        AppColors.accent,
        surface:          AppColors.surfaceDark,
        error:            AppColors.error,
        onPrimary:        Colors.white,
        onSecondary:      Colors.white,
        onSurface:        AppColors.textPrimaryDark,
        onError:          Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor:        AppColors.surfaceDark,
        foregroundColor:        AppColors.textPrimaryDark,
        elevation:              0,
        scrolledUnderElevation: 1,
        shadowColor:            AppColors.dividerDark,
        centerTitle:            false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor:                    Colors.transparent,
          statusBarIconBrightness:           Brightness.light,
          systemNavigationBarColor:          AppColors.surfaceDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.headingLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: 22,
        ),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.dividerDark, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.surfaceVariantDark,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHintDark,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryLight, width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation:       0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle:       AppTextStyles.labelLarge,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color:     AppColors.dividerDark,
        thickness: 0.5,
        space:     0,
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation:       4,
      ),
    );
  }
}