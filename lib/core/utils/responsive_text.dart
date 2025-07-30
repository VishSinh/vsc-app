import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vsc_app/app/app_config.dart';

/// Responsive text utilities that adapt to system text scaling and accessibility settings
class ResponsiveText {
  /// Get responsive headline style using ScreenUtil
  static TextStyle getHeadline(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 28.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightBold,
      color: AppConfig.textColorPrimary,
    );
  }

  /// Get responsive title style using ScreenUtil
  static TextStyle getTitle(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 20.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightSemiBold,
      color: AppConfig.textColorPrimary,
    );
  }

  /// Get responsive subtitle style using ScreenUtil
  static TextStyle getSubtitle(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 16.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightMedium,
      color: AppConfig.textColorSecondary,
    );
  }

  /// Get responsive body style using ScreenUtil
  static TextStyle getBody(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 14.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightNormal,
      color: AppConfig.textColorPrimary,
    );
  }

  /// Get responsive caption style using ScreenUtil
  static TextStyle getCaption(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 12.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightNormal,
      color: AppConfig.textColorMuted,
    );
  }

  /// Get responsive button style using ScreenUtil
  static TextStyle getButton(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 14.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightMedium,
      color: AppConfig.textColorPrimary,
    );
  }

  /// Get responsive overline style using ScreenUtil
  static TextStyle getOverline(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 12.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightNormal,
      color: AppConfig.textColorMuted,
    );
  }

  /// Get responsive display style for large headings using ScreenUtil
  static TextStyle getDisplay(BuildContext context) {
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: 32.sp, // Using ScreenUtil for consistent scaling
      fontWeight: AppConfig.fontWeightBold,
      color: AppConfig.textColorPrimary,
    );
  }

  /// Get responsive text style with custom color
  static TextStyle getCustom(BuildContext context, {Color? color}) {
    final textScaler = MediaQuery.of(context).textScaler;
    final baseFontSize = AppConfig.fontSizeMd;
    final scaledFontSize = textScaler.scale(baseFontSize);
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: scaledFontSize,
      fontWeight: AppConfig.fontWeightNormal,
      color: color ?? AppConfig.textColorPrimary,
    );
  }

  /// Get responsive text style with custom weight
  static TextStyle getWithWeight(BuildContext context, {FontWeight? weight}) {
    final textScaler = MediaQuery.of(context).textScaler;
    final baseFontSize = AppConfig.fontSizeMd;
    final scaledFontSize = textScaler.scale(baseFontSize);
    return TextStyle(
      fontFamily: AppConfig.fontFamily,
      fontSize: scaledFontSize,
      fontWeight: weight ?? AppConfig.fontWeightNormal,
      color: AppConfig.textColorPrimary,
    );
  }
}
