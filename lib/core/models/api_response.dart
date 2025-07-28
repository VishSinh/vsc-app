import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API response wrapper used across all API calls
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T data;
  final ErrorData error;

  const ApiResponse({
    required this.success,
    required this.data,
    required this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => 
      _$ApiResponseToJson(this, toJsonT);
}

/// Standard error data structure used across all API responses
@JsonSerializable()
class ErrorData {
  final String code;
  final String message;
  final String details;

  const ErrorData({
    required this.code,
    required this.message,
    required this.details,
  });

  factory ErrorData.fromJson(Map<String, dynamic> json) => _$ErrorDataFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorDataToJson(this);

  /// Create a network error
  factory ErrorData.networkError(String details) => ErrorData(
    code: 'NETWORK_ERROR',
    message: 'Network error occurred',
    details: details,
  );

  /// Create an unauthorized error
  factory ErrorData.unauthorized() => ErrorData(
    code: 'UNAUTHORIZED',
    message: 'Authentication required',
    details: 'No token found',
  );

  /// Create a generic error
  factory ErrorData.generic(String message, {String? details}) => ErrorData(
    code: 'GENERIC_ERROR',
    message: message,
    details: details ?? '',
  );
}

/// Standard message data structure for simple responses
@JsonSerializable()
class MessageData {
  final String message;

  const MessageData({
    required this.message,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) => _$MessageDataFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDataToJson(this);
} 