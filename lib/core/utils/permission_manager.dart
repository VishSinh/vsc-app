import 'package:flutter/material.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  List<String> _currentPermissions = [];
  bool _isInitialized = false;

  /// Initialize permissions
  void initializePermissions(List<String> permissions) {
    _currentPermissions = permissions;
    _isInitialized = true;
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    if (!_isInitialized) return false;
    return _currentPermissions.contains(permission);
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    if (!_isInitialized) return false;
    return permissions.any((permission) => _currentPermissions.contains(permission));
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissions) {
    if (!_isInitialized) return false;
    return permissions.every((permission) => _currentPermissions.contains(permission));
  }

  /// Check if user has permission for a specific action on a resource
  bool can(String action, String resource) {
    final permission = '$resource.$action';
    return hasPermission(permission);
  }

  /// Check if user can create a resource
  bool canCreate(String resource) => can('create', resource);

  /// Check if user can read a resource
  bool canRead(String resource) => can('read', resource);

  /// Check if user can update a resource
  bool canUpdate(String resource) => can('update', resource);

  /// Check if user can delete a resource
  bool canDelete(String resource) => can('delete', resource);

  /// Check if user can list a resource
  bool canList(String resource) => can('list', resource);

  /// Check if user can approve orders
  bool canApproveOrders() => hasPermission('order.approve');

  /// Check if user can cancel orders
  bool canCancelOrders() => hasPermission('order.cancel');

  /// Check if user can process payments
  bool canProcessPayments() => hasPermission('payment.process');

  /// Check if user can refund payments
  bool canRefundPayments() => hasPermission('payment.refund');

  /// Check if user can perform inventory transactions
  bool canPerformInventoryTransactions() => hasPermission('inventory.transaction');

  /// Check if user can read audit logs
  bool canReadAuditLogs() => hasPermission('audit.read');

  /// Check if user can export audit logs
  bool canExportAuditLogs() => hasPermission('audit.export');

  /// Check if user can configure system
  bool canConfigureSystem() => hasPermission('system.config');

  /// Check if user can backup system
  bool canBackupSystem() => hasPermission('system.backup');

  /// Check if user can restore system
  bool canRestoreSystem() => hasPermission('system.restore');

  /// Get all current permissions
  List<String> get currentPermissions => List.unmodifiable(_currentPermissions);

  /// Clear permissions (for logout)
  void clearPermissions() {
    _currentPermissions.clear();
    _isInitialized = false;
  }

  /// Check if permissions are initialized
  bool get isInitialized => _isInitialized;

  // Domain-specific permission checks
  bool get canManageAccounts => hasAnyPermission([
    'account.create', 'account.read', 'account.update', 'account.delete', 'account.list'
  ]);

  bool get canManageInventory => hasAnyPermission([
    'inventory.create', 'inventory.read', 'inventory.update', 'inventory.delete', 'inventory.list', 'inventory.transaction'
  ]);

  bool get canManageOrders => hasAnyPermission([
    'order.create', 'order.read', 'order.update', 'order.delete', 'order.list', 'order.approve', 'order.cancel'
  ]);

  bool get canManageProduction => hasAnyPermission([
    'production.create', 'production.read', 'production.update', 'production.delete', 'production.list'
  ]);

  bool get canManageBilling => hasAnyPermission([
    'bill.create', 'bill.read', 'bill.update', 'bill.delete', 'bill.list'
  ]);

  bool get canManagePayments => hasAnyPermission([
    'payment.process', 'payment.refund'
  ]);

  bool get canManageVendors => hasAnyPermission([
    'vendor.create', 'vendor.read', 'vendor.update', 'vendor.delete', 'vendor.list'
  ]);

  bool get canManageCards => hasAnyPermission([
    'card.create', 'card.read', 'card.update', 'card.delete', 'card.list'
  ]);

  bool get canManageCustomers => hasAnyPermission([
    'customer.create', 'customer.read', 'customer.update', 'customer.delete', 'customer.list'
  ]);

  bool get canManageSystem => hasAnyPermission([
    'system.config', 'system.backup', 'system.restore'
  ]);

  bool get canViewAuditLogs => hasAnyPermission([
    'audit.read', 'audit.export'
  ]);
} 