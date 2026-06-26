import 'package:flutter/widgets.dart';

/// Device size category derived from the available width.
enum DeviceType {
  /// Phones (< 600 logical px wide).
  mobile,

  /// Tablets (600–1023 logical px wide).
  tablet,

  /// Large tablets / desktop (>= 1024 logical px wide).
  desktop,
}

/// Lightweight responsive helper used to adapt layouts for phones vs tablets,
/// satisfying the brief's "tablet support" and "responsive layouts" goals.
///
/// Prefer [Responsive.of] inside `build` methods, or [Responsive.deviceType]
/// when only the category is needed.
abstract final class Responsive {
  /// Width (logical px) at/above which a layout is treated as a tablet.
  static const double tabletBreakpoint = 600;

  /// Width (logical px) at/above which a layout is treated as desktop-class.
  static const double desktopBreakpoint = 1024;

  /// Returns the [DeviceType] for the current [context].
  static DeviceType of(BuildContext context) =>
      deviceType(MediaQuery.sizeOf(context).width);

  /// Returns the [DeviceType] for an explicit [width] (handy for tests).
  static DeviceType deviceType(double width) {
    if (width >= desktopBreakpoint) return DeviceType.desktop;
    if (width >= tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Convenience: `true` when the layout is phone-sized.
  static bool isMobile(BuildContext context) =>
      of(context) == DeviceType.mobile;

  /// Returns one of three values based on the current device type.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (of(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}
