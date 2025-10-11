import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/orders/presentation/models/order_item_form_model.dart';
import 'package:vsc_app/features/orders/presentation/services/order_calculation_service.dart';
import 'image_display.dart';

/// Compact, single-row table widget for displaying order items
class OrderItemsCompactTable extends StatelessWidget {
  final List<OrderItemCreationFormModel> items;
  final CardViewModel? Function(String cardId) getCardById;
  final void Function(int index)? onRemoveItem; // if null, hides actions column

  const OrderItemsCompactTable({super.key, required this.items, required this.getCardById, this.onRemoveItem});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final bool showActions = onRemoveItem != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Container(
          padding: EdgeInsets.symmetric(vertical: AppConfig.smallPadding, horizontal: AppConfig.smallPadding),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: SizedBox(
                    width: AppConfig.imageSizeSmall,
                    child: Center(
                      child: Text(
                        'Photo',
                        style: ResponsiveText.getCaption(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Qty',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  'Price',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  'Discount',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  'Box',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  'Printing',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  'Total',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                ),
              ),
              if (showActions) const SizedBox(width: 40),
            ],
          ),
        ),
        Divider(height: AppConfig.defaultPadding),
        // Data rows
        ...List.generate(items.length, (index) {
          final formItem = items[index];
          final card = getCardById(formItem.cardId);

          if (card == null) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppConfig.smallPadding),
              child: Row(
                children: [
                  Expanded(child: Text('Item ${index + 1} - Card not found', style: ResponsiveText.getBody(context))),
                  if (showActions)
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppConfig.errorColor),
                      onPressed: () => onRemoveItem?.call(index),
                    ),
                ],
              ),
            );
          }

          final discountAmount = double.tryParse(formItem.discountAmount) ?? 0.0;
          final boxCost = formItem.requiresBox ? (double.tryParse(formItem.totalBoxCost ?? '0') ?? 0.0) : 0.0;
          final printingCost = formItem.requiresPrinting ? (double.tryParse(formItem.totalPrintingCost ?? '0') ?? 0.0) : 0.0;
          final lineItemTotal = OrderCalculationService.calculateLineItemTotalWithParams(
            basePrice: card.sellPriceAsDouble,
            discountAmount: formItem.discountAmount,
            quantity: formItem.quantity,
            totalBoxCost: formItem.requiresBox ? formItem.totalBoxCost : null,
            totalPrintingCost: formItem.requiresPrinting ? formItem.totalPrintingCost : null,
          );

          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppConfig.smallPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: SizedBox(
                      width: AppConfig.imageSizeLarge,
                      child: ImageDisplay(imageUrl: card.image, width: AppConfig.imageSizeMedium, height: AppConfig.imageSizeMedium),
                    ),
                  ),
                ),

                Expanded(child: Text('${formItem.quantity}', style: ResponsiveText.getBody(context))),
                Expanded(child: Text('₹${card.sellPrice}', style: ResponsiveText.getBody(context))),
                Expanded(child: Text('₹${discountAmount.toStringAsFixed(2)}', style: ResponsiveText.getBody(context))),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        formItem.requiresBox ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: formItem.requiresBox ? AppConfig.successColor : AppConfig.grey600,
                      ),
                      SizedBox(width: 4),
                      Text(formItem.requiresBox ? '₹${boxCost.toStringAsFixed(2)}' : '—', style: ResponsiveText.getBody(context)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        formItem.requiresPrinting ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: formItem.requiresPrinting ? AppConfig.successColor : AppConfig.grey600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        formItem.requiresPrinting ? '₹${printingCost.toStringAsFixed(2)}' : '—',
                        style: ResponsiveText.getBody(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    '₹${lineItemTotal.toStringAsFixed(2)}',
                    style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (showActions)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppConfig.errorColor),
                    onPressed: () => onRemoveItem?.call(index),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
