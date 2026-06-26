/// Spacing, sizing, and radius tokens for a consistent, kid-friendly layout.
///
/// Using named tokens (instead of magic numbers scattered through widgets)
/// keeps padding and corner radii uniform across every screen and makes a
/// global density change a one-line edit.
abstract final class AppSpacing {
  // Spacing scale (logical pixels).
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Corner radii — generously rounded for a soft, playful feel.
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 28;
  static const double radiusPill = 999;

  // Minimum interactive height — large, easy targets for small hands.
  static const double buttonHeight = 60;
  static const double inputHeight = 60;

  // Maximum content width on tablets/desktops so forms stay readable.
  static const double maxContentWidth = 520;
}
