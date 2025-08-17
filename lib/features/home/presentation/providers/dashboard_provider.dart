import 'package:flutter/material.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/home/data/services/dashboard_service.dart';
import 'package:vsc_app/features/home/presentation/models/dashboard_view_model.dart';

/// Provider for managing dashboard data and state
class DashboardProvider extends BaseProvider {
  final DashboardService _dashboardService = DashboardService();
  
  // Dashboard data
  DashboardViewModel? _dashboardData;
  
  // Getters
  DashboardViewModel? get dashboardData => _dashboardData;
  bool get hasDashboardData => _dashboardData != null;
  
  /// Fetch dashboard data from the API
  Future<void> fetchDashboardData({bool showSnackbar = false}) async {
    await executeApiOperation(
      apiCall: () => _dashboardService.getDashboardData(),
      onSuccess: (response) {
        _dashboardData = DashboardViewModel.fromResponse(response.data!);
        notifyListeners();
        return _dashboardData;
      },
      showSnackbar: showSnackbar,
      showLoading: true,
      errorMessage: 'Failed to load dashboard data',
    );
  }
  
  /// Reset the dashboard data
  void resetDashboardData() {
    _dashboardData = null;
    notifyListeners();
  }
}
