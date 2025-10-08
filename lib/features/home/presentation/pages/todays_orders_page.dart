import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/orders/presentation/services/order_calculation_service.dart';

class TodaysOrdersPage extends StatefulWidget {
  const TodaysOrdersPage({super.key});

  @override
  State<TodaysOrdersPage> createState() => _TodaysOrdersPageState();
}

class _TodaysOrdersPageState extends State<TodaysOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.setContext(context);
      provider.getTodaysOrders();
    });
  }

  @override
  void dispose() {
    context.read<AnalyticsProvider>().clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Orders")),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: "Loading today's orders...");
          }

          if (provider.errorMessage != null) {
            return CustomErrorWidget(message: provider.errorMessage!, onRetry: () => provider.getTodaysOrders());
          }

          final orders = provider.todaysOrders ?? [];
          if (orders.isEmpty) {
            return const EmptyStateWidget(message: 'No orders created today', icon: Icons.today_outlined);
          }

          return context.isDesktop ? _buildDesktopTable(orders) : _buildMobileList(orders);
        },
      ),
    );
  }

  Widget _buildMobileList(List<OrderViewModel> orders) {
    return ListView.separated(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          child: InkWell(
            onTap: () => _openOrderDetail(order),
            child: Padding(
              padding: EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.name.isNotEmpty ? order.name : 'Order',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConfig.fontSizeLg),
                        ),
                      ),
                      _buildStatusChip(order.orderStatus),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('Customer: ${order.customerName}', style: TextStyle(color: AppConfig.textColorSecondary)),
                  SizedBox(height: 4),
                  Text('Staff: ${order.staffName}', style: TextStyle(color: AppConfig.textColorSecondary)),
                  SizedBox(height: 4),
                  Text(DateFormatter.formatDateTime(order.orderDate), style: TextStyle(color: AppConfig.textColorSecondary)),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: AppConfig.smallPadding),
      itemCount: orders.length,
    );
  }

  Widget _buildDesktopTable(List<OrderViewModel> orders) {
    const double fixedRowHeight = 70.0;
    const double headerHeight = 50.0;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
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
              children: const [
                Expanded(
                  flex: 1,
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
                    child: Text('Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              padding: EdgeInsets.all(AppConfig.defaultPadding),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildDesktopRow(order, fixedRowHeight);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRow(OrderViewModel order, double rowHeight) {
    return InkWell(
      onTap: () => _openOrderDetail(order),
      child: Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: const Color(0xFF4C4B4B))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  order.name.isNotEmpty ? order.name : 'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                  DateFormatter.formatDateTime(order.orderDate),
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
                        child: const Text(
                          'Box',
                          style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_hasBoxRequirements(order) && _hasPrintingRequirements(order)) const SizedBox(width: 4),
                    if (_hasPrintingRequirements(order))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          'Print',
                          style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
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
                  '₹${OrderCalculationService.calculateOrderTotal(order.orderItems).toStringAsFixed(2)}',
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

  bool _hasBoxRequirements(OrderViewModel order) {
    return order.orderItems.any((item) => item.requiresBox);
  }

  bool _hasPrintingRequirements(OrderViewModel order) {
    return order.orderItems.any((item) => item.requiresPrinting);
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

  Widget _buildStatusChip(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: status.getStatusColor(), borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.getDisplayText(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openOrderDetail(OrderViewModel order) {
    final orderDetailProvider = OrderDetailProvider();
    orderDetailProvider.selectOrder(order);
    context.push(RouteConstants.orderDetail.replaceAll(':id', order.id), extra: orderDetailProvider);
  }
}
