import 'package:flutter/material.dart';

class AppColors {
  AppColors._();


  static const Color primary       = Color(0xFF6C63FF);
  static const Color primaryDark   = Color(0xFF4B44CC);
  static const Color primaryLight  = Color(0xFF9D97FF);
  static const Color accent        = Color(0xFF00D9A6);


  static const Color backgroundLight     = Color(0xFFF8F7FF);
  static const Color surfaceLight        = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEFEEFF);
  static const Color cardLight           = Color(0xFFFFFFFF);


  static const Color backgroundDark     = Color(0xFF0F0E17);
  static const Color surfaceDark        = Color(0xFF1A1928);
  static const Color surfaceVariantDark = Color(0xFF242338);
  static const Color cardDark           = Color(0xFF1E1D2E);


  static const Color textPrimaryLight   = Color(0xFF14131F);
  static const Color textSecondaryLight = Color(0xFF6B6880);
  static const Color textHintLight      = Color(0xFFAAABBE);


  static const Color textPrimaryDark    = Color(0xFFF0EFFF);
  static const Color textSecondaryDark  = Color(0xFFAAABBE);
  static const Color textHintDark       = Color(0xFF6B6880);

  static const Color bubbleSentLight     = Color(0xFF6C63FF);
  static const Color bubbleReceivedLight = Color(0xFFFFFFFF);
  static const Color bubbleSentDark      = Color(0xFF4B44CC);
  static const Color bubbleReceivedDark  = Color(0xFF1E1D2E);


  static const Color online  = Color(0xFF00D9A6);
  static const Color offline = Color(0xFF6B6880);
  static const Color error   = Color(0xFFFF4D6D);
  static const Color warning = Color(0xFFFFB347);
  static const Color success = Color(0xFF00D9A6);
  static const Color divider = Color(0xFFE8E7F0);
  static const Color dividerDark = Color(0xFF2A2940);


  static const Color tickSent      = Color(0xFFAAABBE);
  static const Color tickDelivered = Color(0xFFAAABBE);
  static const Color tickRead      = Color(0xFF00D9A6);


  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0F0E17), Color(0xFF1A1928), Color(0xFF242338)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}