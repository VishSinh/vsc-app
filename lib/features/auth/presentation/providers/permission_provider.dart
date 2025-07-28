import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/permission_model.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/permission_service.dart';
import 'package:vsc_app/core/utils/permission_manager.dart';

class PermissionProvider extends BaseProvider {
  final PermissionService _permissionService;
  final PermissionManager _permissionManager;
  
  bool _isInitialized = false;
  List<String> _currentPermissions = [];
  List<Permission> _allPermissions = [];

  PermissionProvider({
    PermissionService? permissionService,
    PermissionManager? permissionManager,
  }) : _permissionService = permissionService ?? PermissionService(),
       _permissionManager = permissionManager ?? PermissionManager();

  // Getters
  bool get isInitialized => _isInitialized;
  List<String> get currentPermissions => List.unmodifiable(_currentPermissions);
  List<Permission> get allPermissions => List.unmodifiable(_allPermissions);

  /// Initialize permissions for the current user
  Future<void> initializePermissions() async {
    if (_isInitialized) return;
    
    await executeAsync(() async {
      final cachedPermissions = await _permissionService.getCachedStaffPermissions();
      if (cachedPermissions.isNotEmpty) {
        _initializeWithPermissions(cachedPermissions);
      }

      final response = await _permissionService.getStaffPermissions();
      
      if (response.success) {
        _currentPermissions = response.data.permissions;
        _isInitialized = true;
        
        await _permissionService.cacheStaffPermissions(_currentPermissions);
        _permissionManager.initializePermissions(_currentPermissions);
      } else {
        throw Exception(response.error.message.isNotEmpty 
            ? response.error.message 
            : 'Failed to load permissions');
      }
    });
  }

  /// Load all available permissions (for admin use)
  Future<void> loadAllPermissions() async {
    await executeApiCall(
      () => _permissionService.getAllPermissions(),
      onSuccess: (data) {
        _allPermissions = data.permissions;
      },
    );
  }

  // Permission checking methods
  bool hasPermission(String permission) => _permissionManager.hasPermission(permission);
  bool hasAnyPermission(List<String> permissions) => _permissionManager.hasAnyPermission(permissions);
  bool hasAllPermissions(List<String> permissions) => _permissionManager.hasAllPermissions(permissions);
  bool can(String action, String resource) => _permissionManager.can(action, resource);
  bool canCreate(String resource) => _permissionManager.canCreate(resource);
  bool canRead(String resource) => _permissionManager.canRead(resource);
  bool canUpdate(String resource) => _permissionManager.canUpdate(resource);
  bool canDelete(String resource) => _permissionManager.canDelete(resource);
  bool canList(String resource) => _permissionManager.canList(resource);

  // Domain-specific permission checks
  bool get canManageAccounts => _permissionManager.canManageAccounts;
  bool get canManageInventory => _permissionManager.canManageInventory;
  bool get canManageOrders => _permissionManager.canManageOrders;
  bool get canManageProduction => _permissionManager.canManageProduction;
  bool get canManageBilling => _permissionManager.canManageBilling;
  bool get canManagePayments => _permissionManager.canManagePayments;
  bool get canManageVendors => _permissionManager.canManageVendors;
  bool get canManageCards => _permissionManager.canManageCards;
  bool get canManageCustomers => _permissionManager.canManageCustomers;
  bool get canManageSystem => _permissionManager.canManageSystem;
  bool get canViewAuditLogs => _permissionManager.canViewAuditLogs;

  // Specific permission checks
  bool get canApproveOrders => _permissionManager.canApproveOrders();
  bool get canCancelOrders => _permissionManager.canCancelOrders();
  bool get canProcessPayments => _permissionManager.canProcessPayments();
  bool get canRefundPayments => _permissionManager.canRefundPayments();
  bool get canPerformInventoryTransactions => _permissionManager.canPerformInventoryTransactions();
  bool get canReadAuditLogs => _permissionManager.canReadAuditLogs();
  bool get canExportAuditLogs => _permissionManager.canExportAuditLogs();
  bool get canConfigureSystem => _permissionManager.canConfigureSystem();
  bool get canBackupSystem => _permissionManager.canBackupSystem();
  bool get canRestoreSystem => _permissionManager.canRestoreSystem();

  void clearPermissions() {
    _currentPermissions.clear();
    _allPermissions.clear();
    _isInitialized = false;
    _permissionManager.clearPermissions();
    clearMessages();
  }

  List<String> getPermissionsByDomain(String domain) {
    return _currentPermissions.where((permission) => permission.startsWith('$domain.')).toList();
  }

  Set<String> getAvailableDomains() {
    return _currentPermissions.map((permission) {
      final parts = permission.split('.');
      return parts.isNotEmpty ? parts.first : '';
    }).where((domain) => domain.isNotEmpty).toSet();
  }

  void _initializeWithPermissions(List<String> permissions) {
    _currentPermissions = permissions;
    _isInitialized = true;
    _permissionManager.initializePermissions(permissions);
  }
} 