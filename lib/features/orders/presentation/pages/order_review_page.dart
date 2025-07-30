import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
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
      SnackbarUtils.showError(context, 'Please select delivery date and time');
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.createOrder();

    print('Sucess - $success, mounted - $mounted');

    if (success && mounted) {
      SnackbarUtils.showSuccess(context, UITextConstants.orderCreatedSuccessfully);
      context.go(RouteConstants.orders);
    }
    print("Shoudl not reach");
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

  Widget _buildMobileLayout(OrderProvider orderProvider) {
    print('🔍 OrderReviewPage: Building mobile layout');
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  Widget _buildDesktopLayout(OrderProvider orderProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConfig.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  Widget _buildHeader(OrderProvider orderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(UITextConstants.orderReviewTitle, style: ResponsiveText.getHeadline(context).copyWith(color: AppConfig.primaryColor)),
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
            Text('Customer Information', style: ResponsiveText.getTitle(context)),
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
            Text(UITextConstants.deliveryDate, style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),
            // Mobile-friendly layout
            if (context.isMobile) ...[
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_selectedDate?.toString().split(' ')[0] ?? 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              ListTile(
                title: const Text('Time'),
                subtitle: Text(_selectedTime?.format(context) ?? 'Not selected'),
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
                  final item = orderProvider.orderItems[index];
                  final card = orderProvider.getCardById(item.cardId);

                  if (card == null) {
                    return Card(
                      margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                      child: Padding(padding: EdgeInsets.all(AppConfig.defaultPadding), child: Text('Item ${index + 1} - Card not found')),
                    );
                  }

                  // Calculate line item total
                  final basePrice = card.sellPriceAsDouble;
                  final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
                  final quantity = item.quantity;
                  final boxCost = item.requiresBox ? (double.tryParse(item.totalBoxCost ?? '0') ?? 0.0) : 0.0;
                  final printingCost = item.requiresPrinting ? (double.tryParse(item.totalPrintingCost ?? '0') ?? 0.0) : 0.0;

                  final lineItemTotal = ((basePrice - discountAmount) * quantity) + boxCost + printingCost;

                  return Card(
                    margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                    child: Padding(
                      padding: EdgeInsets.all(AppConfig.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text('Item ${index + 1}', style: ResponsiveText.getSubtitle(context).copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: AppConfig.defaultPadding),

                          if (context.isMobile) ...[
                            // Mobile: Compact layout
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                                  child: Image.network(
                                    card.image,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppConfig.grey300,
                                          borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                                        ),
                                        child: Icon(Icons.image, color: AppConfig.grey600),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: AppConfig.defaultPadding),
                                // Basic Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Price: ₹${card.sellPrice}', style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600)),
                                      Text('Quantity: ${quantity}', style: ResponsiveText.getBody(context)),
                                      Text('Discount: ₹${discountAmount.toStringAsFixed(2)}', style: ResponsiveText.getBody(context)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppConfig.defaultPadding),

                            // Additional Details (only show if relevant)
                            if (item.requiresBox || item.requiresPrinting) ...[
                              Row(
                                children: [
                                  if (item.requiresBox) ...[
                                    Expanded(child: Text('Box: ₹${boxCost.toStringAsFixed(2)}', style: ResponsiveText.getBody(context))),
                                  ],
                                  if (item.requiresPrinting) ...[
                                    Expanded(child: Text('Printing: ₹${printingCost.toStringAsFixed(2)}', style: ResponsiveText.getBody(context))),
                                  ],
                                ],
                              ),
                              SizedBox(height: AppConfig.smallPadding),
                            ],
                          ] else ...[
                            // Desktop: Modern card layout
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card Image - Larger and more prominent
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                                  child: Image.network(
                                    card.image,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: AppConfig.grey300,
                                          borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                                        ),
                                        child: Icon(Icons.image, color: AppConfig.grey600, size: 40),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: AppConfig.largePadding),
                                // Modern info layout
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Primary info row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDesktopInfoRow('Price', '₹${card.sellPrice}', Icons.attach_money, AppConfig.primaryColor),
                                          ),
                                          SizedBox(width: AppConfig.defaultPadding),
                                          Expanded(
                                            child: _buildDesktopInfoRow('Quantity', '${quantity}', Icons.shopping_cart, AppConfig.successColor),
                                          ),
                                          SizedBox(width: AppConfig.defaultPadding),
                                          Expanded(
                                            child: _buildDesktopInfoRow(
                                              'Discount',
                                              '₹${discountAmount.toStringAsFixed(2)}',
                                              Icons.discount,
                                              AppConfig.warningColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppConfig.defaultPadding),
                                      // Secondary info row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDesktopInfoRow('Stock', '${card.quantity} units', Icons.inventory, AppConfig.grey600),
                                          ),
                                          SizedBox(width: AppConfig.defaultPadding),
                                          Expanded(
                                            child: _buildDesktopInfoRow(
                                              'Box',
                                              item.requiresBox
                                                  ? 'Yes - ${item.boxType?.name.toUpperCase() ?? 'N/A'} - ₹${boxCost.toStringAsFixed(2)}'
                                                  : 'No',
                                              Icons.inventory_2,
                                              item.requiresBox ? AppConfig.successColor : AppConfig.grey600,
                                            ),
                                          ),
                                          SizedBox(width: AppConfig.defaultPadding),
                                          Expanded(
                                            child: _buildDesktopInfoRow(
                                              'Printing',
                                              item.requiresPrinting ? 'Yes - ₹${printingCost.toStringAsFixed(2)}' : 'No',
                                              Icons.print,
                                              item.requiresPrinting ? AppConfig.successColor : AppConfig.grey600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppConfig.defaultPadding),
                                      // Total row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDesktopInfoRow(
                                              'Total',
                                              '₹${lineItemTotal.toStringAsFixed(2)}',
                                              Icons.calculate,
                                              AppConfig.primaryColor,
                                              isTotal: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Line Total for mobile only (desktop has it in the grid)
                          if (context.isMobile) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(AppConfig.smallPadding),
                              decoration: BoxDecoration(
                                color: AppConfig.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calculate, color: AppConfig.primaryColor, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Line Total: ₹${lineItemTotal.toStringAsFixed(2)}',
                                    style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  // Widget _buildDesktopInfoRow(String label, String value, IconData icon, {bool isTotal = false}) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Icon(icon, size: 16, color: isTotal ? AppConfig.primaryColor : AppConfig.grey600),
  //           SizedBox(width: 4),
  //           Text(
  //             label,
  //             style: ResponsiveText.getCaption(
  //               context,
  //             ).copyWith(color: isTotal ? AppConfig.primaryColor : AppConfig.grey600, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 4),
  //       Text(
  //         value,
  //         style: ResponsiveText.getBody(
  //           context,
  //         ).copyWith(fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isTotal ? AppConfig.primaryColor : null),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDesktopInfoRow(String label, String value, IconData icon, Color color, {bool isTotal = false}) {
    return Container(
      padding: EdgeInsets.all(AppConfig.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.smallRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                label,
                style: ResponsiveText.getCaption(context).copyWith(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: ResponsiveText.getBody(context).copyWith(fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderProvider orderProvider) {
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
