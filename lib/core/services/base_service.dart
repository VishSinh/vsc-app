import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/app/app_config.dart';

/// Base service class that provides common functionality for all API services
abstract class BaseService {
  // Use the dynamic API base URL from AppConstants
  static String get _baseUrl => AppConstants.apiBaseUrl;

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  BaseService({Dio? dio, FlutterSecureStorage? secureStorage}) : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = dio ?? _createDio();
    _setupInterceptors();
  }

  /// Create and configure Dio instance with interceptors
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: AppConstants.requestTimeout,
        receiveTimeout: AppConstants.requestTimeout,
        sendTimeout: AppConstants.requestTimeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    // Add pretty logger interceptor
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: AppConfig.fontSize5xl.toInt(),
      ),
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

  /// Setup Dio interceptors for authentication and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header if token exists
          final token = await _secureStorage.read(key: AppConstants.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle network errors
          if (error.type == DioExceptionType.connectionError) {
            handler.reject(DioException(requestOptions: error.requestOptions, error: 'Network error: No internet connection'));
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  /// Get the secure storage instance
  FlutterSecureStorage get secureStorage => _secureStorage;

  /// Get the Dio instance
  Dio get dio => _dio;

  /// HTTP GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// HTTP POST request
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  /// HTTP PUT request
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  /// HTTP DELETE request
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  /// Execute a request and handle the response
  Future<ApiResponse<T>> executeRequest<T>(Future<Response> Function() request, T Function(dynamic json) fromJson) async {
    try {
      final response = await request();
      return handleResponse(response, fromJson);
    } on DioException catch (e) {
      return handleDioError(e);
    } catch (e) {
      return ApiResponse(success: false, data: null, error: ErrorData.networkError(e.toString()));
    }
  }

  /// Handle API response and convert to ApiResponse<T> with built-in JSON parsing
  ApiResponse<T> handleResponse<T>(Response response, T Function(dynamic json) fromJson) {
    try {
      // Dio automatically parses JSON, so response.data is already parsed
      final jsonData = response.data as Map<String, dynamic>;

      // Check if this is a success or error response
      final bool success = jsonData['success'] as bool;

      if (success) {
        // Success response: has data, no error
        final data = jsonData['data'];
        T parsedData;

        if (data == null) {
          // Handle case where data is null but success is true
          parsedData = fromJson({});
        } else {
          parsedData = fromJson(data);
        }

        // Extract pagination data if present
        PaginationData? pagination;
        if (jsonData.containsKey('pagination')) {
          final paginationJson = jsonData['pagination'] as Map<String, dynamic>;
          pagination = PaginationData.fromJson(paginationJson);
        }

        return ApiResponse(success: true, data: parsedData, error: null, pagination: pagination);
      } else {
        // Error response: has error, no data
        final errorJson = jsonData['error'] as Map<String, dynamic>;
        final error = ErrorData.fromJson(errorJson);

        return ApiResponse(success: false, data: null, error: error);
      }
    } catch (e) {
      return ApiResponse(success: false, data: null, error: ErrorData.networkError('Failed to parse response: $e'));
    }
  }

  /// Handle Dio errors
  ApiResponse<T> handleDioError<T>(DioException error) {
    String errorMessage = 'Network error occurred';

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      switch (statusCode) {
        case 401:
          errorMessage = 'Unauthorized: Please login again';
          break;
        case 403:
          errorMessage = 'Forbidden: You don\'t have permission to access this resource';
          break;
        case 404:
          errorMessage = 'Resource not found';
          break;
        case 500:
          errorMessage = 'Server error: Please try again later';
          break;
        default:
          if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
            final errorData = responseData['error'] as Map<String, dynamic>;
            errorMessage = errorData['message'] ?? 'Unknown error occurred';
          } else {
            errorMessage = 'Request failed with status code: $statusCode';
          }
      }
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Request timeout';
    }

    return ApiResponse(success: false, data: null, error: ErrorData.networkError(errorMessage));
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
