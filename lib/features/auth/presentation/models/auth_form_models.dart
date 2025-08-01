import 'package:flutter/material.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/auth/data/models/auth_requests.dart';

import 'package:vsc_app/features/auth/domain/validators/auth_validators.dart';
import 'package:vsc_app/features/auth/presentation/validators/auth_form_validators.dart';

/// Form model for login form with validation
class LoginFormViewModel {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool isValid;
  final ValidationResult validationResult;

  const LoginFormViewModel({required this.phoneController, required this.passwordController, required this.isValid, required this.validationResult});

  /// Create from form data with validation
  factory LoginFormViewModel.fromFormData({required String phone, required String password}) {
    final phoneController = TextEditingController(text: phone);
    final passwordController = TextEditingController(text: password);

    // UI validation first
    final formValidation = AuthFormValidators.validateLoginForm(phone: phone, password: password);

    // Domain validation if form is valid
    ValidationResult domainValidation = ValidationResult.success();
    if (formValidation.isValid) {
      domainValidation = AuthDomainValidators.validateLoginData(phone: phone, password: password);
    }

    final combinedValidation = formValidation.combine(domainValidation);
    final isValid = combinedValidation.isValid;

    return LoginFormViewModel(
      phoneController: phoneController,
      passwordController: passwordController,
      isValid: isValid,
      validationResult: combinedValidation,
    );
  }

  /// Create empty form
  factory LoginFormViewModel.empty() {
    return LoginFormViewModel(
      phoneController: TextEditingController(),
      passwordController: TextEditingController(),
      isValid: false,
      validationResult: ValidationResult.success(),
    );
  }

  /// Create copy with updated values
  LoginFormViewModel copyWith({String? phone, String? password}) {
    final newPhone = phone ?? phoneController.text;
    final newPassword = password ?? passwordController.text;

    return LoginFormViewModel.fromFormData(phone: newPhone, password: newPassword);
  }

  /// Convert to API request
  LoginRequest toApiRequest() {
    return LoginRequest(phone: phoneController.text.trim(), password: passwordController.text);
  }

  /// Get error message for a specific field
  String? getFieldError(String field) {
    return validationResult.getMessage(field);
  }

  /// Dispose controllers
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
  }
}

/// Form model for register form with validation
class RegisterFormViewModel {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String role;
  final bool isValid;
  final ValidationResult validationResult;

  const RegisterFormViewModel({
    required this.nameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.role,
    required this.isValid,
    required this.validationResult,
  });

  /// Create from form data with validation
  factory RegisterFormViewModel.fromFormData({
    required String name,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
  }) {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final passwordController = TextEditingController(text: password);
    final confirmPasswordController = TextEditingController(text: confirmPassword);

    // UI validation first
    final formValidation = AuthFormValidators.validateRegisterForm(
      name: name,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
    );

    // Domain validation if form is valid
    ValidationResult domainValidation = ValidationResult.success();
    if (formValidation.isValid) {
      domainValidation = AuthDomainValidators.validateRegistrationData(
        name: name,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );
    }

    final combinedValidation = formValidation.combine(domainValidation);
    final isValid = combinedValidation.isValid;

    return RegisterFormViewModel(
      nameController: nameController,
      phoneController: phoneController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      role: role,
      isValid: isValid,
      validationResult: combinedValidation,
    );
  }

  /// Create empty form
  factory RegisterFormViewModel.empty() {
    return RegisterFormViewModel(
      nameController: TextEditingController(),
      phoneController: TextEditingController(),
      passwordController: TextEditingController(),
      confirmPasswordController: TextEditingController(),
      role: '',
      isValid: false,
      validationResult: ValidationResult.success(),
    );
  }

  /// Create copy with updated values
  RegisterFormViewModel copyWith({String? name, String? phone, String? password, String? confirmPassword, String? role}) {
    return RegisterFormViewModel.fromFormData(
      name: name ?? nameController.text,
      phone: phone ?? phoneController.text,
      password: password ?? passwordController.text,
      confirmPassword: confirmPassword ?? confirmPasswordController.text,
      role: role ?? this.role,
    );
  }

  /// Convert to API request
  RegisterRequest toApiRequest() {
    return RegisterRequest(name: nameController.text.trim(), phone: phoneController.text.trim(), password: passwordController.text, role: role);
  }

  /// Get error message for a specific field
  String? getFieldError(String field) {
    return validationResult.getMessage(field);
  }

  /// Get available roles for selection
  static List<String> get availableRoles => UserRole.values.map((role) => role.value).toList();

  /// Dispose controllers
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
