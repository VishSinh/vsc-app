import 'package:vsc_app/core/validation/validation_result.dart';

/// Presentation validators for card UI-specific validations
/// These validators handle form field validation and UI state checks
class CardValidators {
  /// Validate cost price field
  static ValidationResult validateCostPrice(String costPrice) {
    if (costPrice.trim().isEmpty) {
      return ValidationResult.failureSingle('costPrice', 'Please enter cost price');
    }

    final costPriceDouble = double.tryParse(costPrice);
    if (costPriceDouble == null) {
      return ValidationResult.failureSingle('costPrice', 'Please enter a valid number');
    }

    if (costPriceDouble < 0) {
      return ValidationResult.failureSingle('costPrice', 'Cost price cannot be negative');
    }

    return ValidationResult.success();
  }

  /// Validate sell price field
  static ValidationResult validateSellPrice(String sellPrice) {
    if (sellPrice.trim().isEmpty) {
      return ValidationResult.failureSingle('sellPrice', 'Please enter sell price');
    }

    final sellPriceDouble = double.tryParse(sellPrice);
    if (sellPriceDouble == null) {
      return ValidationResult.failureSingle('sellPrice', 'Please enter a valid number');
    }

    if (sellPriceDouble <= 0) {
      return ValidationResult.failureSingle('sellPrice', 'Sell price must be greater than 0');
    }

    return ValidationResult.success();
  }

  /// Validate quantity field
  static ValidationResult validateQuantity(String quantity) {
    if (quantity.trim().isEmpty) {
      return ValidationResult.failureSingle('quantity', 'Please enter quantity');
    }

    final quantityInt = int.tryParse(quantity);
    if (quantityInt == null) {
      return ValidationResult.failureSingle('quantity', 'Please enter a valid number');
    }

    if (quantityInt <= 0) {
      return ValidationResult.failureSingle('quantity', 'Quantity must be greater than 0');
    }

    return ValidationResult.success();
  }

  /// Validate max discount field
  static ValidationResult validateMaxDiscount(String maxDiscount) {
    if (maxDiscount.trim().isEmpty) {
      return ValidationResult.failureSingle('maxDiscount', 'Please enter max discount');
    }

    final maxDiscountDouble = double.tryParse(maxDiscount);
    if (maxDiscountDouble == null) {
      return ValidationResult.failureSingle('maxDiscount', 'Please enter a valid number');
    }

    if (maxDiscountDouble < 0) {
      return ValidationResult.failureSingle('maxDiscount', 'Max discount cannot be negative');
    }

    if (maxDiscountDouble > 100) {
      return ValidationResult.failureSingle('maxDiscount', 'Max discount cannot exceed 100%');
    }

    return ValidationResult.success();
  }

  /// Validate vendor ID field
  static ValidationResult validateVendorId(String vendorId) {
    if (vendorId.trim().isEmpty) {
      return ValidationResult.failureSingle('vendorId', 'Please select a vendor');
    }

    return ValidationResult.success();
  }

  /// Validate image field
  static ValidationResult validateImage(dynamic image) {
    if (image == null) {
      return ValidationResult.failureSingle('image', 'Please select an image');
    }

    return ValidationResult.success();
  }

  /// Validate barcode field
  static ValidationResult validateBarcode(String barcode) {
    if (barcode.trim().isEmpty) {
      return ValidationResult.failureSingle('barcode', 'Please enter a barcode');
    }

    return ValidationResult.success();
  }

  /// Validate card form (UI validation)
  static ValidationResult validateCardForm({
    required String costPrice,
    required String sellPrice,
    required String quantity,
    required String maxDiscount,
    required String vendorId,
    dynamic image,
  }) {
    final errors = <ValidationError>[];

    final costPriceResult = validateCostPrice(costPrice);
    if (!costPriceResult.isValid) {
      errors.addAll(costPriceResult.errors);
    }

    final sellPriceResult = validateSellPrice(sellPrice);
    if (!sellPriceResult.isValid) {
      errors.addAll(sellPriceResult.errors);
    }

    final quantityResult = validateQuantity(quantity);
    if (!quantityResult.isValid) {
      errors.addAll(quantityResult.errors);
    }

    final maxDiscountResult = validateMaxDiscount(maxDiscount);
    if (!maxDiscountResult.isValid) {
      errors.addAll(maxDiscountResult.errors);
    }

    final vendorIdResult = validateVendorId(vendorId);
    if (!vendorIdResult.isValid) {
      errors.addAll(vendorIdResult.errors);
    }

    final imageResult = validateImage(image);
    if (!imageResult.isValid) {
      errors.addAll(imageResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
