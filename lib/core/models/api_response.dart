import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API response wrapper used across all API calls
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ErrorData? error;
  final PaginationData? pagination;

  const ApiResponse({required this.success, this.data, this.error, this.pagination});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => _$ApiResponseToJson(this, toJsonT);
}

/// Error data structure for API responses
@JsonSerializable()
class ErrorData {
  final String code;
  final String message;
  final String details;

  const ErrorData({required this.code, required this.message, required this.details});

  factory ErrorData.fromJson(Map<String, dynamic> json) => _$ErrorDataFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorDataToJson(this);

  /// Create a network error
  factory ErrorData.networkError(String message) => ErrorData(code: 'NETWORK_ERROR', message: message, details: '');

  /// Create an empty error (for success responses)
  factory ErrorData.empty() => ErrorData(code: '', message: '', details: '');
}

/// Pagination data structure for API responses
@JsonSerializable()
class PaginationData {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'page_size')
  final int pageSize;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_previous')
  final bool hasPrevious;
  @JsonKey(name: 'next_page')
  final int? nextPage;
  @JsonKey(name: 'previous_page')
  final int? previousPage;

  const PaginationData({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    this.nextPage,
    this.previousPage,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) => _$PaginationDataFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationDataToJson(this);
}

/// Standard message data structure for simple responses
@JsonSerializable()
class MessageData {
  final String message;

  const MessageData({required this.message});

  factory MessageData.fromJson(Map<String, dynamic> json) => _$MessageDataFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDataToJson(this);
}
