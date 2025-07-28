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

  /// Execute an API call with standardized error handling
  Future<bool> executeApiCall<T>(Future<ApiResponse<T>> Function() apiCall, {void Function(T data)? onSuccess, void Function(String error)? onError}) async {
    final result = await executeAsync(() async {
      final response = await apiCall();

      if (response.success) {
        onSuccess?.call(response.data);
        return true;
      } else {
        final errorMessage = response.error.message.isNotEmpty ? response.error.message : 'Operation failed';
        onError?.call(errorMessage);
        throw Exception(errorMessage);
      }
    });

    return result ?? false;
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
  bool _hasMoreData = true;

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
    _hasMoreData = true;
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
