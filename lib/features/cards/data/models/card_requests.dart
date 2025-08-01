import 'package:json_annotation/json_annotation.dart';

part 'card_requests.g.dart';

/// API request model for creating a new card
@JsonSerializable()
class CreateCardRequest {
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
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
    required this.maxDiscount,
    required this.vendorId,
  });

  factory CreateCardRequest.fromJson(Map<String, dynamic> json) => _$CreateCardRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCardRequestToJson(this);
}
