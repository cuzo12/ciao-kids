import 'package:flutter/material.dart';

/// Central color palette for Ciao Kids.
///
/// Colors are bright, warm, and high-contrast to suit a children's product
/// while keeping the Italian flag (green / white / red) as a visual anchor.
/// Both light and dark variants are defined here so the theming layer
/// ([app_theme.dart]) can switch between them without redeclaring values.
///
/// This class is not meant to be instantiated; every member is `static`.
abstract final class AppColors {
  // --- Brand ---------------------------------------------------------------

  /// Primary brand green (inspired by the Italian flag).
  static const Color primary = Color(0xFF2FBF71);
  static const Color primaryDark = Color(0xFF1F9D5A);
  static const Color primaryLight = Color(0xFF7FE3AD);

  /// Warm coral red — used for energy, errors, and the flag accent.
  static const Color secondary = Color(0xFFFF5C5C);
  static const Color secondaryDark = Color(0xFFE23B3B);

  /// Sunny yellow used for rewards (coins, stars, badges).
  static const Color accent = Color(0xFFFFC93C);

  /// Friendly sky blue used for informational accents.
  static const Color tertiary = Color(0xFF4DA6FF);

  // --- Light theme surfaces ------------------------------------------------

  static const Color backgroundLight = Color(0xFFFFF9F0);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1ECE3);
  static const Color textPrimaryLight = Color(0xFF2D2A32);
  static const Color textSecondaryLight = Color(0xFF6E6A75);

  // --- Dark theme surfaces -------------------------------------------------

  static const Color backgroundDark = Color(0xFF14141C);
  static const Color surfaceDark = Color(0xFF1E1E2A);
  static const Color surfaceVariantDark = Color(0xFF2A2A3A);
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFFB6B3C2);

  // --- Semantic ------------------------------------------------------------

  static const Color success = Color(0xFF2FBF71);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFE23B3B);
  static const Color info = Color(0xFF4DA6FF);

  // --- Gradients -----------------------------------------------------------

  /// Cheerful primary gradient used on hero surfaces and the splash screen.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, tertiary],
  );

  /// Warm reward gradient used on coin / streak badges.
  static const LinearGradient rewardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );
}
