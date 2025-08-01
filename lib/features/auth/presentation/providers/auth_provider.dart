import 'package:vsc_app/core/enums/user_role.dart';
import 'package:vsc_app/core/providers/base_provider.dart';

import 'package:vsc_app/features/auth/data/services/auth_service.dart';
import 'package:vsc_app/features/auth/domain/models/auth_user.dart';
import 'package:vsc_app/features/auth/domain/services/auth_mapper_service.dart';
import 'package:vsc_app/features/auth/domain/validators/auth_validators.dart';
import 'package:vsc_app/features/auth/presentation/models/auth_form_models.dart';
import 'package:vsc_app/features/auth/presentation/models/auth_view_models.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/auth/presentation/validators/auth_form_validators.dart';

class AuthProvider extends BaseProvider with AutoSnackBarMixin {
  final AuthService _authService;
  final PermissionProvider _permissionProvider;

  AuthUser? _currentUser;
  LoginFormViewModel? _loginForm;
  RegisterFormViewModel? _registerForm;

  AuthProvider({AuthService? authService, PermissionProvider? permissionProvider})
    : _authService = authService ?? AuthService(),
      _permissionProvider = permissionProvider ?? PermissionProvider();

  // Getters
  bool get isLoggedIn => _currentUser != null;
  AuthUser? get currentUser => _currentUser;
  UserRole? get userRole => _currentUser?.role;
  String? get token => _currentUser?.token;

  /// Get current login form
  LoginFormViewModel? get loginForm => _loginForm;

  /// Get current register form
  RegisterFormViewModel? get registerForm => _registerForm;

  /// Get AuthUserViewModel for UI consumption
  AuthUserViewModel? get authUserViewModel {
    if (_currentUser == null) return null;
    return AuthUserViewModel.fromDomainModel(_currentUser!);
  }

  /// Get LoginFormDisplayViewModel for UI consumption
  LoginFormDisplayViewModel get loginFormDisplayViewModel {
    if (_loginForm == null) {
      return LoginFormDisplayViewModel.empty();
    }

    final fieldErrors = <String, String?>{};
    if (_loginForm!.validationResult.hasError('phone')) {
      fieldErrors['phone'] = _loginForm!.validationResult.getMessage('phone');
    }
    if (_loginForm!.validationResult.hasError('password')) {
      fieldErrors['password'] = _loginForm!.validationResult.getMessage('password');
    }

    return LoginFormDisplayViewModel(isLoading: isLoading, errorMessage: errorMessage, isFormValid: _loginForm!.isValid, fieldErrors: fieldErrors);
  }

  /// Get RegisterFormDisplayViewModel for UI consumption
  RegisterFormDisplayViewModel get registerFormDisplayViewModel {
    if (_registerForm == null) {
      return RegisterFormDisplayViewModel.empty();
    }

    final fieldErrors = <String, String?>{};
    final validation = _registerForm!.validationResult;

    for (final field in ['name', 'phone', 'password', 'confirmPassword', 'role']) {
      if (validation.hasError(field)) {
        fieldErrors[field] = validation.getMessage(field);
      }
    }

    return RegisterFormDisplayViewModel(
      isLoading: isLoading,
      errorMessage: errorMessage,
      isFormValid: _registerForm!.isValid,
      fieldErrors: fieldErrors,
      availableRoles: RegisterFormViewModel.availableRoles,
    );
  }

