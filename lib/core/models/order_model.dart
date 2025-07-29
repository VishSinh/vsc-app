import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

enum BoxType {
  @JsonValue('FOLDING')
  folding,
  @JsonValue('COMPLETE')
  complete,
}

@JsonSerializable()
class OrderItem {
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

  const OrderItem({
    required this.cardId,
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    required this.requiresPrinting,
    this.boxType,
    this.totalBoxCost,
    this.totalPrintingCost,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class CreateOrderRequest {
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'delivery_date')
  final String deliveryDate;
  @JsonKey(name: 'order_items')
  final List<OrderItem> orderItems;

  const CreateOrderRequest({required this.customerId, required this.deliveryDate, required this.orderItems});

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

@JsonSerializable()
class Order {
  final String id;
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'delivery_date')
  final String deliveryDate;
  @JsonKey(name: 'order_items')
  final List<OrderItem> orderItems;
  final String status;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.deliveryDate,
    required this.orderItems,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
