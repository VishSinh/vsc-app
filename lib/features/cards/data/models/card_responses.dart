import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/models/api_response.dart';

part 'card_responses.g.dart';

/// API response model for card data
@JsonSerializable()
class CardResponse {
  final String id;
  @JsonKey(name: 'vendor_id')
  final String vendorId;
  @JsonKey(name: 'vendor_name')
  final String vendorName;
  final String barcode;
  @JsonKey(name: 'card_type')
  final String cardType;
  @JsonKey(name: 'sell_price')
  final String sellPrice;
  @JsonKey(name: 'cost_price')
  final String costPrice;
  @JsonKey(name: 'max_discount')
  final String maxDiscount;
  final int quantity;
  final String image;
  @JsonKey(name: 'perceptual_hash')
  final String perceptualHash;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const CardResponse({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.barcode,
    required this.cardType,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity,
    required this.image,
    required this.perceptualHash,
    required this.isActive,
  });

  factory CardResponse.fromJson(Map<String, dynamic> json) => _$CardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CardResponseToJson(this);

  // Helper methods to convert string prices to double
  double get sellPriceAsDouble => double.tryParse(sellPrice) ?? 0.0;
  double get costPriceAsDouble => double.tryParse(costPrice) ?? 0.0;
  double get maxDiscountAsDouble => double.tryParse(maxDiscount) ?? 0.0;
}

/// API response model for card creation with full card details
@JsonSerializable()
class CreateCardResponse {
  final String id;
  @JsonKey(name: 'vendor_id')
  final String vendorId;
  @JsonKey(name: 'vendor_name')
  final String vendorName;
  final String barcode;
  @JsonKey(name: 'card_type')
  final String cardType;
  @JsonKey(name: 'sell_price')
  final String sellPrice;
  @JsonKey(name: 'cost_price')
  final String costPrice;
  @JsonKey(name: 'max_discount')
  final String maxDiscount;
  final int quantity;
  final String image;
  @JsonKey(name: 'perceptual_hash')
  final String perceptualHash;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final String message;

  const CreateCardResponse({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.barcode,
    required this.cardType,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity,
    required this.image,
    required this.perceptualHash,
    required this.isActive,
    required this.message,
  });

  factory CreateCardResponse.fromJson(Map<String, dynamic> json) => _$CreateCardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCardResponseToJson(this);

  // Helper methods to convert string prices to double
  double get sellPriceAsDouble => double.tryParse(sellPrice) ?? 0.0;
  double get costPriceAsDouble => double.tryParse(costPrice) ?? 0.0;
  double get maxDiscountAsDouble => double.tryParse(maxDiscount) ?? 0.0;
}

/// API response model for similar card data
@JsonSerializable()
class SimilarCardResponse {
  final String id;
  @JsonKey(name: 'vendor_id')
  final String vendorId;
  final String barcode;
  @JsonKey(name: 'card_type')
  final String cardType;
  @JsonKey(name: 'sell_price')
  final String sellPrice;
  @JsonKey(name: 'cost_price')
  final String costPrice;
  @JsonKey(name: 'max_discount')
  final String maxDiscount;
  final int quantity;
  final String image;
  @JsonKey(name: 'perceptual_hash')
  final String perceptualHash;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const SimilarCardResponse({
    required this.id,
    required this.vendorId,
    required this.barcode,
    required this.cardType,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity,
    required this.image,
    required this.perceptualHash,
    required this.isActive,
  });

  factory SimilarCardResponse.fromJson(Map<String, dynamic> json) => _$SimilarCardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SimilarCardResponseToJson(this);

  // Helper methods to convert string prices to double
  double get sellPriceAsDouble => double.tryParse(sellPrice) ?? 0.0;
  double get costPriceAsDouble => double.tryParse(costPrice) ?? 0.0;
  double get maxDiscountAsDouble => double.tryParse(maxDiscount) ?? 0.0;
}

// Type aliases for better readability
typedef CardListResponse = ApiResponse<List<CardResponse>>;
typedef SimilarCardListResponse = ApiResponse<List<SimilarCardResponse>>;
typedef CreateCardApiResponse = ApiResponse<CreateCardResponse>;
