import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';

abstract class BaseService {
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  BaseService({Dio? dio, FlutterSecureStorage? secureStorage}) : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = dio ?? _createDio();
  }

  /// Create and configure Dio instance with interceptors
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    // Add pretty logger interceptor
    dio.interceptors.add(
      PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, responseHeader: false, error: true, compact: true, maxWidth: 90),
    );

    // Add auth token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _secureStorage.read(key: AppConstants.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized globally
          if (error.response?.statusCode == 401) {
            await _clearAuth();
            throw UnauthorizedException('Session expired. Please log in again.');
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Get the secure storage instance
  FlutterSecureStorage get secureStorage => _secureStorage;

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Make a GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(endpoint, queryParameters: queryParameters);
  }

  /// Make a POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    return await _dio.post(endpoint, data: data);
  }

  /// Make a PATCH request
  Future<Response> patch(String endpoint, {dynamic data}) async {
    return await _dio.patch(endpoint, data: data);
  }

  /// Make a DELETE request
  Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }

  /// Make a PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    return await _dio.put(endpoint, data: data);
  }

  /// Execute a request with automatic error handling
  Future<ApiResponse<T>> executeRequest<T>(Future<Response> Function() request, T Function(dynamic json) fromJson) async {
    try {
      final response = await request();
      return handleResponse(response, fromJson);
    } on DioException catch (e) {
      return handleError(e, fromJson);
    } catch (e) {
      return ApiResponse(success: false, data: null as T, error: ErrorData.networkError(e.toString()));
    }
  }

  /// Handle API response and convert to ApiResponse<T> with built-in JSON parsing
  ApiResponse<T> handleResponse<T>(Response response, T Function(dynamic json) fromJson) {
    try {
      // Dio automatically parses JSON, so response.data is already parsed
      final jsonData = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(jsonData, (json) => fromJson(json));
    } catch (e) {
      return ApiResponse(success: false, data: null as T, error: ErrorData.networkError(e.toString()));
    }
  }

  /// Handle DioError and return a standardized error response
  ApiResponse<T> handleError<T>(DioException error, T Function(dynamic json) fromJson) {
    String errorMessage = 'Network error occurred';

    if (error.response != null) {
      // Server responded with error status
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String? ?? responseData['error']?['message'] as String? ?? 'Server error ($statusCode)';
      } else {
        errorMessage = 'Server error ($statusCode)';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Receive timeout';
    } else if (error.type == DioExceptionType.sendTimeout) {
      errorMessage = 'Send timeout';
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection';
    } else if (error.type == DioExceptionType.badResponse) {
      errorMessage = 'Bad response from server';
    } else if (error.type == DioExceptionType.cancel) {
      errorMessage = 'Request was cancelled';
    }

    return ApiResponse(success: false, data: null as T, error: ErrorData.networkError(errorMessage));
  }

  /// Clear authentication data
  Future<void> _clearAuth() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
    await _secureStorage.delete(key: AppConstants.userRoleKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.authTokenKey);
    return token != null;
  }

  /// Get stored authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.authTokenKey);
  }

  /// Store authentication token
  Future<void> storeToken(String token) async {
    await _secureStorage.write(key: AppConstants.authTokenKey, value: token);
  }

  /// Store user role
  Future<void> storeUserRole(String role) async {
    await _secureStorage.write(key: AppConstants.userRoleKey, value: role);
  }

  /// Get stored user role
  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: AppConstants.userRoleKey);
  }

  /// Clear all stored data
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
  }

  /// Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Add custom headers
  void addHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Remove custom headers
  void removeHeaders(List<String> headerKeys) {
    for (final key in headerKeys) {
      _dio.options.headers.remove(key);
    }
  }

  /// Set request timeout
  void setTimeout(Duration timeout) {
    _dio.options.connectTimeout = timeout;
    _dio.options.receiveTimeout = timeout;
    _dio.options.sendTimeout = timeout;
  }
}

/// Custom exception for unauthorized access
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for network errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  ApiException(this.message, {this.code, this.details});

  @override
  String toString() => 'ApiException: $message${code != null ? ' (Code: $code)' : ''}';
}
