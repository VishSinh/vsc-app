import 'package:json_annotation/json_annotation.dart';
import 'order_api_models.dart';

part 'order_requests.g.dart';

@JsonSerializable()
class CreateOrderRequest {
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'delivery_date')
  final String deliveryDate;
  @JsonKey(name: 'order_items')
  final List<OrderItemApiModel> orderItems;

  const CreateOrderRequest({required this.customerId, required this.deliveryDate, required this.orderItems});

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}
