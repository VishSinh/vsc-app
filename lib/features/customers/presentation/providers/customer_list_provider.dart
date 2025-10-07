import 'package:vsc_app/core/models/pagination_data.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/customers/data/services/customer_service.dart';
import 'package:vsc_app/features/customers/presentation/models/base_customer_view_model.dart';

/// Provider to manage loading and paginating customers list
class CustomerListProvider extends BaseProvider {
  final CustomerService _customerService = CustomerService();

  final List<BaseCustomerViewModel> _customers = [];
  PaginationData? _pagination;
  String _searchPhone = '';

  List<BaseCustomerViewModel> get customers => List.unmodifiable(_customers);
  PaginationData? get pagination => _pagination;
  String get searchPhone => _searchPhone;

  /// Load customers with server-side pagination
  Future<void> loadCustomers({int page = 1, int pageSize = 10}) async {
    await executeApiOperation(
      apiCall: () => _customerService.getCustomers(page: page, pageSize: pageSize),
      onSuccess: (response) {
        final customerViewModels = (response.data ?? [])
            .map((c) => BaseCustomerViewModel(id: c.id, name: c.name, phone: c.phone, isActive: c.isActive))
            .toList();
        _customers
          ..clear()
          ..addAll(customerViewModels);
        _pagination = response.pagination;
        notifyListeners();
        return true;
      },
      showSnackbar: false,
      errorMessage: 'Failed to load customers',
    );
  }

  Future<void> searchByPhone(String phone) async {
    _searchPhone = phone;
    notifyListeners();

    if (phone.trim().isEmpty) {
      await loadCustomers(page: 1);
      return;
    }

    await executeApiOperation(
      apiCall: () => _customerService.getCustomerByPhone(phone.trim()),
      onSuccess: (response) {
        final c = response.data!;
        _customers
          ..clear()
          ..add(BaseCustomerViewModel(id: c.id, name: c.name, phone: c.phone, isActive: c.isActive));
        _pagination = null;
        notifyListeners();
        return true;
      },
      showSnackbar: false,
      errorMessage: 'Customer not found',
    );
  }

  void clearSearch() {
    _searchPhone = '';
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (_pagination?.hasNext == true) {
      final current = _pagination?.currentPage ?? 1;
      AppLogger.service('CustomerListProvider', 'Loading next page: ${current + 1}');
      await loadCustomers(page: current + 1, pageSize: _pagination?.pageSize ?? 10);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_pagination?.hasPrevious == true) {
      final current = _pagination?.currentPage ?? 1;
      AppLogger.service('CustomerListProvider', 'Loading previous page: ${current - 1}');
      await loadCustomers(page: current - 1, pageSize: _pagination?.pageSize ?? 10);
    }
  }

  bool get hasMoreCustomers => _pagination?.hasNext ?? false;

  Future<void> refreshCustomers() async {
    await loadCustomers(page: 1, pageSize: _pagination?.pageSize ?? 10);
  }
}
