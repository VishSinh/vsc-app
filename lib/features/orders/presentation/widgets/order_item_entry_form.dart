import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';
import 'package:vsc_app/features/orders/presentation/models/order_item_form_model.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_item_form_provider.dart';

/// Widget for entering order item details
class OrderItemEntryForm extends StatelessWidget {
  final void Function(OrderItemCreationFormModel) onAddItem;
  final bool isLoading;

  const OrderItemEntryForm({super.key, required this.onAddItem, this.isLoading = false});

  void _handleAddItem(BuildContext context) {
    final formProvider = context.read<OrderItemFormProvider>();

    // Always provide default values for empty fields
    final quantity = formProvider.quantityController.text.isEmpty ? 1 : int.tryParse(formProvider.quantityController.text) ?? 1;

    final discountAmount = formProvider.discountController.text.isEmpty ? '0' : formProvider.discountController.text;

    final boxCost = formProvider.requiresBox && formProvider.boxCostController.text.isEmpty ? '0' : formProvider.boxCostController.text;

    final printingCost = formProvider.requiresPrinting && formProvider.printingCostController.text.isEmpty
        ? '0'
        : formProvider.printingCostController.text;

    AppLogger.debug('OrderItemEntryForm: Adding item without cardId');
    onAddItem(
      OrderItemCreationFormModel(
        quantity: quantity,
        discountAmount: discountAmount,
        requiresBox: formProvider.requiresBox,
        requiresPrinting: formProvider.requiresPrinting,
        totalBoxCost: formProvider.requiresBox ? boxCost : null,
        totalPrintingCost: formProvider.requiresPrinting ? printingCost : null,
        boxType: formProvider.selectedBoxType,
      ),
    );
    formProvider.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderItemFormProvider(),
      child: Consumer<OrderItemFormProvider>(
        builder: (context, formProvider, child) {
          return Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Item Details', style: ResponsiveText.getTitle(context)),
                SizedBox(height: AppConfig.defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: formProvider.quantityController,
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
                        controller: formProvider.discountController,
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
                  value: formProvider.requiresBox,
                  onChanged: (value) {
                    formProvider.setRequiresBox(value ?? false);
                  },
                ),
                if (formProvider.requiresBox) ...[
                  DropdownButtonFormField<OrderBoxType>(
                    value: formProvider.selectedBoxType,
                    decoration: InputDecoration(labelText: UITextConstants.boxType, border: const OutlineInputBorder()),
                    items: OrderBoxType.values.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
                    }).toList(),
                    onChanged: (value) {
                      formProvider.setSelectedBoxType(value ?? OrderBoxType.folding);
                    },
                  ),
                  SizedBox(height: AppConfig.defaultPadding),
                  TextFormField(
                    controller: formProvider.boxCostController,
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
                  value: formProvider.requiresPrinting,
                  onChanged: (value) {
                    formProvider.setRequiresPrinting(value ?? false);
                  },
                ),
                if (formProvider.requiresPrinting) ...[
                  SizedBox(height: AppConfig.defaultPadding),
                  TextFormField(
                    controller: formProvider.printingCostController,
                    decoration: InputDecoration(
                      labelText: UITextConstants.printingCost,
                      hintText: UITextConstants.printingCostHint,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                SizedBox(height: AppConfig.defaultPadding),
                ButtonUtils.successButton(
                  onPressed: isLoading ? null : () => _handleAddItem(context),
                  label: UITextConstants.addOrderItem,
                  icon: Icons.add,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
