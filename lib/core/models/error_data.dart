import 'package:json_annotation/json_annotation.dart';

part 'error_data.g.dart';

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
