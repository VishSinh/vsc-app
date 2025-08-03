import 'package:json_annotation/json_annotation.dart';

part 'box_order_requests.g.dart';

/// Request model for updating a box order
@JsonSerializable()
class BoxOrderUpdateRequest {
  @JsonKey(name: 'box_maker_id')
  final String? boxMakerId;

  @JsonKey(name: 'total_box_cost')
  final String? totalBoxCost;

  @JsonKey(name: 'box_status')
  final String? boxStatus;

  @JsonKey(name: 'box_type')
  final String? boxType;

  @JsonKey(name: 'box_quantity')
  final int? boxQuantity;

  @JsonKey(name: 'estimated_completion')
  final String? estimatedCompletion;

  const BoxOrderUpdateRequest({this.boxMakerId, this.totalBoxCost, this.boxStatus, this.boxType, this.boxQuantity, this.estimatedCompletion});

  factory BoxOrderUpdateRequest.fromJson(Map<String, dynamic> json) => _$BoxOrderUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BoxOrderUpdateRequestToJson(this);
}
