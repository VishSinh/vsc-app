import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/snackbar_constants.dart';
import 'dart:async';

class SnackbarUtils {
  static OverlayEntry? _currentOverlayEntry;
  static Timer? _hideTimer;

  static void _removeCurrentOverlay() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
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

    // Clear existing SnackBars and overlays to avoid stacking
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    _removeCurrentOverlay();

    final overlayState = Overlay.of(context, rootOverlay: true);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final double rightMargin = AppConfig.snackbarRightMargin;
    final double topMargin = AppConfig.snackbarTopMargin;
    final double maxWidth = AppConfig.snackbarMaxWidth;
    final double minHorizontal = AppConfig.snackbarLeftMargin + rightMargin;
    final double availableWidth = (screenWidth - minHorizontal).clamp(0.0, double.infinity);
    final double snackbarWidth = availableWidth < maxWidth ? availableWidth : maxWidth;

    _currentOverlayEntry = OverlayEntry(
      builder: (context) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: topMargin,
                right: rightMargin,
                child: Material(
                  color: Colors.transparent,
                  elevation: AppConfig.snackbarElevation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: snackbarWidth),
                    child: Container(
                      padding: AppConfig.snackbarPadding,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData, color: iconColor, size: AppConfig.snackbarIconSize),
                          SizedBox(width: AppConfig.snackbarIconSpacing),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppConfig.snackbarTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppConfig.snackbarTitleFontSize,
                                  ),
                                ),
                                const SizedBox(height: AppConfig.snackbarTextSpacing),
                                Text(
                                  message,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppConfig.snackbarTextSecondaryColor,
                                    fontSize: AppConfig.snackbarMessageFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlayState.insert(_currentOverlayEntry!);

    // Auto-hide after a short duration
    _hideTimer = Timer(const Duration(seconds: 3), _removeCurrentOverlay);
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
