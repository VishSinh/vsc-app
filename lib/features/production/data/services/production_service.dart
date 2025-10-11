import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/message_data.dart';
import 'package:vsc_app/features/production/data/models/box_order_requests.dart';
import 'package:vsc_app/features/production/data/models/printing_job_requests.dart';
import 'package:vsc_app/features/production/data/models/printer_response.dart';
import 'package:vsc_app/features/production/data/models/tracing_studio_response.dart';
import 'package:vsc_app/features/production/data/models/box_maker_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/features/production/data/models/box_order_table_item.dart';
import 'package:vsc_app/features/production/data/models/printing_table_item.dart';
import 'package:vsc_app/features/production/data/models/tracing_table_item.dart';

class ProductionService extends ApiService {
  /// Update box order status and details
  Future<ApiResponse<MessageData>> updateBoxOrder({required String boxOrderId, required BoxOrderUpdateRequest request}) async {
    return await executeRequest(
      () => patch('${AppConstants.boxOrdersEndpoint}$boxOrderId/', data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update printing job status and details
  Future<ApiResponse<MessageData>> updatePrintingJob({
    required String printingJobId,
    required PrintingJobUpdateRequest request,
  }) async {
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

  /// Get printing table items by printer id
  Future<ApiResponse<List<PrintingTableItem>>> getPrintingItemsByPrinter({
    required String printerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await executeRequest(
      () => get(AppConstants.printingEndpoint, queryParameters: {'printer_id': printerId, 'page': page, 'page_size': pageSize}),
      (json) {
        if (json is List<dynamic>) {
          try {
            return json.map((item) => PrintingTableItem.fromJson(item as Map<String, dynamic>)).toList();
          } catch (e) {
            throw Exception('Failed to parse printing items: $e');
          }
        }
        throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
      },
    );
  }

  /// Get tracing table items by tracing studio id
  Future<ApiResponse<List<TracingTableItem>>> getTracingItemsByStudio({
    required String tracingStudioId,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await executeRequest(
      () => get(
        AppConstants.tracingEndpoint,
        queryParameters: {'tracing_studio_id': tracingStudioId, 'page': page, 'page_size': pageSize},
      ),
      (json) {
        if (json is List<dynamic>) {
          try {
            return json.map((item) => TracingTableItem.fromJson(item as Map<String, dynamic>)).toList();
          } catch (e) {
            throw Exception('Failed to parse tracing items: $e');
          }
        }
        throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
      },
    );
  }

  /// Get box order table items by box maker id
  Future<ApiResponse<List<BoxOrderTableItem>>> getBoxOrdersByBoxMaker({
    required String boxMakerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await executeRequest(
      () => get(AppConstants.boxOrdersEndpoint, queryParameters: {'box_maker_id': boxMakerId, 'page': page, 'page_size': pageSize}),
      (json) {
        if (json is List<dynamic>) {
          try {
            return json.map((item) => BoxOrderTableItem.fromJson(item as Map<String, dynamic>)).toList();
          } catch (e) {
            throw Exception('Failed to parse box orders: $e');
          }
        }
        throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
      },
    );
  }

  /// Toggle paid status for a printing job
  Future<ApiResponse<MessageData>> togglePrinterPaid({required String printingJobId, required bool paid}) async {
    return await executeRequest(
      () => patch('${AppConstants.printingEndpoint}$printingJobId/', data: {'printer_paid': paid}),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Toggle paid status for a tracing studio entry (on printing job)
  Future<ApiResponse<MessageData>> toggleTracingPaid({required String printingJobId, required bool paid}) async {
    return await executeRequest(
      () => patch('${AppConstants.tracingEndpoint}$printingJobId/', data: {'tracing_studio_paid': paid}),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Toggle paid status for a box order
  Future<ApiResponse<MessageData>> toggleBoxMakerPaid({required String boxOrderId, required bool paid}) async {
    return await executeRequest(
      () => patch('${AppConstants.boxOrdersEndpoint}$boxOrderId/', data: {'box_maker_paid': paid}),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }
}
