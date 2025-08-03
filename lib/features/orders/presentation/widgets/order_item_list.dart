import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/core/widgets/shared_widgets.dart';
import 'order_widgets.dart';
import 'package:vsc_app/features/orders/presentation/providers/order_create_provider.dart';

/// Widget for displaying the list of order items
class OrderItemList extends StatelessWidget {
  final VoidCallback? onRemoveItem;

  const OrderItemList({super.key, this.onRemoveItem});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderCreateProvider>(
      builder: (context, orderProvider, child) {
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
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderProvider.orderItems.length,
                    itemBuilder: (context, index) {
                      final formItem = orderProvider.orderItems[index];
                      final card = orderProvider.getCardViewModelById(formItem.cardId);

                      if (card == null) {
                        return ListTile(
                          title: Text('Item ${index + 1} - Card not found'),
                          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => onRemoveItem?.call()),
                        );
                      }

                      // Convert form model to view model for display
                      // final viewItem = OrderItemViewModel.fromCreationFormModel(formItem, card);

                      return OrderItemCard(
                        key: ValueKey('order_item_${formItem.cardId}_$index'),
                        item: formItem,
                        card: card,
                        index: index,
                        onRemove: onRemoveItem,
                        showRemoveButton: true,
                        isReviewMode: false,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
