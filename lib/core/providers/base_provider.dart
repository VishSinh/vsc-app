import 'package:flutter/material.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/services/navigation_service.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

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

  /// Unified API operation handler
  Future<R?> executeApiOperation<T, R>({
    required Future<ApiResponse<T>> Function() apiCall,
    required R Function(ApiResponse<T> response) onSuccess,
    BuildContext? context,
    bool showSnackbar = true,
    bool showLoading = true,
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      if (showLoading) setLoading(true);
      clearMessages();

      final response = await apiCall();

      if (response.success) {
        final result = onSuccess(response);

        // Success messages respect the showSnackbar parameter
        if (showSnackbar && context != null && successMessage != null) {
          setSuccessWithSnackBar(successMessage, context);
        } else if (successMessage != null) {
          setSuccess(successMessage);
        }

        return result;
      } else {
        final errorMsg = errorMessage ?? response.error?.message ?? 'Operation failed';
        // Error cases always show snackbar for better UX
        if (context != null) {
          setErrorWithSnackBar(errorMsg, context);
        } else {
          setError(errorMsg);
        }
        return null;
      }
    } catch (e) {
      final errorMsg = errorMessage ?? 'Error: $e';
      // Error cases always show snackbar for better UX
      if (context != null) {
        setErrorWithSnackBar(errorMsg, context);
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

/// Mixin for automatic error handling with SnackBar display
mixin AutoSnackBarMixin on BaseProvider {
  BuildContext? _context;

  /// Set the context for automatic SnackBar display
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Override setError to automatically show SnackBar
  @override
  void setError(String? error) {
    super.setError(error);

    if (error != null && _context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_context!.mounted) {
          SnackbarUtils.showError(_context!, error);
        }
      });
    }
  }

  /// Override setSuccess to automatically show SnackBar
  @override
  void setSuccess(String? success) {
    super.setSuccess(success);

    if (success != null && _context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_context!.mounted) {
          SnackbarUtils.showSuccess(_context!, success);
        }
      });
    }
  }

  /// Clear context when provider is disposed
  void clearContext() {
    _context = null;
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
