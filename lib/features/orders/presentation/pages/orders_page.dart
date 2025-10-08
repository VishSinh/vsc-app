import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/orders/presentation/services/order_calculation_service.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/features/orders/presentation/widgets/orders_filter_dialog.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // _loadOrdersIfNeeded();
        _loadOrders();
      }
    });
  }

  List<OrderViewModel> get _filteredOrders {
    final orderProvider = context.read<OrderListProvider>();
    var orders = orderProvider.orders;

    // Apply search filter
    if (orderProvider.searchQuery.isNotEmpty) {
      orders = orders
          .where(
            (order) =>
                order.id.toLowerCase().contains(orderProvider.searchQuery.toLowerCase()) ||
                order.name.toLowerCase().contains(orderProvider.searchQuery.toLowerCase()) ||
                order.customerName.toLowerCase().contains(orderProvider.searchQuery.toLowerCase()) ||
                order.staffName.toLowerCase().contains(orderProvider.searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply status filter
    if (orderProvider.statusFilter != 'all') {
      orders = orders
          .where((order) => order.orderStatus.toApiString().toLowerCase() == orderProvider.statusFilter.toLowerCase())
          .toList();
    }

    return orders;
  }

  void _loadOrders() {
    // Fetch orders from API - BaseProvider handles errors automatically
    final orderProvider = context.read<OrderListProvider>();
    orderProvider.setContext(context);
    orderProvider.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderListProvider>(
      builder: (context, orderProvider, child) {
        return _buildOrdersContent();
      },
    );
  }

  Widget _buildOrdersContent() {
    return Consumer<OrderListProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return const LoadingWidget(message: 'Loading orders...');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildOrdersActionBar(context),
              const SizedBox(height: 8),
              Expanded(child: _buildOrdersList(orderProvider)),
            ],
          ),
        );
      },
    );
  }

  // Removed unused _buildFilters method

  Widget _buildOrdersList(OrderListProvider orderProvider) {
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

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          context.isMobile ? _buildMobileList() : _buildDesktopTable(),
          if (orderProvider.pagination != null) Positioned(bottom: 10, child: _buildPagination(orderProvider)),
        ],
      ),
    );
  }

  Widget _buildOrdersActionBar(BuildContext context) {
    final orderProvider = context.read<OrderListProvider>();
    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => orderProvider.setSearchQuery(val),
                  decoration: const InputDecoration(
                    hintText: 'Search (id, name, customer, staff)',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => OrdersFilterDialog.show(context),
                icon: Icon(Icons.filter_list, color: orderProvider.hasActiveFilters ? Colors.red : null),
                label: Text('Filters', style: TextStyle(color: orderProvider.hasActiveFilters ? Colors.red : null)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  side: BorderSide(
                    color: orderProvider.hasActiveFilters ? Colors.red : Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'Search by phone (coming soon)',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Expanded(
        //   child: TextField(
        //     onChanged: (val) => orderProvider.setSearchQuery(val),
        //     decoration: const InputDecoration(
        //       hintText: 'Search orders (id, name, customer, staff)',
        //       prefixIcon: Icon(Icons.search),
        //       border: OutlineInputBorder(),
        //       isDense: true,
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 8),
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'Search by phone (coming soon)',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => OrdersFilterDialog.show(context),
          icon: Icon(Icons.filter_list, color: orderProvider.hasActiveFilters ? Colors.red : null),
          label: Text('Filters', style: TextStyle(color: orderProvider.hasActiveFilters ? Colors.red : null, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: orderProvider.hasActiveFilters ? Colors.red : Theme.of(context).colorScheme.primary, width: 2),
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshOrders() async {
    final orderProvider = context.read<OrderListProvider>();
    await orderProvider.fetchOrders();
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () {
              final orderDetailProvider = OrderDetailProvider();
              orderDetailProvider.selectOrder(order);
              context.push(RouteConstants.orderDetail.replaceAll(':id', order.id), extra: orderDetailProvider);
            },
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                        decoration: BoxDecoration(color: order.orderStatus.getStatusColor(), borderRadius: BorderRadius.circular(16)),
                        child: Text(
                          order.orderStatus.getDisplayText(),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOrderInfoRow(Icons.calendar_today, 'Ordered:', DateFormatter.formatDate(order.orderDate)),
                  const SizedBox(height: 8),
                  _buildOrderInfoRow(Icons.person, 'Customer:', order.customerName),
                  const SizedBox(height: 8),
                  _buildOrderInfoRow(Icons.badge, 'Staff:', order.staffName),
                  const SizedBox(height: 8),
                  _buildOrderInfoRow(Icons.local_shipping, 'Delivery:', DateFormatter.formatDate(order.deliveryDate)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${order.orderItems.length + order.serviceItems.length} item${(order.orderItems.length + order.serviceItems.length) != 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (_hasBoxRequirements(order)) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                      ],
                      if (_hasPrintingRequirements(order)) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.print, size: 16, color: Colors.green),
                      ],
                      const Spacer(),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹ ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.green,
                                fontFamily: 'Roboto',
                                height: 1.0,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${OrderCalculationService.calculateOrderTotal(order.orderItems, serviceItems: order.serviceItems).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
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
                            child: Row(
                              children: [
                                const Text(
                                  'Box',
                                  style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w500),
                                ),
                                if (_isAnyBoxExpenseMissing(order)) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        if (_hasBoxRequirements(order) && _hasPrintingRequirements(order)) const SizedBox(width: 4),
                        if (_hasPrintingRequirements(order))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Text(
                                  'Print',
                                  style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w500),
                                ),
                                if (_isAnyPrintingOrTracingExpenseMissing(order)) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    const double fixedRowHeight = 65.0; // Fixed height for each row
    const double headerHeight = 50.0; // Height of the header row
    const double borderRadius = 12.0;

    return Container(
      height: MediaQuery.of(context).size.height, // Account for header, padding, etc.
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!, width: 1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          children: [
            // Header Row
            Container(
              height: headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text('Order Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Staff', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Order Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Box Maker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Printer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Tracing Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
            // Data Rows - Scrollable with fixed height
            Expanded(
              child: ListView.builder(
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return _buildDesktopRow(order, fixedRowHeight);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopRow(OrderViewModel order, double rowHeight) {
    return InkWell(
      onTap: () {
        final orderDetailProvider = OrderDetailProvider();
        orderDetailProvider.selectOrder(order);
        context.push(RouteConstants.orderDetail.replaceAll(':id', order.id), extra: orderDetailProvider);
      },
      child: Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: const Color(0xFF4C4B4B))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  order.name.isNotEmpty ? order.name : 'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  order.customerName,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  order.staffName,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  DateFormatter.formatDate(order.orderDate),
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: order.orderStatus.getStatusColor(), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    order.orderStatus.getDisplayText(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  _getBoxMakerName(order) ?? '--',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  _getPrinterName(order) ?? '--',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  _getTracingStudioName(order) ?? '--',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasBoxRequirements(order))
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Text(
                              'Box',
                              style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            if (_isAnyBoxExpenseMissing(order)) ...[
                              const SizedBox(width: 3),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (_hasBoxRequirements(order) && _hasPrintingRequirements(order)) const SizedBox(width: 4),
                    if (_hasPrintingRequirements(order))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Text(
                              'Print',
                              style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            if (_isAnyPrintingOrTracingExpenseMissing(order)) ...[
                              const SizedBox(width: 3),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '₹${OrderCalculationService.calculateOrderTotal(order.orderItems, serviceItems: order.serviceItems).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(OrderListProvider orderProvider) {
    if (orderProvider.pagination == null) return const SizedBox.shrink();

    final currentPage = orderProvider.pagination?.currentPage ?? 1;
    final totalPages = orderProvider.pagination?.totalPages ?? 1;
    final hasPrevious = orderProvider.pagination!.hasPrevious;
    final hasNext = orderProvider.hasMoreOrders;

    return PaginationWidget(
      currentPage: currentPage,
      totalPages: totalPages,
      hasPrevious: hasPrevious,
      hasNext: hasNext,
      onPreviousPage: hasPrevious ? () => orderProvider.loadPreviousPage() : null,
      onNextPage: hasNext ? () => orderProvider.loadNextPage() : null,
      showTotalItems: true,
      totalItems: orderProvider.pagination?.totalItems,
    );
  }

  // Using OrderStatusExtension.getDisplayTextFromString instead of local formatting method

  bool _hasBoxRequirements(OrderViewModel order) {
    return order.orderItems.any((item) => item.requiresBox);
  }

  bool _hasPrintingRequirements(OrderViewModel order) {
    return order.orderItems.any((item) => item.requiresPrinting);
  }

  bool _isAnyBoxExpenseMissing(OrderViewModel order) {
    for (final item in order.orderItems) {
      if (item.boxOrders != null) {
        for (final box in item.boxOrders!) {
          if (box.totalBoxExpense == null) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _isAnyPrintingOrTracingExpenseMissing(OrderViewModel order) {
    for (final item in order.orderItems) {
      if (item.printingJobs != null) {
        for (final job in item.printingJobs!) {
          if (job.totalPrintingExpense == null || job.totalTracingExpense == null) {
            return true;
          }
        }
      }
    }
    return false;
  }

  String? _getBoxMakerName(OrderViewModel order) {
    for (final item in order.orderItems) {
      if (item.boxOrders != null) {
        for (final box in item.boxOrders!) {
          if (box.boxMakerName != null && box.boxMakerName!.isNotEmpty) {
            return box.boxMakerName;
          }
        }
      }
    }
    return null;
  }

  String? _getPrinterName(OrderViewModel order) {
    for (final item in order.orderItems) {
      if (item.printingJobs != null) {
        for (final job in item.printingJobs!) {
          if (job.printerName != null && job.printerName!.isNotEmpty) {
            return job.printerName;
          }
        }
      }
    }
    return null;
  }

  String? _getTracingStudioName(OrderViewModel order) {
    for (final item in order.orderItems) {
      if (item.printingJobs != null) {
        for (final job in item.printingJobs!) {
          if (job.tracingStudioName != null && job.tracingStudioName!.isNotEmpty) {
            return job.tracingStudioName;
          }
        }
      }
    }
    return null;
  }

  // Using OrderCalculationService.calculateOrderTotal instead of local method

  // Using OrderStatusExtension.getColorFromString instead of local color mapping method

  Widget _buildOrderInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        SizedBox(
          width: 75, // Slightly increased width for larger text
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
