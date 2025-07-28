import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/auth_service.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';

class AuthProvider extends BaseProvider {
  final AuthService _authService;
  final PermissionProvider _permissionProvider;

  bool _isLoggedIn = false;
  UserRole? _userRole;
  String? _token;

  AuthProvider({AuthService? authService, PermissionProvider? permissionProvider}) : _authService = authService ?? AuthService(), _permissionProvider = permissionProvider ?? PermissionProvider();

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  UserRole? get userRole => _userRole;
  String? get token => _token;

  /// Check if user has a specific role
  bool hasRole(UserRole role) {
    return _userRole == role;
  }

  /// Initialize auth state on app start
  Future<void> initializeAuth() async {
    await executeAsync(() async {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final roleString = await _authService.getUserRole();

        _isLoggedIn = true;
        _userRole = roleString != null ? UserRole.fromString(roleString) : null;

        // Only load permissions if we have a valid token
        try {
          await _permissionProvider.initializePermissions();
        } catch (e) {
          // If permissions fail, clear auth and redirect to login
          await logout();
        }
      }
    });
  }

  /// Login with phone and password
  Future<bool> login({required String phone, required String password}) async {
    return await executeApiCall(
      () => _authService.login(phone: phone, password: password),
      onSuccess: (data) {
        _isLoggedIn = true;
        _userRole = data.userRole;
        _token = data.token;

        // Load permissions after successful login
        _permissionProvider.initializePermissions();
      },
    );
  }

  /// Register new staff member (Admin only)
  Future<bool> register({required String name, required String phone, required String password, required String role}) async {
    return await executeApiCall(() => _authService.register(name: name, phone: phone, password: password, role: role));
  }

  /// Logout user
  Future<void> logout() async {
    await executeAsync(() async {
      await _authService.logout();
      _isLoggedIn = false;
      _userRole = null;
      _token = null;

      // Clear permissions on logout
      _permissionProvider.clearPermissions();
    }, showLoading: false);
  }
}
