import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/orders/presentation/widgets/shared_orders_desktop_table.dart';
import 'package:vsc_app/features/orders/presentation/widgets/shared_order_mobile_card.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/widgets/shared_bills_desktop_table.dart';
import 'package:vsc_app/features/bills/presentation/widgets/shared_bill_mobile_card.dart';

class PendingOrdersPage extends StatefulWidget {
  const PendingOrdersPage({super.key});

  @override
  State<PendingOrdersPage> createState() => _PendingOrdersPageState();
}

class _PendingOrdersPageState extends State<PendingOrdersPage> {
  late final AnalyticsProvider _analyticsProvider;
  bool _showBills = false;
  @override
  void initState() {
    super.initState();
    _analyticsProvider = context.read<AnalyticsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyticsProvider.setContext(context);
      _analyticsProvider.getPendingOrders();
    });
  }

  @override
  void dispose() {
    _analyticsProvider.clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final int? ordersCount = analytics.pendingOrders?.length;
    final int? billsCount = analytics.pendingBills?.length;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(UITextConstants.pending),
            const SizedBox(width: 12),
            ChoiceChip(
              label: Text(ordersCount != null ? '${UITextConstants.orders} ($ordersCount)' : UITextConstants.orders),
              selected: !_showBills,
              onSelected: (selected) {
                if (selected && _showBills) {
                  setState(() => _showBills = false);
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(billsCount != null ? '${UITextConstants.bills} ($billsCount)' : UITextConstants.bills),
              selected: _showBills,
              onSelected: (selected) async {
                if (selected && !_showBills) {
                  setState(() => _showBills = true);
                  final provider = context.read<AnalyticsProvider>();
                  if (provider.pendingBills == null) {
                    await provider.getPendingBills();
                  }
                }
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          final Future<void> Function() refreshFn = _showBills ? provider.getPendingBills : provider.getPendingOrders;

          if (provider.isLoading) {
            return LoadingWidget(message: _showBills ? 'Loading pending bills...' : 'Loading pending orders...');
          }

          if (provider.errorMessage != null) {
            return _buildRefreshPlaceholder(
              onRefresh: refreshFn,
              child: CustomErrorWidget(message: provider.errorMessage!, onRetry: refreshFn),
            );
          }

          if (_showBills) {
            final bills = provider.pendingBills ?? [];
            if (bills.isEmpty) {
              return _buildRefreshPlaceholder(
                onRefresh: provider.getPendingBills,
                child: const EmptyStateWidget(message: 'No pending bills', icon: Icons.receipt_long_outlined),
              );
            }
            final content = context.isDesktop
                ? SharedBillsDesktopTable(bills: bills, onTapBill: _openBillDetail)
                : _buildBillMobileList(bills);
            return RefreshIndicator(onRefresh: provider.getPendingBills, child: content);
          } else {
            final orders = provider.pendingOrders ?? [];
            if (orders.isEmpty) {
              return _buildRefreshPlaceholder(
                onRefresh: provider.getPendingOrders,
                child: const EmptyStateWidget(message: 'No pending orders', icon: Icons.pending_outlined),
              );
            }
            final content = context.isDesktop
                ? SharedOrdersDesktopTable(orders: orders, onTapOrder: _openOrderDetail)
                : _buildOrderMobileList(orders);
            return RefreshIndicator(onRefresh: provider.getPendingOrders, child: content);
          }
        },
      ),
    );
  }

  Widget _buildOrderMobileList(List<OrderViewModel> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) => SharedOrderMobileCard(order: orders[index], onTap: (o) => _openOrderDetail(o)),
    );
  }

  Widget _buildBillMobileList(List<BillViewModel> bills) {
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) => SharedBillMobileCard(bill: bills[index], onTap: (b) => _openBillDetail(b)),
    );
  }

  void _openOrderDetail(OrderViewModel order) {
    final orderDetailProvider = OrderDetailProvider();
    orderDetailProvider.selectOrder(order);
    context.push(RouteConstants.orderDetail.replaceAll(':id', order.id), extra: orderDetailProvider);
  }

  void _openBillDetail(BillViewModel bill) {
    context.pushNamed(RouteConstants.billDetailRouteName, pathParameters: {'id': bill.id});
  }

  Widget _buildRefreshPlaceholder({required Future<void> Function() onRefresh, required Widget child}) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(child: child),
        ],
      ),
    );
  }
}
