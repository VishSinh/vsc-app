import 'package:json_annotation/json_annotation.dart';

part 'order_api_models.g.dart';

enum BoxType {
  @JsonValue('FOLDING')
  folding,
  @JsonValue('COMPLETE')
  complete,
}

@JsonSerializable()
class OrderItemApiModel {
  @JsonKey(name: 'card_id')
  final String cardId;
  @JsonKey(name: 'discount_amount')
  final String discountAmount;
  final int quantity;
  @JsonKey(name: 'requires_box')
  final bool requiresBox;
  @JsonKey(name: 'requires_printing')
  final bool requiresPrinting;
  @JsonKey(name: 'box_type')
  final BoxType? boxType;
  @JsonKey(name: 'total_box_cost')
  final String? totalBoxCost;
  @JsonKey(name: 'total_printing_cost')
  final String? totalPrintingCost;

  const OrderItemApiModel({
    required this.cardId,
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    required this.requiresPrinting,
    this.boxType,
    this.totalBoxCost,
    this.totalPrintingCost,
  });

  factory OrderItemApiModel.fromJson(Map<String, dynamic> json) => _$OrderItemApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemApiModelToJson(this);
}
