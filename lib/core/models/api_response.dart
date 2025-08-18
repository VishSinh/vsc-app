import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/models/error_data.dart';
import 'package:vsc_app/core/models/pagination_data.dart';

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
