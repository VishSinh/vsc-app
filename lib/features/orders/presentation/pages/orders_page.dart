import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/utils/responsive_layout.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/navigation_items.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _statusFilter = 'all';
  bool _isLoading = true; // Show shimmer while orders load

  List<OrderViewModel> get _filteredOrders {
    final orderProvider = context.read<OrderProvider>();
    var orders = orderProvider.orders;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      orders = orders
          .where(
            (order) => order.id.toLowerCase().contains(_searchQuery.toLowerCase()) || order.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply status filter
    if (_statusFilter != 'all') {
      orders = orders.where((order) => order.orderStatus.toLowerCase() == _statusFilter.toLowerCase()).toList();
    }

    return orders;
  }

  @override
  void initState() {
    super.initState();
    _setSelectedIndex();
    _loadOrders();
  }

  void _loadOrders() {
    // Show shimmer while loading
    setState(() {
      _isLoading = true;
    });

    // Fetch orders from API
    final orderProvider = context.read<OrderProvider>();
    orderProvider
        .fetchOrders()
        .then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

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
    return NavigationItems.getDestinationsForPermissions(
      canManageOrders: permissionProvider.canManageOrders,
      canManageInventory: permissionProvider.canManageInventory,
      canManageProduction: permissionProvider.canManageProduction,
      canManageVendors: permissionProvider.canManageVendors,
      canManageSystem: permissionProvider.canManageSystem,
      canViewAuditLogs: permissionProvider.canViewAuditLogs,
    );
  }

  void _setSelectedIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final destinations = _getDestinations();
        final index = NavigationItems.getSelectedIndexForPage('orders', destinations);
        setState(() {
          _selectedIndex = index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: _selectedIndex,
      destinations: _getDestinations(),
      onDestinationSelected: _onDestinationSelected,
      pageTitle: UITextConstants.orders,
      child: _buildOrdersContent(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _loadOrders(),
            backgroundColor: Colors.orange,
            heroTag: 'reload',
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () => context.go(RouteConstants.customerSearch),
            backgroundColor: AppConfig.primaryColor,
            heroTag: 'add',
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (_isLoading) {
          return _buildLoadingSpinner();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            SizedBox(height: AppConfig.defaultPadding),
            Expanded(child: _buildOrdersList(orderProvider)),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(labelText: 'Search by name or order ID...', prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _statusFilter,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Status')),
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
          ],
          onChanged: (value) {
            setState(() {
              _statusFilter = value ?? 'all';
            });
          },
        ),
      ],
    );
  }

  Widget _buildLoadingSpinner() {
    return const Center(child: SpinKitDoubleBounce(color: Colors.blue, size: 50.0));
  }

  Widget _buildOrdersList(OrderProvider orderProvider) {
    if (orderProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(orderProvider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => _loadOrders(), child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }

    return Column(
      children: [
        Expanded(child: context.isMobile ? _buildMobileList() : _buildDesktopTable()),
        _buildPagination(orderProvider),
      ],
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.name.isNotEmpty ? order.name : 'Order #${order.id.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (order.specialInstruction.isNotEmpty)
                            Text(
                              order.specialInstruction,
                              style: const TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: _getStatusColor(order.orderStatus), borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        _formatStatus(order.orderStatus),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Ordered: ${_formatDateTime(order.orderDate)}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Delivery: ${_formatDateTime(order.deliveryDate)}')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${order.orderItems.length} item${order.orderItems.length != 1 ? 's' : ''}'),
                    if (_hasBoxRequirements(order)) ...[const SizedBox(width: 12), const Icon(Icons.inventory_2, size: 16, color: Colors.blue)],
                    if (_hasPrintingRequirements(order)) ...[const SizedBox(width: 8), const Icon(Icons.print, size: 16, color: Colors.green)],
                    const Spacer(),
                    Text(
                      '₹${_calculateTotalAmount(order.orderItems).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                if (_hasBoxRequirements(order) || _hasPrintingRequirements(order)) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_hasBoxRequirements(order))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            'Box',
                            style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500),
                          ),
                        ),
                      if (_hasBoxRequirements(order) && _hasPrintingRequirements(order)) const SizedBox(width: 4),
                      if (_hasPrintingRequirements(order))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            'Print',
                            style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 200, // Account for navigation rail
        ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order Name')),
            DataColumn(label: Text('Order Date')),
            DataColumn(label: Text('Delivery Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Items')),
            DataColumn(label: Text('Services')),
            DataColumn(label: Text('Total')),
          ],
          rows: _filteredOrders.map((order) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.name.isNotEmpty ? order.name : 'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (order.specialInstruction.isNotEmpty)
                        Text(
                          order.specialInstruction,
                          style: const TextStyle(fontSize: 10, color: Colors.orange, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                DataCell(Text(_formatDateTime(order.orderDate))),
                DataCell(Text(_formatDateTime(order.deliveryDate))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getStatusColor(order.orderStatus), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      _formatStatus(order.orderStatus),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataCell(Text('${order.orderItems.length}')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hasBoxRequirements(order))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: const Text(
                            'Box',
                            style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                          ),
                        ),
                      if (_hasBoxRequirements(order) && _hasPrintingRequirements(order)) const SizedBox(width: 6),
                      if (_hasPrintingRequirements(order))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: const Text(
                            'Print',
                            style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),
                DataCell(Text('₹${_calculateTotalAmount(order.orderItems).toStringAsFixed(2)}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination(OrderProvider orderProvider) {
    if (orderProvider.pagination == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (orderProvider.pagination!.hasPrevious) ElevatedButton(onPressed: () => orderProvider.loadNextPage(), child: const Text('Previous')),
          const SizedBox(width: 16),
          Text('Page ${orderProvider.pagination?.currentPage ?? 1} of ${orderProvider.pagination?.totalPages ?? 1}'),
          const SizedBox(width: 16),
          if (orderProvider.hasMoreOrders) ElevatedButton(onPressed: () => orderProvider.loadNextPage(), child: const Text('Next')),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'confirmed':
        return 'CONFIRMED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  bool _hasBoxRequirements(OrderViewModel order) {
    return order.orderItems.any((item) => item.requiresBox);
  }

  bool _hasPrintingRequirements(OrderViewModel order) {
    return order.orderItems.any((item) => item.requiresPrinting);
  }

  double _calculateTotalAmount(List<OrderItemViewModel> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      final pricePerItem = double.tryParse(item.pricePerItem) ?? 0.0;
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      final lineTotal = (pricePerItem * item.quantity) - discountAmount;

      // Add box costs
      final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));

      // Add printing costs
      final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));

      return total + lineTotal + boxCosts + printingCosts;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
