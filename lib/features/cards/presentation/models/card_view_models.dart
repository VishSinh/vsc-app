import 'package:vsc_app/features/cards/domain/models/card.dart';
import 'package:vsc_app/features/cards/domain/services/card_business_service.dart';

/// UI model for displaying card information
/// Contains only formatting and display logic
class CardViewModel {
  final String id;
  final String vendorId;
  final String barcode;
  final String sellPrice;
  final String costPrice;
  final String maxDiscount;
  final int quantity;
  final String image;
  final String perceptualHash;
  final bool isActive;

  // Computed properties for UI
  final double sellPriceAsDouble;
  final double costPriceAsDouble;
  final double maxDiscountAsDouble;
  final double profitMargin;
  final double totalValue;

  const CardViewModel({
    required this.id,
    required this.vendorId,
    required this.barcode,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity,
    required this.image,
    required this.perceptualHash,
    required this.isActive,
    required this.sellPriceAsDouble,
    required this.costPriceAsDouble,
    required this.maxDiscountAsDouble,
    required this.profitMargin,
    required this.totalValue,
  });

  /// Create from domain model with formatting
  factory CardViewModel.fromDomainModel(CardEntity domainModel) {
    final sellPriceAsDouble = domainModel.sellPrice;
    final costPriceAsDouble = domainModel.costPrice;
    final maxDiscountAsDouble = domainModel.maxDiscount;

    // Use domain service for business calculations
    final profitMargin = CardBusinessService.calculateProfitMargin(domainModel.sellPrice, domainModel.costPrice);
    final totalValue = CardBusinessService.calculateTotalValue(domainModel.sellPrice, domainModel.quantity);

    return CardViewModel(
      id: domainModel.id,
      vendorId: domainModel.vendorId,
      barcode: domainModel.barcode,
      sellPrice: sellPriceAsDouble.toString(),
      costPrice: costPriceAsDouble.toString(),
      maxDiscount: maxDiscountAsDouble.toString(),
      quantity: domainModel.quantity,
      image: domainModel.image,
      perceptualHash: domainModel.perceptualHash,
      isActive: domainModel.isActive,
      sellPriceAsDouble: sellPriceAsDouble,
      costPriceAsDouble: costPriceAsDouble,
      maxDiscountAsDouble: maxDiscountAsDouble,
      profitMargin: profitMargin,
      totalValue: totalValue,
    );
  }

  // Formatted getters for UI
  String get formattedSellPrice => '\$${sellPriceAsDouble.toStringAsFixed(2)}';
  String get formattedCostPrice => '\$${costPriceAsDouble.toStringAsFixed(2)}';
  String get formattedMaxDiscount => '${maxDiscountAsDouble.toStringAsFixed(2)}%';
  String get formattedProfitMargin => '${profitMargin.toStringAsFixed(1)}%';
  String get formattedTotalValue => '\$${totalValue.toStringAsFixed(2)}';
  String get formattedQuantity => quantity.toString();
  String get formattedSimilarity => ''; // Not applicable for regular cards
}
