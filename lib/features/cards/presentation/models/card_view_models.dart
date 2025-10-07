import 'package:vsc_app/features/cards/data/models/card_responses.dart';
import 'package:vsc_app/core/enums/card_type.dart';
import 'package:vsc_app/features/cards/presentation/services/card_calculation_service.dart';

/// UI model for displaying card information
/// Contains only formatting and display logic
class CardViewModel {
  final String id;
  final String vendorId;
  final String vendorName;
  final String barcode;
  final CardType? cardType;
  final String cardTypeRaw;
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
    required this.vendorName,
    required this.barcode,
    required this.cardType,
    required this.cardTypeRaw,
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

  /// Create from API response with direct conversion
  factory CardViewModel.fromApiResponse(CardResponse response) {
    final sellPriceAsDouble = response.sellPriceAsDouble;
    final costPriceAsDouble = response.costPriceAsDouble;
    final maxDiscountAsDouble = response.maxDiscountAsDouble;

    // Calculate business logic using presentation service
    final profitMargin = CardCalculationService.calculateProfitMargin(sellPriceAsDouble, costPriceAsDouble);
    final totalValue = CardCalculationService.calculateTotalValue(sellPriceAsDouble, response.quantity);

    return CardViewModel(
      id: response.id,
      vendorId: response.vendorId,
      vendorName: response.vendorName,
      barcode: response.barcode,
      cardType: CardTypeExtension.fromApiString(response.cardType),
      cardTypeRaw: response.cardType,
      sellPrice: sellPriceAsDouble.toString(),
      costPrice: costPriceAsDouble.toString(),
      maxDiscount: maxDiscountAsDouble.toString(),
      quantity: response.quantity,
      image: response.image,
      perceptualHash: response.perceptualHash,
      isActive: response.isActive,
      sellPriceAsDouble: sellPriceAsDouble,
      costPriceAsDouble: costPriceAsDouble,
      maxDiscountAsDouble: maxDiscountAsDouble,
      profitMargin: profitMargin,
      totalValue: totalValue,
    );
  }

  // Formatted getters for UI
  String get formattedSellPrice => '₹${sellPriceAsDouble.toStringAsFixed(2)}';
  String get formattedCostPrice => '₹${costPriceAsDouble.toStringAsFixed(2)}';
  String get formattedMaxDiscount => '${maxDiscountAsDouble.toStringAsFixed(2)}%';
  String get formattedProfitMargin => '${profitMargin.toStringAsFixed(1)}%';
  String get formattedTotalValue => '₹${totalValue.toStringAsFixed(2)}';
  String get formattedQuantity => quantity.toString();
  String get formattedSimilarity => ''; // Not applicable for regular cards
}

/// UI model for displaying similar card information
/// Contains only formatting and display logic
class SimilarCardViewModel {
  final String id;
  final String vendorId;
  final String barcode;
  final CardType? cardType;
  final String cardTypeRaw;
  final String sellPrice;
  final String costPrice;
  final String maxDiscount;
  final int quantity;
  final String image;
  final String perceptualHash;
  final bool isActive;
  final double similarity;

  // Computed properties for UI
  final double sellPriceAsDouble;
  final double costPriceAsDouble;
  final double maxDiscountAsDouble;
  final double profitMargin;
  final double totalValue;

  const SimilarCardViewModel({
    required this.id,
    required this.vendorId,
    required this.barcode,
    required this.cardType,
    required this.cardTypeRaw,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity,
    required this.image,
    required this.perceptualHash,
    required this.isActive,
    required this.similarity,
    required this.sellPriceAsDouble,
    required this.costPriceAsDouble,
    required this.maxDiscountAsDouble,
    required this.profitMargin,
    required this.totalValue,
  });

  /// Create from API response with direct conversion
  factory SimilarCardViewModel.fromApiResponse(CardResponse response, {double similarity = 0.0}) {
    final sellPriceAsDouble = response.sellPriceAsDouble;
    final costPriceAsDouble = response.costPriceAsDouble;
    final maxDiscountAsDouble = response.maxDiscountAsDouble;

    // Calculate business logic using presentation service
    final profitMargin = CardCalculationService.calculateProfitMargin(sellPriceAsDouble, costPriceAsDouble);
    final totalValue = CardCalculationService.calculateTotalValue(sellPriceAsDouble, response.quantity);

    return SimilarCardViewModel(
      id: response.id,
      vendorId: response.vendorId,
      barcode: response.barcode,
      cardType: CardTypeExtension.fromApiString(response.cardType),
      cardTypeRaw: response.cardType,
      sellPrice: sellPriceAsDouble.toString(),
      costPrice: costPriceAsDouble.toString(),
      maxDiscount: maxDiscountAsDouble.toString(),
      quantity: response.quantity,
      image: response.image,
      perceptualHash: response.perceptualHash,
      isActive: response.isActive,
      similarity: similarity,
      sellPriceAsDouble: sellPriceAsDouble,
      costPriceAsDouble: costPriceAsDouble,
      maxDiscountAsDouble: maxDiscountAsDouble,
      profitMargin: profitMargin,
      totalValue: totalValue,
    );
  }

  // Formatted getters for UI
  String get formattedSellPrice => '₹${sellPriceAsDouble.toStringAsFixed(2)}';
  String get formattedCostPrice => '₹${costPriceAsDouble.toStringAsFixed(2)}';
  String get formattedMaxDiscount => '${maxDiscountAsDouble.toStringAsFixed(2)}%';
  String get formattedProfitMargin => '${profitMargin.toStringAsFixed(1)}%';
  String get formattedTotalValue => '₹${totalValue.toStringAsFixed(2)}';
  String get formattedQuantity => quantity.toString();
  String get formattedSimilarity => CardCalculationService.formatSimilarityScore(similarity);
}
