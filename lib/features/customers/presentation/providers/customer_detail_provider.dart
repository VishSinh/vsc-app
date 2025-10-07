import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/customers/data/services/customer_service.dart';
import 'package:vsc_app/features/customers/presentation/models/base_customer_view_model.dart';

class CustomerDetailProvider extends BaseProvider {
  final CustomerService _customerService = CustomerService();

  BaseCustomerViewModel? _customer;
  BaseCustomerViewModel? get customer => _customer;

  Future<void> loadCustomer(String id) async {
    await executeApiOperation(
      apiCall: () => _customerService.getCustomerById(id),
      onSuccess: (response) {
        final c = response.data!;
        _customer = BaseCustomerViewModel(id: c.id, name: c.name, phone: c.phone, isActive: c.isActive);
        notifyListeners();
        return true;
      },
      showSnackbar: false,
      errorMessage: 'Failed to load customer',
    );
  }

  Future<bool> updateCustomer({required String id, String? name, String? phone}) async {
    final res = await executeApiOperation(
      apiCall: () => _customerService.updateCustomer(id: id, name: name, phone: phone),
      onSuccess: (response) {
        final c = response.data!;
        _customer = BaseCustomerViewModel(id: c.id, name: c.name, phone: c.phone, isActive: c.isActive);
        notifyListeners();
        return true;
      },
      showSnackbar: true,
      successMessage: 'Customer updated',
      errorMessage: 'Failed to update customer',
    );
    return res ?? false;
  }
}
