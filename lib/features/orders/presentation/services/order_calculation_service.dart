/// Service for order-related calculations
class OrderCalculationService {
  /// Calculate profit margin percentage
  static double calculateProfitMargin(double sellPrice, double costPrice) {
    if (costPrice == 0) return 0;
    return ((sellPrice - costPrice) / costPrice) * 100;
  }

  /// Calculate total value (price * quantity)
  static double calculateTotalValue(double sellPrice, int quantity) {
    return sellPrice * quantity;
  }

  /// Calculate line item total for creation flow
  static double calculateLineItemTotalForCreation(
    String discountAmount,
    int quantity,
    String? totalBoxCost,
    String? totalPrintingCost,
    double basePrice,
  ) {
    final discount = double.tryParse(discountAmount) ?? 0.0;
    final boxCost = double.tryParse(totalBoxCost ?? '0') ?? 0.0;
    final printingCost = double.tryParse(totalPrintingCost ?? '0') ?? 0.0;

    return ((basePrice - discount) * quantity) + boxCost + printingCost;
  }

  /// Calculate line item total for fetched data
  static double calculateLineItemTotalForFetched(
    String pricePerItem,
    String discountAmount,
    int quantity,
    List<Map<String, dynamic>>? boxOrders,
    List<Map<String, dynamic>>? printingJobs,
  ) {
    final price = double.tryParse(pricePerItem) ?? 0.0;
    final discount = double.tryParse(discountAmount) ?? 0.0;

    final boxCosts = (boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box['total_box_cost'] ?? '0') ?? 0.0));

    final printingCosts = (printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job['total_printing_cost'] ?? '0') ?? 0.0));

    return ((price - discount) * quantity) + boxCosts + printingCosts;
  }

  /// Calculate total discount for creation flow
  static double calculateTotalDiscountForCreation(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) {
      final discountAmount = double.tryParse(item['discount_amount'] ?? '0') ?? 0.0;
      final quantity = item['quantity'] ?? 0;
      return total + (discountAmount * quantity);
    });
  }

  /// Calculate total additional costs for creation flow
  static double calculateTotalAdditionalCostsForCreation(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) {
      final boxCost = double.tryParse(item['total_box_cost'] ?? '0') ?? 0.0;
      final printingCost = double.tryParse(item['total_printing_cost'] ?? '0') ?? 0.0;
      return total + boxCost + printingCost;
    });
  }

  /// Get order item count
  static int getOrderItemCount(List<Map<String, dynamic>> items) {
    return items.fold(0, (total, item) => total + (item['quantity'] as int? ?? 0));
  }
}
