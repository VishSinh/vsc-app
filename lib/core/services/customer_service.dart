import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/customer_model.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class CustomerService extends ApiService {
  /// Get customer by phone number
  Future<ApiResponse<Customer>> getCustomerByPhone(String phone) async =>
      await executeRequest(() => get('${AppConstants.customersEndpoint}?phone=$phone'), (json) => Customer.fromJson(json as Map<String, dynamic>));

  /// Create a new customer
  Future<ApiResponse<MessageData>> createCustomer({required String name, required String phone}) async => await executeRequest(
    () => post(
      AppConstants.customersEndpoint,
      data: CreateCustomerRequest(name: name, phone: phone).toJson(),
    ),
    (json) => MessageData.fromJson(json as Map<String, dynamic>),
  );
}
