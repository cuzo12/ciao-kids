import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale for Ciao Kids.
///
/// Headings use **Fredoka** (rounded, playful) and body copy uses **Nunito**
/// (highly legible for early readers). Both are loaded via `google_fonts`, so
/// no font binaries need to ship in the bundle for Milestone 1.
///
/// [textTheme] returns a [TextTheme] whose colors are resolved for the given
/// [onSurface] color, allowing the same scale to serve light and dark themes.
abstract final class AppTypography {
  /// Builds the app-wide [TextTheme] tinted for the supplied [onSurface] color.
  static TextTheme textTheme(Color onSurface) {
    final Color muted = onSurface.withValues(alpha: 0.7);

    return TextTheme(
      // Display / hero text.
      displayLarge: GoogleFonts.fredoka(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: onSurface,
      ),

      // Section headings.
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),

      // Titles (cards, list items).
      titleLarge: GoogleFonts.fredoka(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),

      // Body copy.
      bodyLarge: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: muted,
      ),

      // Labels (buttons, chips, captions).
      labelLarge: GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: muted,
      ),
    );
  }

  /// Convenience accessor for the light-mode text theme.
  static TextTheme get light => textTheme(AppColors.textPrimaryLight);

  /// Convenience accessor for the dark-mode text theme.
  static TextTheme get dark => textTheme(AppColors.textPrimaryDark);
}
