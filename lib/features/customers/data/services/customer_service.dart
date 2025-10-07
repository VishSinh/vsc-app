import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/message_data.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/features/customers/data/models/customer_responses.dart';
import 'package:vsc_app/features/customers/data/models/customer_requests.dart';
import 'package:vsc_app/core/utils/query_params.dart';
import 'package:vsc_app/core/services/service_utils.dart';

class CustomerService extends ApiService {
  /// Get customers with pagination
  Future<ApiResponse<List<CustomerResponse>>> getCustomers({int page = 1, int pageSize = AppConstants.defaultPageSize}) async {
    final params = QueryParamsBuilder().withPagination(page: page, pageSize: pageSize).build();

    return await executeRequest(
      () => get(AppConstants.customersEndpoint, queryParameters: params),
      (json) => ServiceUtils.parseList<CustomerResponse>(json, (item) => CustomerResponse.fromJson(item as Map<String, dynamic>)),
    );
  }

  /// Get customer by ID
  Future<ApiResponse<CustomerResponse>> getCustomerById(String id) async => await executeRequest(
    () => get('${AppConstants.customersEndpoint}$id/'),
    (json) => ServiceUtils.parseItem<CustomerResponse>(json, CustomerResponse.fromJson),
  );

  /// Get customer by phone number
  Future<ApiResponse<CustomerResponse>> getCustomerByPhone(String phone) async => await executeRequest(
    () => get('${AppConstants.customersEndpoint}?phone=$phone'),
    (json) => ServiceUtils.parseItem<CustomerResponse>(json, CustomerResponse.fromJson),
  );

  /// Create a new customer
  Future<ApiResponse<MessageData>> createCustomer({required String name, required String phone}) async => await executeRequest(
    () => post(
      AppConstants.customersEndpoint,
      data: CreateCustomerRequest(name: name, phone: phone),
    ),
    (json) => MessageData.fromJson(json as Map<String, dynamic>),
  );

  /// Update a customer (partial update)
  Future<ApiResponse<CustomerResponse>> updateCustomer({required String id, String? name, String? phone}) async =>
      await executeRequest(
        () => patch('${AppConstants.customersEndpoint}$id/', data: {'name': name, 'phone': phone}),
        (json) => ServiceUtils.parseItem<CustomerResponse>(json, CustomerResponse.fromJson),
      );
}
