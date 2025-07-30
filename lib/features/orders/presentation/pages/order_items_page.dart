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
  }

  void _addOrderItem() {
    if (!_formKey.currentState!.validate()) return;

    final orderProvider = context.read<OrderProvider>();
    final currentCard = orderProvider.currentCard;

    if (currentCard == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please search for a card first'), backgroundColor: AppConfig.errorColor));
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity > currentCard.quantity) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quantity exceeds available stock (${currentCard.quantity})'), backgroundColor: AppConfig.errorColor));
      return;
    }

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

    // Clear form
    _barcodeController.clear();
    _quantityController.text = '1';
    _discountController.text = '0.00';
    _boxCostController.text = '0.00';
    _printingCostController.text = '0.00';
    _requiresBox = false;
    _requiresPrinting = false;
    _selectedBoxType = BoxType.folding;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added to order'), backgroundColor: AppConfig.successColor));
  }

  void _removeOrderItem(int index) {
    final orderProvider = context.read<OrderProvider>();
    orderProvider.removeOrderItem(index);
  }

  void _proceedToReview() {
    final orderProvider = context.read<OrderProvider>();
    if (orderProvider.orderItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add at least one item to the order'), backgroundColor: AppConfig.errorColor));
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
          _buildHeader(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildSearchForm(orderProvider),
          SizedBox(height: AppConfig.largePadding),
          _buildOrderItemsList(orderProvider),
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
                _buildSearchForm(orderProvider),
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
                _buildOrderItemsList(orderProvider),
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
        Text(UITextConstants.orderCreationTitle, style: AppConfig.headlineStyle.copyWith(color: AppConfig.primaryColor)),
        SizedBox(height: AppConfig.smallPadding),
        Text(UITextConstants.orderCreationSubtitle, style: AppConfig.subtitleStyle),
        if (orderProvider.selectedCustomer != null) ...[
          SizedBox(height: AppConfig.defaultPadding),
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer', style: AppConfig.titleStyle),
                  SizedBox(height: AppConfig.smallPadding),
                  Text('Name: ${orderProvider.selectedCustomer!.name}'),
                  Text('Phone: ${orderProvider.selectedCustomer!.phone}'),
                ],
              ),
            ),
          ),
        ],
      ],
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
              Text('Search Card', style: AppConfig.titleStyle),
              SizedBox(height: AppConfig.defaultPadding),
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
              if (orderProvider.currentCard != null) ...[
                SizedBox(height: AppConfig.largePadding),
                _buildCardDetails(orderProvider.currentCard!),
                SizedBox(height: AppConfig.defaultPadding),
                _buildItemForm(),
                SizedBox(height: AppConfig.defaultPadding),
                ButtonUtils.successButton(onPressed: _addOrderItem, label: UITextConstants.addOrderItem, icon: Icons.add),
              ],
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
            Text('Card Details', style: AppConfig.titleStyle),
            SizedBox(height: AppConfig.smallPadding),
            Text('Barcode: ${card.barcode}', style: AppConfig.bodyStyle),
            Text('Price: \$${card.sellPrice}', style: AppConfig.bodyStyle),
            Text('Stock: ${card.quantity}', style: AppConfig.bodyStyle),
            Text('Max Discount: ${card.maxDiscount}%', style: AppConfig.bodyStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildItemForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item Details', style: AppConfig.titleStyle),
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
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderProvider.orderItems.length,
                itemBuilder: (context, index) {
                  final item = orderProvider.orderItems[index];
                  return ListTile(
                    title: Text('Item ${index + 1}'),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeOrderItem(index)),
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
          child: ButtonUtils.secondaryButton(onPressed: () => context.go(RouteConstants.customerSearch), label: 'Back', icon: Icons.arrow_back),
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
