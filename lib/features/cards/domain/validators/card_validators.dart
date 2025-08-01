import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/cards/domain/models/card.dart';

/// Domain validators for card business rules
/// Contains business logic validation that is independent of UI
class CardDomainValidators {
  /// Validate card has required business fields
  static ValidationResult validateCard(CardEntity card) {
    final errors = <ValidationError>[];

    if (card.id.isEmpty) {
      errors.add(ValidationError(field: 'id', message: 'Card ID is required'));
    }

    if (card.vendorId.isEmpty) {
      errors.add(ValidationError(field: 'vendorId', message: 'Vendor ID is required'));
    }

    if (card.barcode.isEmpty) {
      errors.add(ValidationError(field: 'barcode', message: 'Barcode is required'));
    }

    if (card.sellPrice <= 0) {
      errors.add(ValidationError(field: 'sellPrice', message: 'Sell price must be greater than 0'));
    }

    if (card.costPrice < 0) {
      errors.add(ValidationError(field: 'costPrice', message: 'Cost price cannot be negative'));
    }

    if (card.quantity < 0) {
      errors.add(ValidationError(field: 'quantity', message: 'Quantity cannot be negative'));
    }

    if (card.maxDiscount < 0) {
      errors.add(ValidationError(field: 'maxDiscount', message: 'Max discount cannot be negative'));
    }

    if (card.maxDiscount > 100) {
      errors.add(ValidationError(field: 'maxDiscount', message: 'Max discount cannot exceed 100%'));
    }

    if (card.sellPrice < card.costPrice) {
      errors.add(ValidationError(field: 'sellPrice', message: 'Sell price cannot be less than cost price'));
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  /// Validate card has sufficient stock for order
  static ValidationResult validateStockAvailability(CardEntity card, int requestedQuantity) {
    if (requestedQuantity <= 0) {
      return ValidationResult.failureSingle('quantity', 'Requested quantity must be greater than 0');
    }

    if (requestedQuantity > card.quantity) {
      return ValidationResult.failureSingle('quantity', 'Insufficient stock. Available: ${card.quantity}, Requested: $requestedQuantity');
    }

    return ValidationResult.success();
  }

  /// Validate discount amount is within allowed range
  static ValidationResult validateDiscountAmount(double discountAmount, CardEntity card) {
    if (discountAmount < 0) {
      return ValidationResult.failureSingle('discount', 'Discount amount cannot be negative');
    }

    final maxDiscountAmount = card.sellPrice * (card.maxDiscount / 100);
    if (discountAmount > maxDiscountAmount) {
      return ValidationResult.failureSingle(
        'discount',
        'Discount amount exceeds maximum allowed discount of ₹${maxDiscountAmount.toStringAsFixed(2)}',
      );
    }

    return ValidationResult.success();
  }

  /// Validate card is active for operations
  static ValidationResult validateCardActive(CardEntity card) {
    if (!card.isActive) {
      return ValidationResult.failureSingle('card', 'Card is not active and cannot be used');
    }

    return ValidationResult.success();
  }

  /// Validate card has valid pricing structure
  static ValidationResult validatePricingStructure(CardEntity card) {
    if (card.sellPrice <= card.costPrice) {
      return ValidationResult.failureSingle('pricing', 'Sell price must be greater than cost price for profitable operations');
    }

    final profitMargin = ((card.sellPrice - card.costPrice) / card.sellPrice) * 100;
    if (profitMargin < 5) {
      return ValidationResult.failureSingle('pricing', 'Profit margin is too low (${profitMargin.toStringAsFixed(1)}%). Minimum 5% required.');
    }

    return ValidationResult.success();
  }

  /// Validate card has required image
  static ValidationResult validateCardImage(CardEntity card) {
    if (card.image.isEmpty) {
      return ValidationResult.failureSingle('image', 'Card image is required');
    }

    return ValidationResult.success();
  }

  /// Validate card has valid perceptual hash for similarity matching
  static ValidationResult validatePerceptualHash(CardEntity card) {
    if (card.perceptualHash.isEmpty) {
      return ValidationResult.failureSingle('perceptualHash', 'Perceptual hash is required for similarity matching');
    }

    return ValidationResult.success();
  }
}
