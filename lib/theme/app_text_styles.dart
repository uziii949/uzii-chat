import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Inter';


  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font, fontSize: 28,
    fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _font, fontSize: 22,
    fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.3,
  );


  static const TextStyle headingLarge = TextStyle(
    fontFamily: _font, fontSize: 18,
    fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.4,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _font, fontSize: 16,
    fontWeight: FontWeight.w600, letterSpacing: -0.1, height: 1.4,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: _font, fontSize: 14,
    fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.4,
  );


  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font, fontSize: 16,
    fontWeight: FontWeight.w400, letterSpacing: 0.1, height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font, fontSize: 14,
    fontWeight: FontWeight.w400, letterSpacing: 0.1, height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font, fontSize: 13,
    fontWeight: FontWeight.w400, letterSpacing: 0.1, height: 1.5,
  );


  static const TextStyle messageText = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w400, letterSpacing: 0.1, height: 1.45,
  );

  static const TextStyle messageTime = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w400, letterSpacing: 0.2,
  );

  static const TextStyle chatName = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w600, letterSpacing: -0.1,
  );

  static const TextStyle chatPreview = TextStyle(
    fontFamily: _font, fontSize: 13,
    fontWeight: FontWeight.w400, letterSpacing: 0.1, height: 1.4,
  );

  static const TextStyle unreadBadge = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w700, letterSpacing: 0.2,
    color: Colors.white,
  );


  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font, fontSize: 14,
    fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _font, fontSize: 12,
    fontWeight: FontWeight.w500, letterSpacing: 0.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w500, letterSpacing: 0.4,
  );


  static const TextStyle caption = TextStyle(
    fontFamily: _font, fontSize: 12,
    fontWeight: FontWeight.w400, letterSpacing: 0.3, height: 1.4,
  );

  static const TextStyle captionMuted = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w400, letterSpacing: 0.3,
    color: AppColors.textSecondaryLight,
  );
}