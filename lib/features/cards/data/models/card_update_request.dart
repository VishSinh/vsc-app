// class CardUpdateSerializer(BaseSerializer):
//     image = serializers.ImageField(required=False)
//     cost_price = serializers.DecimalField(required=False, max_digits=PRICE_MAX_DIGITS, decimal_places=PRICE_DECIMAL_PLACES, min_value=0)
//     sell_price = serializers.DecimalField(required=False, max_digits=PRICE_MAX_DIGITS, decimal_places=PRICE_DECIMAL_PLACES, min_value=0)
//     max_discount = serializers.DecimalField(required=False, max_digits=PRICE_MAX_DIGITS, decimal_places=PRICE_DECIMAL_PLACES, min_value=0)
//     quantity = serializers.IntegerField(required=False, min_value=0)
//     vendor_id = serializers.UUIDField(required=False)

import 'package:json_annotation/json_annotation.dart';

part 'card_update_request.g.dart';

@JsonSerializable()
class CardUpdateRequest {
  @JsonKey(name: 'cost_price')
  final double? costPrice;
  @JsonKey(name: 'sell_price')
  final double? sellPrice;
  @JsonKey(name: 'max_discount')
  final double? maxDiscount;
  final int? quantity;
  @JsonKey(name: 'vendor_id')
  final String? vendorId;
  @JsonKey(name: 'card_type')
  final String? cardType; // Use CardTypeExtension.toApiString()

  const CardUpdateRequest({this.costPrice, this.sellPrice, this.maxDiscount, this.quantity, this.vendorId, this.cardType});

  factory CardUpdateRequest.fromJson(Map<String, dynamic> json) => _$CardUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CardUpdateRequestToJson(this);
}
