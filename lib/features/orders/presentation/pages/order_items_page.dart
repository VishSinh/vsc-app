import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/models/card_model.dart' as card_model;
import 'package:vsc_app/core/models/order_model.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_provider.dart';

class OrderItemsPage extends StatefulWidget {
  const OrderItemsPage({super.key});

  @override
  State<OrderItemsPage> createState() => _OrderItemsPageState();
}

class _OrderItemsPageState extends State<OrderItemsPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  final _boxCostController = TextEditingController();
  final _printingCostController = TextEditingController();

  bool _requiresBox = false;
  bool _requiresPrinting = false;
  BoxType _selectedBoxType = BoxType.folding;

  @override
  void initState() {
    super.initState();
    // Clear order items but preserve selected customer when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      final selectedCustomer = orderProvider.selectedCustomer; // Preserve customer
      orderProvider.clearOrderItemsOnly(); // Only clear items, not customer
      print('🔍 OrderItemsPage: Cleared order items but preserved customer: ${selectedCustomer?.name}');
    });

    _quantityController.text = '1';
    _discountController.text = '0.00';
    _boxCostController.text = '0.00';
    _printingCostController.text = '0.00';
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _boxCostController.dispose();
    _printingCostController.dispose();
    super.dispose();
  }

  Future<void> _searchCard() async {
    if (!_formKey.currentState!.validate()) return;

    final orderProvider = context.read<OrderProvider>();
    await orderProvider.searchCardByBarcode(_barcodeController.text.trim());

    // Show error if any
    if (orderProvider.errorMessage != null) {
      SnackbarUtils.showError(context, orderProvider.errorMessage!);
    }
  }

  void _addOrderItem() {
    if (!_formKey.currentState!.validate()) return;

    final orderProvider = context.read<OrderProvider>();
    final currentCard = orderProvider.currentCard;

    if (currentCard == null) {
      SnackbarUtils.showError(context, 'Please search for a card first');
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity > currentCard.quantity) {
      SnackbarUtils.showError(context, 'Quantity exceeds available stock (${currentCard.quantity})');
      return;
    }

    print('🔍 OrderItemsPage: Adding item to order');
    print('🔍 OrderItemsPage: Current items count: ${orderProvider.orderItems.length}');

    orderProvider.addOrderItem(
      cardId: currentCard.id,
      discountAmount: _discountController.text,
      quantity: quantity,
      requiresBox: _requiresBox,
      requiresPrinting: _requiresPrinting,
      boxType: _requiresBox ? _selectedBoxType : null,
      totalBoxCost: _requiresBox ? _boxCostController.text : null,
      totalPrintingCost: _requiresPrinting ? _printingCostController.text : null,
    );

    // Show error if any
    if (orderProvider.errorMessage != null) {
      SnackbarUtils.showError(context, orderProvider.errorMessage!);
      return; // Don't clear form or show success message
    }

    print('🔍 OrderItemsPage: After adding item, count: ${orderProvider.orderItems.length}');

    // Clear form
    _barcodeController.clear();
    _quantityController.text = '1';
    _discountController.text = '0.00';
    _boxCostController.text = '0.00';
    _printingCostController.text = '0.00';
    _requiresBox = false;
    _requiresPrinting = false;
    _selectedBoxType = BoxType.folding;

    SnackbarUtils.showSuccess(context, 'Item added to order');
  }

  void _removeOrderItem(int index) {
    final orderProvider = context.read<OrderProvider>();
    orderProvider.removeOrderItem(index);
  }

  void _proceedToReview() {
    final orderProvider = context.read<OrderProvider>();
    if (orderProvider.orderItems.isEmpty) {
      SnackbarUtils.showError(context, 'Please add at least one item to the order');
      return;
    }
    context.go(RouteConstants.orderReview);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UITextConstants.orderCreationTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RouteConstants.customerSearch)),
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
          _buildCustomerCard(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildSearchForm(orderProvider),
          if (orderProvider.currentCard != null) ...[SizedBox(height: AppConfig.largePadding), _buildCardDetails(orderProvider.currentCard!)],
          SizedBox(height: AppConfig.largePadding),
          _buildOrderItemsList(orderProvider),
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
          // Top row: Customer Card and Search Card side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 150, // Fixed height for customer card
                  child: _buildCustomerCard(orderProvider),
                ),
              ),
              SizedBox(width: AppConfig.largePadding),
              Expanded(flex: 1, child: _buildSearchForm(orderProvider)),
            ],
          ),
          if (orderProvider.currentCard != null) ...[SizedBox(height: AppConfig.largePadding), _buildCardDetails(orderProvider.currentCard!)],
          SizedBox(height: AppConfig.largePadding),
          // Bottom section: Order Items taking full width
          _buildOrderItemsList(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildActionButtons(orderProvider),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents expansion issues
          children: [
            // Row(),
            Text('Customer', style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.smallPadding, width: double.infinity),
            if (orderProvider.selectedCustomer != null) ...[
              Text('Name: ${orderProvider.selectedCustomer!.name}'),
              Text('Phone: ${orderProvider.selectedCustomer!.phone}'),
            ] else ...[
              Text('No customer selected', style: ResponsiveText.getBody(context).copyWith(color: AppConfig.grey400)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm(OrderProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: UITextConstants.barcode,
                  hintText: UITextConstants.barcodeHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return UITextConstants.pleaseEnterBarcode;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppConfig.defaultPadding),
              ButtonUtils.primaryButton(onPressed: orderProvider.isLoading ? null : _searchCard, label: 'Search Card', icon: Icons.search),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDetails(card_model.Card card) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: AppConfig.primaryColor, size: 20),
                SizedBox(width: AppConfig.smallPadding),
                Expanded(
                  child: Text('Card Details', style: ResponsiveText.getTitle(context).copyWith(color: AppConfig.primaryColor)),
                ),
                IconButton(
                  onPressed: () {
                    final orderProvider = context.read<OrderProvider>();
                    orderProvider.clearCurrentCard();
                  },
                  icon: Icon(Icons.close, color: AppConfig.errorColor),
                  tooltip: 'Discard Card',
                ),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),
            if (context.isMobile) ...[
              // Mobile: Stacked layout
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Image - Full width on mobile
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                    child: Image.network(
                      card.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
                          child: Icon(Icons.image, color: AppConfig.grey600),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppConfig.defaultPadding),
                  // Card Information
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildInfoRow('Barcode', card.barcode, Icons.qr_code)),
                          SizedBox(width: AppConfig.defaultPadding),
                          Expanded(child: _buildInfoRow('Price', '₹${card.sellPrice}', Icons.attach_money)),
                        ],
                      ),
                      SizedBox(height: AppConfig.smallPadding),
                      Row(
                        children: [
                          Expanded(child: _buildInfoRow('Stock', '${card.quantity} units', Icons.inventory)),
                          SizedBox(width: AppConfig.defaultPadding),
                          Expanded(child: _buildInfoRow('Max Discount', '₹${card.maxDiscount}', Icons.discount)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppConfig.defaultPadding),
                  // Item Details Form for Mobile
                  _buildItemForm(),
                  SizedBox(height: AppConfig.defaultPadding),
                  ButtonUtils.successButton(onPressed: _addOrderItem, label: UITextConstants.addOrderItem, icon: Icons.add),
                ],
              ),
            ] else ...[
              // Desktop: Side by side layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Image and card info
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConfig.smallRadius),
                          child: Image.network(
                            card.image,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 300,
                                decoration: BoxDecoration(color: AppConfig.grey300, borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
                                child: Icon(Icons.image, color: AppConfig.grey600),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: AppConfig.defaultPadding),
                        // Card Info below image
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow('Price', '₹${card.sellPrice}', Icons.attach_money)),
                            SizedBox(width: AppConfig.defaultPadding),
                            Expanded(child: _buildInfoRow('Stock', '${card.quantity} units', Icons.inventory)),
                            SizedBox(width: AppConfig.defaultPadding),
                            Expanded(child: _buildInfoRow('Max Discount', '₹${card.maxDiscount}', Icons.discount)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppConfig.largePadding),
                  // Right side: Item details
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item Details', style: ResponsiveText.getTitle(context)),
                        SizedBox(height: AppConfig.defaultPadding),
                        _buildItemForm(),
                        SizedBox(height: AppConfig.defaultPadding),
                        ButtonUtils.successButton(onPressed: _addOrderItem, label: UITextConstants.addOrderItem, icon: Icons.add),
                      ],
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppConfig.grey600),
            SizedBox(width: 4),
            Text(label, style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.grey600)),
          ],
        ),
        SizedBox(height: 2),
        Text(value, style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLineItemInfo(String label, String value, IconData icon, {bool isTotal = false, bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: isTotal ? AppConfig.primaryColor : AppConfig.grey600),
              SizedBox(width: 4),
              Text(
                label,
                style: ResponsiveText.getCaption(
                  context,
                ).copyWith(color: isTotal ? AppConfig.primaryColor : AppConfig.grey600, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: ResponsiveText.getBody(
              context,
            ).copyWith(fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isTotal ? AppConfig.primaryColor : null),
          ),
        ],
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

  Widget _buildItemForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item Details', style: ResponsiveText.getTitle(context)),
        SizedBox(height: AppConfig.defaultPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: UITextConstants.quantity, border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return UITextConstants.pleaseEnterValidQuantity;
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return UITextConstants.pleaseEnterValidQuantity;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _discountController,
                decoration: InputDecoration(labelText: UITextConstants.discountAmount, border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return UITextConstants.pleaseEnterDiscountAmount;
                  }
                  final discount = double.tryParse(value);
                  if (discount == null || discount < 0) {
                    return UITextConstants.pleaseEnterValidDiscount;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppConfig.defaultPadding),
        CheckboxListTile(
          title: Text(UITextConstants.requiresBox),
          value: _requiresBox,
          onChanged: (value) {
            setState(() {
              _requiresBox = value ?? false;
            });
          },
        ),
        if (_requiresBox) ...[
          DropdownButtonFormField<BoxType>(
            value: _selectedBoxType,
            decoration: InputDecoration(labelText: UITextConstants.boxType, border: const OutlineInputBorder()),
            items: BoxType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBoxType = value ?? BoxType.folding;
              });
            },
          ),
          SizedBox(height: AppConfig.defaultPadding),
          TextFormField(
            controller: _boxCostController,
            decoration: InputDecoration(
              labelText: UITextConstants.boxCost,
              hintText: UITextConstants.boxCostHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
        CheckboxListTile(
          title: Text(UITextConstants.requiresPrinting),
          value: _requiresPrinting,
          onChanged: (value) {
            setState(() {
              _requiresPrinting = value ?? false;
            });
          },
        ),
        if (_requiresPrinting) ...[
          SizedBox(height: AppConfig.defaultPadding),
          TextFormField(
            controller: _printingCostController,
            decoration: InputDecoration(
              labelText: UITextConstants.printingCost,
              hintText: UITextConstants.printingCostHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }

  Widget _buildOrderItemsList(OrderProvider orderProvider) {
    print('🔍 OrderItemsPage: Building order items list, count: ${orderProvider.orderItems.length}');

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
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderProvider.orderItems.length,
                itemBuilder: (context, index) {
                  final item = orderProvider.orderItems[index];
                  final card = orderProvider.getCardById(item.cardId);

                  if (card == null) {
                    return ListTile(
                      title: Text('Item ${index + 1} - Card not found'),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeOrderItem(index)),
                    );
                  }

                  // Calculate line item total
                  final basePrice = card.sellPriceAsDouble;
                  final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
                  final quantity = item.quantity;
                  final boxCost = item.requiresBox ? (double.tryParse(item.totalBoxCost ?? '0') ?? 0.0) : 0.0;
                  final printingCost = item.requiresPrinting ? (double.tryParse(item.totalPrintingCost ?? '0') ?? 0.0) : 0.0;

                  final lineItemTotal = ((basePrice - discountAmount) * quantity) + boxCost + printingCost;

                  print('🔍 OrderItemsPage: Building item $index: ${item.quantity}');
                  return Card(
                    margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                    child: Padding(
                      padding: EdgeInsets.all(AppConfig.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with delete button
                          Row(
                            children: [
                              Expanded(
                                child: Text('Item ${index + 1}', style: ResponsiveText.getSubtitle(context).copyWith(fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppConfig.errorColor),
                                onPressed: () => _removeOrderItem(index),
                              ),
                            ],
                          ),
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

  Widget _buildActionButtons(OrderProvider orderProvider) {
    return Row(
      children: [
        Expanded(
          child: ButtonUtils.secondaryButton(
            onPressed: () => context.go(RouteConstants.customerSearch),
            label: UITextConstants.back,
            icon: Icons.arrow_back,
          ),
        ),
        SizedBox(width: AppConfig.defaultPadding),
        Expanded(
          child: ButtonUtils.primaryButton(
            onPressed: orderProvider.orderItems.isNotEmpty ? _proceedToReview : null,
            label: UITextConstants.reviewOrder,
            icon: Icons.arrow_forward,
          ),
        ),
      ],
    );
  }
}
