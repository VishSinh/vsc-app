import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/home/data/models/auth_requests.dart';

/// Form model for login form with validation
class LoginFormModel {
  final String phone;
  final String password;

  const LoginFormModel({required this.phone, required this.password});

  /// Validate login form
  ValidationResult validate() {
    final errors = <ValidationError>[];

    ValidationResult validatePhone() {
      if (phone.trim().isEmpty) {
        return ValidationResult.failureSingle('phone', 'Please enter phone number');
      }

      if (phone.trim().length < 10) {
        return ValidationResult.failureSingle('phone', 'Phone number must be at least 10 digits');
      }

      if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone.trim())) {
        return ValidationResult.failureSingle('phone', 'Phone number contains invalid characters');
      }

      return ValidationResult.success();
    }

    ValidationResult validatePassword() {
      if (password.isEmpty) {
        return ValidationResult.failureSingle('password', 'Please enter password');
      }

      if (password.length < 6) {
        return ValidationResult.failureSingle('password', 'Password must be at least 6 characters');
      }

      if (password.length > 50) {
        return ValidationResult.failureSingle('password', 'Password must be less than 50 characters');
      }

      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      final hasNumber = RegExp(r'[0-9]').hasMatch(password);
      if (!hasLetter || !hasNumber) {
        return ValidationResult.failureSingle('password', 'Password must contain at least one letter and one number');
      }

      return ValidationResult.success();
    }

    final phoneResult = validatePhone();
    if (!phoneResult.isValid) {
      errors.addAll(phoneResult.errors);
    }

    final passwordResult = validatePassword();
    if (!passwordResult.isValid) {
      errors.addAll(passwordResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  /// Create empty form
  factory LoginFormModel.empty() {
    return LoginFormModel(phone: '', password: '');
  }

  /// Create copy with updated values
  LoginFormModel copyWith({String? phone, String? password}) {
    return LoginFormModel(phone: phone ?? this.phone, password: password ?? this.password);
  }

  /// Convert to API request
  LoginRequest toApiRequest() {
    return LoginRequest(phone: phone.trim(), password: password);
  }
}

/// Form model for register form with validation
class RegisterFormModel {
  final String name;
  final String phone;
  final String password;
  final String confirmPassword;
  final String role;

  const RegisterFormModel({required this.name, required this.phone, required this.password, required this.confirmPassword, required this.role});

  /// Validate register form
  ValidationResult validate() {
    final errors = <ValidationError>[];

    ValidationResult validateName() {
      if (name.trim().isEmpty) {
        return ValidationResult.failureSingle('name', 'Please enter name');
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

    ValidationResult validatePhone() {
      if (phone.trim().isEmpty) {
        return ValidationResult.failureSingle('phone', 'Please enter phone number');
      }

      if (phone.trim().length < 10) {
        return ValidationResult.failureSingle('phone', 'Phone number must be at least 10 digits');
      }

      if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone.trim())) {
        return ValidationResult.failureSingle('phone', 'Phone number contains invalid characters');
      }

      return ValidationResult.success();
    }

    ValidationResult validatePassword() {
      if (password.isEmpty) {
        return ValidationResult.failureSingle('password', 'Please enter password');
      }

      if (password.length < 6) {
        return ValidationResult.failureSingle('password', 'Password must be at least 6 characters');
      }

      if (password.length > 50) {
        return ValidationResult.failureSingle('password', 'Password must be less than 50 characters');
      }

      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      final hasNumber = RegExp(r'[0-9]').hasMatch(password);
      if (!hasLetter || !hasNumber) {
        return ValidationResult.failureSingle('password', 'Password must contain at least one letter and one number');
      }

      return ValidationResult.success();
    }

    ValidationResult validateConfirmPassword() {
      if (confirmPassword.isEmpty) {
        return ValidationResult.failureSingle('confirmPassword', 'Please confirm password');
      }

      if (password != confirmPassword) {
        return ValidationResult.failureSingle('confirmPassword', 'Passwords do not match');
      }

      return ValidationResult.success();
    }

    ValidationResult validateRole() {
      if (role.isEmpty) {
        return ValidationResult.failureSingle('role', 'Please select a role');
      }

      final validRoles = ['ADMIN', 'MANAGER', 'SALES'];
      if (!validRoles.contains(role)) {
        return ValidationResult.failureSingle('role', 'Please select a valid role');
      }

      return ValidationResult.success();
    }

    final nameResult = validateName();
    if (!nameResult.isValid) {
      errors.addAll(nameResult.errors);
    }

    final phoneResult = validatePhone();
    if (!phoneResult.isValid) {
      errors.addAll(phoneResult.errors);
    }

    final passwordResult = validatePassword();
    if (!passwordResult.isValid) {
      errors.addAll(passwordResult.errors);
    }

    final confirmPasswordResult = validateConfirmPassword();
    if (!confirmPasswordResult.isValid) {
      errors.addAll(confirmPasswordResult.errors);
    }

    final roleResult = validateRole();
    if (!roleResult.isValid) {
      errors.addAll(roleResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  /// Create empty form
  factory RegisterFormModel.empty() {
    return RegisterFormModel(name: '', phone: '', password: '', confirmPassword: '', role: '');
  }

  /// Create copy with updated values
  RegisterFormModel copyWith({String? name, String? phone, String? password, String? confirmPassword, String? role}) {
    return RegisterFormModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      role: role ?? this.role,
    );
  }

  /// Convert to API request
  RegisterRequest toApiRequest() {
    return RegisterRequest(name: name.trim(), phone: phone.trim(), password: password, role: role);
  }

  /// Get available roles for selection
  static List<String> get availableRoles => UserRole.values.map((role) => role.value).toList();
}