  /// Check if user has a specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  /// Initialize auth state on app start
  Future<void> initializeAuth() async {
    await executeAsync(() async {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final roleString = await _authService.getUserRole();
        if (roleString != null) {
          // Create a minimal user from stored data
          _currentUser = AuthUser(
            id: '', // Not available from stored data
            name: '', // Not available from stored data
            phone: '', // Not available from stored data
            token: '', // Not available from stored data
            role: UserRole.fromString(roleString),
            createdAt: DateTime.now(),
          );
        }

        // Only initialize cached permissions, don't call API
        // Permissions API will be called only after fresh login
        await _permissionProvider.initializeCachedPermissions();
      }
    });
  }

  /// Update login form
  void updateLoginForm({String? phone, String? password}) {
    final currentPhone = phone ?? _loginForm?.phoneController.text ?? '';
    final currentPassword = password ?? _loginForm?.passwordController.text ?? '';

    _loginForm = LoginFormViewModel.fromFormData(phone: currentPhone, password: currentPassword);
    notifyListeners();
  }

  /// Update register form
  void updateRegisterForm({String? name, String? phone, String? password, String? confirmPassword, String? role}) {
    final currentName = name ?? _registerForm?.nameController.text ?? '';
    final currentPhone = phone ?? _registerForm?.phoneController.text ?? '';
    final currentPassword = password ?? _registerForm?.passwordController.text ?? '';
    final currentConfirmPassword = confirmPassword ?? _registerForm?.confirmPasswordController.text ?? '';
    final currentRole = role ?? _registerForm?.role ?? '';

    _registerForm = RegisterFormViewModel.fromFormData(
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

    // UI validation first
    final formValidation = AuthFormValidators.validateLoginForm(
      phone: _loginForm!.phoneController.text,
      password: _loginForm!.passwordController.text,
    );

    if (!formValidation.isValid) {
      setError(formValidation.firstMessage ?? 'Please check your input');
      return false;
    }

    // Domain validation
    final domainValidation = AuthDomainValidators.validateLoginData(
      phone: _loginForm!.phoneController.text,
      password: _loginForm!.passwordController.text,
    );

    if (!domainValidation.isValid) {
      setError(domainValidation.firstMessage ?? 'Invalid credentials');
      return false;
    }

    return await executeApiCall(
      () => _authService.login(_loginForm!.phoneController.text.trim(), _loginForm!.passwordController.text),
      onSuccess: (loginData) {
        // Clear previous data first
        _permissionProvider.clearPermissions();

        // Convert to domain model
        _currentUser = AuthMapperService.fromLoginResponse(loginData);

        // Load permissions after successful login (only once per session)
        _permissionProvider.initializePermissions();
        setSuccess('Login successful!');
      },
    );
  }

  /// Register new staff member (Admin only)
  Future<bool> register() async {
    if (_registerForm == null) {
      setError('Register form not initialized');
      return false;
    }

    // UI validation first
    final formValidation = AuthFormValidators.validateRegisterForm(
      name: _registerForm!.nameController.text,
      phone: _registerForm!.phoneController.text,
      password: _registerForm!.passwordController.text,
      confirmPassword: _registerForm!.confirmPasswordController.text,
      role: _registerForm!.role,
    );

    if (!formValidation.isValid) {
      setError(formValidation.firstMessage ?? 'Please check your input');
      return false;
    }

    // Domain validation
    final domainValidation = AuthDomainValidators.validateRegistrationData(
      name: _registerForm!.nameController.text,
      phone: _registerForm!.phoneController.text,
      password: _registerForm!.passwordController.text,
      confirmPassword: _registerForm!.confirmPasswordController.text,
      role: _registerForm!.role,
    );

    if (!domainValidation.isValid) {
      setError(domainValidation.firstMessage ?? 'Invalid registration data');
      return false;
    }

    // Check if user has permission to register
    final permissionValidation = AuthDomainValidators.validateRegistrationPermission(_currentUser);
    if (!permissionValidation.isValid) {
      setError(permissionValidation.firstMessage ?? 'Permission denied');
      return false;
    }

    return await executeApiCall(
      () => _authService.register(
        name: _registerForm!.nameController.text.trim(),
        phone: _registerForm!.phoneController.text.trim(),
        password: _registerForm!.passwordController.text,
        role: _registerForm!.role,
      ),
      onSuccess: (data) {
        setSuccess('Staff member registered successfully!');
      },
    );
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

  /// Dispose resources
  @override
  void dispose() {
    _loginForm?.dispose();
    _registerForm?.dispose();
    super.dispose();
  }
}
