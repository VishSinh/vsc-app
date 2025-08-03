import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/features/auth/data/models/auth_responses.dart';

/// View model for displaying user information
class AuthUserViewModel {
  final String displayRole;
  final bool isAdmin;
  final bool isManager;
  final bool isSales;

  const AuthUserViewModel({required this.displayRole, required this.isAdmin, required this.isManager, required this.isSales});

  /// Create from API response
  factory AuthUserViewModel.fromApiResponse(LoginResponse loginResponse) {
    return AuthUserViewModel(
      displayRole: _formatRole(loginResponse.userRole),
      isAdmin: _isAdmin(loginResponse.userRole),
      isManager: _isManager(loginResponse.userRole),
      isSales: _isSales(loginResponse.userRole),
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

  // Helper methods for role checking
  static bool _isAdmin(UserRole role) => role.name == 'admin';
  static bool _isManager(UserRole role) => role.name == 'manager' || role.name == 'admin';
  static bool _isSales(UserRole role) => role.name == 'sales' || role.name == 'manager' || role.name == 'admin';
}
