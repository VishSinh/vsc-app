import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/cards/data/models/card_update_request.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

class CardUpdateFormModel {
  final String? costPrice;
  final String? sellPrice;
  final String? quantity;
  final String? maxDiscount;
  final String? vendorId;
  final XFile? image;

  CardUpdateFormModel({this.costPrice, this.sellPrice, this.quantity, this.maxDiscount, this.vendorId, this.image});

  /// Create form model from existing card data
  factory CardUpdateFormModel.fromCard(CardViewModel card) {
    return CardUpdateFormModel(
      costPrice: card.costPrice,
      sellPrice: card.sellPrice,
      quantity: card.quantity.toString(),
      maxDiscount: card.maxDiscount,
      vendorId: card.vendorId,
      image: null, // Image will be optional for updates
    );
  }

  /// Create copy with updated fields
  CardUpdateFormModel copyWith({String? costPrice, String? sellPrice, String? quantity, String? maxDiscount, String? vendorId, XFile? image}) {
    return CardUpdateFormModel(
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      vendorId: vendorId ?? this.vendorId,
      image: image ?? this.image,
    );
  }

  ValidationResult validate() {
    final errors = <ValidationError>[];

    ValidationResult validateCostPrice() {
      if (costPrice != null) {
        if (costPrice!.trim().isEmpty) {
          return ValidationResult.failureSingle('costPrice', 'Please enter cost price');
        }

        final costPriceValue = double.tryParse(costPrice!);
        if (costPriceValue == null) {
          return ValidationResult.failureSingle('costPrice', 'Please enter a valid number');
        }

        if (costPriceValue < 0) {
          return ValidationResult.failureSingle('costPrice', 'Cost price cannot be negative');
        }
      }

      return ValidationResult.success();
    }

    ValidationResult validateSellPrice() {
      if (sellPrice != null) {
        if (sellPrice!.trim().isEmpty) {
          return ValidationResult.failureSingle('sellPrice', 'Please enter sell price');
        }

        final sellPriceValue = double.tryParse(sellPrice!);
        if (sellPriceValue == null) {
          return ValidationResult.failureSingle('sellPrice', 'Please enter a valid number');
        }

        if (sellPriceValue <= 0) {
          return ValidationResult.failureSingle('sellPrice', 'Sell price must be greater than 0');
        }
      }

      return ValidationResult.success();
    }

    ValidationResult validateQuantity() {
      if (quantity != null) {
        if (quantity!.trim().isEmpty) {
          return ValidationResult.failureSingle('quantity', 'Please enter quantity');
        }

        final quantityValue = int.tryParse(quantity!);
        if (quantityValue == null) {
          return ValidationResult.failureSingle('quantity', 'Please enter a valid number');
        }

        if (quantityValue <= 0) {
          return ValidationResult.failureSingle('quantity', 'Quantity must be greater than 0');
        }
      }

      return ValidationResult.success();
    }

    ValidationResult validateMaxDiscount() {
      if (maxDiscount != null) {
        if (maxDiscount!.trim().isEmpty) {
          return ValidationResult.failureSingle('maxDiscount', 'Please enter max discount');
        }

        final maxDiscountValue = double.tryParse(maxDiscount!);
        if (maxDiscountValue == null) {
          return ValidationResult.failureSingle('maxDiscount', 'Please enter a valid number');
        }

        if (maxDiscountValue < 0) {
          return ValidationResult.failureSingle('maxDiscount', 'Max discount cannot be negative');
        }

        if (maxDiscountValue > 100) {
          return ValidationResult.failureSingle('maxDiscount', 'Max discount cannot exceed 100%');
        }
      }

      return ValidationResult.success();
    }

    ValidationResult validateVendorId() {
      if (vendorId != null && vendorId!.trim().isEmpty) {
        return ValidationResult.failureSingle('vendorId', 'Please select a vendor');
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

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  CardUpdateRequest toApiRequest() {
    return CardUpdateRequest(
      costPrice: costPrice?.isNotEmpty == true ? double.parse(costPrice!) : null,
      sellPrice: sellPrice?.isNotEmpty == true ? double.parse(sellPrice!) : null,
      quantity: quantity?.isNotEmpty == true ? int.parse(quantity!) : null,
      maxDiscount: maxDiscount?.isNotEmpty == true ? double.parse(maxDiscount!) : null,
      vendorId: vendorId?.isNotEmpty == true ? vendorId : null,
    );
  }
}
