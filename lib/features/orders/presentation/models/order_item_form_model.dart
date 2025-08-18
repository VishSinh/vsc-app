import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/orders/data/models/order_requests.dart';
import 'package:vsc_app/core/validation/validation_result.dart';

/// Form model for order item creation
class OrderItemCreationFormModel {
  String cardId;
  final String discountAmount;
  final int quantity;
  final bool requiresBox;
  final bool requiresPrinting;
  final OrderBoxType? boxType;
  final String? totalBoxCost;
  final String? totalPrintingCost;

  OrderItemCreationFormModel({
    this.cardId = '',
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    required this.requiresPrinting,
    this.boxType,
    this.totalBoxCost,
    this.totalPrintingCost,
  });

  ValidationResult validate() {
    final errors = <ValidationError>[];

    ValidationResult validateCardId() {
      if (cardId.trim().isEmpty) {
        return ValidationResult.failureSingle('cardId', 'Card is required');
      }
      return ValidationResult.success();
    }

    ValidationResult validateQuantity() {
      if (quantity <= 0) {
        return ValidationResult.failureSingle('quantity', 'Quantity must be greater than 0');
      }
      return ValidationResult.success();
    }

    ValidationResult validateDiscountAmount() {
      final discountAmountValue = double.tryParse(discountAmount);
      if (discountAmountValue == null) {
        return ValidationResult.failureSingle('discountAmount', 'Invalid discount amount');
      } else if (discountAmountValue < 0) {
        return ValidationResult.failureSingle('discountAmount', 'Discount amount cannot be negative');
      }
      return ValidationResult.success();
    }

    ValidationResult validateBoxRequirements() {
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

    ValidationResult validatePrintingRequirements() {
      if (!requiresPrinting) {
        return ValidationResult.success();
      }

      final printingCost = double.tryParse(totalPrintingCost ?? '');
      if (printingCost == null || printingCost < 0) {
        return ValidationResult.failureSingle('totalPrintingCost', 'Valid printing cost is required');
      }

      return ValidationResult.success();
    }

    final cardIdResult = validateCardId();
    if (!cardIdResult.isValid) {
      errors.addAll(cardIdResult.errors);
    }

    final quantityResult = validateQuantity();
    if (!quantityResult.isValid) {
      errors.addAll(quantityResult.errors);
    }

    final discountAmountResult = validateDiscountAmount();
    if (!discountAmountResult.isValid) {
      errors.addAll(discountAmountResult.errors);
    }

    final boxRequirementsResult = validateBoxRequirements();
    if (!boxRequirementsResult.isValid) {
      errors.addAll(boxRequirementsResult.errors);
    }

    final printingRequirementsResult = validatePrintingRequirements();
    if (!printingRequirementsResult.isValid) {
      errors.addAll(printingRequirementsResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  OrderItemRequest toApiRequest() {
    return OrderItemRequest(
      cardId: cardId,
      discountAmount: discountAmount,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: requiresBox ? boxType?.toApiString() : null,
      totalBoxCost: totalBoxCost ?? '0.00',
      totalPrintingCost: totalPrintingCost ?? '0.00',
    );
  }

  /// Create a copy with updated values
  OrderItemCreationFormModel copyWith({
    String? cardId,
    String? discountAmount,
    int? quantity,
    bool? requiresBox,
    bool? requiresPrinting,
    OrderBoxType? boxType,
    String? totalBoxCost,
    String? totalPrintingCost,
  }) {
    return OrderItemCreationFormModel(
      cardId: cardId ?? this.cardId,
      discountAmount: discountAmount ?? this.discountAmount,
      quantity: quantity ?? this.quantity,
      requiresBox: requiresBox ?? this.requiresBox,
      requiresPrinting: requiresPrinting ?? this.requiresPrinting,
      boxType: boxType ?? this.boxType,
      totalBoxCost: totalBoxCost ?? this.totalBoxCost,
      totalPrintingCost: totalPrintingCost ?? this.totalPrintingCost,
    );
  }
}
