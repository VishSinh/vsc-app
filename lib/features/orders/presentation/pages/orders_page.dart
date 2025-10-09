import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/widgets/pagination_widget.dart';
import 'package:vsc_app/features/orders/presentation/widgets/orders_filter_dialog.dart';
import 'package:vsc_app/features/orders/presentation/widgets/shared_orders_desktop_table.dart';
// Shared helpers and widgets are used via shared components
import 'package:vsc_app/features/orders/presentation/widgets/shared_order_mobile_card.dart';

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
          context.isMobile
              ? _buildMobileList()
              : SharedOrdersDesktopTable(
                  orders: _filteredOrders,
                  onTapOrder: (order) {
                    final orderDetailProvider = OrderDetailProvider();
                    orderDetailProvider.selectOrder(order);
                    context.push(RouteConstants.orderDetail.replaceAll(':id', order.id), extra: orderDetailProvider);
                  },
                ),
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
      itemBuilder: (context, index) => SharedOrderMobileCard(order: _filteredOrders[index]),
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

  // Using shared helpers and widgets for common order UI
}
