import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/models/api_response.dart';

part 'card_model.g.dart';

@JsonSerializable()
class Card {
  final String id;
  @JsonKey(name: 'vendor_id')
  final String vendorId;
  final String barcode;
  @JsonKey(name: 'sell_price')
  final String sellPrice;
  @JsonKey(name: 'cost_price')
  final String costPrice;
  @JsonKey(name: 'max_discount')
  final String maxDiscount;
  final int quantity; // Reverted back to non-nullable
  final String image;
  @JsonKey(name: 'perceptual_hash')
  final String perceptualHash;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const Card({
    required this.id,
    required this.vendorId,
    required this.barcode,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity, // Made required again
    required this.image,
    required this.perceptualHash,
    required this.isActive,
  });

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);

  // Helper methods to convert string prices to double
  double get sellPriceAsDouble => double.tryParse(sellPrice) ?? 0.0;
  double get costPriceAsDouble => double.tryParse(costPrice) ?? 0.0;
  double get maxDiscountAsDouble => double.tryParse(maxDiscount) ?? 0.0;
}

@JsonSerializable()
class CreateCardRequest {
  final String image;
  @JsonKey(name: 'cost_price')
  final double costPrice;
  @JsonKey(name: 'sell_price')
  final double sellPrice;
  final int quantity;
  @JsonKey(name: 'max_discount')
  final double maxDiscount;
  @JsonKey(name: 'vendor_id')
  final String vendorId;

  const CreateCardRequest({
    required this.image,
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
    required this.maxDiscount,
    required this.vendorId,
  });

  factory CreateCardRequest.fromJson(Map<String, dynamic> json) => _$CreateCardRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCardRequestToJson(this);
}

// Type aliases for better readability
typedef CardListResponse = ApiResponse<List<Card>>;
typedef CreateCardResponse = ApiResponse<MessageData>;
