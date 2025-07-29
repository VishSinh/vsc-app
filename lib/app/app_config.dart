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

  // Additional Colors
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);
  static const Color transparent = Colors.transparent;
  static const Color black87 = Color(0xffdd000000);
  static const Color red = Colors.red;

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

  // ================================ UI CONSTANTS ================================

  // Loading Indicators
  static const double loadingIndicatorSize = 20.0;
  static const double loadingIndicatorStrokeWidth = 2.0;
  static const double defaultLoadingSize = 40.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  static const double iconSizeXXLarge = 64.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Constraints
  static const double maxWidthSmall = 400.0;
  static const double maxWidthMedium = 600.0;
  static const double maxWidthLarge = 800.0;
  static const double maxWidthXLarge = 1200.0;

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // Snackbar Constants
  static const double snackbarElevation = 2.0; // Small elevation to ensure visibility
  static const double snackbarMaxWidth = 400.0;
  static const EdgeInsets snackbarMargin = EdgeInsets.only(bottom: 20, right: 20);

  // Shimmer Colors
  static const Color shimmerBaseColor = Color(0xFF424242); // Colors.grey[700]
  static const Color shimmerHighlightColor = Color(0xFF616161); // Colors.grey[600]

  // Snackbar Colors
  static const Color snackbarSuccessColor = Color(0xFF388E3C); // Colors.green[700]
  static const Color snackbarErrorColor = Color(0xFFD32F2F); // Colors.red[700]
  static const Color snackbarWarningColor = Color(0xFFF57C00); // Colors.orange[700]
  static const Color snackbarInfoColor = Color(0xFF1976D2); // Colors.blue[700]
  static const Color snackbarDefaultColor = Color(0xFF424242); // Colors.grey[700]
  static const Color snackbarTextColor = Colors.white;
  static const Color snackbarTextSecondaryColor = Color(0xffb3ffffff); // Colors.white70

  // Snackbar Spacing
  static const EdgeInsets snackbarPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const double snackbarIconSize = 24.0;
  static const double snackbarIconSpacing = 12.0;
  static const double snackbarTextSpacing = 4.0;

  // Snackbar Margins
  static const double snackbarRightMargin = 20.0;
  static const double snackbarBottomMargin = 20.0;
  static const double snackbarLeftMargin = 15.0;
  static const double snackbarTopMargin = 5.0;
  static const double snackbarHorizontalMargin = 15.0;
  static const double snackbarVerticalMargin = 10.0;

  // Snackbar Typography
  static const double snackbarTitleFontSize = 16.0;
  static const double snackbarMessageFontSize = 14.0;

  // Border Radius (Additional)
  static const double borderRadiusTiny = 2.0;
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  // Spacing (Additional)
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
}
