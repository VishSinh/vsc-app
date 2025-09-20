import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

/// Responsive text utility that provides consistent text styles
/// Can easily switch between ScreenUtil and fixed values for testing
class ResponsiveText {
  // Toggle this to switch between responsive and fixed sizing
  static const bool _useScreenUtil = false; // Set to true to use ScreenUtil, false for fixed values

  // Helper method to get responsive or fixed font size
  static double _getFontSize(double fixedSize) {
    if (_useScreenUtil) {
      return fixedSize.sp;
    }
    return fixedSize;
  }

  // Helper method to get responsive or fixed width/height
  static double _getDimension(double fixedSize) {
    if (_useScreenUtil) {
      return fixedSize.w;
    }
    return fixedSize;
  }

  // Helper method to get responsive or fixed radius
  static double _getRadius(double fixedSize) {
    if (_useScreenUtil) {
      return fixedSize.r;
    }
    return fixedSize;
  }

  // Headline styles
  static TextStyle getHeadline(BuildContext context) => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: _getFontSize(32.0),
    fontWeight: AppConfig.fontWeightBold,
    color: AppConfig.textColorPrimary,
  );

  static TextStyle getTitle(BuildContext context) => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: _getFontSize(24.0),
    fontWeight: AppConfig.fontWeightSemiBold,
    color: AppConfig.textColorPrimary,
  );

  static TextStyle getSubtitle(BuildContext context) => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: _getFontSize(18.0),
    fontWeight: AppConfig.fontWeightMedium,
    color: AppConfig.textColorSecondary,
  );

  static TextStyle getBody(BuildContext context) => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: _getFontSize(16.0),
    fontWeight: AppConfig.fontWeightNormal,
    color: AppConfig.textColorPrimary,
  );

  static TextStyle getCaption(BuildContext context) => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: _getFontSize(14.0),
    fontWeight: AppConfig.fontWeightNormal,
    color: AppConfig.textColorMuted,
  );

  static TextStyle getButton(BuildContext context) => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: _getFontSize(16.0),
    fontWeight: AppConfig.fontWeightMedium,
    color: AppConfig.textColorPrimary,
  );

  // Alternative method names for consistency
  static TextStyle getHeadlineStyle(BuildContext context) => getHeadline(context);
  static TextStyle getTitleStyle(BuildContext context) => getTitle(context);
  static TextStyle getSubtitleStyle(BuildContext context) => getSubtitle(context);
  static TextStyle getBodyStyle(BuildContext context) => getBody(context);
  static TextStyle getCaptionStyle(BuildContext context) => getCaption(context);
  static TextStyle getButtonStyle(BuildContext context) => getButton(context);

  // Responsive text scaling utilities
  static TextStyle getResponsiveText(BuildContext context, {double baseSize = 16.0, FontWeight? weight}) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: _getFontSize(baseSize),
      fontWeight: weight ?? AppConfig.fontWeightNormal,
      color: AppConfig.textColorPrimary,
    );
  }

  // Responsive text with custom color
  static TextStyle getResponsiveTextWithColor(BuildContext context, {double baseSize = 16.0, FontWeight? weight, Color? color}) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: _getFontSize(baseSize),
      fontWeight: weight ?? AppConfig.fontWeightNormal,
      color: color ?? AppConfig.textColorPrimary,
    );
  }

  // Responsive text for specific screen sizes
  static TextStyle getResponsiveTextForScreen(
    BuildContext context, {
    double mobileSize = 14.0,
    double tabletSize = 16.0,
    double desktopSize = 18.0,
    FontWeight? weight,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double fontSize = mobileSize; // Default to mobile size

    switch (screenSize) {
      case ScreenSize.mobile:
        fontSize = mobileSize;
        break;
      case ScreenSize.tablet:
        fontSize = tabletSize;
        break;
      case ScreenSize.desktop:
        fontSize = desktopSize;
        break;
    }

    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: _getFontSize(fontSize),
      fontWeight: weight ?? AppConfig.fontWeightNormal,
      color: AppConfig.textColorPrimary,
    );
  }

  // Spacing utilities
  static double getSpacing(double fixedSize) => _getDimension(fixedSize);
  static double getPadding(double fixedSize) => _getDimension(fixedSize);
  static double getMargin(double fixedSize) => _getDimension(fixedSize);
  static double getRadius(double fixedSize) => _getRadius(fixedSize);

  // Common spacing values
  static double get smallSpacing => getSpacing(8.0);
  static double get defaultSpacing => getSpacing(16.0);
  static double get largeSpacing => getSpacing(24.0);
  static double get xlSpacing => getSpacing(32.0);

  // Common padding values
  static double get smallPadding => getPadding(8.0);
  static double get defaultPadding => getPadding(16.0);
  static double get largePadding => getPadding(24.0);
  static double get xlPadding => getPadding(32.0);

  // Common radius values
  static double get smallRadius => getRadius(4.0);
  static double get defaultRadius => getRadius(8.0);
  static double get largeRadius => getRadius(12.0);
  static double get xlRadius => getRadius(16.0);
}
