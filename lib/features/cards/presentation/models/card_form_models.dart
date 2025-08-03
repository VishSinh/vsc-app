import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/cards/data/models/card_requests.dart';
import 'package:vsc_app/features/cards/presentation/services/card_validators.dart';

/// Form model for card creation with validation
class CardFormViewModel {
  final String costPrice;
  final String sellPrice;
  final String quantity;
  final String maxDiscount;
  final String vendorId;
  final XFile? image;

  // Validation errors
  final String? costPriceError;
  final String? sellPriceError;
  final String? quantityError;
  final String? maxDiscountError;
  final String? vendorIdError;
  final String? imageError;

  // Validation helper
  final bool isValid;

  const CardFormViewModel({
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
    required this.maxDiscount,
    required this.vendorId,
    this.image,
    this.costPriceError,
    this.sellPriceError,
    this.quantityError,
    this.maxDiscountError,
    this.vendorIdError,
    this.imageError,
    required this.isValid,
  });

  /// Create from form data with validation
  factory CardFormViewModel.fromFormData({
    required String costPrice,
    required String sellPrice,
    required String quantity,
    required String maxDiscount,
    required String vendorId,
    XFile? image,
  }) {
    // Validate all fields
    final costPriceResult = CardValidators.validateCostPrice(costPrice);
    final sellPriceResult = CardValidators.validateSellPrice(sellPrice);
    final quantityResult = CardValidators.validateQuantity(quantity);
    final maxDiscountResult = CardValidators.validateMaxDiscount(maxDiscount);
    final vendorIdResult = CardValidators.validateVendorId(vendorId);
    final imageResult = CardValidators.validateImage(image);

    // Check if form is valid
    final isValid =
        costPriceResult.isValid &&
        sellPriceResult.isValid &&
        quantityResult.isValid &&
        maxDiscountResult.isValid &&
        vendorIdResult.isValid &&
        imageResult.isValid;

    return CardFormViewModel(
      costPrice: costPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      maxDiscount: maxDiscount,
      vendorId: vendorId,
      image: image,
      costPriceError: costPriceResult.isValid ? null : costPriceResult.firstMessage,
      sellPriceError: sellPriceResult.isValid ? null : sellPriceResult.firstMessage,
      quantityError: quantityResult.isValid ? null : quantityResult.firstMessage,
      maxDiscountError: maxDiscountResult.isValid ? null : maxDiscountResult.firstMessage,
      vendorIdError: vendorIdResult.isValid ? null : vendorIdResult.firstMessage,
      imageError: imageResult.isValid ? null : imageResult.firstMessage,
      isValid: isValid,
    );
  }

  /// Create empty form
  factory CardFormViewModel.empty() {
    return CardFormViewModel(costPrice: '', sellPrice: '', quantity: '', maxDiscount: '', vendorId: '', image: null, isValid: false);
  }

  /// Create copy with updated fields
  CardFormViewModel copyWith({String? costPrice, String? sellPrice, String? quantity, String? maxDiscount, String? vendorId, XFile? image}) {
    return CardFormViewModel.fromFormData(
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      vendorId: vendorId ?? this.vendorId,
      image: image ?? this.image,
    );
  }

  // Helper getters
  double? get costPriceAsDouble => double.tryParse(costPrice);
  double? get sellPriceAsDouble => double.tryParse(sellPrice);
  int? get quantityAsInt => int.tryParse(quantity);
  double? get maxDiscountAsDouble => double.tryParse(maxDiscount);

  /// Validates the card form
  ValidationResult validate() {
    final errors = <String>[];

    if (costPrice.isEmpty) {
      errors.add('Cost price is required');
    } else if (costPriceAsDouble == null || costPriceAsDouble! <= 0) {
      errors.add('Cost price must be a positive number');
    }

    if (sellPrice.isEmpty) {
      errors.add('Sell price is required');
    } else if (sellPriceAsDouble == null || sellPriceAsDouble! <= 0) {
      errors.add('Sell price must be a positive number');
    }

    if (quantity.isEmpty) {
      errors.add('Quantity is required');
    } else if (quantityAsInt == null || quantityAsInt! <= 0) {
      errors.add('Quantity must be a positive number');
    }

    if (maxDiscount.isEmpty) {
      errors.add('Max discount is required');
    } else if (maxDiscountAsDouble == null || maxDiscountAsDouble! < 0) {
      errors.add('Max discount must be a non-negative number');
    }

    if (vendorId.isEmpty) {
      errors.add('Vendor is required');
    }

    if (image == null) {
      errors.add('Image is required');
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors.map((e) => ValidationError(field: 'card', message: e)).toList());
  }

  /// Convert form model to API request
  CreateCardRequest toApiRequest() {
    return CreateCardRequest(
      costPrice: costPriceAsDouble ?? 0.0,
      sellPrice: sellPriceAsDouble ?? 0.0,
      quantity: quantityAsInt ?? 0,
      maxDiscount: maxDiscountAsDouble ?? 0.0,
      vendorId: vendorId,
    );
  }
}
