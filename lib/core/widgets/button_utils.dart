import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsc_app/app/app_config.dart';

/// Centralized button utilities for consistent styling across the app
class ButtonUtils {
  /// Primary action button (blue)
  static Widget primaryButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return _buildButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: AppConfig.primaryColor,
      foregroundColor: AppConfig.textColorPrimary,
      isLoading: isLoading,
    );
  }

  /// Success action button (green)
  static Widget successButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return _buildButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: AppConfig.successColor,
      foregroundColor: AppConfig.textColorPrimary,
      isLoading: isLoading,
    );
  }

  /// Warning action button (orange)
  static Widget warningButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return _buildButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: AppConfig.warningColor,
      foregroundColor: AppConfig.textColorPrimary,
      isLoading: isLoading,
    );
  }

  /// Secondary action button (purple)
  static Widget secondaryButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return _buildButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: AppConfig.secondaryColor,
      foregroundColor: AppConfig.textColorPrimary,
      isLoading: isLoading,
    );
  }

  /// Accent action button (teal)
  static Widget accentButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return _buildButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: AppConfig.accentColor,
      foregroundColor: AppConfig.textColorPrimary,
      isLoading: isLoading,
    );
  }

  /// Danger action button (red)
  static Widget dangerButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return _buildButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: AppConfig.errorColor,
      foregroundColor: AppConfig.textColorPrimary,
      isLoading: isLoading,
    );
  }

  /// Custom colored button
  static Widget customButton({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    required Color backgroundColor,
    Color foregroundColor = AppConfig.textColorPrimary,
    bool isLoading = false,
  }) {
    return _buildButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isLoading: isLoading,
    );
  }

  /// Internal method to build consistent button styling
  static Widget _buildButton({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    required Color backgroundColor,
    required Color foregroundColor,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? SpinKitDoubleBounce(color: foregroundColor, size: AppConfig.loadingIndicatorSize) : Icon(icon),
      label: Text(label, style: AppConfig.buttonStyle),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding, vertical: AppConfig.smallPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
        textStyle: AppConfig.buttonStyle,
      ),
    );
  }

  /// Full width primary button for forms
  static Widget fullWidthPrimaryButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: primaryButton(onPressed: onPressed, label: label, icon: icon, isLoading: isLoading),
    );
  }

  /// Full width success button for forms
  static Widget fullWidthSuccessButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: successButton(onPressed: onPressed, label: label, icon: icon, isLoading: isLoading),
    );
  }

  static Widget fullWidthSecondaryButton({required VoidCallback? onPressed, required String label, IconData? icon, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: secondaryButton(onPressed: onPressed, label: label, icon: icon, isLoading: isLoading),
    );
  }
}
