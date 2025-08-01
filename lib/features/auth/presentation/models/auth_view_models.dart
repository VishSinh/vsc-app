import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/features/auth/domain/models/auth_user.dart';

/// View model for displaying user information
class AuthUserViewModel {
  final String displayName;
  final String displayRole;
  final String displayPhone;
  final bool isAdmin;
  final bool isManager;
  final bool isSales;

  const AuthUserViewModel({
    required this.displayName,
    required this.displayRole,
    required this.displayPhone,
    required this.isAdmin,
    required this.isManager,
    required this.isSales,
  });

  /// Create from domain model
  factory AuthUserViewModel.fromDomainModel(AuthUser user) {
    return AuthUserViewModel(
      displayName: user.name.isNotEmpty ? user.name : 'Unknown User',
      displayRole: _formatRole(user.role),
      displayPhone: _formatPhone(user.phone),
      isAdmin: user.isAdmin,
      isManager: user.isManager,
      isSales: user.isSales,
    );
  }

  /// Format role for display
  static String _formatRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.sales:
        return 'Sales';
    }
  }

  /// Format phone number for display
  static String _formatPhone(String phone) {
    if (phone.isEmpty) return 'No phone';

    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return phone;
  }

  /// Get role color for UI
  String get roleColor {
    switch (displayRole) {
      case 'Administrator':
        return '#FF4444'; // Red
      case 'Manager':
        return '#FF8800'; // Orange
      case 'Sales':
        return '#00AA00'; // Green
      default:
        return '#666666'; // Gray
    }
  }

  /// Get role icon for UI
  String get roleIcon {
    switch (displayRole) {
      case 'Administrator':
        return '👑';
      case 'Manager':
        return '👔';
      case 'Sales':
        return '💼';
      default:
        return '👤';
    }
  }
}

/// View model for login form display
class LoginFormDisplayViewModel {
  final bool isLoading;
  final String? errorMessage;
  final bool isFormValid;
  final Map<String, String?> fieldErrors;

  const LoginFormDisplayViewModel({required this.isLoading, this.errorMessage, required this.isFormValid, required this.fieldErrors});

  /// Create empty state
  factory LoginFormDisplayViewModel.empty() {
    return const LoginFormDisplayViewModel(isLoading: false, isFormValid: false, fieldErrors: {});
  }

  /// Create loading state
  factory LoginFormDisplayViewModel.loading() {
    return const LoginFormDisplayViewModel(isLoading: true, isFormValid: false, fieldErrors: {});
  }

  /// Create error state
  factory LoginFormDisplayViewModel.error(String message) {
    return LoginFormDisplayViewModel(isLoading: false, errorMessage: message, isFormValid: false, fieldErrors: {});
  }

  /// Check if a specific field has an error
  bool hasFieldError(String field) {
    return fieldErrors.containsKey(field) && fieldErrors[field] != null;
  }

  /// Get error message for a specific field
  String? getFieldError(String field) {
    return fieldErrors[field];
  }
}

/// View model for register form display
class RegisterFormDisplayViewModel {
  final bool isLoading;
  final String? errorMessage;
  final bool isFormValid;
  final Map<String, String?> fieldErrors;
  final List<String> availableRoles;

  const RegisterFormDisplayViewModel({
    required this.isLoading,
    this.errorMessage,
    required this.isFormValid,
    required this.fieldErrors,
    required this.availableRoles,
  });

  /// Create empty state
  factory RegisterFormDisplayViewModel.empty() {
    return RegisterFormDisplayViewModel(
      isLoading: false,
      isFormValid: false,
      fieldErrors: {},
      availableRoles: UserRole.values.map((role) => role.value).toList(),
    );
  }

  /// Create loading state
  factory RegisterFormDisplayViewModel.loading() {
    return RegisterFormDisplayViewModel(
      isLoading: true,
      isFormValid: false,
      fieldErrors: {},
      availableRoles: UserRole.values.map((role) => role.value).toList(),
    );
  }

  /// Create error state
  factory RegisterFormDisplayViewModel.error(String message) {
    return RegisterFormDisplayViewModel(
      isLoading: false,
      errorMessage: message,
      isFormValid: false,
      fieldErrors: {},
      availableRoles: UserRole.values.map((role) => role.value).toList(),
    );
  }

  /// Check if a specific field has an error
  bool hasFieldError(String field) {
    return fieldErrors.containsKey(field) && fieldErrors[field] != null;
  }

  /// Get error message for a specific field
  String? getFieldError(String field) {
    return fieldErrors[field];
  }
}
