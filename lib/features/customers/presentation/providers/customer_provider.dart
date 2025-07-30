import 'package:vsc_app/core/models/customer_model.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/customer_service.dart';

class CustomerProvider extends BaseProvider {
  final CustomerService _customerService = CustomerService();

  Customer? _selectedCustomer;
  Customer? get selectedCustomer => _selectedCustomer;

  /// Search customer by phone number
  Future<Customer?> searchCustomerByPhone(String phone) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _customerService.getCustomerByPhone(phone);

      if (response.success && response.data != null) {
        _selectedCustomer = response.data;
        notifyListeners();
        return response.data;
      } else {
        final errorMessage = response.error?.details ?? response.error?.message ?? 'Customer not found';
        print('🔍 CustomerProvider: Setting error: "$errorMessage"');
        setError(errorMessage);
        return null;
      }
    } catch (e) {
      setError('Failed to search customer: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Create a new customer
  Future<bool> createCustomer({required String name, required String phone}) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _customerService.createCustomer(name: name, phone: phone);

      if (response.success) {
        // After creating, search for the customer to get the full details
        final customer = await searchCustomerByPhone(phone);
        return customer != null;
      } else {
        setError(response.error?.details ?? response.error?.message ?? 'Failed to create customer');
        return false;
      }
    } catch (e) {
      setError('Failed to create customer: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Clear selected customer
  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  @override
  void reset() {
    super.reset();
    _selectedCustomer = null;
  }
}
