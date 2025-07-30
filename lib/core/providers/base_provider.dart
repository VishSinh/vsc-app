import 'package:flutter/material.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/services/navigation_service.dart';

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

  /// Execute an API call with automatic error handling
  Future<bool> executeApiCall<T>(
    Future<ApiResponse<T>> Function() apiCall, {
    Function(T data)? onSuccess,
    Function(ErrorData error)? onError,
    BuildContext? context,
  }) async {
    try {
      setLoading(true);
      clearMessages();

      final response = await apiCall();

      if (response.success && response.data != null) {
        if (onSuccess != null) {
          onSuccess(response.data as T);
        }
        return true;
      } else {
        final errorMessage = response.error?.details ?? response.error?.message ?? 'Unknown error occurred';
        setError(errorMessage);
        if (onError != null && response.error != null) {
          onError(response.error!);
        }
        return false;
      }
    } catch (e) {
      final errorMessage = 'Network error: $e';
      setError(errorMessage);
      return false;
    } finally {
      setLoading(false);
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
