import '../models/order_item.dart';
import 'package:vsc_app/core/validation/validation_result.dart';

/// Domain validators for business rule validations
/// These validators enforce business logic and rules
class OrderDomainValidators {
  /// Validates quantity against business rules
  static ValidationResult validateQuantity(int quantity, int availableStock) {
    if (quantity <= 0) {
      return ValidationResult.failureSingle('quantity', 'Quantity must be greater than 0');
    }
    if (quantity > availableStock) {
      return ValidationResult.failureSingle('quantity', 'Quantity exceeds available stock ($availableStock)');
    }
    return ValidationResult.success();
  }

  /// Validates discount amount against business rules
  static ValidationResult validateDiscountAmount(double discountAmount, double maxDiscount) {
    if (discountAmount < 0) {
      return ValidationResult.failureSingle('discount', 'Discount cannot be negative');
    }
    if (discountAmount > maxDiscount) {
      return ValidationResult.failureSingle('discount', 'Discount cannot exceed maximum discount (₹${maxDiscount.toStringAsFixed(2)})');
    }
    return ValidationResult.success();
  }

  /// Validates box cost against business rules
  static ValidationResult validateBoxCost(double? boxCost, bool requiresBox) {
    if (!requiresBox) return ValidationResult.success();

    if (boxCost == null || boxCost < 0) {
      return ValidationResult.failureSingle('boxCost', 'Box cost must be a valid positive amount');
    }
    return ValidationResult.success();
  }

  /// Validates printing cost against business rules
  static ValidationResult validatePrintingCost(double? printingCost, bool requiresPrinting) {
    if (!requiresPrinting) return ValidationResult.success();

    if (printingCost == null || printingCost < 0) {
      return ValidationResult.failureSingle('printingCost', 'Printing cost must be a valid positive amount');
    }
    return ValidationResult.success();
  }

  /// Validates if card is already in order (business rule)
  static ValidationResult validateCardNotInOrder(String cardId, List<OrderItem> orderItems) {
    final existingItem = orderItems.where((item) => item.cardId == cardId).firstOrNull;
    if (existingItem != null) {
      return ValidationResult.failureSingle('cardId', 'This card is already added to the order');
    }
    return ValidationResult.success();
  }

  /// Validates if item can be added to order (business rules)
  static ValidationResult validateItemAddition({
    required String cardId,
    required List<OrderItem> existingItems,
    required int quantity,
    required int availableStock,
  }) {
    final errors = <ValidationError>[];

    // Check if card is already in order items
    final existingItem = existingItems.where((item) => item.cardId == cardId).firstOrNull;
    if (existingItem != null) {
      errors.add(const ValidationError(field: 'cardId', message: 'This card is already added to the order'));
    }

    // Validate quantity
    final quantityResult = validateQuantity(quantity, availableStock);
    if (!quantityResult.isValid) {
      errors.addAll(quantityResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  /// Validates order item against business rules
  static ValidationResult validateOrderItem(OrderItem item, int availableStock) {
    final errors = <ValidationError>[];

    // Validate quantity
    final quantityResult = validateQuantity(item.quantity, availableStock);
    if (!quantityResult.isValid) {
      errors.addAll(quantityResult.errors);
    }

    // Validate discount amount
    if (item.discountAmount < 0) {
      errors.add(const ValidationError(field: 'discount', message: 'Discount cannot be negative'));
    }

    // Validate box cost
    final boxCostResult = validateBoxCost(item.boxCost, item.requiresBox);
    if (!boxCostResult.isValid) {
      errors.addAll(boxCostResult.errors);
    }

    // Validate printing cost
    final printingCostResult = validatePrintingCost(item.printingCost, item.requiresPrinting);
    if (!printingCostResult.isValid) {
      errors.addAll(printingCostResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  /// Validates order against business rules
  static ValidationResult validateOrder(List<OrderItem> orderItems) {
    if (orderItems.isEmpty) {
      return ValidationResult.failureSingle('orderItems', 'Order must contain at least one item');
    }

    final errors = <ValidationError>[];

    // Validate each item
    for (int i = 0; i < orderItems.length; i++) {
      final item = orderItems[i];
      if (!item.isValid) {
        errors.add(ValidationError(field: 'orderItems[$i]', message: 'Order contains invalid items'));
      }
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
