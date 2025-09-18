import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/orders/presentation/models/order_item_form_model.dart';
import 'package:vsc_app/features/orders/presentation/models/order_update_form_models.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:vsc_app/features/orders/presentation/widgets/image_display.dart';
import 'package:vsc_app/features/orders/presentation/widgets/order_item_card.dart';
import 'package:vsc_app/features/orders/presentation/widgets/order_item_entry_form.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';

class EditOrderPage extends StatefulWidget {
  final String orderId;
  final OrderDetailProvider? orderProvider;

  const EditOrderPage({super.key, required this.orderId, this.orderProvider});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  late final OrderDetailProvider _orderProvider;

  final TextEditingController _specialInstructionController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  OrderStatus? _selectedStatus;

  // Form state for updates
  final OrderUpdateFormModel _updateForm = OrderUpdateFormModel(orderItems: [], addItems: [], removeItemIds: []);

  @override
  void initState() {
    super.initState();
    _orderProvider = widget.orderProvider ?? OrderDetailProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _orderProvider.setContext(context);
      await _orderProvider.getOrderById(widget.orderId);
      _prefillFromOrder();
    });
  }

  @override
  void dispose() {
    _specialInstructionController.dispose();
    _deliveryDateController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _prefillFromOrder() {
    final order = _orderProvider.currentOrder;
    if (order == null) return;
    _specialInstructionController.text = order.specialInstruction;
    _deliveryDateController.text = order.deliveryDate.toIso8601String();
    _selectedStatus = OrderStatusExtension.fromApiString(order.orderStatus);
    setState(() {});
  }

  void _handleAddOrderItem(OrderItemCreationFormModel item) {
    // Append to addItems list
    // Attach scanned card id if present
    final scanned = _orderProvider.currentScannedCard;
    if (scanned != null) {
      item.cardId = scanned.id;
    }
    _updateForm.addItems ??= [];
    _updateForm.addItems!.add(item);
    setState(() {});
    _orderProvider.setSuccessWithSnackBar('Item added to be created', context);
  }

  void _removeAddItemAt(int index) {
    if (_updateForm.addItems == null) return;
    if (index >= 0 && index < _updateForm.addItems!.length) {
      _updateForm.addItems!.removeAt(index);
      setState(() {});
    }
  }

  void _toggleRemoveExistingItem(String orderItemId) {
    _updateForm.removeItemIds ??= [];
    if (_updateForm.removeItemIds!.contains(orderItemId)) {
      _updateForm.removeItemIds!.remove(orderItemId);
    } else {
      _updateForm.removeItemIds!.add(orderItemId);
    }
    setState(() {});
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
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                  _barcodeController.text = code;
                  Navigator.of(context).pop();
                  Future.microtask(() {
                    if (mounted) {
                      _orderProvider.searchCardByBarcode(code);
                    }
                  });
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submitUpdate() async {
    _updateForm.specialInstruction = _specialInstructionController.text;
    _updateForm.deliveryDate = _deliveryDateController.text.isEmpty ? null : _deliveryDateController.text;
    _updateForm.orderStatus = _selectedStatus;

    final validation = _updateForm.validate();
    if (!validation.isValid) {
      _orderProvider.setErrorWithSnackBar(validation.firstMessage ?? 'Please check your input', context);
      return;
    }

    await _orderProvider.updateOrder(orderId: widget.orderId, formModel: _updateForm);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _orderProvider,
      child: Consumer<OrderDetailProvider>(
        builder: (context, provider, _) {
          final order = provider.currentOrder;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Order'),
              leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
            ),
            body: order == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(AppConfig.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(order),
                        SizedBox(height: AppConfig.largePadding),
                        _buildEditForm(order),
                        SizedBox(height: AppConfig.largePadding),
                        _buildExistingItemsSection(order),
                        SizedBox(height: AppConfig.largePadding),
                        _buildAddItemsSection(),
                        SizedBox(height: AppConfig.largePadding),
                        _buildSubmitButtons(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OrderViewModel order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Row(
          children: [
            Expanded(child: Text(order.name.isNotEmpty ? order.name : 'Order', style: ResponsiveText.getTitle(context))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: OrderStatusExtension.getColorFromString(order.orderStatus), borderRadius: BorderRadius.circular(16)),
              child: Text(OrderStatusExtension.getDisplayTextFromString(order.orderStatus), style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(OrderViewModel order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Info', style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),

            DropdownButtonFormField<OrderStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Order Status', border: OutlineInputBorder()),
              items: OrderStatus.values.map((s) => DropdownMenuItem<OrderStatus>(value: s, child: Text(s.getDisplayText()))).toList(),
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            SizedBox(height: AppConfig.defaultPadding),
            TextFormField(
              controller: _deliveryDateController,
              decoration: const InputDecoration(labelText: 'Delivery Date (ISO)', hintText: 'YYYY-MM-DDTHH:mm:ssZ', border: OutlineInputBorder()),
            ),
            SizedBox(height: AppConfig.defaultPadding),
            TextFormField(
              controller: _specialInstructionController,
              decoration: const InputDecoration(labelText: 'Special Instruction', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingItemsSection(OrderViewModel order) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Existing Items (${order.orderItems.length})', style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),
            if (order.orderItems.isEmpty)
              const EmptyStateWidget(message: 'No items', icon: Icons.shopping_cart_outlined)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.orderItems.length,
                itemBuilder: (context, index) {
                  final existing = order.orderItems[index];
                  final card = _orderProvider.getCardForOrderItem(existing.cardId);
                  return Card(
                    margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
                    child: Padding(
                      padding: EdgeInsets.all(AppConfig.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Item ${index + 1}', style: ResponsiveText.getSubtitle(context).copyWith(fontWeight: FontWeight.bold)),
                              ),
                              TextButton.icon(
                                onPressed: () => _toggleRemoveExistingItem(existing.id),
                                icon: Icon(
                                  _updateForm.removeItemIds?.contains(existing.id) == true ? Icons.undo : Icons.delete,
                                  color: AppConfig.errorColor,
                                ),
                                label: Text(
                                  _updateForm.removeItemIds?.contains(existing.id) == true ? 'Undo Remove' : 'Remove',
                                  style: TextStyle(color: AppConfig.errorColor),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConfig.smallPadding),
                          if (card != null) ImageDisplay(imageUrl: card.image, width: context.isMobile ? double.infinity : 180, height: 140),
                          SizedBox(height: AppConfig.smallPadding),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: existing.quantity.toString(),
                                  decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final qty = int.tryParse(v);
                                    _addOrReplaceUpdateItem(existing.id, quantity: qty);
                                  },
                                ),
                              ),
                              SizedBox(width: AppConfig.defaultPadding),
                              Expanded(
                                child: TextFormField(
                                  initialValue: existing.discountAmount,
                                  decoration: const InputDecoration(labelText: 'Discount Amount', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => _addOrReplaceUpdateItem(existing.id, discountAmount: v),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConfig.defaultPadding),
                          Wrap(
                            spacing: AppConfig.defaultPadding,
                            runSpacing: AppConfig.defaultPadding,
                            children: [
                              StatefulBuilder(
                                builder: (context, setLocal) {
                                  final isRemoved = _updateForm.removeItemIds?.contains(existing.id) == true;
                                  return Row(
                                    children: [
                                      FilterChip(
                                        label: const Text('Requires Box'),
                                        selected: _getPendingRequiresBox(existing.id) ?? existing.requiresBox,
                                        onSelected: isRemoved
                                            ? null
                                            : (val) {
                                                _addOrReplaceUpdateItem(existing.id, requiresBox: val);
                                                setLocal(() {});
                                              },
                                      ),
                                      SizedBox(width: AppConfig.defaultPadding),
                                      FilterChip(
                                        label: const Text('Requires Printing'),
                                        selected: _getPendingRequiresPrinting(existing.id) ?? existing.requiresPrinting,
                                        onSelected: isRemoved
                                            ? null
                                            : (val) {
                                                _addOrReplaceUpdateItem(existing.id, requiresPrinting: val);
                                                setLocal(() {});
                                              },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              if ((_getPendingRequiresBox(existing.id) ?? existing.requiresBox) &&
                                  !(_updateForm.removeItemIds?.contains(existing.id) == true)) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<OrderBoxType?>(
                                        value:
                                            _getPendingBoxType(existing.id) ??
                                            (existing.boxOrders != null && existing.boxOrders!.isNotEmpty ? existing.boxOrders!.first.boxType : null),
                                        decoration: const InputDecoration(labelText: 'Box Type', border: OutlineInputBorder()),
                                        items: OrderBoxType.values
                                            .map((t) => DropdownMenuItem<OrderBoxType?>(value: t, child: Text(t.name.toUpperCase())))
                                            .toList(),
                                        onChanged: (val) => _updateBoxFields(existing.id, boxType: val),
                                      ),
                                    ),
                                    SizedBox(width: AppConfig.defaultPadding),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue:
                                            _getPendingBoxCost(existing.id) ??
                                            (existing.boxOrders != null && existing.boxOrders!.isNotEmpty
                                                ? existing.boxOrders!.first.totalBoxCost
                                                : ''),
                                        decoration: const InputDecoration(labelText: 'Total Box Cost', border: OutlineInputBorder()),
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) => _updateBoxFields(existing.id, totalBoxCost: v),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if ((_getPendingRequiresPrinting(existing.id) ?? existing.requiresPrinting) &&
                                  !(_updateForm.removeItemIds?.contains(existing.id) == true)) ...[
                                TextFormField(
                                  initialValue:
                                      _getPendingPrintingCost(existing.id) ??
                                      (existing.printingJobs != null && existing.printingJobs!.isNotEmpty
                                          ? existing.printingJobs!.first.totalPrintingCost
                                          : ''),
                                  decoration: const InputDecoration(labelText: 'Total Printing Cost', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => _updatePrintingFields(existing.id, totalPrintingCost: v),
                                ),
                              ],
                            ],
                          ),
                          if (_updateForm.removeItemIds?.contains(existing.id) == true)
                            Padding(
                              padding: EdgeInsets.only(top: AppConfig.smallPadding),
                              child: Row(
                                children: [
                                  Icon(Icons.info, size: 16, color: AppConfig.errorColor),
                                  SizedBox(width: 6),
                                  Text(
                                    'Marked for removal',
                                    style: TextStyle(color: AppConfig.errorColor, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
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

  void _addOrReplaceUpdateItem(String orderItemId, {int? quantity, String? discountAmount, bool? requiresBox, bool? requiresPrinting}) {
    _updateForm.orderItems ??= [];
    final idx = _updateForm.orderItems!.indexWhere((e) => e.orderItemId == orderItemId);
    if (idx >= 0) {
      final existing = _updateForm.orderItems![idx];
      _updateForm.orderItems![idx] = existing.copyWith(
        quantity: quantity ?? existing.quantity,
        discountAmount: discountAmount ?? existing.discountAmount,
        requiresBox: requiresBox ?? existing.requiresBox,
        requiresPrinting: requiresPrinting ?? existing.requiresPrinting,
      );
    } else {
      _updateForm.orderItems!.add(
        OrderItemUpdateFormModel(
          orderItemId: orderItemId,
          quantity: quantity,
          discountAmount: discountAmount,
          requiresBox: requiresBox,
          requiresPrinting: requiresPrinting,
        ),
      );
    }
    setState(() {});
  }

  bool? _getPendingRequiresBox(String orderItemId) {
    final idx = _updateForm.orderItems?.indexWhere((e) => e.orderItemId == orderItemId) ?? -1;
    if (idx >= 0) return _updateForm.orderItems![idx].requiresBox;
    return null;
  }

  bool? _getPendingRequiresPrinting(String orderItemId) {
    final idx = _updateForm.orderItems?.indexWhere((e) => e.orderItemId == orderItemId) ?? -1;
    if (idx >= 0) return _updateForm.orderItems![idx].requiresPrinting;
    return null;
  }

  // Extended pending field helpers
  OrderBoxType? _getPendingBoxType(String orderItemId) {
    final idx = _updateForm.orderItems?.indexWhere((e) => e.orderItemId == orderItemId) ?? -1;
    if (idx >= 0) return _updateForm.orderItems![idx].boxType;
    return null;
  }

  String? _getPendingBoxCost(String orderItemId) {
    final idx = _updateForm.orderItems?.indexWhere((e) => e.orderItemId == orderItemId) ?? -1;
    if (idx >= 0) return _updateForm.orderItems![idx].totalBoxCost;
    return null;
  }

  String? _getPendingPrintingCost(String orderItemId) {
    final idx = _updateForm.orderItems?.indexWhere((e) => e.orderItemId == orderItemId) ?? -1;
    if (idx >= 0) return _updateForm.orderItems![idx].totalPrintingCost;
    return null;
  }

  void _updateBoxFields(String orderItemId, {OrderBoxType? boxType, String? totalBoxCost}) {
    _updateForm.orderItems ??= [];
    final idx = _updateForm.orderItems!.indexWhere((e) => e.orderItemId == orderItemId);
    if (idx >= 0) {
      final cur = _updateForm.orderItems![idx];
      _updateForm.orderItems![idx] = cur.copyWith(boxType: boxType ?? cur.boxType, totalBoxCost: totalBoxCost ?? cur.totalBoxCost);
    } else {
      _updateForm.orderItems!.add(OrderItemUpdateFormModel(orderItemId: orderItemId, boxType: boxType, totalBoxCost: totalBoxCost));
    }
    setState(() {});
  }

  void _updatePrintingFields(String orderItemId, {String? totalPrintingCost}) {
    _updateForm.orderItems ??= [];
    final idx = _updateForm.orderItems!.indexWhere((e) => e.orderItemId == orderItemId);
    if (idx >= 0) {
      final cur = _updateForm.orderItems![idx];
      _updateForm.orderItems![idx] = cur.copyWith(totalPrintingCost: totalPrintingCost ?? cur.totalPrintingCost);
    } else {
      _updateForm.orderItems!.add(OrderItemUpdateFormModel(orderItemId: orderItemId, totalPrintingCost: totalPrintingCost));
    }
    setState(() {});
  }

  Widget _buildAddItemsSection() {
    final card = _orderProvider.currentScannedCard;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Items', style: ResponsiveText.getTitle(context)),
            SizedBox(height: AppConfig.defaultPadding),
            // Barcode search
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(labelText: 'Barcode', hintText: 'Scan or enter barcode', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(width: AppConfig.defaultPadding),
                ButtonUtils.secondaryButton(onPressed: _showBarcodeScanner, label: 'Scan', icon: Icons.qr_code_scanner),
                SizedBox(width: AppConfig.defaultPadding),
                ButtonUtils.primaryButton(
                  onPressed: _orderProvider.isLoading ? null : () => _orderProvider.searchCardByBarcode(_barcodeController.text.trim()),
                  label: 'Search',
                  icon: Icons.search,
                ),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),
            if (card != null) ...[
              ImageDisplay(imageUrl: card.image, width: context.isMobile ? double.infinity : 180, height: 140),
              SizedBox(height: AppConfig.defaultPadding),
            ],
            OrderItemEntryForm(onAddItem: _handleAddOrderItem, isLoading: _orderProvider.isLoading),
            SizedBox(height: AppConfig.defaultPadding),
            if ((_updateForm.addItems?.isNotEmpty ?? false))
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _updateForm.addItems!.length,
                itemBuilder: (context, index) {
                  final tempItem = _updateForm.addItems![index];
                  final orderCard = _orderProvider.getCardForOrderItem(tempItem.cardId);
                  if (orderCard == null) {
                    return ListTile(
                      title: Text('New Item ${index + 1} - Card not found'),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeAddItemAt(index)),
                    );
                  }
                  return OrderItemCard(
                    item: tempItem,
                    card: CardViewModel(
                      id: orderCard.id,
                      vendorId: '',
                      barcode: '',
                      sellPrice: orderCard.sellPrice,
                      costPrice: orderCard.costPrice,
                      maxDiscount: orderCard.maxDiscount,
                      quantity: orderCard.quantity,
                      image: orderCard.image,
                      perceptualHash: '',
                      isActive: orderCard.isActive,
                      sellPriceAsDouble: orderCard.sellPriceAsDouble,
                      costPriceAsDouble: orderCard.costPriceAsDouble,
                      maxDiscountAsDouble: orderCard.maxDiscountAsDouble,
                      profitMargin: 0,
                      totalValue: 0,
                    ),
                    index: index,
                    onRemove: () => _removeAddItemAt(index),
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

  Widget _buildSubmitButtons() {
    return Row(
      children: [
        Expanded(
          child: ButtonUtils.secondaryButton(onPressed: () => context.pop(), label: 'Cancel', icon: Icons.arrow_back),
        ),
        SizedBox(width: AppConfig.defaultPadding),
        Expanded(
          child: ButtonUtils.primaryButton(onPressed: _orderProvider.isLoading ? null : _submitUpdate, label: 'Save Changes', icon: Icons.save),
        ),
      ],
    );
  }
}
