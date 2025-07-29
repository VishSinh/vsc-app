import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/models/api_response.dart';

part 'card_model.g.dart';

@JsonSerializable()
class Card {
  final String? id;
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
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Card({
    this.id,
    required this.image,
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
    required this.maxDiscount,
    required this.vendorId,
    this.createdAt,
    this.updatedAt,
  });

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);
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

typedef CreateCardResponse = ApiResponse<MessageData>;
