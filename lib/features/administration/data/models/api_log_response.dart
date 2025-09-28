import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'api_log_response.g.dart';

@JsonSerializable()
class ApiLogResponse {
  final String id;
  @JsonKey(name: 'staff_id')
  final String staffId;
  @JsonKey(name: 'staff_name')
  final String staffName;
  final String endpoint;
  @JsonKey(name: 'request_method')
  final String requestMethod;
  @JsonKey(name: 'request_body', fromJson: apiLogCoerceToMap, toJson: apiLogMapToJson)
  final Map<String, dynamic> requestBody;
  @JsonKey(name: 'response_body', fromJson: apiLogCoerceToMap, toJson: apiLogMapToJson)
  final Map<String, dynamic> responseBody;
  @JsonKey(name: 'status_code')
  final int statusCode;
  @JsonKey(name: 'duration_ms')
  final int durationMs;
  @JsonKey(name: 'ip_address', defaultValue: '')
  final String ipAddress;
  @JsonKey(name: 'user_agent', defaultValue: '')
  final String userAgent;
  @JsonKey(name: 'query_params', fromJson: apiLogCoerceToMap, toJson: apiLogMapToJson)
  final Map<String, dynamic> queryParams;
  @JsonKey(fromJson: apiLogCoerceToMap, toJson: apiLogMapToJson)
  final Map<String, dynamic> headers;
  @JsonKey(name: 'request_id')
  final String? requestId;
  @JsonKey(name: 'response_size_bytes')
  final int responseSizeBytes;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ApiLogResponse({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.endpoint,
    required this.requestMethod,
    required this.requestBody,
    required this.responseBody,
    required this.statusCode,
    required this.durationMs,
    required this.ipAddress,
    required this.userAgent,
    required this.queryParams,
    required this.headers,
    required this.requestId,
    required this.responseSizeBytes,
    required this.createdAt,
  });

  factory ApiLogResponse.fromJson(Map<String, dynamic> json) => _$ApiLogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiLogResponseToJson(this);
}

Map<String, dynamic> apiLogCoerceToMap(Object? raw) {
  if (raw == null) return <String, dynamic>{};
  if (raw is Map) {
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }
  if (raw is String) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
      if (decoded is List) {
        return <String, dynamic>{'items': decoded};
      }
      return <String, dynamic>{'value': raw};
    } catch (_) {
      return <String, dynamic>{'value': raw};
    }
  }
  if (raw is List) {
    return <String, dynamic>{'items': raw};
  }
  return <String, dynamic>{'value': raw};
}

Map<String, dynamic> apiLogMapToJson(Map<String, dynamic> value) => value;
