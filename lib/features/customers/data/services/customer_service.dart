import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/message_data.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/features/customers/data/models/customer_responses.dart';
import 'package:vsc_app/features/customers/data/models/customer_requests.dart';

class CustomerService extends ApiService {
  /// Get customer by ID
  Future<ApiResponse<CustomerResponse>> getCustomerById(String id) async =>
      await executeRequest(() => get('${AppConstants.customersEndpoint}$id/'), (json) => CustomerResponse.fromJson(json as Map<String, dynamic>));

  /// Get customer by phone number
  Future<ApiResponse<CustomerResponse>> getCustomerByPhone(String phone) async => await executeRequest(
    () => get('${AppConstants.customersEndpoint}?phone=$phone'),
    (json) => CustomerResponse.fromJson(json as Map<String, dynamic>),
  );

  /// Create a new customer
  Future<ApiResponse<MessageData>> createCustomer({required String name, required String phone}) async => await executeRequest(
    () => post(
      AppConstants.customersEndpoint,
      data: CreateCustomerRequest(name: name, phone: phone),
    ),
    (json) => MessageData.fromJson(json as Map<String, dynamic>),
  );
}
