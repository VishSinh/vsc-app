import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/enums/box_status.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/core/enums/printing_status.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/orders/presentation/widgets/box_order_edit_dialog.dart';
import 'package:vsc_app/features/orders/presentation/widgets/printing_job_edit_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_view_model.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/enums/service_type.dart';
import 'package:vsc_app/features/orders/presentation/services/order_calculation_service.dart';
import 'package:vsc_app/features/home/presentation/providers/permission_provider.dart';
import 'package:vsc_app/core/utils/image_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final OrderDetailProvider? orderProvider;

  const OrderDetailPage({super.key, required this.orderId, this.orderProvider});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final OrderDetailProvider _orderProvider;

  @override
  void initState() {
    super.initState();
    _orderProvider = widget.orderProvider ?? OrderDetailProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadOrderDetails();
      }
    });
  }

  void _loadOrderDetails() {
    _orderProvider.getOrderById(widget.orderId);
  }

  Future<void> _confirmAndDeleteOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _orderProvider.setContext(context);
      final success = await _orderProvider.deleteOrder(widget.orderId);
      if (success && mounted) {
        context.go(RouteConstants.orders);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.watch<PermissionProvider>();
    return ChangeNotifierProvider.value(
      value: _orderProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.orders)),
          actions: [
            if (permissionProvider.canDelete('order'))
              IconButton(icon: const Icon(Icons.delete_forever), onPressed: _confirmAndDeleteOrder, tooltip: 'Delete Order'),
            if (permissionProvider.canUpdate('order'))
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('${RouteConstants.orders}/${widget.orderId}/edit'),
                tooltip: 'Edit',
              ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadOrderDetails(), tooltip: 'Refresh'),
          ],
        ),
        body: _buildOrderDetailContent(),
      ),
    );
  }

  Widget _buildOrderDetailContent() {
    return Consumer<OrderDetailProvider>(
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
                SizedBox(height: AppConfig.defaultPadding),
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
    return Center(
      child: SpinKitDoubleBounce(color: Colors.blue, size: AppConfig.iconSizeXXLarge),
    );
  }

  Widget _buildMobileLayout(OrderViewModel order) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          SizedBox(height: AppConfig.largePadding),
          _buildOrderInfo(order),
          SizedBox(height: AppConfig.largePadding),
          _buildOrderItems(order),
        ],
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
            padding: EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                SizedBox(height: AppConfig.largePadding),
                _buildOrderInfo(order),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: _buildOrderItems(order)),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(OrderViewModel order) {
    return Card(
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
                    style: TextStyle(fontSize: AppConfig.fontSize3xl, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: order.orderStatus.getStatusColor(), borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    order.orderStatus.getDisplayText(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (order.specialInstruction.isNotEmpty) ...[
              SizedBox(height: AppConfig.spacingMedium),
              Container(
                padding: EdgeInsets.all(AppConfig.smallPadding),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: AppConfig.iconSizeMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.specialInstruction,
                        style: TextStyle(fontSize: AppConfig.fontSizeMd, color: Colors.orange, fontStyle: FontStyle.italic),
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
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: TextStyle(fontSize: AppConfig.fontSizeXl, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    'Customer',
                    style: TextStyle(fontSize: AppConfig.fontSizeMd, fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
                  ),
                ),
                Expanded(
                  child: Consumer<OrderDetailProvider>(
                    builder: (context, provider, _) {
                      final phone = provider.getCustomerPhone(order.customerId);
                      // Trigger fetch if not present
                      if (phone == null) provider.fetchCustomerPhone(order.customerId);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: TextStyle(fontSize: AppConfig.fontSizeMd, fontWeight: FontWeight.w500),
                          ),
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
                                style: TextStyle(
                                  fontSize: AppConfig.fontSizeMd,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
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
            _buildInfoRow('Staff', order.staffName),
            _buildInfoRow('Order Date', _formatDateTime(order.orderDate)),
            _buildInfoRow('Delivery Date', _formatDateTime(order.deliveryDate)),
            _buildInfoRow('Total Items', '${order.orderItems.length}'),
            _buildInfoRow(
              'Total Amount',
              '₹${OrderCalculationService.calculateOrderTotal(order.orderItems, serviceItems: order.serviceItems).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            if (order.billId.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('${RouteConstants.bills}/${order.billId}'),
                  icon: const Icon(Icons.receipt),
                  label: const Text('View Bill'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: AppConfig.fontSizeMd, fontWeight: FontWeight.w500, color: AppConfig.textColorSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: AppConfig.fontSizeMd, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderViewModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items',
          style: TextStyle(fontSize: AppConfig.fontSizeXl, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...order.orderItems.map((item) => _buildOrderItemCard(item)),
        if (order.serviceItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Service Items',
            style: TextStyle(fontSize: AppConfig.fontSizeXl, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...order.serviceItems.map((svc) => _buildServiceItemCard(svc)),
        ],
      ],
    );
  }

  Widget _buildOrderItemCard(OrderItemViewModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display card image at the top for mobile
                      if (item.card != null && item.card!.image.isNotEmpty)
                        Container(margin: const EdgeInsets.only(bottom: 12), child: _buildCardImage(item.card!)),
                      // Item details below the image on mobile
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildItemInfoRow('Quantity', '${item.quantity}'),
                          _buildItemInfoRow('Price per Item', '₹${item.pricePerItem}'),
                          _buildItemInfoRow('Discount Amount', '₹${item.discountAmount}'),
                          _buildItemInfoRow('Line Total', '₹${OrderCalculationService.calculateItemTotal(item).toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildItemInfoRow('Quantity', '${item.quantity}'),
                            _buildItemInfoRow('Price per Item', '₹${item.pricePerItem}'),
                            _buildItemInfoRow('Discount Amount', '₹${item.discountAmount}'),
                            _buildItemInfoRow('Line Total', '₹${OrderCalculationService.calculateItemTotal(item).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      // Display card image on the right side for desktop
                      if (item.card != null && item.card!.image.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        _buildCardImage(item.card!),
                      ],
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
                      'Box Required',
                      style: TextStyle(fontSize: AppConfig.fontSizeSm, color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (item.requiresBox && item.requiresPrinting) const SizedBox(width: 8),
                if (item.requiresPrinting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      'Printing Required',
                      style: TextStyle(fontSize: AppConfig.fontSizeSm, color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            if (item.boxOrders != null && item.boxOrders!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildBoxOrders(item.boxOrders!),
            ],
            if (item.printingJobs != null && item.printingJobs!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPrintingJobs(item.printingJobs!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(OrderCardViewModel card) {
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
  }

  Widget _buildItemInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: TextStyle(fontSize: AppConfig.fontSizeMd, color: AppConfig.textColorSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: AppConfig.fontSizeMd, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxOrders(List<BoxOrderViewModel> boxOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Box Orders',
          style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        SizedBox(height: AppConfig.smallPadding),
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
                child: Text(
                  'Box Order',
                  style: TextStyle(fontSize: AppConfig.fontSizeMd, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: BoxStatusExtension.getColorFromString(box.boxStatus),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  BoxStatusExtension.getDisplayTextFromString(box.boxStatus),
                  style: TextStyle(color: Colors.white, fontSize: AppConfig.fontSizeXs, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showEditBoxOrderDialog(box),
                icon: Icon(Icons.edit, size: AppConfig.iconSizeSmall, color: Colors.blue),
                tooltip: 'Edit Box Order',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          SizedBox(height: AppConfig.smallPadding),
          _buildBoxInfoRow('Type', box.boxType.toString().split('.').last.toUpperCase()),
          _buildBoxInfoRow('Quantity', '${box.boxQuantity}'),
          _buildBoxInfoRow('Cost', '₹${box.totalBoxCost}'),
          _buildBoxInfoRow('Expense', box.totalBoxExpense == null ? 'Not added' : '₹${box.totalBoxExpense}'),
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
        Text(
          'Printing Jobs',
          style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        SizedBox(height: AppConfig.smallPadding),
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
                child: Text(
                  'Printing Job',
                  style: TextStyle(fontSize: AppConfig.fontSizeMd, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: PrintingStatusExtension.getColorFromString(job.printingStatus),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  PrintingStatusExtension.getDisplayTextFromString(job.printingStatus),
                  style: TextStyle(color: Colors.white, fontSize: AppConfig.fontSizeXs, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showEditPrintingJobDialog(job),
                icon: Icon(Icons.edit, size: AppConfig.iconSizeSmall, color: Colors.green),
                tooltip: 'Edit Printing Job',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          SizedBox(height: AppConfig.smallPadding),
          _buildPrintingInfoRow('Quantity', '${job.printQuantity}'),
          _buildPrintingInfoRow('Cost', '₹${job.totalPrintingCost}'),
          _buildPrintingInfoRow('Printing Expense', job.totalPrintingExpense == null ? 'Not added' : '₹${job.totalPrintingExpense}'),
          _buildPrintingInfoRow('Tracing Expense', job.totalTracingExpense == null ? 'Not added' : '₹${job.totalTracingExpense}'),
          if (job.printerId != null) _buildPrintingInfoRow('Printer', job.printerName ?? job.printerId!),
          if (job.tracingStudioId != null) _buildPrintingInfoRow('Tracing Studio', job.tracingStudioName ?? job.tracingStudioId!),
          if (job.estimatedCompletion != null) _buildPrintingInfoRow('Est. Completion', _formatDateTime(job.estimatedCompletion!)),
        ],
      ),
    );
  }

  Widget _buildBoxInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: AppConfig.fontSizeSm, color: AppConfig.textColorSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: AppConfig.fontSizeSm, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: AppConfig.fontSizeSm, color: AppConfig.textColorSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: AppConfig.fontSizeSm, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Using OrderStatusExtension.getDisplayTextFromString instead of local formatting method

  // Using BoxStatusExtension.getDisplayTextFromString instead of local formatting method

  // Using PrintingStatus enum instead of local formatting method

  // Using OrderStatusExtension.getColorFromString instead of local color mapping method

  // Using BoxStatusExtension.getColorFromString instead of local color mapping method

  // Using PrintingStatus.getColorFromString instead of local color mapping method

  // Using OrderCalculationService for all calculation methods

  Widget _buildServiceItemCard(ServiceItemViewModel svc) {
    final typeText = svc.serviceType?.displayText ?? svc.serviceTypeRaw;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    typeText,
                    style: TextStyle(fontSize: AppConfig.fontSizeLg, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'Qty: ${svc.quantity}',
                    style: TextStyle(fontSize: AppConfig.fontSizeSm, color: Colors.teal, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrintingInfoRow('Total Cost', '₹${svc.totalCost}'),
            if (svc.totalExpense != null) _buildPrintingInfoRow('Expense', '₹${svc.totalExpense}'),
            if (svc.description != null && svc.description!.isNotEmpty) _buildPrintingInfoRow('Description', svc.description!),
          ],
        ),
      ),
    );
  }

  void _showEditBoxOrderDialog(BoxOrderViewModel box) {
    showDialog(
      context: context,
      builder: (context) => BoxOrderEditDialog(
        boxOrderId: box.id,
        currentBoxMakerId: box.boxMakerId ?? '',
        currentTotalBoxCost: box.totalBoxCost,
        currentTotalBoxExpense: box.totalBoxExpense ?? '',
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
        currentTotalPrintingExpense: job.totalPrintingExpense ?? '',
        currentTotalTracingExpense: job.totalTracingExpense ?? '',
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
