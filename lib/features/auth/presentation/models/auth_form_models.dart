import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/auth/data/models/auth_requests.dart';

/// Form model for login form with validation
class LoginFormViewModel {
  final String phone;
  final String password;

  const LoginFormViewModel({required this.phone, required this.password});

  /// Create from form data
  factory LoginFormViewModel.fromFormData({required String phone, required String password}) {
    return LoginFormViewModel(phone: phone, password: password);
  }

  /// Validate login form
  ValidationResult validate() {
    final errors = <String>[];

    // UI validation
    if (phone.trim().isEmpty) {
      errors.add('Please enter phone number');
    }

    if (password.isEmpty) {
      errors.add('Please enter password');
    }

    // Business validation
    if (phone.trim().isNotEmpty && phone.trim().length < 10) {
      errors.add('Phone number must be at least 10 digits');
    }

    if (phone.trim().isNotEmpty && !RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone.trim())) {
      errors.add('Phone number contains invalid characters');
    }

    if (password.isNotEmpty && password.length < 6) {
      errors.add('Password must be at least 6 characters');
    }

    if (password.isNotEmpty && password.length > 50) {
      errors.add('Password must be less than 50 characters');
    }

    if (password.isNotEmpty) {
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      final hasNumber = RegExp(r'[0-9]').hasMatch(password);
      if (!hasLetter || !hasNumber) {
        errors.add('Password must contain at least one letter and one number');
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors.map((e) => ValidationError(field: 'login', message: e)).toList());
  }

  /// Create empty form
  factory LoginFormViewModel.empty() {
    return LoginFormViewModel(phone: '', password: '');
  }

  /// Create copy with updated values
  LoginFormViewModel copyWith({String? phone, String? password}) {
    final newPhone = phone ?? this.phone;
    final newPassword = password ?? this.password;

    return LoginFormViewModel.fromFormData(phone: newPhone, password: newPassword);
  }

  /// Convert to API request
  LoginRequest toApiRequest() {
    return LoginRequest(phone: phone.trim(), password: password);
  }
}

/// Form model for register form with validation
class RegisterFormViewModel {
  final String name;
  final String phone;
  final String password;
  final String confirmPassword;
  final String role;

  const RegisterFormViewModel({required this.name, required this.phone, required this.password, required this.confirmPassword, required this.role});

  /// Create from form data
  factory RegisterFormViewModel.fromFormData({
    required String name,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
  }) {
    return RegisterFormViewModel(name: name, phone: phone, password: password, confirmPassword: confirmPassword, role: role);
  }

  /// Validate register form
  ValidationResult validate() {
    final errors = <String>[];

    // UI validation
    if (name.trim().isEmpty) {
      errors.add('Please enter name');
    }

    if (phone.trim().isEmpty) {
      errors.add('Please enter phone number');
    }

    if (password.isEmpty) {
      errors.add('Please enter password');
    }

    if (confirmPassword.isEmpty) {
      errors.add('Please confirm password');
    }

    if (role.isEmpty) {
      errors.add('Please select a role');
    }

    // Business validation
    if (name.trim().isNotEmpty && name.trim().length < 2) {
      errors.add('Name must be at least 2 characters');
    }

    if (name.trim().isNotEmpty && name.trim().length > 50) {
      errors.add('Name must be less than 50 characters');
    }

    if (name.trim().isNotEmpty && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim())) {
      errors.add('Name can only contain letters and spaces');
    }

    if (phone.trim().isNotEmpty && phone.trim().length < 10) {
      errors.add('Phone number must be at least 10 digits');
    }

    if (phone.trim().isNotEmpty && !RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone.trim())) {
      errors.add('Phone number contains invalid characters');
    }

    if (password.isNotEmpty && password.length < 6) {
      errors.add('Password must be at least 6 characters');
    }

    if (password.isNotEmpty && password.length > 50) {
      errors.add('Password must be less than 50 characters');
    }

    if (password.isNotEmpty) {
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      final hasNumber = RegExp(r'[0-9]').hasMatch(password);
      if (!hasLetter || !hasNumber) {
        errors.add('Password must contain at least one letter and one number');
      }
    }

    if (password.isNotEmpty && confirmPassword.isNotEmpty && password != confirmPassword) {
      errors.add('Passwords do not match');
    }

    if (role.isNotEmpty) {
      final validRoles = ['ADMIN', 'MANAGER', 'SALES'];
      if (!validRoles.contains(role)) {
        errors.add('Please select a valid role');
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors.map((e) => ValidationError(field: 'register', message: e)).toList());
  }

  /// Create empty form
  factory RegisterFormViewModel.empty() {
    return RegisterFormViewModel(name: '', phone: '', password: '', confirmPassword: '', role: '');
  }

  /// Create copy with updated values
  RegisterFormViewModel copyWith({String? name, String? phone, String? password, String? confirmPassword, String? role}) {
    return RegisterFormViewModel.fromFormData(
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
