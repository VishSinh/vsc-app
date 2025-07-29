import 'package:flutter/material.dart';
import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/auth_service.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

class AuthProvider extends BaseProvider {
  final AuthService _authService;
  final PermissionProvider _permissionProvider;

  bool _isLoggedIn = false;
  UserRole? _userRole;
  String? _token;

  AuthProvider({AuthService? authService, PermissionProvider? permissionProvider})
    : _authService = authService ?? AuthService(),
      _permissionProvider = permissionProvider ?? PermissionProvider();

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

        // Only initialize cached permissions, don't call API
        // Permissions API will be called only after fresh login
        await _permissionProvider.initializeCachedPermissions();
      }
    });
  }

  /// Login with phone and password
  Future<bool> login({required String phone, required String password, BuildContext? context}) async {
    return await executeApiCall(
      () => _authService.login(phone, password),
      onSuccess: (data) {
        // Clear previous data first
        _permissionProvider.clearPermissions();

        _isLoggedIn = true;
        _userRole = data.userRole;
        _token = data.token;

        // Load permissions after successful login (only once per session)
        _permissionProvider.initializePermissions();
        if (context != null) {
          SnackbarUtils.showSuccess(context, 'Login successful!');
        }
      },
      onError: (error) {
        if (context != null) {
          SnackbarUtils.showApiError(context, error.message);
        }
      },
      context: context,
    );
  }

  /// Register new staff member (Admin only)
  Future<bool> register({required String name, required String phone, required String password, required String role, BuildContext? context}) async {
    return await executeApiCall(
      () => _authService.register(name: name, phone: phone, password: password, role: role),
      onSuccess: (data) {
        if (context != null) {
          SnackbarUtils.showSuccess(context, 'Staff member registered successfully!');
        }
      },
      onError: (error) {
        if (context != null) {
          SnackbarUtils.showApiError(context, error.message);
        }
      },
      context: context,
    );
  }

  /// Logout user
  Future<void> logout({BuildContext? context}) async {
    await executeAsync(() async {
      // Clear permissions first
      _permissionProvider.clearPermissions();

      await _authService.logout();
      _isLoggedIn = false;
      _userRole = null;
      _token = null;

      if (context != null) {
        SnackbarUtils.showSuccess(context, 'Logged out successfully!');
      }
    }, showLoading: false);
  }
}
