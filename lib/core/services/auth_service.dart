import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/auth_model.dart';
import 'package:vsc_app/core/services/base_service.dart';

class AuthService extends BaseService {
  AuthService({super.dio, super.secureStorage});

  /// Login with phone and password
  Future<LoginResponse> login({required String phone, required String password}) async {
    final request = LoginRequest(phone: phone, password: password);

    final response = await executeRequest(() => post(AppConstants.loginEndpoint, data: request.toJson()), (json) => LoginData.fromJson(json as Map<String, dynamic>));

    if (response.success) {
      // Store token and role using the new methods
      await storeToken(response.data.token);
      await storeUserRole(response.data.role);
    }

    return response;
  }

  /// Register new staff member (Admin only)
  Future<RegisterResponse> register({required String name, required String phone, required String password, required String role}) async {
    final request = RegisterRequest(name: name, phone: phone, password: password, role: role);

    return await executeRequest(() => post(AppConstants.registerEndpoint, data: request.toJson()), (json) => MessageData.fromJson(json as Map<String, dynamic>));
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await isAuthenticated();
  }

  /// Get stored user role
  @override
  Future<String?> getUserRole() async {
    return await super.getUserRole();
  }

  /// Logout user
  Future<void> logout() async {
    await clearAllData();
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final response = await executeRequest(() => post('/auth/refresh/'), (json) => LoginData.fromJson(json as Map<String, dynamic>));

      if (response.success) {
        await storeToken(response.data.token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Validate current token
  Future<bool> validateToken() async {
    try {
      final response = await executeRequest(() => get('/auth/validate/'), (json) => MessageData.fromJson(json as Map<String, dynamic>));
      return response.success;
    } catch (e) {
      return false;
    }
  }
}
