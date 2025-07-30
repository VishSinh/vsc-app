import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_provider.dart';

class OrderReviewPage extends StatefulWidget {
  const OrderReviewPage({super.key});

  @override
  State<OrderReviewPage> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Set default delivery date to tomorrow
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateDeliveryDate();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0));
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _updateDeliveryDate();
    }
  }

  void _updateDeliveryDate() {
    if (_selectedDate != null && _selectedTime != null) {
      final orderProvider = context.read<OrderProvider>();
      final deliveryDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      orderProvider.setDeliveryDate(deliveryDateTime.toIso8601String());
    }
  }

  Future<void> _submitOrder() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select delivery date and time'), backgroundColor: AppConfig.errorColor));
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.createOrder();

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(UITextConstants.orderCreatedSuccessfully), backgroundColor: AppConfig.successColor));
      context.go(RouteConstants.orders);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UITextConstants.orderReviewTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.orderItems)),
      ),
      body: Consumer<OrderProvider>(
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

  Widget _buildMobileLayout(OrderProvider orderProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildCustomerInfo(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildDeliveryDateSection(),
          SizedBox(height: AppConfig.largePadding),
          _buildOrderItemsReview(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildActionButtons(orderProvider),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(OrderProvider orderProvider) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConfig.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(orderProvider),
                SizedBox(height: AppConfig.largePadding),
                _buildCustomerInfo(orderProvider),
                SizedBox(height: AppConfig.largePadding),
                _buildDeliveryDateSection(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConfig.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItemsReview(orderProvider),
                SizedBox(height: AppConfig.largePadding),
                _buildActionButtons(orderProvider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(OrderProvider orderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(UITextConstants.orderReviewTitle, style: AppConfig.headlineStyle.copyWith(color: AppConfig.primaryColor)),
        SizedBox(height: AppConfig.smallPadding),
        Text(UITextConstants.orderReviewSubtitle, style: AppConfig.subtitleStyle),
      ],
    );
  }

  Widget _buildCustomerInfo(OrderProvider orderProvider) {
    if (orderProvider.selectedCustomer == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Information', style: AppConfig.titleStyle),
            SizedBox(height: AppConfig.smallPadding),
            Text('Name: ${orderProvider.selectedCustomer!.name}'),
            Text('Phone: ${orderProvider.selectedCustomer!.phone}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDateSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(UITextConstants.deliveryDate, style: AppConfig.titleStyle),
            SizedBox(height: AppConfig.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Date'),
                    subtitle: Text(_selectedDate?.toString().split(' ')[0] ?? 'Not selected'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Time'),
                    subtitle: Text(_selectedTime?.format(context) ?? 'Not selected'),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsReview(OrderProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Items (${orderProvider.orderItems.length})', style: AppConfig.titleStyle),
            SizedBox(height: AppConfig.defaultPadding),
            if (orderProvider.orderItems.isEmpty)
              const EmptyStateWidget(message: UITextConstants.noOrderItems, icon: Icons.shopping_cart_outlined)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderProvider.orderItems.length,
                itemBuilder: (context, index) {
                  final item = orderProvider.orderItems[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                    child: Padding(
                      padding: EdgeInsets.all(AppConfig.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Item ${index + 1}', style: AppConfig.titleStyle),
                          SizedBox(height: AppConfig.smallPadding),
                          Text('Quantity: ${item.quantity}'),
                          Text('Discount: ₹${item.discountAmount}'),
                          if (item.requiresBox) ...[
                            Text('Box Type: ${item.boxType?.name.toUpperCase()}'),
                            Text('Box Cost: ₹${item.totalBoxCost ?? '0.00'}'),
                          ],
                          if (item.requiresPrinting) ...[Text('Printing Cost: ₹${item.totalPrintingCost ?? '0.00'}')],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderProvider orderProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ButtonUtils.secondaryButton(onPressed: () => context.go(RouteConstants.orderItems), label: 'Back', icon: Icons.arrow_back),
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
