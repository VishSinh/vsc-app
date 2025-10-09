import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/enums/bill_status.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';

class SharedBillMobileCard extends StatelessWidget {
  final BillViewModel bill;
  final void Function(BillViewModel bill)? onTap;

  const SharedBillMobileCard({super.key, required this.bill, this.onTap});

  void _defaultTap(BuildContext context) {
    context.pushNamed(RouteConstants.billDetailRouteName, pathParameters: {'id': bill.id});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: () => onTap != null ? onTap!(bill) : _defaultTap(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.receipt_long, size: 20, color: Colors.blue),
        ),
        title: Text(
          bill.orderName,
          style: ResponsiveText.getTitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Items: ${bill.order.orderItems.length}',
                style: ResponsiveText.getBody(context).copyWith(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              bill.summary.formattedTotalWithTax,
              style: ResponsiveText.getSubtitle(context).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Builder(
              builder: (context) {
                final color = bill.paymentStatus.getStatusColor();
                return Text(
                  bill.paymentStatus.getDisplayText(),
                  style: ResponsiveText.getCaption(context).copyWith(color: color, fontWeight: FontWeight.w600),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
