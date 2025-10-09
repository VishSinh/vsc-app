import 'package:flutter/material.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/features/orders/presentation/services/order_calculation_service.dart';
import 'package:vsc_app/features/orders/presentation/widgets/shared_order_helpers.dart' as shared;
import 'package:vsc_app/features/orders/presentation/widgets/shared_order_widgets.dart' as shared_widgets;

class SharedOrdersDesktopTable extends StatelessWidget {
  final List<OrderViewModel> orders;
  final void Function(OrderViewModel order) onTapOrder;

  const SharedOrdersDesktopTable({super.key, required this.orders, required this.onTapOrder});

  @override
  Widget build(BuildContext context) {
    const double fixedRowHeight = 65.0; // Fixed height for each row
    const double headerHeight = 50.0; // Height of the header row
    const double borderRadius = 12.0;

    return Container(
      height: MediaQuery.of(context).size.height,
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
                children: const [
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
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return InkWell(
                    onTap: () => onTapOrder(order),
                    child: Container(
                      height: fixedRowHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF4C4B4B))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
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
                                decoration: BoxDecoration(
                                  color: order.orderStatus.getStatusColor(),
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                shared.getBoxMakerName(order) ?? '--',
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
                                shared.getPrinterName(order) ?? '--',
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
                                shared.getTracingStudioName(order) ?? '--',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: shared_widgets.buildJobsBadges(
                                showBox: shared.hasBoxRequirements(order),
                                showPrint: shared.hasPrintingRequirements(order),
                                boxMissing: shared.isAnyBoxExpenseMissing(order),
                                printOrTracingMissing: shared.isAnyPrintingOrTracingExpenseMissing(order),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
