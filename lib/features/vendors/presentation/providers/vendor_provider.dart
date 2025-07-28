import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/vendor_model.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/vendor_service.dart';

class VendorProvider extends BaseProvider with PaginationMixin {
  final VendorService _vendorService;
  
  List<Vendor> _vendors = [];

  VendorProvider({
    VendorService? vendorService,
  }) : _vendorService = vendorService ?? VendorService();

  // Getters
  List<Vendor> get vendors => List.unmodifiable(_vendors);

  /// Load vendors with pagination
  Future<void> loadVendors({bool refresh = false}) async {
    if (isLoading) return;
    
    await executeAsync(() async {
      if (refresh) {
        resetPagination();
        _vendors.clear();
      }

      if (!hasMoreData) return;

      final response = await _vendorService.getVendors(
        page: currentPage,
        pageSize: pageSize,
      );

      if (response.success) {
        if (refresh) {
          _vendors = response.data;
        } else {
          _vendors.addAll(response.data);
        }
        
        setHasMoreData(response.data.length == pageSize);
        incrementPage();
      } else {
        throw Exception(response.error.message.isNotEmpty 
            ? response.error.message 
            : 'Failed to load vendors');
      }
    });
  }

  /// Create a new vendor
  Future<bool> createVendor({
    required String name,
    required String phone,
  }) async {
    return await executeApiCall(
      () => _vendorService.createVendor(name: name, phone: phone),
      onSuccess: (data) {
        // Refresh the vendor list
        loadVendors(refresh: true);
      },
    );
  }

  /// Refresh vendors list
  Future<void> refreshVendors() async {
    await loadVendors(refresh: true);
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
    
    return vendors.where((vendor) =>
        vendor.name.toLowerCase().contains(query.toLowerCase()) ||
        vendor.phone.contains(query)
    ).toList();
  }
} 