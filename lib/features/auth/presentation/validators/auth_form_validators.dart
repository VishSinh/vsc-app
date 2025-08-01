import 'package:vsc_app/core/validation/validation_result.dart';

/// Presentation validators for form-specific validation
class AuthFormValidators {
  /// Validates if phone field is not empty (UI validation)
  static ValidationResult validatePhoneNotEmpty(String phone) {
    if (phone.trim().isEmpty) {
      return ValidationResult.failureSingle('phone', 'Please enter phone number');
    }
    return ValidationResult.success();
  }

  /// Validates if password field is not empty (UI validation)
  static ValidationResult validatePasswordNotEmpty(String password) {
    if (password.isEmpty) {
      return ValidationResult.failureSingle('password', 'Please enter password');
    }
    return ValidationResult.success();
  }

  /// Validates if name field is not empty (UI validation)
  static ValidationResult validateNameNotEmpty(String name) {
    if (name.trim().isEmpty) {
      return ValidationResult.failureSingle('name', 'Please enter name');
    }
    return ValidationResult.success();
  }

  /// Validates if confirm password field is not empty (UI validation)
  static ValidationResult validateConfirmPasswordNotEmpty(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return ValidationResult.failureSingle('confirmPassword', 'Please confirm password');
    }
    return ValidationResult.success();
  }

  /// Validates if role field is not empty (UI validation)
  static ValidationResult validateRoleNotEmpty(String role) {
    if (role.isEmpty) {
      return ValidationResult.failureSingle('role', 'Please select a role');
    }
    return ValidationResult.success();
  }

  /// Validates if passwords match (UI validation)
  static ValidationResult validatePasswordsMatch(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return ValidationResult.failureSingle('confirmPassword', 'Passwords do not match');
    }
    return ValidationResult.success();
  }

  /// Validates login form fields (UI validation)
  static ValidationResult validateLoginForm({required String phone, required String password}) {
    final phoneResult = validatePhoneNotEmpty(phone);
    if (!phoneResult.isValid) return phoneResult;

    final passwordResult = validatePasswordNotEmpty(password);
    if (!passwordResult.isValid) return passwordResult;

    return ValidationResult.success();
  }

  /// Validates register form fields (UI validation)
  static ValidationResult validateRegisterForm({
    required String name,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
  }) {
    final nameResult = validateNameNotEmpty(name);
    if (!nameResult.isValid) return nameResult;

    final phoneResult = validatePhoneNotEmpty(phone);
    if (!phoneResult.isValid) return phoneResult;

    final passwordResult = validatePasswordNotEmpty(password);
    if (!passwordResult.isValid) return passwordResult;

    final confirmPasswordResult = validateConfirmPasswordNotEmpty(confirmPassword);
    if (!confirmPasswordResult.isValid) return confirmPasswordResult;

    final passwordsMatchResult = validatePasswordsMatch(password, confirmPassword);
    if (!passwordsMatchResult.isValid) return passwordsMatchResult;

    final roleResult = validateRoleNotEmpty(role);
    if (!roleResult.isValid) return roleResult;

    return ValidationResult.success();
  }
}
