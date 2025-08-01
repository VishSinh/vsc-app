import 'package:json_annotation/json_annotation.dart';

part 'order_requests.g.dart';

/// Request model for creating an order
@JsonSerializable()
class CreateOrderRequest {
  @JsonKey(name: 'customer_id')
  final String customerId;
  final String name;
  @JsonKey(name: 'delivery_date')
  final String deliveryDate;
  @JsonKey(name: 'order_items')
  final List<OrderItemRequest> orderItems;

  const CreateOrderRequest({required this.customerId, required this.name, required this.deliveryDate, required this.orderItems});

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

/// Request model for order item
@JsonSerializable()
class OrderItemRequest {
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
  final String? boxType;
  @JsonKey(name: 'total_box_cost')
  final String totalBoxCost;
  @JsonKey(name: 'total_printing_cost')
  final String totalPrintingCost;

  const OrderItemRequest({
    required this.cardId,
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    required this.requiresPrinting,
    this.boxType,
    required this.totalBoxCost,
    required this.totalPrintingCost,
  });

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) => _$OrderItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemRequestToJson(this);
}
