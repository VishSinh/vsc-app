import 'package:json_annotation/json_annotation.dart';
import 'order_api_models.dart';

part 'order_responses.g.dart';

@JsonSerializable()
class OrderResponse {
  final String id;
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'delivery_date')
  final String deliveryDate;
  @JsonKey(name: 'order_items')
  final List<OrderItemApiModel> orderItems;
  final String status;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const OrderResponse({
    required this.id,
    required this.customerId,
    required this.deliveryDate,
    required this.orderItems,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}
