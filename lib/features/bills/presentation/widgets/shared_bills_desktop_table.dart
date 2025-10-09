import 'package:flutter/material.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/core/enums/bill_status.dart';

class SharedBillsDesktopTable extends StatelessWidget {
  final List<BillViewModel> bills;
  final void Function(BillViewModel bill) onTapBill;

  const SharedBillsDesktopTable({super.key, required this.bills, required this.onTapBill});

  @override
  Widget build(BuildContext context) {
    const double fixedRowHeight = 65.0;
    const double headerHeight = 50.0;
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
                    flex: 2,
                    child: Center(
                      child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                      child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Pending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return InkWell(
                    onTap: () => onTapBill(bill),
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
                                bill.orderName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                bill.order.customerName,
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
                                DateFormatter.formatDate(bill.order.orderDate),
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
                                  color: bill.paymentStatus.getStatusColor(),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  bill.paymentStatus.getDisplayText(),
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
                                bill.summary.formattedTotalWithTax,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '₹${(bill.summary.totalWithTax - bill.summary.pendingAmount).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                bill.summary.pendingAmount == 0 ? '-' : bill.summary.formattedPendingAmount,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: bill.summary.pendingAmount == 0 ? Colors.white : Colors.red,
                                ),
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
