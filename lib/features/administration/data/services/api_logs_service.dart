import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/features/administration/data/models/api_log_response.dart';

class ApiLogsService extends ApiService {
  Future<ApiResponse<List<ApiLogResponse>>> getApiLogs({
    int page = 1,
    int pageSize = 50,
    String? staffId,
    DateTime? start,
    DateTime? end,
    String? endpoint,
    int? statusCode,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
      if (start != null) 'start': start.toUtc().toIso8601String(),
      if (end != null) 'end': end.toUtc().toIso8601String(),
      if (endpoint != null && endpoint.isNotEmpty) 'endpoint': endpoint,
      if (statusCode != null) 'status_code': statusCode,
    };

    return await executeRequest(() => get(AppConstants.auditApiLogsEndpoint, queryParameters: params), (json) {
      if (json is List<dynamic>) {
        return json.map((e) => ApiLogResponse.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format for API logs');
    });
  }
}
