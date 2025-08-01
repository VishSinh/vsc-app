import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/features/auth/data/models/auth_requests.dart';
import 'package:vsc_app/features/auth/data/models/auth_responses.dart';
import 'package:vsc_app/features/auth/domain/models/auth_user.dart';

/// Service for mapping between data and domain models
class AuthMapperService {
  /// Convert LoginData API response to AuthUser domain model
  static AuthUser fromLoginResponse(LoginData loginData) {
    return AuthUser(
      id: '', // API doesn't provide ID in login response
      name: '', // API doesn't provide name in login response
      phone: '', // API doesn't provide phone in login response
      token: loginData.token,
      role: loginData.userRole,
      createdAt: DateTime.now(), // Use current time as fallback
    );
  }

  /// Convert RegisterRequest to API model
  static RegisterRequest toRegisterRequest({required String name, required String phone, required String password, required String role}) {
    return RegisterRequest(name: name, phone: phone, password: password, role: role);
  }

  /// Convert LoginRequest to API model
  static LoginRequest toLoginRequest({required String phone, required String password}) {
    return LoginRequest(phone: phone, password: password);
  }

  /// Create AuthUser from individual fields (for registration)
  static AuthUser createUser({required String id, required String name, required String phone, required String token, required UserRole role}) {
    return AuthUser(id: id, name: name, phone: phone, token: token, role: role, createdAt: DateTime.now());
  }
}
