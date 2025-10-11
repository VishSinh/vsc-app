import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/orders/presentation/models/order_item_form_model.dart';
import '../widgets/order_widgets.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:vsc_app/features/orders/presentation/providers/order_create_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/core/enums/service_type.dart';
import 'package:vsc_app/features/orders/presentation/models/service_item_form_model.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _barcodeController = TextEditingController();

  // Add a variable to track the last scanned barcode and time
  String? _lastScannedBarcode;
  DateTime? _lastScanTime;
  bool _showServiceForm = false;

  // Persistent Service Item form state
  ServiceType? _serviceType;
  final TextEditingController _svcQtyController = TextEditingController();
  final TextEditingController _svcCostController = TextEditingController();
  final TextEditingController _svcExpenseController = TextEditingController();
  final TextEditingController _svcDescController = TextEditingController();

  // Scrolling and focus helpers
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderCreateProvider>();
      orderProvider.clearOrderItemsOnly();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _svcQtyController.dispose();
    _svcCostController.dispose();
    _svcExpenseController.dispose();
    _svcDescController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _searchCard() {
    final orderProvider = context.read<OrderCreateProvider>();
    orderProvider.setContext(context);
    Future.microtask(() async {
      await orderProvider.searchCardByBarcode(_barcodeController.text.trim());
    });
  }

  void _removeOrderItem(int index) {
    final orderProvider = context.read<OrderCreateProvider>();
    orderProvider.removeOrderItem(index);
  }

  void _proceedToReview() {
    final orderProvider = context.read<OrderCreateProvider>();
    if (orderProvider.orderItems.isEmpty && orderProvider.serviceItems.isEmpty) {
      orderProvider.setErrorWithSnackBar('Please add at least one order item or service item', context);
      return;
    }
    context.push(RouteConstants.orderReview, extra: orderProvider);
  }

  void _handleAddOrderItem(OrderItemCreationFormModel item) {
    final orderProvider = context.read<OrderCreateProvider>();
    final currentCard = orderProvider.currentCardViewModel;
    if (currentCard == null) {
      orderProvider.setErrorWithSnackBar('Please search for a card first', context);
      return;
    }

    item.cardId = currentCard.id;

    // Validate item before adding to order list
    final validation = item.validate();
    if (!validation.isValid) {
      orderProvider.setErrorWithSnackBar(validation.firstMessage ?? 'Please check item details', context);
      return;
    }

    // Enforce discount amount not exceeding the card's max discount (flat amount per unit)
    final double maxAllowedDiscountPerUnit = currentCard.maxDiscountAsDouble;
    final double enteredDiscountPerUnit = double.tryParse(item.discountAmount) ?? -1;
    if (enteredDiscountPerUnit.isNaN || enteredDiscountPerUnit < 0) {
      orderProvider.setErrorWithSnackBar(UITextConstants.pleaseEnterValidDiscount, context);
      return;
    }
    if (enteredDiscountPerUnit > maxAllowedDiscountPerUnit) {
      orderProvider.setErrorWithSnackBar('Discount per item cannot exceed ₹${maxAllowedDiscountPerUnit.toStringAsFixed(2)}', context);
      return;
    }

    // Enforce stock constraint
    if (item.quantity > currentCard.quantity) {
      orderProvider.setErrorWithSnackBar('Quantity cannot exceed available stock (${currentCard.quantity})', context);
      return;
    }

    orderProvider.addOrderItem(item);
    orderProvider.setSuccessWithSnackBar('Item added to order', context);
    // After adding, clear the selected card so details are hidden
    orderProvider.clearCurrentCard();
    _barcodeController.clear();
    _scrollToReviewButton();
  }

  void _handleAddServiceItem(ServiceItemCreationFormModel item) {
    final orderProvider = context.read<OrderCreateProvider>();

    // Validate service item
    final validation = item.validate();
    if (!validation.isValid) {
      orderProvider.setErrorWithSnackBar(validation.firstMessage ?? 'Please check service item details', context);
      return;
    }

    orderProvider.addServiceItem(item);
    orderProvider.setSuccessWithSnackBar('Service item added to order', context);
    // Hide form and scroll to the review button
    setState(() => _showServiceForm = false);
    _scrollToReviewButton();
  }

  void _showBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan Barcode'),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String barcode = barcodes.first.rawValue ?? '';
                if (barcode.isNotEmpty) {
                  // Debounce logic: prevent multiple scans of the same barcode within 2 seconds
                  final now = DateTime.now();
                  if (_lastScannedBarcode == barcode && _lastScanTime != null && now.difference(_lastScanTime!).inSeconds < 2) {
                    // Skip this scan - it's a duplicate within the debounce period
                    return;
                  }

                  // Update the last scanned barcode and time
                  _lastScannedBarcode = barcode;
                  _lastScanTime = now;

                  AppLogger.info('Barcode scanned: $barcode', category: 'BARCODE_SCAN');
                  _barcodeController.text = barcode;
                  Navigator.of(context).pop();

                  // Automatically search for the card after scanning
                  // Use microtask to avoid context issues
                  Future.microtask(() {
                    if (mounted) {
                      _searchCard();
                    }
                  });
                }
              }
            },
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Camera Error', style: ResponsiveText.getTitle(context)),
                    const SizedBox(height: 8),
                    Text(error.errorDetails?.message ?? 'Unknown error occurred'),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Go Back')),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _scrollToReviewButton() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _reviewButtonKey.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          alignment: 1.0,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      } else if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UITextConstants.orderCreationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<OrderCreateProvider>().clearCurrentCard();
            context.pop();
          },
        ),
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
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerCard(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildSearchForm(orderProvider),
          if (orderProvider.currentCardViewModel != null) ...[
            SizedBox(height: AppConfig.largePadding),
            _buildCardDetails(orderProvider.currentCardViewModel!),
          ],
          SizedBox(height: AppConfig.largePadding),
          _buildOrderItemsList(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildServiceItemsSection(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildActionButtons(orderProvider),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(OrderCreateProvider orderProvider) {
    return SingleChildScrollView(
      controller: _scrollController,
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
                  height: AppConfig.cardHeightMedium, // Fixed height for customer card
                  child: _buildCustomerCard(orderProvider),
                ),
              ),
              SizedBox(width: AppConfig.largePadding),
              Expanded(flex: 1, child: _buildSearchForm(orderProvider)),
            ],
          ),
          if (orderProvider.currentCardViewModel != null) ...[
            SizedBox(height: AppConfig.largePadding),
            _buildCardDetails(orderProvider.currentCardViewModel!),
          ],
          SizedBox(height: AppConfig.largePadding),
          // Bottom section: Order Items taking full width
          _buildOrderItemsList(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildServiceItemsSection(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildActionButtons(orderProvider),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderCreateProvider orderProvider) {
    return CustomerInfoCard(customer: orderProvider.selectedCustomer);
  }

  Widget _buildSearchForm(OrderCreateProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: UITextConstants.barcode,
                      hintText: UITextConstants.barcodeHint,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () => _showBarcodeScanner(),
                        tooltip: 'Scan Barcode',
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return UITextConstants.pleaseEnterBarcode;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: ButtonUtils.primaryButton(
                    onPressed: orderProvider.isLoading ? null : _searchCard,
                    label: 'Search Card',
                    icon: Icons.search,
                  ),
                ),
                SizedBox(width: AppConfig.defaultPadding),
                Expanded(
                  child: ButtonUtils.secondaryButton(
                    onPressed: () => _showBarcodeScanner(),
                    label: 'Scan Barcode',
                    icon: Icons.qr_code_scanner,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetails(CardViewModel card) {
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
                    final orderProvider = context.read<OrderCreateProvider>();
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
                  // Card Image - Full width on mobile
                  ImageDisplay(imageUrl: card.image, width: double.infinity, height: AppConfig.imageSizeLarge),
                  SizedBox(height: AppConfig.defaultPadding),
                  // Item Details Form for Mobile
                  OrderItemEntryForm(
                    onAddItem: _handleAddOrderItem,
                    isLoading: false, // Will be handled by parent
                    maxQuantity: card.quantity,
                  ),
                  // Removed duplicate Add Item button here
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
                        // Card Info
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow('Price', '₹${card.sellPrice}', Icons.attach_money)),
                            SizedBox(width: AppConfig.defaultPadding),
                            Expanded(child: _buildInfoRow('Stock', '${card.quantity} units', Icons.inventory)),
                            SizedBox(width: AppConfig.defaultPadding),
                            Expanded(child: _buildInfoRow('Max Discount', '₹${card.maxDiscount}', Icons.discount)),
                          ],
                        ),
                        SizedBox(height: AppConfig.defaultPadding),
                        // Card Image
                        ImageDisplay(imageUrl: card.image, width: double.infinity, height: AppConfig.imageSizeXLarge),
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
                        OrderItemEntryForm(
                          onAddItem: _handleAddOrderItem,
                          isLoading: false, // Will be handled by parent
                          maxQuantity: card.quantity,
                        ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppConfig.textColorPrimary),
            SizedBox(width: AppConfig.spacingTiny),
            Text(
              label,
              style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.textColorPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: AppConfig.spacingTiny),
        Text(value, style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildOrderItemsList(OrderCreateProvider orderProvider) {
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
              OrderItemsCompactTable(
                items: orderProvider.orderItems,
                getCardById: (id) => orderProvider.getCardViewModelById(id),
                onRemoveItem: (index) => _removeOrderItem(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItemsSection(OrderCreateProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Service Items (${orderProvider.serviceItems.length})', style: ResponsiveText.getTitle(context))),
                ButtonUtils.secondaryButton(
                  onPressed: () {
                    setState(() => _showServiceForm = !_showServiceForm);
                  },
                  label: _showServiceForm ? 'Hide Form' : 'Add Service Item',
                  icon: _showServiceForm ? Icons.close : Icons.add,
                ),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),
            if (_showServiceForm) ...[_buildServiceItemEntryForm(orderProvider), SizedBox(height: AppConfig.defaultPadding)],
            if (orderProvider.serviceItems.isEmpty)
              const EmptyStateWidget(message: 'No service items added yet', icon: Icons.home_repair_service)
            else
              ServiceItemsCompactTable(
                items: orderProvider.serviceItems,
                onRemoveItem: (index) => orderProvider.removeServiceItem(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItemEntryForm(OrderCreateProvider orderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ServiceType>(
                value: _serviceType,
                onChanged: (val) => setState(() => _serviceType = val),
                decoration: const InputDecoration(labelText: 'Service Type', border: OutlineInputBorder()),
                items: ServiceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayText))).toList(),
              ),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _svcQtyController,
                decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConfig.defaultPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _svcExpenseController,
                decoration: const InputDecoration(labelText: 'Total Expense', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: AppConfig.defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _svcCostController,
                decoration: const InputDecoration(labelText: 'Total Cost', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConfig.defaultPadding),
        TextFormField(
          controller: _svcDescController,
          decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        SizedBox(height: AppConfig.defaultPadding),
        ButtonUtils.successButton(
          onPressed: () {
            final qty = int.tryParse(_svcQtyController.text) ?? 0;
            final item = ServiceItemCreationFormModel(
              serviceType: _serviceType,
              quantity: qty,
              totalCost: _svcCostController.text,
              totalExpense: _svcExpenseController.text,
              description: _svcDescController.text.isEmpty ? null : _svcDescController.text,
            );
            _handleAddServiceItem(item);
            _svcQtyController.clear();
            _svcCostController.clear();
            _svcExpenseController.clear();
            _svcDescController.clear();
            setState(() => _serviceType = null);
          },
          label: 'Add Service Item',
          icon: Icons.add,
        ),
      ],
    );
  }

  Widget _buildActionButtons(OrderCreateProvider orderProvider) {
    return Row(
      children: [
        Expanded(
          child: ButtonUtils.secondaryButton(onPressed: () => context.pop(), label: UITextConstants.back, icon: Icons.arrow_back),
        ),
        SizedBox(width: AppConfig.defaultPadding),
        Expanded(
          key: _reviewButtonKey,
          child: ButtonUtils.primaryButton(
            onPressed: (orderProvider.orderItems.isNotEmpty || orderProvider.serviceItems.isNotEmpty) ? _proceedToReview : null,
            label: UITextConstants.reviewOrder,
            icon: Icons.arrow_forward,
          ),
        ),
      ],
    );
  }
}
