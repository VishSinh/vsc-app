import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';

/// Screen size categories for responsive design
enum ScreenSize { mobile, tablet, desktop }

/// Centralized responsive utilities for consistent breakpoint usage
class ResponsiveUtils {
  /// Get the current screen size based on width
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < AppConfig.mobileBreakpoint) {
      return ScreenSize.mobile;
    } else if (width < AppConfig.tabletBreakpoint) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) => getScreenSize(context) == ScreenSize.mobile;

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) => getScreenSize(context) == ScreenSize.tablet;

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) => getScreenSize(context) == ScreenSize.desktop;

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
        return 3;
    }
  }

  /// Get responsive child aspect ratio for grids
  static double getGridChildAspectRatio(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return 0.9; // More compact cards on mobile
      case ScreenSize.tablet:
        return 0.8;
      case ScreenSize.desktop:
        return 0.7;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return EdgeInsets.all(AppConfig.defaultPadding);
      case ScreenSize.tablet:
        return EdgeInsets.all(AppConfig.largePadding);
      case ScreenSize.desktop:
        return EdgeInsets.all(AppConfig.largePadding * 1.5);
    }
  }

  /// Get responsive max width for containers
  static double getResponsiveMaxWidth(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return AppConfig.maxWidthLarge;
      case ScreenSize.desktop:
        return AppConfig.maxWidthXLarge;
    }
  }

  /// Get responsive form width (for login, forms, etc.)
  static double getFormWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return width * 0.92; // Slightly more space for text
      case ScreenSize.tablet:
        return 500;
      case ScreenSize.desktop:
        return 600;
    }
  }

  /// Get responsive image dimensions
  static Size getResponsiveImageSize(BuildContext context, {double aspectRatio = 4 / 3}) {
    final width = MediaQuery.of(context).size.width;
    final imageWidth = width;
    final imageHeight = (imageWidth * aspectRatio);

    return Size(imageWidth, imageHeight);
  }

  /// Get responsive image width based on screen size
  static double getResponsiveImageWidth(BuildContext context, {double desktopFraction = 0.3, double mobileFraction = 0.6}) {
    final width = MediaQuery.of(context).size.width;
    return isDesktop(context) ? width * desktopFraction : width * mobileFraction;
  }

  /// Get responsive image height based on screen size
  static double getResponsiveImageHeight(BuildContext context, {double desktopFraction = 0.3, double mobileFraction = 0.6}) {
    final width = MediaQuery.of(context).size.width;
    return isDesktop(context) ? width * desktopFraction : width * mobileFraction;
  }

  /// Get responsive spacing between elements
  static double getResponsiveSpacing(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return AppConfig.defaultPadding;
      case ScreenSize.tablet:
        return AppConfig.largePadding;
      case ScreenSize.desktop:
        return AppConfig.largePadding * 1.5;
    }
  }

  /// Check if layout should be side-by-side (desktop) or stacked (mobile/tablet)
  static bool shouldUseSideBySideLayout(BuildContext context) {
    return isDesktop(context);
  }

  /// Get responsive navigation type
  static NavigationType getNavigationType(BuildContext context) {
    if (isMobile(context)) {
      return NavigationType.drawer;
    } else {
      return NavigationType.rail;
    }
  }
}

/// Navigation types for responsive layout
enum NavigationType { drawer, rail }

/// Extension for easier responsive checks
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => ResponsiveUtils.getScreenSize(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  int get gridCrossAxisCount => ResponsiveUtils.getGridCrossAxisCount(this);
  double get gridChildAspectRatio => ResponsiveUtils.getGridChildAspectRatio(this);
  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  double get responsiveMaxWidth => ResponsiveUtils.getResponsiveMaxWidth(this);
  double get formWidth => ResponsiveUtils.getFormWidth(this);
  double get responsiveSpacing => ResponsiveUtils.getResponsiveSpacing(this);
  bool get shouldUseSideBySideLayout => ResponsiveUtils.shouldUseSideBySideLayout(this);
  double getResponsiveImageWidth({double desktopFraction = 0.3, double mobileFraction = 0.6}) =>
      ResponsiveUtils.getResponsiveImageWidth(this, desktopFraction: desktopFraction, mobileFraction: mobileFraction);
  double getResponsiveImageHeight({double desktopFraction = 0.3, double mobileFraction = 0.6}) =>
      ResponsiveUtils.getResponsiveImageHeight(this, desktopFraction: desktopFraction, mobileFraction: mobileFraction);
}
