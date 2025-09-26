import 'package:flutter/foundation.dart';
import 'dart:io';

/// Application constants and configuration values
class AppConstants {
  // API Configuration
  // Dynamically determine the correct API base URL based on platform
  static String get apiBaseUrl {
    final bool isLocal = false; // Use local endpoints in debug/profile
    if (kIsWeb) {
      return isLocal ? 'http://localhost/api/v1' : 'http://15.235.147.1/api/v1';
    } else if (Platform.isAndroid) {
      // Android emulator can reach host via 10.0.2.2
      return isLocal ? 'http://10.0.2.2:8000/api/v1' : 'http://15.235.147.1/api/v1';
    } else {
      // iOS simulator and other platforms
      return isLocal ? 'http://localhost/api/v1' : 'http://15.235.147.1/api/v1';
    }
  }

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';
  static const String staffPermissionsKey = 'staff_permissions';

  // ================================ API ENDPOINTS ================================
  // Auth
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  // Permissions
  static const String permissionsEndpoint = '/permissions/';
  static const String allPermissionsEndpoint = '/permissions/all/';
  // Vendors
  static const String vendorsEndpoint = '/vendors/';
  // Staff
  static const String staffEndpoint = '/staff/';
  // Cards
  static const String cardsEndpoint = '/cards/';
  static const String similarCardsEndpoint = '/cards/similar/';
  // Customers
  static const String customersEndpoint = '/customers/';
  // Orders
  static const String ordersEndpoint = '/orders/';
  // Production
  static const String boxOrdersEndpoint = '/box-orders/';
  static const String printingJobsEndpoint = '/printing-jobs/';
  static const String printersEndpoint = '/printers/';
  static const String tracingStudiosEndpoint = '/tracing-studios/';
  static const String boxMakersEndpoint = '/box-makers/';
  // Bills
  static const String billsEndpoint = '/bills/';
  static const String paymentsEndpoint = '/payments/';
  // Dashboard
  static const String dashboardEndpoint = '/dashboard/';
  // Analytics
  static const String detailedAnalyticsEndpoint = '/analytics/detail/';
  // Audit
  static const String auditModelLogsEndpoint = '/audit/model-logs/';

  // ==========================================================================

  // Pagination
  static const int defaultPageSize = 10;

  // Validation
  static const int minNameLength = 2;
  static const int minPhoneLength = 10;

  // Network Configuration
  static const Duration requestTimeout = Duration(seconds: 30);

  // UI Configuration
}
