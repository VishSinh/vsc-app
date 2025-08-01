import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/vendor_service.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

class VendorProvider extends BaseProvider with PaginationMixin {
  final VendorService _vendorService;

  final List<Vendor> _vendors = [];
  String? _errorMessage;

  VendorProvider({VendorService? vendorService}) : _vendorService = vendorService ?? VendorService();

  // Getters
  List<Vendor> get vendors => List.unmodifiable(_vendors);
  @override
  String? get errorMessage => _errorMessage;

  /// Load vendors
  Future<void> loadVendors() async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _vendorService.getVendors();

      if (response.success && response.data != null) {
        _vendors.clear();
        _vendors.addAll(response.data!);
        notifyListeners();
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to load vendors';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load vendors: $e';
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  /// Get vendor by ID
  Future<Vendor?> getVendorById(String id) async {
    try {
      AppLogger.service('VendorProvider', 'Getting vendor by ID: $id');

      final response = await _vendorService.getVendorById(id);

      AppLogger.debug('VendorProvider: API response received');
      AppLogger.debug('VendorProvider: Response success: ${response.success}');
      AppLogger.debug('VendorProvider: Response data: ${response.data}');
      AppLogger.debug('VendorProvider: Response error: ${response.error}');

      if (response.success && response.data != null) {
        AppLogger.success('VendorProvider', 'Successfully retrieved vendor');
        return response.data;
      } else {
        AppLogger.apiError('getVendorById', response.error?.message ?? 'Unknown error');
        throw Exception(response.error?.details ?? response.error?.message ?? 'Failed to load vendor');
      }
    } catch (e) {
      AppLogger.errorCaught('VendorProvider.getVendorById', e.toString(), errorObject: e);
      throw Exception('Failed to load vendor: $e');
    }
  }

  /// Create a new vendor
  Future<bool> createVendor({required String name, required String phone}) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _vendorService.createVendor(name: name, phone: phone);

      if (response.success) {
        await loadVendors(); // Refresh the list
        return true;
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to create vendor';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create vendor: $e';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Update an existing vendor
  Future<bool> updateVendor({required String id, required String name, required String phone}) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _vendorService.updateVendor(id: id, name: name, phone: phone);

      if (response.success) {
        await loadVendors(); // Refresh the list
        return true;
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to update vendor';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update vendor: $e';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Delete a vendor
  Future<bool> deleteVendor({required String id}) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _vendorService.deleteVendor(id: id);

      if (response.success) {
        await loadVendors(); // Refresh the list
        return true;
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to delete vendor';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete vendor: $e';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Refresh vendors list
  Future<void> refreshVendors() async {
    await loadVendors();
  }

  /// Load more vendors (for pagination)
  Future<void> loadMoreVendors() async {
    await loadVendors();
  }

  /// Clear all data
  void clearData() {
    _vendors.clear();
    resetPagination();
    clearMessages();
  }

  /// Filter vendors by search query
  List<Vendor> getFilteredVendors(String query) {
    if (query.isEmpty) return vendors;

    return vendors.where((vendor) => vendor.name.toLowerCase().contains(query.toLowerCase()) || vendor.phone.contains(query)).toList();
  }
}
