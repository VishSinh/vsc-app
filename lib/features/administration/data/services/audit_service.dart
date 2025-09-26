import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/features/administration/data/models/model_log_response.dart';

class AuditService extends ApiService {
  /// Get model logs with pagination and filters
  Future<ApiResponse<List<ModelLogResponse>>> getModelLogs({
    int page = 1,
    int pageSize = 50,
    String? staffId,
    String? action, // CREATE, UPDATE, DELETE
    DateTime? start,
    DateTime? end,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
      if (action != null && action.isNotEmpty) 'action': action,
      if (start != null) 'start': start.toUtc().toIso8601String(),
      if (end != null) 'end': end.toUtc().toIso8601String(),
    };

    return await executeRequest(() => get(AppConstants.auditModelLogsEndpoint, queryParameters: params), (json) {
      if (json is List<dynamic>) {
        return json.map((e) => ModelLogResponse.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format for model logs');
    });
  }
}
