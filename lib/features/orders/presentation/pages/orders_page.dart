import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedIndex = 0; // Will be set based on permissions
  String _searchQuery = '';
  String _statusFilter = 'All';

  // Mock data - will be replaced with real API data
  final List<Map<String, dynamic>> _orders = [
    {'id': 'ORD-001', 'customer': 'John Doe', 'date': '2024-01-15', 'status': 'Pending', 'total': 1250.00, 'items': 5},
    {'id': 'ORD-002', 'customer': 'Jane Smith', 'date': '2024-01-14', 'status': 'In Production', 'total': 890.00, 'items': 3},
    {'id': 'ORD-003', 'customer': 'Bob Johnson', 'date': '2024-01-13', 'status': 'Completed', 'total': 2100.00, 'items': 8},
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final destinations = _getDestinations();
    final route = NavigationItems.getRouteForIndex(index, destinations);
    if (route != RouteConstants.orders) {
      context.go(route);
    }
  }

  List<NavigationDestination> _getDestinations() {
    final permissionProvider = context.read<PermissionProvider>();
    final destinations = NavigationItems.getDestinationsForPermissions(
      canManageOrders: permissionProvider.canManageOrders,
      canManageInventory: permissionProvider.canManageInventory,
      canManageProduction: permissionProvider.canManageProduction,
      canManageVendors: permissionProvider.canManageVendors,
      canManageSystem: permissionProvider.canManageSystem,
      canViewAuditLogs: permissionProvider.canViewAuditLogs,
    );

    AppLogger.debug('OrdersPage: Available destinations: ${destinations.map((d) => d.label).toList()}');
    AppLogger.debug('OrdersPage: Permissions - Orders: ${permissionProvider.canManageOrders}, Inventory: ${permissionProvider.canManageInventory}');

    return destinations;
  }

  void _setSelectedIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final destinations = _getDestinations();
        final index = NavigationItems.getSelectedIndexForPage('orders', destinations);
        AppLogger.debug('OrdersPage: Setting selected index to $index for destinations: ${destinations.map((d) => d.label).toList()}');
        setState(() {
          _selectedIndex = index;
        });
      }
    });
  }

  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((order) {
      final matchesSearch =
          order['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order['customer'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || order['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _setSelectedIndex();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _getDestinations();

    // Ensure selectedIndex is valid
    int validSelectedIndex = _selectedIndex;
    if (validSelectedIndex < 0 || validSelectedIndex >= destinations.length) {
      validSelectedIndex = 0; // Default to first destination
      AppLogger.debug('OrdersPage: Invalid selectedIndex $_selectedIndex, defaulting to 0');
    }

    return ResponsiveLayout(
      selectedIndex: validSelectedIndex,
      destinations: destinations,
      onDestinationSelected: _onDestinationSelected,
      pageTitle: UITextConstants.orders,
      floatingActionButton: FloatingActionButton(onPressed: () => context.go(RouteConstants.customerSearch), child: const Icon(Icons.add)),
      child: _buildOrdersContent(),
    );
  }

  Widget _buildOrdersContent() {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          _buildFilters(),
          SizedBox(height: context.responsiveSpacing),

          // Orders List
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        // Search
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(hintText: 'Search ${UITextConstants.orders.toLowerCase()}...', prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SizedBox(width: AppConfig.defaultPadding),
        // Status Filter
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: _statusFilter,
            decoration: InputDecoration(labelText: 'Status'),
            items: [
              UITextConstants.statusAll,
              UITextConstants.statusPending,
              UITextConstants.statusInProduction,
              UITextConstants.statusCompleted,
              'Cancelled',
            ].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _statusFilter = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    if (context.isMobile) {
      return _buildMobileList();
    } else {
      return _buildDesktopTable();
    }
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
          child: ListTile(
            title: Text(order['id'], style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order['customer'], style: ResponsiveText.getBody(context)),
                Text('${order['items']} items • ₹${order['total'].toStringAsFixed(2)}', style: ResponsiveText.getCaption(context)),
              ],
            ),
            trailing: Chip(
              label: Text(order['status']),
              backgroundColor: _getStatusColor(order['status']).withOpacity(0.1),
              labelStyle: TextStyle(color: _getStatusColor(order['status'])),
            ),
            onTap: () {
              // Navigate to order details
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Items')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredOrders.map((order) {
          return DataRow(
            cells: [
              DataCell(Text(order['id'], style: ResponsiveText.getBody(context))),
              DataCell(Text(order['customer'], style: ResponsiveText.getBody(context))),
              DataCell(Text(order['date'], style: ResponsiveText.getBody(context))),
              DataCell(
                Chip(
                  label: Text(order['status']),
                  backgroundColor: _getStatusColor(order['status']).withOpacity(0.1),
                  labelStyle: TextStyle(color: _getStatusColor(order['status'])),
                ),
              ),
              DataCell(Text(order['items'].toString(), style: ResponsiveText.getBody(context))),
              DataCell(Text('₹${order['total'].toStringAsFixed(2)}', style: ResponsiveText.getBody(context))),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit order
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // View order details
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppConfig.warningColor;
      case 'In Production':
        return AppConfig.accentColor;
      case 'Completed':
        return AppConfig.successColor;
      case 'Cancelled':
        return AppConfig.errorColor;
      default:
        return AppConfig.grey400;
    }
  }
}
