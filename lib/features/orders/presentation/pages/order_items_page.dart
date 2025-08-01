import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import '../widgets/order_widgets.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';

import 'package:vsc_app/features/orders/presentation/providers/order_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/orders/presentation/models/order_form_models.dart';

class OrderItemsPage extends StatefulWidget {
  const OrderItemsPage({super.key});

  @override
  State<OrderItemsPage> createState() => _OrderItemsPageState();
}

class _OrderItemsPageState extends State<OrderItemsPage> {
  final _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear order items but preserve selected customer when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      orderProvider.setContext(context); // Set context for auto SnackBar
      final selectedCustomer = orderProvider.selectedCustomer; // Preserve customer
      orderProvider.clearOrderItemsOnly(); // Only clear items, not customer
      AppLogger.debug('OrderItemsPage: Cleared order items but preserved customer: ${selectedCustomer?.name}');
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _searchCard() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.searchCardByBarcode(_barcodeController.text.trim());
    // ✅ Auto SnackBar - no manual error handling needed!
  }

  void _removeOrderItem(int index) {
    final orderProvider = context.read<OrderProvider>();
    orderProvider.removeOrderItem(index);
  }

  void _proceedToReview() {
    final orderProvider = context.read<OrderProvider>();
    if (orderProvider.orderItems.isEmpty) {
      orderProvider.setError('Please add at least one item to the order'); // ✅ Auto SnackBar
      return;
    }
    context.go(RouteConstants.orderReview);
  }

  void _handleAddOrderItem(OrderItemFormViewModel data) {
    final orderProvider = context.read<OrderProvider>();
    final currentCard = orderProvider.currentCardViewModel;
    if (currentCard == null) {
      orderProvider.setError('Please search for a card first'); // ✅ Auto SnackBar
      return;
    }
    orderProvider.addOrderItem(
      cardId: currentCard.id,
      discountAmount: data.discountAmount,
      quantity: data.quantity,
      requiresBox: data.requiresBox,
      requiresPrinting: data.requiresPrinting,
      boxType: data.boxType,
      totalBoxCost: data.totalBoxCost,
      totalPrintingCost: data.totalPrintingCost,
    );
    orderProvider.setSuccess('Item added to order'); // ✅ Auto SnackBar
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
          if (orderProvider.currentCardViewModel != null) ...[
            SizedBox(height: AppConfig.largePadding),
            _buildCardDetails(orderProvider.currentCardViewModel!),
          ],
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
          _buildActionButtons(orderProvider),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderProvider orderProvider) {
    return CustomerInfoCard(customer: orderProvider.selectedCustomer);
  }

  Widget _buildSearchForm(OrderProvider orderProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
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
                  ImageDisplay(imageUrl: card.image, width: double.infinity, height: AppConfig.imageSizeLarge),
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
                  OrderItemEntryForm(
                    onAddItem: _handleAddOrderItem,
                    isLoading: false, // Will be handled by parent
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
                        // Card Image
                        ImageDisplay(imageUrl: card.image, width: double.infinity, height: AppConfig.imageSizeXLarge),
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
                        OrderItemEntryForm(
                          onAddItem: _handleAddOrderItem,
                          isLoading: false, // Will be handled by parent
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
          children: [
            Icon(icon, size: 16, color: AppConfig.grey600),
            SizedBox(width: AppConfig.spacingTiny),
            Text(label, style: ResponsiveText.getCaption(context).copyWith(color: AppConfig.grey600)),
          ],
        ),
        SizedBox(height: AppConfig.spacingTiny),
        Text(value, style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildOrderItemsList(OrderProvider orderProvider) {
    AppLogger.debug('OrderItemsPage: Building order items list, count: ${orderProvider.orderItems.length}');

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
                  final card = orderProvider.getCardViewModelById(item.cardId);

                  if (card == null) {
                    return ListTile(
                      title: Text('Item ${index + 1} - Card not found'),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeOrderItem(index)),
                    );
                  }

                  return OrderItemCard(
                    item: item,
                    card: card,
                    index: index,
                    onRemove: () => _removeOrderItem(index),
                    showRemoveButton: true,
                    isReviewMode: false,
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
