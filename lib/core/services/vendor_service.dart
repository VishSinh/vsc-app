import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/message_data.dart';
import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

class VendorService extends ApiService {
  VendorService({super.dio, super.secureStorage});

  /// Get all vendors with pagination
  Future<VendorListResponse> getVendors({int page = 1, int pageSize = AppConstants.defaultPageSize}) async =>
      await executeRequest(() => get(AppConstants.vendorsEndpoint, queryParameters: {'page': page, 'page_size': pageSize}), (json) {
        if (json is List) {
          return json.map((item) => Vendor.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          return <Vendor>[];
        }
      });

  /// Create a new vendor
  Future<CreateVendorResponse> createVendor({required String name, required String phone}) async {
    final request = CreateVendorRequest(name: name, phone: phone);

    return await executeRequest(
      () => post(AppConstants.vendorsEndpoint, data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update a vendor
  Future<CreateVendorResponse> updateVendor({required String id, required String name, required String phone}) async {
    final request = CreateVendorRequest(name: name, phone: phone);

    return await executeRequest(
      () => put('${AppConstants.vendorsEndpoint}$id/', data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a vendor
  Future<CreateVendorResponse> deleteVendor({required String id}) async =>
      await executeRequest(() => delete('${AppConstants.vendorsEndpoint}$id/'), (json) => MessageData.fromJson(json as Map<String, dynamic>));

  /// Get vendor by ID
  Future<ApiResponse<Vendor>> getVendorById(String id) async {
    AppLogger.service('VendorService', 'Getting vendor details');
    AppLogger.debug('VendorService: Endpoint: ${AppConstants.vendorsEndpoint}$id/');

    final response = await executeRequest(() => get('${AppConstants.vendorsEndpoint}$id/'), (json) {
      AppLogger.debug('VendorService: Raw JSON received: $json');
      AppLogger.debug('VendorService: JSON type: ${json.runtimeType}');

      if (json is Map<String, dynamic>) {
        AppLogger.debug('VendorService: Creating Vendor from JSON');
        return Vendor.fromJson(json);
      } else {
        AppLogger.error('VendorService: JSON is not a Map, it is: ${json.runtimeType}');
        throw Exception('Invalid vendor data format');
      }
    });

    AppLogger.debug('VendorService: Final response: $response');
    AppLogger.debug('VendorService: Response success: ${response.success}');
    AppLogger.debug('VendorService: Response data: ${response.data}');

    return response;
  }
}
