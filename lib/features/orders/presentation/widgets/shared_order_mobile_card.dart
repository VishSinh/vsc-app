import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/orders/presentation/services/order_calculation_service.dart';
import 'package:vsc_app/features/orders/presentation/widgets/shared_order_helpers.dart' as shared;
import 'package:vsc_app/features/orders/presentation/widgets/shared_order_widgets.dart' as shared_widgets;

class SharedOrderMobileCard extends StatelessWidget {
  final OrderViewModel order;
  final void Function(OrderViewModel order)? onTap;

  const SharedOrderMobileCard({super.key, required this.order, this.onTap});

  void _defaultTap(BuildContext context) {
    final orderDetailProvider = OrderDetailProvider();
    orderDetailProvider.selectOrder(order);
    context.push(RouteConstants.orderDetail.replaceAll(':id', order.id), extra: orderDetailProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(order);
          } else {
            _defaultTap(context);
          }
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
              shared_widgets.buildOrderInfoRow(Icons.calendar_today, 'Ordered:', DateFormatter.formatDate(order.orderDate)),
              const SizedBox(height: 8),
              shared_widgets.buildOrderInfoRow(Icons.person, 'Customer:', order.customerName),
              const SizedBox(height: 8),
              shared_widgets.buildOrderInfoRow(Icons.badge, 'Staff:', order.staffName),
              const SizedBox(height: 8),
              shared_widgets.buildOrderInfoRow(Icons.local_shipping, 'Delivery:', DateFormatter.formatDate(order.deliveryDate)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${order.orderItems.length + order.serviceItems.length} item${(order.orderItems.length + order.serviceItems.length) != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (shared.hasBoxRequirements(order)) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                  ],
                  if (shared.hasPrintingRequirements(order)) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.print, size: 16, color: Colors.green),
                  ],
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '₹ ',
                          style: TextStyle(
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
              if (shared.hasBoxRequirements(order) || shared.hasPrintingRequirements(order)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (shared.hasBoxRequirements(order))
                      shared_widgets.buildJobsBadges(
                        showBox: true,
                        showPrint: shared.hasPrintingRequirements(order),
                        boxMissing: shared.isAnyBoxExpenseMissing(order),
                        printOrTracingMissing: shared.isAnyPrintingOrTracingExpenseMissing(order),
                      ),
                    if (shared.hasBoxRequirements(order) && shared.hasPrintingRequirements(order)) const SizedBox(width: 4),
                    if (shared.hasPrintingRequirements(order) && !shared.hasBoxRequirements(order))
                      shared_widgets.buildJobsBadges(
                        showBox: false,
                        showPrint: true,
                        boxMissing: false,
                        printOrTracingMissing: shared.isAnyPrintingOrTracingExpenseMissing(order),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
