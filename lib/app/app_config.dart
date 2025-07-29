import 'package:flutter/material.dart';

class AppConfig {
  // App Information
  static const String appName = 'VSC Inventory Management';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF424242);
  static const Color accentColor = Color(0xFF2196F3);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border radius
  static const double defaultRadius = 8.0;
  static const double smallRadius = 4.0;
  static const double largeRadius = 12.0;

  // Typography
  static const String fontFamily = 'Roboto';

  // Font Sizes
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSize2xl = 20.0;
  static const double fontSize3xl = 24.0;
  static const double fontSize4xl = 28.0;
  static const double fontSize5xl = 32.0;

  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Text Colors
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Color(0xFFB0B0B0);
  static const Color textColorMuted = Color(0xFF808080);
  static const Color textColorSuccess = Color(0xFF4CAF50);
  static const Color textColorWarning = Color(0xFFFF9800);
  static const Color textColorError = Color(0xFFF44336);

  // Text Styles
  static const TextStyle headlineStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize4xl,
    fontWeight: fontWeightBold,
    color: textColorPrimary,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize2xl,
    fontWeight: fontWeightSemiBold,
    color: textColorPrimary,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeLg,
    fontWeight: fontWeightMedium,
    color: textColorSecondary,
  );

  static const TextStyle bodyStyle = TextStyle(fontFamily: fontFamily, fontSize: fontSizeMd, fontWeight: fontWeightNormal, color: textColorPrimary);

  static const TextStyle captionStyle = TextStyle(fontFamily: fontFamily, fontSize: fontSizeSm, fontWeight: fontWeightNormal, color: textColorMuted);

  static const TextStyle buttonStyle = TextStyle(fontFamily: fontFamily, fontSize: fontSizeMd, fontWeight: fontWeightMedium, color: textColorPrimary);
}
