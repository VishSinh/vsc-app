/// Pure business entity representing an order item
class OrderItem {
  final String cardId;
  final double discountAmount;
  final int quantity;
  final bool requiresBox;
  final bool requiresPrinting;
  final OrderBoxType? boxType;
  final double boxCost;
  final double printingCost;

  const OrderItem({
    required this.cardId,
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    required this.requiresPrinting,
    this.boxType,
    required this.boxCost,
    required this.printingCost,
  });

  /// Calculate the line item total
  double calculateLineTotal(double basePrice) {
    final discountedPrice = basePrice - discountAmount;
    final itemSubtotal = discountedPrice * quantity;
    return itemSubtotal + boxCost + printingCost;
  }

  /// Check if the order item is valid
  bool get isValid {
    return cardId.isNotEmpty && quantity > 0 && discountAmount >= 0 && (!requiresBox || boxCost >= 0) && (!requiresPrinting || printingCost >= 0);
  }

  /// Get total additional costs for this item
  double get totalAdditionalCosts => boxCost + printingCost;

  /// Create a copy with updated values
  OrderItem copyWith({
    String? cardId,
    double? discountAmount,
    int? quantity,
    bool? requiresBox,
    bool? requiresPrinting,
    OrderBoxType? boxType,
    double? boxCost,
    double? printingCost,
  }) {
    return OrderItem(
      cardId: cardId ?? this.cardId,
      discountAmount: discountAmount ?? this.discountAmount,
      quantity: quantity ?? this.quantity,
      requiresBox: requiresBox ?? this.requiresBox,
      requiresPrinting: requiresPrinting ?? this.requiresPrinting,
      boxType: boxType ?? this.boxType,
      boxCost: boxCost ?? this.boxCost,
      printingCost: printingCost ?? this.printingCost,
    );
  }
}

/// Box type enum for order items
enum OrderBoxType { folding, complete }
