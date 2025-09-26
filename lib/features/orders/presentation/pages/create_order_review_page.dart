import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import '../widgets/order_widgets.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_create_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/orders/presentation/services/order_calculation_service.dart';
import 'package:vsc_app/core/enums/service_type.dart';

class CreateOrderReviewPage extends StatefulWidget {
  const CreateOrderReviewPage({super.key});

  @override
  State<CreateOrderReviewPage> createState() => _CreateOrderReviewPageState();
}

class _CreateOrderReviewPageState extends State<CreateOrderReviewPage> {
  final TextEditingController _orderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default delivery date after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderCreateProvider>();
      orderProvider.setDefaultDeliveryDateTime();
    });
  }

  @override
  void dispose() {
    _orderNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final orderProvider = context.read<OrderCreateProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: orderProvider.selectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != orderProvider.selectedDeliveryDate) {
      orderProvider.setDeliveryDate(picked);
    }
  }

  Future<void> _selectTime() async {
    final orderProvider = context.read<OrderCreateProvider>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: orderProvider.selectedDeliveryTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null && picked != orderProvider.selectedDeliveryTime) {
      orderProvider.setDeliveryTime(picked);
    }
  }

  void _updateOrderName() {
    final orderProvider = context.read<OrderCreateProvider>();
    orderProvider.setOrderName(_orderNameController.text);
  }

  Future<void> _submitOrder() async {
    final orderProvider = context.read<OrderCreateProvider>();
    print('Order name: ${_orderNameController.text}');

    // Check if order name is provided
    // if (_orderNameController.text.trim().isEmpty) {
    //   orderProvider.setErrorWithSnackBar('Please enter an order name', context);
    //   return;
    // }

    orderProvider.setOrderName(_orderNameController.text);
    orderProvider.setContext(context);
    print('Order name: ${orderProvider.orderName}');

    // The loading state will be handled by the provider's isLoading flag
    final billId = await orderProvider.createOrder();

    if (billId.isNotEmpty && mounted) {
      // Navigate to bill detail with fromOrderCreation flag set to true
      final billPath = RouteConstants.billDetail.replaceAll(':id', billId);
      context.go(billPath, extra: {'fromOrderCreation': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UITextConstants.orderReviewTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Consumer<OrderCreateProvider>(
        builder: (context, orderProvider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < AppConfig.mobileBreakpoint) {
                return _buildMobileLayout(orderProvider);
              } else {
                return _buildDesktopLayout(orderProvider);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(OrderCreateProvider orderProvider) {
    AppLogger.debug('OrderReviewPage: Building mobile layout');
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Name field
          _buildOrderNameSection(),
          SizedBox(height: AppConfig.defaultPadding),
          // Customer Info and Delivery Date stacked on mobile
          _buildCustomerInfo(orderProvider),
          SizedBox(height: AppConfig.defaultPadding),
          _buildDeliveryDateSection(),
          SizedBox(height: AppConfig.largePadding),
          // Order Items taking full width
          _buildOrderItemsReview(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildServiceItemsReview(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildActionButtons(orderProvider),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(OrderCreateProvider orderProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Name field taking full width
          _buildOrderNameSection(),
          SizedBox(height: AppConfig.largePadding),
          // Customer Info and Delivery Date in same row
          Row(
            children: [
              Expanded(child: _buildCustomerInfo(orderProvider)),
              SizedBox(width: AppConfig.largePadding),
              Expanded(child: _buildDeliveryDateSection()),
            ],
          ),
          SizedBox(height: AppConfig.largePadding),
          // Order Items taking full width
          _buildOrderItemsReview(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildServiceItemsReview(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildActionButtons(orderProvider),
        ],
      ),
    );
  }

  Widget _buildOrderNameSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Name', style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),
            TextField(
              controller: _orderNameController,
              decoration: const InputDecoration(labelText: 'Enter order name', hintText: 'e.g., John weds Jane', border: OutlineInputBorder()),
              onChanged: (value) => _updateOrderName(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(OrderCreateProvider orderProvider) {
    if (orderProvider.selectedCustomer == null) return const SizedBox.shrink();

    return CustomerInfoCard(customer: orderProvider.selectedCustomer, title: 'Customer Information');
  }

  Widget _buildDeliveryDateSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(UITextConstants.deliveryDate, style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),
            // Mobile-friendly layout
            if (context.isMobile) ...[
              ListTile(
                title: const Text('Date'),
                subtitle: Text(context.read<OrderCreateProvider>().selectedDeliveryDate?.toString().split(' ')[0] ?? 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              ListTile(
                title: const Text('Time'),
                subtitle: Text(context.read<OrderCreateProvider>().selectedDeliveryTime?.format(context) ?? 'Not selected'),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),
            ] else ...[
              // Desktop layout with side-by-side
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Date'),
                      subtitle: Text(context.read<OrderCreateProvider>().selectedDeliveryDate?.toString().split(' ')[0] ?? 'Not selected'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Time'),
                      subtitle: Text(context.read<OrderCreateProvider>().selectedDeliveryTime?.format(context) ?? 'Not selected'),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsReview(OrderCreateProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Items (${orderProvider.orderItems.length})', style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),
            if (orderProvider.orderItems.isEmpty)
              const EmptyStateWidget(message: UITextConstants.noOrderItems, icon: Icons.shopping_cart_outlined)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderProvider.orderItems.length,
                itemBuilder: (context, index) {
                  final formItem = orderProvider.orderItems[index];
                  final card = orderProvider.getCardViewModelById(formItem.cardId);

                  if (card == null) {
                    return Card(
                      margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                      child: Padding(padding: EdgeInsets.all(AppConfig.defaultPadding), child: Text('Item ${index + 1} - Card not found')),
                    );
                  }

                  return OrderItemCard(item: formItem, card: card, index: index, showRemoveButton: false, isReviewMode: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItemsReview(OrderCreateProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Items (${orderProvider.serviceItems.length})', style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),
            if (orderProvider.serviceItems.isEmpty)
              const EmptyStateWidget(message: 'No service items added', icon: Icons.home_repair_service)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderProvider.serviceItems.length,
                itemBuilder: (context, index) {
                  final svc = orderProvider.serviceItems[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                    child: Padding(
                      padding: EdgeInsets.all(AppConfig.defaultPadding),
                      child: Row(
                        children: [
                          const Icon(Icons.home_repair_service),
                          SizedBox(width: AppConfig.defaultPadding),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  svc.serviceType?.displayText ?? svc.serviceType?.toApiString() ?? 'SERVICE',
                                  style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text('Qty: ${svc.quantity}  •  Expense: ₹${svc.totalExpense}  •  Cost: ₹${svc.totalCost}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: AppConfig.defaultPadding),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: ₹${_calculateCreationReviewTotal(orderProvider).toStringAsFixed(2)}',
                    style: ResponsiveText.getTitle(context).copyWith(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateCreationReviewTotal(OrderCreateProvider orderProvider) {
    double total = 0.0;

    // Sum card-based order items using current card price
    for (final formItem in orderProvider.orderItems) {
      final card = orderProvider.getCardViewModelById(formItem.cardId);
      if (card == null) continue;
      total += OrderCalculationService.calculateLineItemTotalWithParams(
        basePrice: card.sellPriceAsDouble,
        discountAmount: formItem.discountAmount,
        quantity: formItem.quantity,
        totalBoxCost: formItem.requiresBox ? formItem.totalBoxCost : null,
        totalPrintingCost: formItem.requiresPrinting ? formItem.totalPrintingCost : null,
      );
    }

    // Add service items total cost
    for (final svc in orderProvider.serviceItems) {
      final cost = OrderCalculationService.parseDouble(svc.totalCost);
      total += cost;
    }

    return total;
  }

  Widget _buildActionButtons(OrderCreateProvider orderProvider) {
    return Column(
      children: [
        // Show a more prominent loading indicator at the top when loading
        if (orderProvider.isLoading)
          Padding(
            padding: EdgeInsets.only(bottom: AppConfig.defaultPadding),
            child: LoadingWidget(message: 'Creating order...'),
          ),
        Row(
          children: [
            Expanded(
              child: ButtonUtils.secondaryButton(
                onPressed: orderProvider.isLoading ? null : () => context.go(RouteConstants.orderItems),
                label: UITextConstants.back,
                icon: Icons.arrow_back,
              ),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: ButtonUtils.primaryButton(
                onPressed: orderProvider.isLoading ? null : _submitOrder,
                label: orderProvider.isLoading ? 'Processing...' : UITextConstants.submitOrder,
                icon: orderProvider.isLoading ? Icons.hourglass_top : Icons.check,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
