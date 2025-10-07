import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/enums/card_type.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/cards/data/models/card_requests.dart';

/// Form model for card creation with validation
class CardFormModel {
  final String costPrice;
  final String sellPrice;
  final String quantity;
  final String maxDiscount;
  final String vendorId;
  final XFile? image;
  final CardType cardType;

  CardFormModel({
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
    required this.maxDiscount,
    required this.vendorId,
    this.image,
    required this.cardType,
  });

  /// Create empty form
  factory CardFormModel.empty() {
    return CardFormModel(costPrice: '', sellPrice: '', quantity: '', maxDiscount: '', vendorId: '', cardType: CardType.single);
  }

  /// Create copy with updated fields
  CardFormModel copyWith({
    String? costPrice,
    String? sellPrice,
    String? quantity,
    String? maxDiscount,
    String? vendorId,
    XFile? image,
    CardType? cardType,
  }) {
    return CardFormModel(
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      vendorId: vendorId ?? this.vendorId,
      image: image ?? this.image,
      cardType: cardType ?? this.cardType,
    );
  }

  ValidationResult validate() {
    final errors = <ValidationError>[];

    ValidationResult validateCostPrice() {
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

    ValidationResult validateSellPrice() {
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

    ValidationResult validateQuantity() {
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

    ValidationResult validateMaxDiscount() {
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

    ValidationResult validateVendorId() {
      if (vendorId.trim().isEmpty) {
        return ValidationResult.failureSingle('vendorId', 'Please select a vendor');
      }

      return ValidationResult.success();
    }

    ValidationResult validateImage() {
      if (image == null) {
        return ValidationResult.failureSingle('image', 'Please select an image');
      }

      return ValidationResult.success();
    }

    final costPriceResult = validateCostPrice();
    if (!costPriceResult.isValid) {
      errors.addAll(costPriceResult.errors);
    }

    final sellPriceResult = validateSellPrice();
    if (!sellPriceResult.isValid) {
      errors.addAll(sellPriceResult.errors);
    }

    final quantityResult = validateQuantity();
    if (!quantityResult.isValid) {
      errors.addAll(quantityResult.errors);
    }

    final maxDiscountResult = validateMaxDiscount();
    if (!maxDiscountResult.isValid) {
      errors.addAll(maxDiscountResult.errors);
    }

    final vendorIdResult = validateVendorId();
    if (!vendorIdResult.isValid) {
      errors.addAll(vendorIdResult.errors);
    }

    final imageResult = validateImage();
    if (!imageResult.isValid) {
      errors.addAll(imageResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  CreateCardRequest toApiRequest() {
    return CreateCardRequest(
      costPrice: double.parse(costPrice),
      sellPrice: double.parse(sellPrice),
      quantity: int.parse(quantity),
      maxDiscount: double.parse(maxDiscount),
      vendorId: vendorId,
      cardType: cardType.toApiString(),
    );
  }
}
