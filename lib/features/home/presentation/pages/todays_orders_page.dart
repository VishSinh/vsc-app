import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/home/presentation/providers/analytics_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
// Shared helpers and widgets are used inside shared components
import 'package:vsc_app/features/orders/presentation/widgets/shared_orders_desktop_table.dart';
import 'package:vsc_app/features/orders/presentation/widgets/shared_order_mobile_card.dart';

class TodaysOrdersPage extends StatefulWidget {
  const TodaysOrdersPage({super.key});

  @override
  State<TodaysOrdersPage> createState() => _TodaysOrdersPageState();
}

class _TodaysOrdersPageState extends State<TodaysOrdersPage> {
  int _selectedDays = 1;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.setContext(context);
      provider.getTodaysOrders(days: _selectedDays);
    });
  }

  // Mobile info rows and badges handled by shared widgets

  @override
  void dispose() {
    context.read<AnalyticsProvider>().clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Orders"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), child: _buildDaysSelector()),
        ),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: "Loading today's orders...");
          }

          if (provider.errorMessage != null) {
            return CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.getTodaysOrders(days: _selectedDays),
            );
          }

          final orders = provider.todaysOrders ?? [];
          if (orders.isEmpty) {
            return const EmptyStateWidget(message: 'No orders created today', icon: Icons.today_outlined);
          }

          return context.isDesktop ? SharedOrdersDesktopTable(orders: orders, onTapOrder: _openOrderDetail) : _buildMobileList(orders);
        },
      ),
    );
  }

  Widget _buildDaysSelector() {
    final List<int> dayOptions = [1, 2, 3, 4, 5];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final day in dayOptions) ...[
            ChoiceChip(
              label: Text('$day'),
              selected: _selectedDays == day,
              onSelected: (selected) {
                if (selected && _selectedDays != day) {
                  setState(() {
                    _selectedDays = day;
                  });
                  context.read<AnalyticsProvider>().getTodaysOrders(days: day);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              labelStyle: TextStyle(
                color: _selectedDays == day ? Theme.of(context).colorScheme.onPrimary : AppConfig.black87,
                fontWeight: FontWeight.w600,
              ),
              shape: StadiumBorder(
                side: BorderSide(color: _selectedDays == day ? Theme.of(context).colorScheme.primary : Colors.grey.shade400),
              ),
              backgroundColor: Colors.grey.shade200,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileList(List<OrderViewModel> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) => SharedOrderMobileCard(order: orders[index], onTap: (o) => _openOrderDetail(o)),
    );
  }

  // Desktop rendering delegated to SharedOrdersDesktopTable

  // Requirement checks via shared helpers when needed

  // Vendor/studio names provided via shared helpers when needed

  // Status chip handled inline where needed

  void _openOrderDetail(OrderViewModel order) {
    final orderDetailProvider = OrderDetailProvider();
    orderDetailProvider.selectOrder(order);
    context.push(RouteConstants.orderDetail.replaceAll(':id', order.id), extra: orderDetailProvider);
  }
}
