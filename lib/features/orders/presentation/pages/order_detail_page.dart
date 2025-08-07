import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_list_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/orders/presentation/widgets/box_order_edit_dialog.dart';
import 'package:vsc_app/features/orders/presentation/widgets/printing_job_edit_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_view_model.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final OrderListProvider? orderProvider;

  const OrderDetailPage({super.key, required this.orderId, this.orderProvider});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    final orderProvider = context.read<OrderListProvider>();
    orderProvider.setContext(context);
    orderProvider.fetchOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    // If provider was passed, use it; otherwise create a new one
    final provider = widget.orderProvider ?? OrderListProvider();

    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.orders)),
        ),
        body: _buildOrderDetailContent(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _loadOrderDetails(),
          backgroundColor: Colors.orange,
          heroTag: 'reload',
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Refresh', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildOrderDetailContent() {
    return Consumer<OrderListProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return _buildLoadingSpinner();
        }

        if (orderProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(orderProvider.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => _loadOrderDetails(), child: const Text('Retry')),
              ],
            ),
          );
        }

        final order = orderProvider.currentOrder;
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }

        return context.isMobile ? _buildMobileLayout(order) : _buildDesktopLayout(order);
      },
    );
  }

  Widget _buildLoadingSpinner() {
    return const Center(child: SpinKitDoubleBounce(color: Colors.blue, size: 50.0));
  }

  Widget _buildMobileLayout(OrderViewModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildOrderHeader(order), const SizedBox(height: 24), _buildOrderInfo(order), const SizedBox(height: 24), _buildOrderItems(order)],
      ),
    );
  }

  Widget _buildDesktopLayout(OrderViewModel order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildOrderHeader(order), const SizedBox(height: 24), _buildOrderInfo(order)],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: Padding(padding: const EdgeInsets.all(16), child: _buildOrderItems(order)),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(OrderViewModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.name.isNotEmpty ? order.name : 'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getStatusColor(order.orderStatus), borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    _formatStatus(order.orderStatus),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (order.specialInstruction.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.specialInstruction,
                        style: const TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(OrderViewModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoRow('Order ID', order.id),
            _buildInfoRow('Customer', order.customerName),
            _buildInfoRow('Staff', order.staffName),
            _buildInfoRow('Order Date', _formatDateTime(order.orderDate)),
            _buildInfoRow('Delivery Date', _formatDateTime(order.deliveryDate)),
            _buildInfoRow('Total Items', '${order.orderItems.length}'),
            _buildInfoRow('Total Amount', '₹${_calculateTotalAmount(order.orderItems).toStringAsFixed(2)}'),
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
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderViewModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...order.orderItems.map((item) => _buildOrderItemCard(item)),
      ],
    );
  }

  Widget _buildOrderItemCard(OrderItemViewModel item) {
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
                  child: Text('Item ID: ${item.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'Order: ${item.orderName}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildItemInfoRow('Quantity', '${item.quantity}'),
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
                    child: const Text(
                      'Box Required',
                      style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (item.requiresBox && item.requiresPrinting) const SizedBox(width: 8),
                if (item.requiresPrinting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      'Printing Required',
                      style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            if (item.boxOrders != null && item.boxOrders!.isNotEmpty) ...[const SizedBox(height: 16), _buildBoxOrders(item.boxOrders!)],
            if (item.printingJobs != null && item.printingJobs!.isNotEmpty) ...[const SizedBox(height: 16), _buildPrintingJobs(item.printingJobs!)],
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

  Widget _buildBoxOrders(List<BoxOrderViewModel> boxOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Box Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        ...boxOrders.map((box) => _buildBoxOrderItem(box)),
      ],
    );
  }

  Widget _buildBoxOrderItem(BoxOrderViewModel box) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Box ID: ${box.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _getBoxStatusColor(box.boxStatus), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _formatBoxStatus(box.boxStatus),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showEditBoxOrderDialog(box),
                icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                tooltip: 'Edit Box Order',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBoxInfoRow('Type', box.boxType.toString().split('.').last.toUpperCase()),
          _buildBoxInfoRow('Quantity', '${box.boxQuantity}'),
          _buildBoxInfoRow('Cost', '₹${box.totalBoxCost}'),
          if (box.boxMakerId != null) _buildBoxInfoRow('Box Maker', box.boxMakerName ?? box.boxMakerId!),
          if (box.estimatedCompletion != null) _buildBoxInfoRow('Est. Completion', _formatDateTime(box.estimatedCompletion!)),
        ],
      ),
    );
  }

  Widget _buildPrintingJobs(List<PrintingJobViewModel> printingJobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Printing Jobs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 8),
        ...printingJobs.map((job) => _buildPrintingJobItem(job)),
      ],
    );
  }

  Widget _buildPrintingJobItem(PrintingJobViewModel job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Job ID: ${job.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _getPrintingStatusColor(job.printingStatus), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _formatPrintingStatus(job.printingStatus),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showEditPrintingJobDialog(job),
                icon: const Icon(Icons.edit, size: 16, color: Colors.green),
                tooltip: 'Edit Printing Job',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPrintingInfoRow('Quantity', '${job.printQuantity}'),
          _buildPrintingInfoRow('Cost', '₹${job.totalPrintingCost}'),
          if (job.printerId != null) _buildPrintingInfoRow('Printer', job.printerName ?? job.printerId!),
          if (job.tracingStudioId != null) _buildPrintingInfoRow('Tracing Studio', job.tracingStudioId!),
          if (job.estimatedCompletion != null) _buildPrintingInfoRow('Est. Completion', _formatDateTime(job.estimatedCompletion!)),
        ],
      ),
    );
  }

  Widget _buildBoxInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPrintingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'confirmed':
        return 'CONFIRMED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatBoxStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatPrintingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getBoxStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPrintingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _calculateLineTotal(OrderItemViewModel item) {
    final pricePerItem = double.tryParse(item.pricePerItem) ?? 0.0;
    final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
    return (pricePerItem * item.quantity) - discountAmount;
  }

  double _calculateTotalAmount(List<OrderItemViewModel> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      final lineTotal = _calculateLineTotal(item);

      // Add box costs
      final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));

      // Add printing costs
      final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));

      return total + lineTotal + boxCosts + printingCosts;
    });
  }

  void _showEditBoxOrderDialog(BoxOrderViewModel box) {
    showDialog(
      context: context,
      builder: (context) => BoxOrderEditDialog(
        boxOrderId: box.id,
        currentBoxMakerId: box.boxMakerId ?? '',
        currentTotalBoxCost: box.totalBoxCost,
        currentTotalBoxExpense: box.totalBoxExpense,
        currentBoxStatus: box.boxStatus,
        currentBoxType: box.boxType.toString().split('.').last,
        currentBoxQuantity: box.boxQuantity,
        currentEstimatedCompletion: box.estimatedCompletion?.toIso8601String(),
        onSuccess: () {
          _loadOrderDetails();
        },
      ),
    );
  }

  void _showEditPrintingJobDialog(PrintingJobViewModel job) {
    showDialog(
      context: context,
      builder: (context) => PrintingJobEditDialog(
        printingJobId: job.id,
        currentPrinterId: job.printerId ?? '',
        currentTracingStudioId: job.tracingStudioId ?? '',
        currentTotalPrintingCost: job.totalPrintingCost,
        currentTotalPrintingExpense: job.totalPrintingExpense,
        currentTotalTracingExpense: job.totalTracingExpense,
        currentPrintingStatus: job.printingStatus,
        currentPrintQuantity: job.printQuantity,
        currentEstimatedCompletion: job.estimatedCompletion?.toIso8601String(),
        onSuccess: () {
          // Reload order details after successful update
          _loadOrderDetails();
        },
      ),
    );
  }
}
