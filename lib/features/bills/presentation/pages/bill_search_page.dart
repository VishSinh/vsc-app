import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/auth/presentation/providers/permission_provider.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/core/enums/bill_status.dart';

class BillSearchPage extends StatefulWidget {
  const BillSearchPage({super.key});

  @override
  State<BillSearchPage> createState() => _BillSearchPageState();
}

class _BillSearchPageState extends State<BillSearchPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _search() async {
    final provider = context.read<BillProvider>();
    provider.setContext(context);
    await provider.getBillByPhone(phone: _phoneController.text.trim());
  }

  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return Colors.green;
      case BillStatus.partial:
        return Colors.orange;
      case BillStatus.pending:
        return Colors.red;
    }
  }

  String _getStatusText(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.partial:
        return 'Partial';
      case BillStatus.pending:
        return 'Pending';
    }
  }

  Widget _buildBillSearchContent(BillProvider provider) {
    return Padding(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(UITextConstants.bills, style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: AppConfig.defaultPadding),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter customer phone number',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onSubmitted: (_) => _search(),
                ),
              ),
              SizedBox(width: AppConfig.smallPadding),
              ElevatedButton.icon(onPressed: _search, icon: const Icon(Icons.search), label: const Text('Search')),
            ],
          ),
          SizedBox(height: AppConfig.largePadding),
          Expanded(
            child: provider.isLoading
                ? const LoadingWidget(message: 'Searching bills...')
                : provider.bills.isEmpty
                ? const EmptyStateWidget(message: 'Search for bills by phone number', icon: Icons.receipt_long)
                : ListView.builder(
                    itemCount: provider.bills.length,
                    itemBuilder: (context, index) {
                      final bill = provider.bills[index];
                      return GestureDetector(
                        onTap: () => context.push('${RouteConstants.bills}/${bill.id}'),
                        child: Card(
                          margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(AppConfig.defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(bill.orderName, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: AppConfig.smallPadding, vertical: 4),
                                      decoration: BoxDecoration(color: _getStatusColor(bill.paymentStatus), borderRadius: BorderRadius.circular(12)),
                                      child: Text(
                                        _getStatusText(bill.paymentStatus),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppConfig.smallPadding),
                                Row(
                                  children: [
                                    Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Text('Bill ID: ${bill.id}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                                  ],
                                ),
                                SizedBox(height: AppConfig.smallPadding),
                                Row(
                                  children: [
                                    Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Text('Order: ${bill.orderId}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                                  ],
                                ),
                                SizedBox(height: AppConfig.smallPadding),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Items: ${bill.order.orderItems.length}', style: Theme.of(context).textTheme.bodyMedium),
                                        Text(
                                          'Tax: ${bill.summary.formattedTaxPercentage}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          bill.summary.formattedTotalWithTax,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                        ),
                                        Text('Grand Total', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        return _buildBillSearchContent(provider);
      },
    );
  }
}
