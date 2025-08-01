import 'package:vsc_app/features/orders/domain/models/order.dart';
import 'package:vsc_app/features/orders/domain/models/order_item.dart';
import 'package:vsc_app/features/cards/domain/models/card.dart';

/// Domain service for order price calculations
/// Handles business logic for calculating order totals, discounts, and additional costs
class OrderPriceCalculatorService {
  /// Calculates line item total for an order item
  double calculateLineItemTotal(OrderItem item, CardEntity card) {
    final basePrice = card.sellPrice;
    final discountAmount = item.discountAmount;
    final quantity = item.quantity;
    final boxCost = item.boxCost;
    final printingCost = item.printingCost;

    return ((basePrice - discountAmount) * quantity) + boxCost + printingCost;
  }

  /// Calculates order total from list of domain items
  double calculateOrderTotal(List<OrderItem> items, Map<String, CardEntity> cardDetails) {
    double total = 0.0;

    for (final item in items) {
      final card = cardDetails[item.cardId];
      if (card != null) {
        total += calculateLineItemTotal(item, card);
      }
    }

    return total;
  }

  /// Calculates total discount for an order
  double calculateTotalDiscount(List<OrderItem> items) {
    double totalDiscount = 0.0;

    for (final item in items) {
      totalDiscount += item.discountAmount * item.quantity;
    }

    return totalDiscount;
  }

  /// Calculates total additional costs (box + printing)
  double calculateTotalAdditionalCosts(List<OrderItem> items) {
    double totalAdditionalCosts = 0.0;

    for (final item in items) {
      totalAdditionalCosts += item.boxCost + item.printingCost;
    }

    return totalAdditionalCosts;
  }

  /// Validates if order is valid for submission
  bool validateOrderSubmission(Order order) {
    return order.customerId.isNotEmpty && order.orderItems.isNotEmpty && order.deliveryDate.isAfter(DateTime.now());
  }

  /// Gets order items count
  int getOrderItemCount(Order order) {
    return order.orderItems.length;
  }
}
