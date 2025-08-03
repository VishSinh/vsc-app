import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/core/enums/user_role.dart';

/// Service for auth-related validations that involve multiple model variables
class AuthValidators {
  /// Validate if user can register (admin only business rule)
  static ValidationResult validateRegistrationPermission(UserRole? userRole) {
    if (userRole == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!_isAdmin(userRole)) {
      return ValidationResult.failureSingle('permission', 'Only administrators can register new users');
    }

    return ValidationResult.success();
  }

  /// Validate if user can access admin features
  static ValidationResult validateAdminAccess(UserRole? userRole) {
    if (userRole == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!_isAdmin(userRole)) {
      return ValidationResult.failureSingle('permission', 'Access denied. Admin privileges required');
    }

    return ValidationResult.success();
  }

  /// Validate if user can access manager features
  static ValidationResult validateManagerAccess(UserRole? userRole) {
    if (userRole == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!_isManager(userRole)) {
      return ValidationResult.failureSingle('permission', 'Access denied. Manager privileges required');
    }

    return ValidationResult.success();
  }

  /// Validate if user can access sales features
  static ValidationResult validateSalesAccess(UserRole? userRole) {
    if (userRole == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!_isSales(userRole)) {
      return ValidationResult.failureSingle('permission', 'Access denied. Sales privileges required');
    }

    return ValidationResult.success();
  }

  // Helper methods for role checking
  static bool _isAdmin(UserRole role) => role.name == 'admin';
  static bool _isManager(UserRole role) => role.name == 'manager' || role.name == 'admin';
  static bool _isSales(UserRole role) => role.name == 'sales' || role.name == 'manager' || role.name == 'admin';
}
