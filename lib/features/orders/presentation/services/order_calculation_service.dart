/// Service for order-related calculations
class OrderCalculationService {
  static double parseDouble(String? value, [double defaultValue = 0.0]) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  // Order Item Calculations

  static double calculateBaseLineTotal(double price, double discount, int quantity) {
    return (price - discount) * quantity;
  }

  static double calculateItemTotal(dynamic item) {
    final price = parseDouble(item.pricePerItem);
    final discount = parseDouble(item.discountAmount);
    final quantity = item.quantity;

    double total = calculateBaseLineTotal(price, discount, quantity);

    if (item.boxOrders != null) {
      for (final box in item.boxOrders) {
        total += parseDouble(box.totalBoxCost);
      }
    }

    if (item.printingJobs != null) {
      for (final job in item.printingJobs) {
        total += parseDouble(job.totalPrintingCost);
      }
    }

    return total;
  }

  static double calculateLineItemTotalWithParams({
    required double basePrice,
    required String discountAmount,
    required int quantity,
    String? totalBoxCost,
    String? totalPrintingCost,
  }) {
    final discount = parseDouble(discountAmount);
    final boxCost = parseDouble(totalBoxCost);
    final printingCost = parseDouble(totalPrintingCost);

    return calculateBaseLineTotal(basePrice, discount, quantity) + boxCost + printingCost;
  }

  // Order Total Calculations

  static double calculateOrderTotal(List<dynamic> orderItems, {List<dynamic> serviceItems = const []}) {
    double total = 0.0;

    for (final item in orderItems) {
      total += calculateItemTotal(item);
    }

    // Add service items total_cost
    for (final svc in serviceItems) {
      final cost = parseDouble(svc.totalCost);
      total += cost;
    }

    return total;
  }

  static double calculateTotalDiscount(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) {
      final discountAmount = parseDouble(item['discount_amount']);
      final quantity = item['quantity'] as int? ?? 0;
      return total + (discountAmount * quantity);
    });
  }

  static double calculateTotalAdditionalCosts(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) {
      final boxCost = parseDouble(item['total_box_cost']);
      final printingCost = parseDouble(item['total_printing_cost']);
      return total + boxCost + printingCost;
    });
  }

  static int getOrderItemCount(List<Map<String, dynamic>> items) {
    return items.fold(0, (total, item) => total + (item['quantity'] as int? ?? 0));
  }

  // Legacy Methods (Kept for backward compatibility)

  static double calculateLineItemTotalForCreation(
    String discountAmount,
    int quantity,
    String? totalBoxCost,
    String? totalPrintingCost,
    double basePrice,
  ) {
    return calculateLineItemTotalWithParams(
      basePrice: basePrice,
      discountAmount: discountAmount,
      quantity: quantity,
      totalBoxCost: totalBoxCost,
      totalPrintingCost: totalPrintingCost,
    );
  }

  static double calculateLineItemTotalForFetched(
    String pricePerItem,
    String discountAmount,
    int quantity,
    List<Map<String, dynamic>>? boxOrders,
    List<Map<String, dynamic>>? printingJobs,
  ) {
    final price = parseDouble(pricePerItem);
    final discount = parseDouble(discountAmount);

    final boxCosts = (boxOrders ?? []).fold(0.0, (sum, box) => sum + parseDouble(box['total_box_cost']));
    final printingCosts = (printingJobs ?? []).fold(0.0, (sum, job) => sum + parseDouble(job['total_printing_cost']));

    return calculateBaseLineTotal(price, discount, quantity) + boxCosts + printingCosts;
  }

  static double calculateTotalDiscountForCreation(List<Map<String, dynamic>> items) {
    return calculateTotalDiscount(items);
  }

  static double calculateTotalAdditionalCostsForCreation(List<Map<String, dynamic>> items) {
    return calculateTotalAdditionalCosts(items);
  }
}
