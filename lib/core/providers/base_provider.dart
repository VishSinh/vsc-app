import 'package:flutter/material.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/services/navigation_service.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  BuildContext? _context;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Set the context for centralized snackbar management
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Clear the stored context
  void clearContext() {
    _context = null;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setSuccess(String? success) {
    _successMessage = success;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Set error with automatic SnackBar display
  void setErrorWithSnackBar(String? error, BuildContext context) {
    _errorMessage = error;
    notifyListeners();

    if (error != null) {
      // Use post-frame callback to ensure context is valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          SnackbarUtils.showError(context, error);
        }
      });
    }
  }

  /// Set success with automatic SnackBar display
  void setSuccessWithSnackBar(String? success, BuildContext context) {
    _successMessage = success;
    notifyListeners();

    if (success != null) {
      // Use post-frame callback to ensure context is valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          SnackbarUtils.showSuccess(context, success);
        }
      });
    }
  }

  /// Execute an async operation with loading state management
  Future<T?> executeAsync<T>(Future<T> Function() operation, {bool showLoading = true}) async {
    try {
      if (showLoading) setLoading(true);
      clearMessages();

      final result = await operation();

      if (showLoading) setLoading(false);
      return result;
    } catch (e) {
      if (showLoading) setLoading(false);

      // Handle UnauthorizedException specifically
      if (e is UnauthorizedException) {
        setError(e.message);
        NavigationService.navigateToLogin();
      } else {
        setError(e.toString());
      }

      return null;
    }
  }

  /// Extract message from response data if it has a message property
  String? _extractMessageFromData(dynamic data) {
    if (data == null) return null;

    // Try to access message property using reflection
    try {
      if (data is Map<String, dynamic>) {
        return data['message'] as String?;
      }
      // For objects with message property
      final message = (data as dynamic).message;
      return message is String ? message : null;
    } catch (e) {
      return null;
    }
  }

  /// Unified API operation handler
  Future<R?> executeApiOperation<T, R>({
    required Future<ApiResponse<T>> Function() apiCall,
    required R Function(ApiResponse<T> response) onSuccess,
    bool showSnackbar = true,
    bool showLoading = true,
    String? successMessage = 'Operation successful',
    String? errorMessage = 'Operation failed',
  }) async {
    try {
      if (showLoading) setLoading(true);
      clearMessages();

      final response = await apiCall();

      if (response.success) {
        final result = onSuccess(response);

        // Prioritize response.data.message over successMessage
        final finalSuccessMessage = _extractMessageFromData(response.data) ?? successMessage;

        // Success messages respect the showSnackbar parameter
        if (showSnackbar && _context != null && finalSuccessMessage != null) {
          setSuccessWithSnackBar(finalSuccessMessage, _context!);
        } else if (finalSuccessMessage != null) {
          setSuccess(finalSuccessMessage);
        }

        return result;
      } else {
        // Prioritize response.error.message over errorMessage
        final finalErrorMessage = response.error?.message ?? errorMessage;
        // Error cases always show snackbar for better UX
        if (_context != null) {
          setErrorWithSnackBar(finalErrorMessage, _context!);
        } else {
          setError(finalErrorMessage);
        }
        return null;
      }
    } catch (e) {
      final errorMsg = 'Error: $e';
      if (_context != null) {
        setErrorWithSnackBar(errorMsg, _context!);
      } else {
        setError(errorMsg);
      }
      return null;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  /// Reset the provider state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

/// Mixin for pagination functionality
mixin PaginationMixin on BaseProvider {
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = false; // Changed from true to false

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;

  void setHasMoreData(bool hasMore) {
    _hasMoreData = hasMore;
    notifyListeners();
  }

  void incrementPage() {
    _currentPage++;
  }

  void resetPagination() {
    _currentPage = 1;
    _hasMoreData = false; // Changed from true to false
  }
}

/// Mixin for search functionality
mixin SearchMixin on BaseProvider {
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
