import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/core/validation/validation_result.dart';

/// Service for order-related validations that involve multiple model variables
class OrderValidators {
  /// Validate card ID field
  static ValidationResult validateCardId(String cardId) {
    if (cardId.trim().isEmpty) {
      return ValidationResult.failureSingle('cardId', 'Card is required');
    }
    return ValidationResult.success();
  }

  /// Validate quantity field
  static ValidationResult validateQuantity(int quantity) {
    if (quantity <= 0) {
      return ValidationResult.failureSingle('quantity', 'Quantity must be greater than 0');
    }
    return ValidationResult.success();
  }

  /// Validate discount amount field
  static ValidationResult validateDiscountAmount(String discountAmount) {
    final discountAmountValue = double.tryParse(discountAmount);
    if (discountAmountValue == null) {
      return ValidationResult.failureSingle('discountAmount', 'Invalid discount amount');
    } else if (discountAmountValue < 0) {
      return ValidationResult.failureSingle('discountAmount', 'Discount amount cannot be negative');
    }
    return ValidationResult.success();
  }

  /// Validate box requirements
  static ValidationResult validateBoxRequirements(bool requiresBox, OrderBoxType? boxType, String? totalBoxCost) {
    if (!requiresBox) {
      return ValidationResult.success();
    }

    if (boxType == null) {
      return ValidationResult.failureSingle('boxType', 'Box type is required');
    }

    final boxCost = double.tryParse(totalBoxCost ?? '');
    if (boxCost == null || boxCost < 0) {
      return ValidationResult.failureSingle('totalBoxCost', 'Valid box cost is required');
    }

    return ValidationResult.success();
  }

  /// Validate printing requirements
  static ValidationResult validatePrintingRequirements(bool requiresPrinting, String? totalPrintingCost) {
    if (!requiresPrinting) {
      return ValidationResult.success();
    }

    final printingCost = double.tryParse(totalPrintingCost ?? '');
    if (printingCost == null || printingCost < 0) {
      return ValidationResult.failureSingle('totalPrintingCost', 'Valid printing cost is required');
    }

    return ValidationResult.success();
  }

  /// Validate order item form
  static ValidationResult validateOrderItem({
    required String cardId,
    required String discountAmount,
    required int quantity,
    required bool requiresBox,
    required bool requiresPrinting,
    OrderBoxType? boxType,
    String? totalBoxCost,
    String? totalPrintingCost,
  }) {
    final errors = <ValidationError>[];

    final cardIdResult = validateCardId(cardId);
    if (!cardIdResult.isValid) {
      errors.addAll(cardIdResult.errors);
    }

    final quantityResult = validateQuantity(quantity);
    if (!quantityResult.isValid) {
      errors.addAll(quantityResult.errors);
    }

    final discountAmountResult = validateDiscountAmount(discountAmount);
    if (!discountAmountResult.isValid) {
      errors.addAll(discountAmountResult.errors);
    }

    final boxRequirementsResult = validateBoxRequirements(requiresBox, boxType, totalBoxCost);
    if (!boxRequirementsResult.isValid) {
      errors.addAll(boxRequirementsResult.errors);
    }

    final printingRequirementsResult = validatePrintingRequirements(requiresPrinting, totalPrintingCost);
    if (!printingRequirementsResult.isValid) {
      errors.addAll(printingRequirementsResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
