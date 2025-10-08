import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_view_model.dart';
import 'package:vsc_app/features/bills/presentation/services/bill_calculation_service.dart';
import 'package:vsc_app/features/bills/presentation/widgets/payment_create_dialog.dart';
import 'package:vsc_app/features/bills/presentation/widgets/bill_adjustment_create_dialog.dart';
import 'package:vsc_app/core/enums/bill_status.dart';
import 'package:vsc_app/core/enums/payment_mode.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/core/enums/service_type.dart';
import 'package:vsc_app/core/enums/bill_adjustment_type.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/core/utils/image_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class BillPage extends StatefulWidget {
  final String billId;
  final bool fromOrderCreation;

  const BillPage({super.key, required this.billId, this.fromOrderCreation = false});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  void _loadBillDetails() async {
    final billProvider = context.read<BillProvider>();
    billProvider.setContext(context);
    await billProvider.getBillByBillId(billId: widget.billId);
    await billProvider.getPaymentsByBillId(billId: widget.billId);
    await billProvider.getBillAdjustmentsByBillId(billId: widget.billId);

    // Load card images for each order item
    if (billProvider.currentBill != null) {
      for (var item in billProvider.currentBill!.order.orderItems) {
        await billProvider.fetchCardImage(item.cardId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        leading: IconButton(
          icon: Icon(widget.fromOrderCreation ? Icons.home : Icons.arrow_back),
          onPressed: () {
            context.read<BillProvider>().clearBillData();
            if (widget.fromOrderCreation) {
              context.go(RouteConstants.dashboard);
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadBillDetails(), tooltip: 'Refresh'),
          Consumer<BillProvider>(
            builder: (context, billProvider, _) {
              final bill = billProvider.currentBill;
              return IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Print',
                onPressed: bill == null
                    ? null
                    : () {
                        context.pushNamed(RouteConstants.billPrintPreviewRouteName, pathParameters: {'id': widget.billId});
                      },
              );
            },
          ),
        ],
      ),
      body: _buildBillDetailContent(),
    );
  }

  Widget _buildBillDetailContent() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        // Show loading if currently loading OR if bill is null and we haven't made an API call yet
        if (billProvider.isLoading || (billProvider.currentBill == null && billProvider.errorMessage == null)) {
          return const LoadingWidget(message: 'Loading bill details...');
        }

        if (billProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(billProvider.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => _loadBillDetails(), child: const Text('Retry')),
              ],
            ),
          );
        }

        final bill = billProvider.currentBill;
        if (bill == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                SizedBox(height: AppConfig.defaultPadding),
                Text('Bill not found', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
                SizedBox(height: AppConfig.smallPadding),
                ElevatedButton(onPressed: () => context.push(RouteConstants.bills), child: const Text('Back to Bills')),
              ],
            ),
          );
        }

        return context.isMobile ? _buildMobileLayout(bill) : _buildDesktopLayout(bill);
      },
    );
  }

  Widget _buildMobileLayout(BillViewModel bill) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBillHeader(bill),
          const SizedBox(height: 24),
          _buildPaymentAndAdjustmentButtons(),
          const SizedBox(height: 24),
          _buildOrderInfo(bill),
          const SizedBox(height: 24),
          _buildPaymentsSection(),
          const SizedBox(height: 24),
          _buildAdjustmentsSection(),
          const SizedBox(height: 24),
          _buildOrderItems(bill),
          if (bill.order.serviceItems.isNotEmpty) ...[const SizedBox(height: 24), _buildServiceItems(bill)],
          const SizedBox(height: 24),
          _buildSummaryCards(bill),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BillViewModel bill) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBillHeader(bill),
                  const SizedBox(height: 24),
                  _buildPaymentAndAdjustmentButtons(),
                  const SizedBox(height: 24),
                  _buildOrderInfo(bill),
                  const SizedBox(height: 24),
                  _buildPaymentsSection(),
                  const SizedBox(height: 24),
                  _buildAdjustmentsSection(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(bill),
                ],
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderItems(bill),
                  if (bill.order.serviceItems.isNotEmpty) ...[const SizedBox(height: 24), _buildServiceItems(bill)],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillHeader(BillViewModel bill) {
    return Card(
      elevation: AppConfig.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(bill.orderName, style: AppConfig.getResponsiveHeadline(context))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: bill.paymentStatus.getStatusColor(), borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    bill.paymentStatus.getDisplayText(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentAndAdjustmentButtons() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        final bill = billProvider.currentBill;
        if (bill == null) return const SizedBox.shrink();

        // Use API-provided pending amount instead of app-side calculation
        final isFullyPaid = (bill.summary.pendingAmount <= 0.0);

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isFullyPaid ? null : _showPaymentDialog,
                icon: const Icon(Icons.payment),
                label: Text(isFullyPaid ? 'Fully Paid' : 'Make Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFullyPaid ? AppConfig.grey600 : AppConfig.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isFullyPaid ? null : _showAdjustmentDialog,
                icon: const Icon(Icons.tune),
                label: const Text('Bill Adjustment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFullyPaid ? AppConfig.grey600 : AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog() {
    final billProvider = context.read<BillProvider>();
    final bill = billProvider.currentBill;
    if (bill == null) return;

    // Use remaining amount from API to ensure consistency with adjustments
    final remainingAmount = bill.summary.pendingAmount;

    showDialog(
      context: context,
      builder: (context) => PaymentCreateDialog(billId: widget.billId, remainingAmount: remainingAmount),
    ).then((result) {
      if (result == true) {
        // Payment was created successfully, refresh the data
        _loadBillDetails();
      }
    });
  }

  void _showAdjustmentDialog() {
    final billProvider = context.read<BillProvider>();
    final bill = billProvider.currentBill;
    if (bill == null) return;

    final remainingAmount = bill.summary.pendingAmount;

    showDialog(
      context: context,
      builder: (context) => BillAdjustmentCreateDialog(billId: widget.billId, remainingAmount: remainingAmount),
    ).then((result) {
      if (result == true) {
        _loadBillDetails();
      }
    });
  }

  Widget _buildOrderInfo(BillViewModel bill) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Information', style: AppConfig.getResponsiveTitle(context)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 120, child: Text('Customer', style: AppConfig.getResponsiveCaption(context))),
                Expanded(
                  child: Consumer<BillProvider>(
                    builder: (context, billProvider, _) {
                      final phone = billProvider.getCustomerPhone(bill.order.customerId);
                      if (phone == null) {
                        // fire and forget; UI will rebuild when phone is fetched
                        billProvider.fetchCustomerPhone(bill.order.customerId);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bill.order.customerName, style: AppConfig.getResponsiveBody(context)),
                          if (phone != null) ...[
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final url = Uri.parse('tel:$phone');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              child: Text(
                                phone,
                                style: AppConfig.getResponsiveBody(
                                  context,
                                ).copyWith(color: Colors.blue, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            _buildInfoRow('Staff', bill.order.staffName),
            _buildInfoRow('Order Date', DateFormatter.formatDateTime(bill.order.orderDate)),
            _buildInfoRow('Delivery Date', DateFormatter.formatDateTime(bill.order.deliveryDate)),
            _buildInfoRow('Status', bill.order.orderStatus.getDisplayText()),
            if (bill.order.specialInstruction.isNotEmpty) _buildInfoRow('Special Instructions', bill.order.specialInstruction),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: AppConfig.getResponsiveCaption(context))),
          Expanded(child: Text(value, style: AppConfig.getResponsiveBody(context))),
        ],
      ),
    );
  }

  Widget _buildOrderItems(BillViewModel bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Card Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...bill.order.orderItems.map((item) => _buildOrderItemCard(item)),
      ],
    );
  }

  Widget _buildServiceItems(BillViewModel bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Service Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...bill.order.serviceItems.map((svc) => _buildServiceItemCard(svc)),
      ],
    );
  }

  Widget _buildOrderItemCard(BillOrderItemViewModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display card image at the top for mobile
                      _buildCardImage(item.cardId),
                      const SizedBox(height: 12),
                      // Item details below the image on mobile
                      Row(
                        children: [
                          Expanded(
                            child: Text('Card', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              'Qty: ${item.quantity}',
                              style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildItemInfoRow('Price per Item', '₹${item.pricePerItem}'),
                      _buildItemInfoRow('Discount Amount', '₹${item.discountAmount}'),
                      _buildItemInfoRow('Card Cost', '₹${_calculateLineTotal(item)}'),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Card', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Qty: ${item.quantity}',
                                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildItemInfoRow('Price per Item', '₹${item.pricePerItem}'),
                            _buildItemInfoRow('Discount Amount', '₹${item.discountAmount}'),
                            _buildItemInfoRow('Card Total', '₹${_calculateLineTotal(item)}'),
                          ],
                        ),
                      ),
                      // Display card image on the right side for desktop
                      const SizedBox(width: 12),
                      _buildCardImage(item.cardId),
                    ],
                  ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (item.requiresBox)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      'Box: ${item.calculatedCosts.formattedBoxCost}',
                      style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (item.requiresBox && item.requiresPrinting) const SizedBox(width: 8),
                if (item.requiresPrinting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      'Print: ${item.calculatedCosts.formattedPrintingCost}',
                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Line Total:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  item.calculatedCosts.formattedTotalCost,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildServiceItemCard(ServiceItemViewModel svc) {
    final typeText = svc.serviceType?.displayText ?? svc.serviceTypeRaw;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(typeText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'Qty: ${svc.quantity}',
                    style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildItemInfoRow('Total', '₹${svc.totalCost}'),
            // if (svc.totalExpense != null) _buildItemInfoRow('Expense', '₹${svc.totalExpense}'), // Hidden as per request
            if (svc.description != null && svc.description!.isNotEmpty) _buildItemInfoRow('Description', svc.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BillViewModel bill) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // First row: Order Items Subtotal, Service Items Subtotal
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Card Items', bill.summary.formattedOrderItemsSubtotal, Colors.grey[600]!)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Services', bill.summary.formattedServiceItemsSubtotal, Colors.teal[600]!)),
              ],
            ),
            const SizedBox(height: 12),
            // Second row: Items Subtotal, Box Cost
            Row(
              children: [
                // Expanded(child: _buildSummaryCard('Items Total', bill.summary.formattedItemsSubtotal, Colors.blue[600]!)),
                Expanded(child: _buildSummaryCard('Printing Cost', bill.summary.formattedTotalPrintingCost, Colors.orange[600]!)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Box Cost', bill.summary.formattedTotalBoxCost, Colors.purple[600]!)),
              ],
            ),
            const SizedBox(height: 12),
            // Third row: Printing Cost, Tax
            Row(
              children: [
                // const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Tax', bill.summary.formattedTaxAmount, Colors.amber[600]!)),
              ],
            ),
            const SizedBox(height: 12),
            // Fourth row: Grand Total
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSummaryCard('Grand Total', bill.summary.formattedGrandTotal, Colors.green[600]!, isHighlighted: true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Pending Amount
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Pending Amount',
                    bill.summary.formattedPendingAmount,
                    Colors.red[600]!,
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.15) : AppConfig.secondaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        border: Border.all(
          color: isHighlighted ? color.withOpacity(0.5) : AppConfig.grey600.withOpacity(0.3),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppConfig.textColorSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isHighlighted ? color : AppConfig.textColorPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        final payments = billProvider.payments;
        final bill = billProvider.currentBill;

        if (bill == null) return const SizedBox.shrink();
        // Use pending amount from API
        final remainingAmount = bill.summary.pendingAmount;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment, color: AppConfig.successColor),
                    const SizedBox(width: 8),
                    Text('Payment History', style: AppConfig.getResponsiveTitle(context)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: remainingAmount <= 0 ? AppConfig.successColor : AppConfig.warningColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        remainingAmount <= 0 ? 'Fully Paid' : '₹${remainingAmount.toStringAsFixed(2)} Remaining',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (payments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No payments made yet', style: AppConfig.getResponsiveCaption(context)),
                    ),
                  )
                else
                  Column(children: payments.map((payment) => _buildPaymentItem(payment)).toList()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdjustmentsSection() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        final adjustments = billProvider.adjustments;
        final bill = billProvider.currentBill;

        if (bill == null) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: AppConfig.primaryColor),
                    const SizedBox(width: 8),
                    Text('Bill Adjustments', style: AppConfig.getResponsiveTitle(context)),
                  ],
                ),
                const SizedBox(height: 16),
                if (adjustments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No bill adjustments yet', style: AppConfig.getResponsiveCaption(context)),
                    ),
                  )
                else
                  Column(
                    children: adjustments
                        .map(
                          (a) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConfig.secondaryColor,
                              borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
                              border: Border.all(color: AppConfig.grey600),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.tune, color: AppConfig.primaryColor, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('₹${a.amount.toStringAsFixed(2)}', style: AppConfig.getResponsiveTitle(context)),
                                      Text(a.adjustmentType.displayText, style: AppConfig.getResponsiveCaption(context)),
                                      if (a.reason.isNotEmpty)
                                        Text('Reason: ${a.reason}', style: AppConfig.getResponsiveCaption(context)),
                                      Text('By: ${a.staffName}', style: AppConfig.getResponsiveCaption(context)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentItem(PaymentViewModel payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConfig.secondaryColor,
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        border: Border.all(color: AppConfig.grey600),
      ),
      child: Row(
        children: [
          Icon(_getPaymentModeIcon(payment.paymentMode), color: _getPaymentModeColor(payment.paymentMode), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${payment.amount.toStringAsFixed(2)}', style: AppConfig.getResponsiveTitle(context)),
                Text(payment.paymentMode.name.toUpperCase(), style: AppConfig.getResponsiveCaption(context)),
                if (payment.transactionRef.isNotEmpty)
                  Text('Ref: ${payment.transactionRef}', style: AppConfig.getResponsiveCaption(context)),
              ],
            ),
          ),
          if (payment.notes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline, size: 16, color: AppConfig.textColorPrimary),
              onPressed: () => _showPaymentNotes(payment),
            ),
        ],
      ),
    );
  }

  IconData _getPaymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.money;
      case PaymentMode.card:
        return Icons.credit_card;
      case PaymentMode.upi:
        return Icons.phone_android;
    }
  }

  Color _getPaymentModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Colors.green;
      case PaymentMode.card:
        return Colors.blue;
      case PaymentMode.upi:
        return Colors.purple;
    }
  }

  void _showPaymentNotes(PaymentViewModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Notes'),
        content: Text(payment.notes),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  double _calculateLineTotal(BillOrderItemViewModel item) {
    return BillCalculationService.calculateLineTotal(item.pricePerItem, item.discountAmount, item.quantity);
  }

  Widget _buildCardImage(String cardId) {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        final card = billProvider.getCardImageById(cardId);

        if (card == null) {
          // Placeholder while loading or if image not found
          return Container(
            width: context.isMobile ? double.infinity : 180,
            height: context.isMobile ? 200 : 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              color: Colors.grey.shade200,
            ),
            child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
          );
        }

        return GestureDetector(
          onTap: () => ImageUtils.showEnlargedImageDialog(context, card.image),
          child: Container(
            width: context.isMobile ? double.infinity : 180,
            height: context.isMobile ? 200 : 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              image: DecorationImage(image: NetworkImage(card.image), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
