import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import '../widgets/order_widgets.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_create_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

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
    // Set default delivery date to tomorrow
    final orderProvider = context.read<OrderCreateProvider>();
    orderProvider.setDefaultDeliveryDateTime();
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

    orderProvider.setOrderName(_orderNameController.text);

    orderProvider.setContext(context);
    final success = await orderProvider.createOrder();

    if (success && mounted) context.go(RouteConstants.dashboard); // Redirect to dashboard after successful order creation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UITextConstants.orderReviewTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.orderItems)),
      ),
      body: Consumer<OrderCreateProvider>(
        builder: (context, orderProvider, child) {
          // Check if customer and order items exist, if not redirect to order items
          if (orderProvider.selectedCustomer == null || orderProvider.orderItems.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(RouteConstants.orderItems);
            });
            return const Center(child: CircularProgressIndicator());
          }

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

  Widget _buildActionButtons(OrderCreateProvider orderProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ButtonUtils.secondaryButton(
                onPressed: () => context.go(RouteConstants.orderItems),
                label: UITextConstants.back,
                icon: Icons.arrow_back,
              ),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: ButtonUtils.primaryButton(
                onPressed: orderProvider.isLoading ? null : _submitOrder,
                label: UITextConstants.submitOrder,
                icon: Icons.check,
              ),
            ),
          ],
        ),
        if (orderProvider.isLoading) ...[SizedBox(height: AppConfig.defaultPadding), LoadingWidget(message: 'Creating order...')],
      ],
    );
  }
}
