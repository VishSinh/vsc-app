import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/auth_model.dart';
import 'package:vsc_app/core/services/base_service.dart';

class AuthService extends BaseService {
  AuthService({super.dio, super.secureStorage});

  /// Login with phone and password
  Future<ApiResponse<LoginData>> login(String phone, String password) async {
    try {
      final response = await executeRequest(
        () => post(AppConstants.loginEndpoint, data: {'phone': phone, 'password': password}),
        (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        // Store token and role
        await secureStorage.write(key: AppConstants.authTokenKey, value: response.data!.token);
        await secureStorage.write(key: AppConstants.userRoleKey, value: response.data!.role);
      }

      return response;
    } catch (e) {
      return ApiResponse(success: false, data: null, error: ErrorData.networkError(e.toString()));
    }
  }

  /// Register new staff member (Admin only)
  Future<RegisterResponse> register({required String name, required String phone, required String password, required String role}) async {
    final request = RegisterRequest(name: name, phone: phone, password: password, role: role);

    return await executeRequest(
      () => post(AppConstants.registerEndpoint, data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
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
}
