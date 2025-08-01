import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'desktop_info_row.dart';
import 'image_display.dart';

/// Reusable order item card widget
class OrderItemCard extends StatelessWidget {
  final OrderItemViewModel item;
  final CardViewModel card;
  final int index;
  final VoidCallback? onRemove;
  final bool showRemoveButton;
  final bool isReviewMode;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.card,
    required this.index,
    this.onRemove,
    this.showRemoveButton = true,
    this.isReviewMode = false,
  });

  /// Get line item total from view model
  double get lineItemTotal => item.lineItemTotal;

  @override
  Widget build(BuildContext context) {
    // Get line item total from view model
    final lineItemTotal = this.lineItemTotal;

    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.smallPadding),
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with optional delete button
            Row(
              children: [
                Expanded(
                  child: Text('Item ${index + 1}', style: ResponsiveText.getSubtitle(context).copyWith(fontWeight: FontWeight.bold)),
                ),
                if (showRemoveButton && onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppConfig.errorColor),
                    onPressed: onRemove,
                  ),
              ],
            ),
            SizedBox(height: AppConfig.defaultPadding),

            if (context.isMobile) ...[_buildMobileLayout(context, lineItemTotal)] else ...[_buildDesktopLayout(context, lineItemTotal)],

            // Line Total for mobile only (desktop has it in the grid)
            if (context.isMobile) ...[_buildMobileLineTotal(context, lineItemTotal)],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double lineItemTotal) {
    final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
    final quantity = item.quantity;
    final boxCost = item.requiresBox ? (double.tryParse(item.totalBoxCost ?? '0') ?? 0.0) : 0.0;
    final printingCost = item.requiresPrinting ? (double.tryParse(item.totalPrintingCost ?? '0') ?? 0.0) : 0.0;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Image
            ImageDisplay(imageUrl: card.image, width: AppConfig.imageSizeSmall, height: AppConfig.imageSizeSmall),
            SizedBox(width: AppConfig.defaultPadding),
            // Basic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: ₹${card.sellPrice}', style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.w600)),
                  Text('Quantity: $quantity', style: ResponsiveText.getBody(context)),
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
              if (item.requiresBox) ...[Expanded(child: Text('Box: ₹${boxCost.toStringAsFixed(2)}', style: ResponsiveText.getBody(context)))],
              if (item.requiresPrinting) ...[
                Expanded(child: Text('Printing: ₹${printingCost.toStringAsFixed(2)}', style: ResponsiveText.getBody(context))),
              ],
            ],
          ),
          SizedBox(height: AppConfig.smallPadding),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, double lineItemTotal) {
    final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
    final quantity = item.quantity;
    final boxCost = item.requiresBox ? (double.tryParse(item.totalBoxCost ?? '0') ?? 0.0) : 0.0;
    final printingCost = item.requiresPrinting ? (double.tryParse(item.totalPrintingCost ?? '0') ?? 0.0) : 0.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Image - Larger and more prominent
        ImageDisplay(imageUrl: card.image, width: AppConfig.imageSizeMedium, height: AppConfig.imageSizeMedium),
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
                    child: DesktopInfoRow(label: 'Price', value: '₹${card.sellPrice}', icon: Icons.attach_money, color: AppConfig.primaryColor),
                  ),
                  SizedBox(width: AppConfig.defaultPadding),
                  Expanded(
                    child: DesktopInfoRow(label: 'Quantity', value: '$quantity', icon: Icons.shopping_cart, color: AppConfig.successColor),
                  ),
                  SizedBox(width: AppConfig.defaultPadding),
                  Expanded(
                    child: DesktopInfoRow(
                      label: 'Discount',
                      value: '₹${discountAmount.toStringAsFixed(2)}',
                      icon: Icons.discount,
                      color: AppConfig.warningColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConfig.defaultPadding),
              // Secondary info row
              Row(
                children: [
                  Expanded(
                    child: DesktopInfoRow(label: 'Stock', value: '${card.quantity} units', icon: Icons.inventory, color: AppConfig.grey600),
                  ),
                  SizedBox(width: AppConfig.defaultPadding),
                  Expanded(
                    child: DesktopInfoRow(
                      label: 'Box',
                      value: item.requiresBox ? 'Yes - ${item.boxType?.name.toUpperCase() ?? 'N/A'} - ₹${boxCost.toStringAsFixed(2)}' : 'No',
                      icon: Icons.inventory_2,
                      color: item.requiresBox ? AppConfig.successColor : AppConfig.grey600,
                    ),
                  ),
                  SizedBox(width: AppConfig.defaultPadding),
                  Expanded(
                    child: DesktopInfoRow(
                      label: 'Printing',
                      value: item.requiresPrinting ? 'Yes - ₹${printingCost.toStringAsFixed(2)}' : 'No',
                      icon: Icons.print,
                      color: item.requiresPrinting ? AppConfig.successColor : AppConfig.grey600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConfig.defaultPadding),
              // Total row
              Row(
                children: [
                  Expanded(
                    child: DesktopInfoRow(
                      label: 'Total',
                      value: '₹${lineItemTotal.toStringAsFixed(2)}',
                      icon: Icons.calculate,
                      color: AppConfig.primaryColor,
                      isTotal: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLineTotal(BuildContext context, double lineItemTotal) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConfig.smallPadding),
      decoration: BoxDecoration(color: AppConfig.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppConfig.smallRadius)),
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
    );
  }
}
