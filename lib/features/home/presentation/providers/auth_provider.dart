import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/home/data/services/auth_service.dart';
import 'package:vsc_app/features/home/data/models/auth_responses.dart';
import 'package:vsc_app/features/home/presentation/models/auth_form_models.dart';
import 'package:vsc_app/features/home/presentation/models/auth_view_models.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/home/presentation/services/auth_validators.dart';

/// Provider for managing authentication state and operations
class AuthProvider extends BaseProvider {
  final AuthService _authService = AuthService();
  final PermissionProvider _permissionProvider = PermissionProvider();

  LoginResponse? _currentUser;
  LoginFormViewModel? _loginForm;
  RegisterFormViewModel? _registerForm;

  // Getters
  bool get isLoggedIn => _currentUser != null;
  LoginResponse? get currentUser => _currentUser;
  UserRole? get userRole => _currentUser?.userRole;
  String? get token => _currentUser?.token;

  /// Get current login form
  LoginFormViewModel? get loginForm => _loginForm;

  /// Get current register form
  RegisterFormViewModel? get registerForm => _registerForm;

  /// Get AuthUserViewModel for UI consumption
  AuthUserViewModel? get authUserViewModel {
    if (_currentUser == null) return null;
    return AuthUserViewModel.fromApiResponse(_currentUser!);
  }

  /// Get available roles for selection
  List<String> get availableRoles => RegisterFormViewModel.availableRoles;

  /// Check if user has a specific role
  bool hasRole(UserRole role) {
    return _currentUser?.userRole == role;
  }

  /// Initialize auth state on app start
  Future<void> initializeAuth() async {
    await executeAsync(() async {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final roleString = await _authService.getUserRole();
        if (roleString != null) {
          // Create LoginResponse from stored role data
          _currentUser = LoginResponse(
            message: 'Current user',
            token: '', // Token is stored separately in secure storage
            role: roleString,
          );
        }

        // Only initialize cached permissions, don't call API
        // Permissions API will be called only after fresh login
        await _permissionProvider.initializeCachedPermissions();
      }
    }, showLoading: false);
  }

  /// Update login form
  void updateLoginForm({String? phone, String? password}) {
    final currentPhone = phone ?? _loginForm?.phone ?? '';
    final currentPassword = password ?? _loginForm?.password ?? '';

    _loginForm = LoginFormViewModel(phone: currentPhone, password: currentPassword);
    notifyListeners();
  }

  /// Update register form
  void updateRegisterForm({String? name, String? phone, String? password, String? confirmPassword, String? role}) {
    final currentName = name ?? _registerForm?.name ?? '';
    final currentPhone = phone ?? _registerForm?.phone ?? '';
    final currentPassword = password ?? _registerForm?.password ?? '';
    final currentConfirmPassword = confirmPassword ?? _registerForm?.confirmPassword ?? '';
    final currentRole = role ?? _registerForm?.role ?? '';

    _registerForm = RegisterFormViewModel(
      name: currentName,
      phone: currentPhone,
      password: currentPassword,
      confirmPassword: currentConfirmPassword,
      role: currentRole,
    );
    notifyListeners();
  }

  /// Initialize login form
  void initializeLoginForm() {
    _loginForm = LoginFormViewModel.empty();
    notifyListeners();
  }

  /// Initialize register form
  void initializeRegisterForm() {
    _registerForm = RegisterFormViewModel.empty();
    notifyListeners();
  }

  /// Login with current form data
  Future<bool> login() async {
    if (_loginForm == null) {
      setError('Login form not initialized');
      return false;
    }

    // Validate form
    final validationResult = _loginForm!.validate();
    if (!validationResult.isValid) {
      setError(validationResult.firstMessage ?? 'Please check your input');
      return false;
    }

    final result = await executeApiOperation(
      apiCall: () => _authService.login(_loginForm!.phone.trim(), _loginForm!.password),
      onSuccess: (response) {
        // Clear previous data first
        _permissionProvider.clearPermissions();

        // Store the login data directly
        _currentUser = response.data!;

        // Load permissions after successful login (only once per session)
        _permissionProvider.initializePermissions();
        return response.data!;
      },
      successMessage: 'Login successful!',
      errorMessage: 'Login failed',
    );
    return result != null;
  }

  /// Register new staff member (Admin only)
  Future<bool> register() async {
    if (_registerForm == null) {
      setError('Register form not initialized');
      return false;
    }

    // Validate form
    final validationResult = _registerForm!.validate();
    if (!validationResult.isValid) {
      setError(validationResult.firstMessage ?? 'Please check your input');
      return false;
    }

    // Check if user has permission to register (admin only)
    final permissionValidation = AuthValidators.validateRegistrationPermission(_currentUser?.userRole);
    if (!permissionValidation.isValid) {
      setError(permissionValidation.firstMessage ?? 'Permission denied');
      return false;
    }

    final result = await executeApiOperation(
      apiCall: () => _authService.register(
        name: _registerForm!.name.trim(),
        phone: _registerForm!.phone.trim(),
        password: _registerForm!.password,
        role: _registerForm!.role,
      ),
      onSuccess: (response) {
        return response.data!;
      },
      successMessage: 'Staff member registered successfully!',
      errorMessage: 'Registration failed',
    );
    return result != null;
  }

  /// Logout user
  Future<void> logout() async {
    await executeAsync(() async {
      // Clear permissions first
      _permissionProvider.clearPermissions();

      await _authService.logout();
      _currentUser = null;
      setSuccess('Logged out successfully!');
    }, showLoading: false);
  }

  /// Reset the provider state
  @override
  void reset() {
    _loginForm = null;
    _registerForm = null;
    super.reset();
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
