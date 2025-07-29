import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:vsc_app/app/app_config.dart';

class SnackbarUtils {
  /// Get responsive snackbar positioning
  static SnackBarBehavior _getSnackBarBehavior(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    print('screenWidth: $screenWidth');
    return screenWidth > AppConfig.tabletBreakpoint ? SnackBarBehavior.floating : SnackBarBehavior.floating;
  }

  /// Get responsive snackbar margin
  static EdgeInsets? _getSnackBarMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > AppConfig.tabletBreakpoint) {
      // For laptop/desktop screens, position at bottom right with smaller width
      // return const EdgeInsets.only(bottom: 20, right: 20);
    }
    return null; // Default margin for mobile
  }

  /// Get responsive snackbar constraints
  static BoxConstraints? _getSnackBarConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > AppConfig.tabletBreakpoint) {
      // For laptop/desktop screens, limit width to make it smaller
      // return const BoxConstraints(maxWidth: 400);
    }
    return null; // Full width for mobile
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 8,
      behavior: _getSnackBarBehavior(context),
      backgroundColor: Colors.transparent,
      margin: _getSnackBarMargin(context),
      content: Container(
        constraints: _getSnackBarConstraints(context),
        child: AwesomeSnackbarContent(title: 'Success!', message: message, contentType: ContentType.success),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 8,
      behavior: _getSnackBarBehavior(context),
      backgroundColor: Colors.transparent,
      margin: _getSnackBarMargin(context),
      content: Container(
        constraints: _getSnackBarConstraints(context),
        child: AwesomeSnackbarContent(title: 'Error!', message: message, contentType: ContentType.failure),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 8,
      behavior: _getSnackBarBehavior(context),
      backgroundColor: Colors.transparent,
      margin: _getSnackBarMargin(context),
      content: Container(
        constraints: _getSnackBarConstraints(context),
        child: AwesomeSnackbarContent(title: 'Warning!', message: message, contentType: ContentType.warning),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: _getSnackBarBehavior(context),
      margin: _getSnackBarMargin(context),
      backgroundColor: Colors.transparent,
      content: Container(
        constraints: _getSnackBarConstraints(context),
        child: AwesomeSnackbarContent(title: 'Info', message: message, contentType: ContentType.help),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show API error snackbar (for failed API calls only)
  static void showApiError(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 8,
      behavior: _getSnackBarBehavior(context),
      backgroundColor: Colors.transparent,
      margin: _getSnackBarMargin(context),
      content: Container(
        constraints: _getSnackBarConstraints(context),
        child: AwesomeSnackbarContent(title: 'API Error', message: message, contentType: ContentType.failure),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
