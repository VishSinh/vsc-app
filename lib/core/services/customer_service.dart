import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/customer_model.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class CustomerService extends BaseService {
  /// Get customer by phone number
  Future<ApiResponse<Customer>> getCustomerByPhone(String phone) async {
    return await executeRequest(
      () => get('${AppConstants.customersEndpoint}?phone=$phone'),
      (json) => Customer.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Create a new customer
  Future<ApiResponse<MessageData>> createCustomer({required String name, required String phone}) async {
    final request = CreateCustomerRequest(name: name, phone: phone);

    return await executeRequest(
      () => post(AppConstants.customersEndpoint, data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }
}
