import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/features/orders/data/models/order_api_models.dart';
import 'package:vsc_app/features/orders/presentation/models/order_form_models.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';

/// Widget for entering order item details
class OrderItemEntryForm extends StatefulWidget {
  final void Function(OrderItemFormViewModel) onAddItem;
  final bool isLoading;

  const OrderItemEntryForm({super.key, required this.onAddItem, this.isLoading = false});

  @override
  State<OrderItemEntryForm> createState() => _OrderItemEntryFormState();
}

class _OrderItemEntryFormState extends State<OrderItemEntryForm> {
  final _formKey = GlobalKey<FormState>();
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
    _quantityController.dispose();
    _discountController.dispose();
    _boxCostController.dispose();
    _printingCostController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _quantityController.text = '1';
    _discountController.text = '0.00';
    _boxCostController.text = '0.00';
    _printingCostController.text = '0.00';
    _requiresBox = false;
    _requiresPrinting = false;
    _selectedBoxType = BoxType.folding;
  }

  void _handleAddItem() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onAddItem(
        OrderItemFormViewModel.fromFormData(
          quantity: int.tryParse(_quantityController.text) ?? 1,
          discountAmount: _discountController.text,
          requiresBox: _requiresBox,
          requiresPrinting: _requiresPrinting,
          totalBoxCost: _requiresBox ? _boxCostController.text : null,
          totalPrintingCost: _requiresPrinting ? _printingCostController.text : null,
          boxType: _selectedBoxType,
        ),
      );
      reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
          SizedBox(height: AppConfig.defaultPadding),
          ButtonUtils.successButton(onPressed: widget.isLoading ? null : _handleAddItem, label: UITextConstants.addOrderItem, icon: Icons.add),
        ],
      ),
    );
  }

  void reset() {
    _resetForm();
    _formKey.currentState?.reset();
  }
}
