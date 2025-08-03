import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/features/production/data/models/box_order_requests.dart';
import 'package:vsc_app/features/production/data/models/printing_job_requests.dart';
import 'package:vsc_app/features/production/data/models/printer_response.dart';
import 'package:vsc_app/features/production/data/models/tracing_studio_response.dart';
import 'package:vsc_app/features/production/data/models/box_maker_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class ProductionService extends ApiService {
  /// Update box order status and details
  Future<ApiResponse<MessageData>> updateBoxOrder({required String boxOrderId, required BoxOrderUpdateRequest request}) async {
    return await executeRequest(
      () => patch('${AppConstants.boxOrdersEndpoint}$boxOrderId/', data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update printing job status and details
  Future<ApiResponse<MessageData>> updatePrintingJob({required String printingJobId, required PrintingJobUpdateRequest request}) async {
    return await executeRequest(
      () => patch('${AppConstants.printingJobsEndpoint}$printingJobId/', data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get printers with pagination
  Future<ApiResponse<List<PrinterResponse>>> getPrinters({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.printersEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        try {
          return json.map((printerJson) {
            if (printerJson is Map<String, dynamic>) {
              return PrinterResponse.fromJson(printerJson);
            } else {
              throw Exception('Invalid printer format: expected Map but got ${printerJson.runtimeType}');
            }
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse printers: $e');
        }
      }
      throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
    });
  }

  /// Get tracing studios with pagination
  Future<ApiResponse<List<TracingStudioResponse>>> getTracingStudios({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.tracingStudiosEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        try {
          return json.map((tracingStudioJson) {
            if (tracingStudioJson is Map<String, dynamic>) {
              return TracingStudioResponse.fromJson(tracingStudioJson);
            } else {
              throw Exception('Invalid tracing studio format: expected Map but got ${tracingStudioJson.runtimeType}');
            }
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse tracing studios: $e');
        }
      }
      throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
    });
  }

  /// Get box makers with pagination
  Future<ApiResponse<List<BoxMakerResponse>>> getBoxMakers({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.boxMakersEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        try {
          return json.map((boxMakerJson) {
            if (boxMakerJson is Map<String, dynamic>) {
              return BoxMakerResponse.fromJson(boxMakerJson);
            } else {
              throw Exception('Invalid box maker format: expected Map but got ${boxMakerJson.runtimeType}');
            }
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse box makers: $e');
        }
      }
      throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
    });
  }
}
