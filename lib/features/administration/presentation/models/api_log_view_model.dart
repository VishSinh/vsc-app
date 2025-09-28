import 'package:vsc_app/features/administration/data/models/api_log_response.dart';

class ApiLogViewModel {
  final String id;
  final String staffId;
  final String staffName;
  final String endpoint;
  final String requestMethod;
  final Map<String, dynamic> requestBody;
  final Map<String, dynamic> responseBody;
  final int statusCode;
  final int durationMs;
  final String ipAddress;
  final String userAgent;
  final Map<String, dynamic> queryParams;
  final Map<String, dynamic> headers;
  final String? requestId;
  final int responseSizeBytes;
  final DateTime createdAt;

  const ApiLogViewModel({
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

  factory ApiLogViewModel.fromResponse(ApiLogResponse r) {
    return ApiLogViewModel(
      id: r.id,
      staffId: r.staffId,
      staffName: r.staffName,
      endpoint: r.endpoint,
      requestMethod: r.requestMethod,
      requestBody: r.requestBody,
      responseBody: r.responseBody,
      statusCode: r.statusCode,
      durationMs: r.durationMs,
      ipAddress: r.ipAddress,
      userAgent: r.userAgent,
      queryParams: r.queryParams,
      headers: r.headers,
      requestId: r.requestId,
      responseSizeBytes: r.responseSizeBytes,
      createdAt: DateTime.parse(r.createdAt).toLocal(),
    );
  }

  static List<ApiLogViewModel> fromResponseList(List<ApiLogResponse> responseList) {
    return responseList.map((e) => ApiLogViewModel.fromResponse(e)).toList();
  }
}
