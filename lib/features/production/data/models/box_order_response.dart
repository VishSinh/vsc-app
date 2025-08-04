import 'package:json_annotation/json_annotation.dart';

part 'box_order_response.g.dart';

@JsonSerializable()
class BoxOrderResponse {
  final String id;
  @JsonKey(name: 'order_item_id')
  final String orderItemId;
  @JsonKey(name: 'box_maker_id')
  final String? boxMakerId;
  @JsonKey(name: 'box_maker_name')
  final String? boxMakerName;
  @JsonKey(name: 'box_type')
  final String boxType;
  @JsonKey(name: 'box_quantity')
  final int boxQuantity;
  @JsonKey(name: 'total_box_cost')
  final String totalBoxCost;
  @JsonKey(name: 'total_box_expense')
  final String? totalBoxExpense;
  @JsonKey(name: 'box_status')
  final String boxStatus;
  @JsonKey(name: 'estimated_completion')
  final String? estimatedCompletion;

  const BoxOrderResponse({
    required this.id,
    required this.orderItemId,
    this.boxMakerId,
    this.boxMakerName,
    required this.boxType,
    required this.boxQuantity,
    required this.totalBoxCost,
    this.totalBoxExpense,
    required this.boxStatus,
    this.estimatedCompletion,
  });

  factory BoxOrderResponse.fromJson(Map<String, dynamic> json) => _$BoxOrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BoxOrderResponseToJson(this);
}
