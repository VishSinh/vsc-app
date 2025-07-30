import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/snackbar_constants.dart';

class SnackbarUtils {
  /// Determines the margin for the snackbar based on screen width.
  static EdgeInsets _getSnackBarMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > AppConfig.tabletBreakpoint) {
      // For DESKTOP and TABLET: bottom-right alignment
      // Calculate position to push snackbar to bottom-right
      double snackbarWidth = AppConfig.snackbarMaxWidth;
      double rightMargin = AppConfig.snackbarRightMargin;
      double bottomMargin = AppConfig.snackbarBottomMargin;
      final double leftMargin = screenWidth - snackbarWidth - rightMargin;

      return EdgeInsets.only(left: leftMargin > 0 ? leftMargin : 0, right: rightMargin, bottom: bottomMargin);
    } else {
      // For PHONE: bottom-center alignment
      return const EdgeInsets.fromLTRB(
        AppConfig.snackbarLeftMargin,
        AppConfig.snackbarTopMargin,
        AppConfig.snackbarLeftMargin,
        AppConfig.snackbarVerticalMargin,
      );
    }
  }

  /// Sets a max-width constraint on larger screens.
  static BoxConstraints? _getSnackBarConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > AppConfig.tabletBreakpoint) {
      return BoxConstraints(maxWidth: AppConfig.snackbarMaxWidth);
    }
    return null;
  }

  /// A private, generic method to display any type of snackbar.
  /// This avoids repeating the same SnackBar creation logic.
  static void _show(BuildContext context, {required String title, required String message, required ContentType contentType}) {
    // Get appropriate colors and icons based on content type
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (contentType) {
      case ContentType.success:
        backgroundColor = AppConfig.snackbarSuccessColor;
        iconColor = AppConfig.snackbarTextColor;
        iconData = Icons.check_circle;
        break;
      case ContentType.failure:
        backgroundColor = AppConfig.snackbarErrorColor;
        iconColor = AppConfig.snackbarTextColor;
        iconData = Icons.error;
        break;
      case ContentType.warning:
        backgroundColor = AppConfig.snackbarWarningColor;
        iconColor = AppConfig.snackbarTextColor;
        iconData = Icons.warning;
        break;
      case ContentType.help:
        backgroundColor = AppConfig.snackbarInfoColor;
        iconColor = AppConfig.snackbarTextColor;
        iconData = Icons.info;
        break;
      default:
        backgroundColor = AppConfig.snackbarDefaultColor;
        iconColor = AppConfig.snackbarTextColor;
        iconData = Icons.info;
        break;
    }

    final snackBar = SnackBar(
      elevation: AppConfig.snackbarElevation,
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      margin: _getSnackBarMargin(context),
      padding: AppConfig.snackbarPadding,
      content: Container(
        constraints: _getSnackBarConstraints(context),
        child: Row(
          children: [
            Icon(iconData, color: iconColor, size: AppConfig.snackbarIconSize),
            SizedBox(width: AppConfig.snackbarIconSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppConfig.snackbarTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppConfig.snackbarTitleFontSize,
                    ),
                  ),
                  const SizedBox(height: AppConfig.snackbarTextSpacing),
                  Text(
                    message,
                    style: const TextStyle(color: AppConfig.snackbarTextSecondaryColor, fontSize: AppConfig.snackbarMessageFontSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Clear existing snackbars to avoid them stacking up
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(snackBar);
  }

  // Your public methods are now clean, single-line calls to _show()

  static void showSuccess(BuildContext context, String message) {
    _show(context, title: SnackbarConstants.successTitle, message: message, contentType: ContentType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, title: SnackbarConstants.errorTitle, message: message, contentType: ContentType.failure);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, title: SnackbarConstants.warningTitle, message: message, contentType: ContentType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, title: SnackbarConstants.infoTitle, message: message, contentType: ContentType.help);
  }

  static void showApiError(BuildContext context, String message) {
    _show(context, title: SnackbarConstants.apiErrorTitle, message: message, contentType: ContentType.failure);
  }
}
