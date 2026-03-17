import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText   = false,
    this.keyboardType  = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.maxLines      = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller:   controller,
      obscureText:  obscureText,
      keyboardType: keyboardType,
      validator:    validator,
      maxLines:     obscureText ? 1 : maxLines,
      style: AppTextStyles.bodyMedium.copyWith(

        color: scheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText:  hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(

          color: isDark
              ? AppColors.textHintDark
              : AppColors.textHintLight,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,

          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          size: 20,
        )
            : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(
          onTap: onSuffixTap,
          child: Icon(
            suffixIcon,
            // ✅ Theme se color
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            size: 20,
          ),
        )
            : null,
        filled:    true,
        fillColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.dividerDark
                : AppColors.divider,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical:   AppSizes.paddingM,
        ),
      ),
    );
  }
}