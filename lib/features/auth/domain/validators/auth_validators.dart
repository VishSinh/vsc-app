import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/auth/domain/models/auth_user.dart';

/// Domain validators for business rules
class AuthDomainValidators {
  /// Validates password strength for business requirements
  static ValidationResult validatePasswordStrength(String password) {
    if (password.isEmpty) {
      return ValidationResult.failureSingle('password', 'Password is required');
    }

    if (password.length < 6) {
      return ValidationResult.failureSingle('password', 'Password must be at least 6 characters');
    }

    if (password.length > 50) {
      return ValidationResult.failureSingle('password', 'Password must be less than 50 characters');
    }

    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return ValidationResult.failureSingle('password', 'Password must contain at least one letter and one number');
    }

    return ValidationResult.success();
  }

  /// Validates phone number format for business requirements
  static ValidationResult validatePhoneFormat(String phone) {
    if (phone.trim().isEmpty) {
      return ValidationResult.failureSingle('phone', 'Phone number is required');
    }

    if (phone.trim().length < 10) {
      return ValidationResult.failureSingle('phone', 'Phone number must be at least 10 digits');
    }

    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone.trim())) {
      return ValidationResult.failureSingle('phone', 'Phone number contains invalid characters');
    }

    return ValidationResult.success();
  }

  /// Validates user name for business requirements
  static ValidationResult validateUserName(String name) {
    if (name.trim().isEmpty) {
      return ValidationResult.failureSingle('name', 'Name is required');
    }

    if (name.trim().length < 2) {
      return ValidationResult.failureSingle('name', 'Name must be at least 2 characters');
    }

    if (name.trim().length > 50) {
      return ValidationResult.failureSingle('name', 'Name must be less than 50 characters');
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim())) {
      return ValidationResult.failureSingle('name', 'Name can only contain letters and spaces');
    }

    return ValidationResult.success();
  }

  /// Validates if user can register (admin only business rule)
  static ValidationResult validateRegistrationPermission(AuthUser? currentUser) {
    if (currentUser == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!currentUser.isAdmin) {
      return ValidationResult.failureSingle('permission', 'Only administrators can register new users');
    }

    return ValidationResult.success();
  }

  /// Validates if user can access admin features
  static ValidationResult validateAdminAccess(AuthUser? user) {
    if (user == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!user.isAdmin) {
      return ValidationResult.failureSingle('permission', 'Access denied. Admin privileges required');
    }

    return ValidationResult.success();
  }

  /// Validates if user can access manager features
  static ValidationResult validateManagerAccess(AuthUser? user) {
    if (user == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!user.isManager) {
      return ValidationResult.failureSingle('permission', 'Access denied. Manager privileges required');
    }

    return ValidationResult.success();
  }

  /// Validates if user can access sales features
  static ValidationResult validateSalesAccess(AuthUser? user) {
    if (user == null) {
      return ValidationResult.failureSingle('permission', 'User not authenticated');
    }

    if (!user.isSales) {
      return ValidationResult.failureSingle('permission', 'Access denied. Sales privileges required');
    }

    return ValidationResult.success();
  }

  /// Validates complete registration data
  static ValidationResult validateRegistrationData({
    required String name,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
  }) {
    final nameResult = validateUserName(name);
    if (!nameResult.isValid) return nameResult;

    final phoneResult = validatePhoneFormat(phone);
    if (!phoneResult.isValid) return phoneResult;

    final passwordResult = validatePasswordStrength(password);
    if (!passwordResult.isValid) return passwordResult;

    if (confirmPassword.isEmpty) {
      return ValidationResult.failureSingle('confirmPassword', 'Please confirm password');
    }

    if (password != confirmPassword) {
      return ValidationResult.failureSingle('confirmPassword', 'Passwords do not match');
    }

    if (role.isEmpty) {
      return ValidationResult.failureSingle('role', 'Please select a role');
    }

    final validRoles = ['ADMIN', 'MANAGER', 'SALES'];
    if (!validRoles.contains(role)) {
      return ValidationResult.failureSingle('role', 'Please select a valid role');
    }

    return ValidationResult.success();
  }

  /// Validates complete login data
  static ValidationResult validateLoginData({required String phone, required String password}) {
    final phoneResult = validatePhoneFormat(phone);
    if (!phoneResult.isValid) return phoneResult;

    if (password.isEmpty) {
      return ValidationResult.failureSingle('password', 'Password is required');
    }

    return ValidationResult.success();
  }
}
