import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/bills/presentation/provider/bill_provider.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_view_model.dart';
import 'package:vsc_app/features/bills/presentation/widgets/payment_create_dialog.dart';
import 'package:vsc_app/core/enums/bill_status.dart';
import 'package:vsc_app/core/enums/payment_mode.dart';

class BillPage extends StatefulWidget {
  final String billId;
  const BillPage({super.key, required this.billId});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  void _loadBillDetails() {
    final billProvider = context.read<BillProvider>();
    billProvider.setContext(context);
    billProvider.getBillByBillId(billId: widget.billId);
    billProvider.getPaymentsByBillId(billId: widget.billId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<BillProvider>().clearBillData();
            context.pop();
          },
        ),
      ),
      body: _buildBillDetailContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _loadBillDetails(),
        backgroundColor: Colors.orange,
        heroTag: 'reload',
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text('Refresh', style: TextStyle(color: Colors.white)),
      ),
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
          _buildPaymentButton(),
          const SizedBox(height: 24),
          _buildOrderInfo(bill),
          const SizedBox(height: 24),
          _buildPaymentsSection(),
          const SizedBox(height: 24),
          _buildOrderItems(bill),
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
                  _buildPaymentButton(),
                  const SizedBox(height: 24),
                  _buildOrderInfo(bill),
                  const SizedBox(height: 24),
                  _buildPaymentsSection(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(bill),
                ],
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: _buildOrderItems(bill)),
          ),
        ),
      ],
    );
  }

  Widget _buildBillHeader(BillViewModel bill) {
    return Card(
      color: AppConfig.secondaryColor,
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
                  decoration: BoxDecoration(color: _getStatusColor(bill.paymentStatus), borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    _getStatusText(bill.paymentStatus),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Bill ID: ${bill.id}', style: AppConfig.getResponsiveCaption(context)),
            const SizedBox(height: 4),
            Text('Order ID: ${bill.orderId}', style: AppConfig.getResponsiveCaption(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        final bill = billProvider.currentBill;
        if (bill == null) return const SizedBox.shrink();

        // Calculate total paid amount from payments
        final totalPaidAmount = billProvider.payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
        final remainingAmount = bill.summary.totalWithTax - totalPaidAmount;
        final isFullyPaid = remainingAmount <= 0;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isFullyPaid ? null : _showPaymentDialog,
            icon: const Icon(Icons.payment),
            label: Text(isFullyPaid ? 'Fully Paid' : 'Make New Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFullyPaid ? AppConfig.grey600 : AppConfig.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentDialog() {
    final billProvider = context.read<BillProvider>();
    final bill = billProvider.currentBill;
    if (bill == null) return;

    // Calculate total paid amount from payments
    final totalPaidAmount = billProvider.payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final remainingAmount = bill.summary.totalWithTax - totalPaidAmount;

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

  Widget _buildOrderInfo(BillViewModel bill) {
    return Card(
      color: AppConfig.secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Information', style: AppConfig.getResponsiveTitle(context)),
            const SizedBox(height: 16),
            _buildInfoRow('Customer', bill.order.customerName),
            _buildInfoRow('Staff', bill.order.staffName),
            _buildInfoRow('Order Date', _formatDateTime(bill.order.orderDate)),
            _buildInfoRow('Delivery Date', _formatDateTime(bill.order.deliveryDate)),
            _buildInfoRow('Status', bill.order.orderStatus),
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
        const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...bill.order.orderItems.map((item) => _buildOrderItemCard(item)),
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
            Row(
              children: [
                Expanded(
                  child: Text('Card ID: ${item.cardId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            _buildItemInfoRow('Line Total', '₹${_calculateLineTotal(item)}'),
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
                const Text('Total Cost:', style: TextStyle(fontWeight: FontWeight.w500)),
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

  Widget _buildSummaryCards(BillViewModel bill) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Subtotal', bill.summary.formattedItemsSubtotal, Colors.grey[600]!)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Tax', bill.summary.formattedTaxAmount, Colors.orange[600]!)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Total', bill.summary.formattedTotalWithTax, Colors.green[600]!, isHighlighted: true)),
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
        color: isHighlighted ? color.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHighlighted ? color : Colors.grey[300]!, width: isHighlighted ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isHighlighted ? color : Colors.black),
          ),
        ],
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPaymentsSection() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        final payments = billProvider.payments;
        final bill = billProvider.currentBill;

        if (bill == null) return const SizedBox.shrink();

        final totalPaidAmount = payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
        final remainingAmount = bill.summary.totalWithTax - totalPaidAmount;

        return Card(
          color: AppConfig.secondaryColor,
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
                if (payment.transactionRef.isNotEmpty) Text('Ref: ${payment.transactionRef}', style: AppConfig.getResponsiveCaption(context)),
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
    final pricePerItem = double.tryParse(item.pricePerItem) ?? 0.0;
    final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
    return (pricePerItem * item.quantity) - discountAmount;
  }
}
