import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Application constants and configuration values
class AppConstants {
  // API Configuration
  // Dynamically determine the correct API base URL based on platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      // For web, use localhost
      // return 'https://vsc-be.onrender.com/api/v1';
      return 'http://localhost:8000/api/v1';
    } else if (Platform.isAndroid) {
      // return 'https://vsc-be.onrender.com/api/v1';
      // For Android emulator, use 10.0.2.2 to reach host machine's localhost
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      // For iOS simulator and other platforms, use localhost
      return 'http://localhost:8000/api/v1';
    }
  }

  static const String apiVersion = 'v1';

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
  // Cards
  static const String cardsEndpoint = '/cards/';
  static const String similarCardsEndpoint = '/cards/similar/';
  // Customers
  static const String customersEndpoint = '/customers/';
  // Orders
  static const String ordersEndpoint = '/orders/';
  // ==========================================================================

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int minNameLength = 2;
  static const int minPhoneLength = 10;

  // UI Constants
  static const double defaultCardElevation = 2.0;
  static const double defaultBorderRadius = 8.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Error Messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String unauthorizedMessage = 'Authentication required';
  static const String genericErrorMessage = 'Something went wrong';
  static const String noTokenMessage = 'No token found';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful';
  static const String registerSuccessMessage = 'Registration successful';
  static const String vendorCreatedMessage = 'Vendor created successfully';

  // Permission Constants
  static const List<String> adminPermissions = [
    'account.create',
    'account.read',
    'account.update',
    'account.delete',
    'account.list',
    'inventory.create',
    'inventory.read',
    'inventory.update',
    'inventory.delete',
    'inventory.list',
    'order.create',
    'order.read',
    'order.update',
    'order.delete',
    'order.list',
    'production.create',
    'production.read',
    'production.update',
    'production.delete',
    'production.list',
    'vendor.create',
    'vendor.read',
    'vendor.update',
    'vendor.delete',
    'vendor.list',
    'customer.create',
    'customer.read',
    'customer.update',
    'customer.delete',
    'customer.list',
    'system.config',
    'system.backup',
    'system.restore',
    'audit.read',
    'audit.export',
  ];

  static const List<String> managerPermissions = [
    'inventory.read',
    'inventory.update',
    'inventory.list',
    'order.create',
    'order.read',
    'order.update',
    'order.list',
    'production.create',
    'production.read',
    'production.update',
    'production.list',
    'vendor.read',
    'vendor.list',
    'customer.read',
    'customer.list',
  ];

  static const List<String> salesPermissions = [
    'order.create',
    'order.read',
    'order.list',
    'customer.read',
    'customer.list',
    'inventory.read',
    'inventory.list',
  ];

  // Feature Flags
  static const bool enableVendorManagement = true;
  static const bool enableCustomerManagement = true;
  static const bool enableProductionManagement = true;
  static const bool enableAuditLogs = true;

  // Cache Configuration
  static const Duration tokenCacheDuration = Duration(hours: 24);
  static const Duration permissionsCacheDuration = Duration(minutes: 30);

  // Network Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // UI Configuration
  static const Map<String, String> featureLabels = {
    'vendors': 'Vendors',
    'customers': 'Customers',
    'orders': 'Orders',
    'inventory': 'Inventory',
    'production': 'Production',
    'administration': 'Administration',
  };

  static const Map<String, IconData> featureIcons = {
    'vendors': Icons.people,
    'customers': Icons.person,
    'orders': Icons.shopping_cart,
    'inventory': Icons.inventory,
    'production': Icons.print,
    'administration': Icons.admin_panel_settings,
  };
}
