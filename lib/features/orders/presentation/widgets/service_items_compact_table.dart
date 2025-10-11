import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/enums/service_type.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/orders/presentation/models/service_item_form_model.dart';

/// Compact, single-row table widget for displaying service items
class ServiceItemsCompactTable extends StatelessWidget {
  final List<ServiceItemCreationFormModel> items;
  final void Function(int index)? onRemoveItem; // if null, hides actions column

  const ServiceItemsCompactTable({super.key, required this.items, this.onRemoveItem});

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
                flex: 2,
                child: Text(
                  'Service',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
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
                  'Expense',
                  style: ResponsiveText.getCaption(context).copyWith(fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  'Cost',
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
          final svc = items[index];
          final Color serviceColor = (svc.serviceType?.color ?? Colors.teal);

          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppConfig.smallPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: serviceColor.withOpacity(0.15),
                        child: Icon(Icons.home_repair_service, color: serviceColor, size: 16),
                      ),
                      SizedBox(width: AppConfig.smallPadding),
                      Expanded(
                        child: Text(
                          svc.serviceType?.displayText ?? svc.serviceType?.toApiString() ?? 'SERVICE',
                          overflow: TextOverflow.ellipsis,
                          style: ResponsiveText.getBody(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Text('${svc.quantity}', style: ResponsiveText.getBody(context))),
                Expanded(child: Text('₹${svc.totalExpense}', style: ResponsiveText.getBody(context))),
                Expanded(
                  child: Text('₹${svc.totalCost}', style: ResponsiveText.getBody(context).copyWith(fontWeight: FontWeight.bold)),
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
