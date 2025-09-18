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

/// Request model for updating an order
@JsonSerializable(includeIfNull: false)
class UpdateOrderRequest {
  @JsonKey(name: 'order_status')
  final String? orderStatus;
  @JsonKey(name: 'delivery_date')
  final String? deliveryDate;
  @JsonKey(name: 'special_instruction')
  final String? specialInstruction;
  @JsonKey(name: 'order_items')
  final List<OrderUpdateItemAPIModel>? orderItems;
  @JsonKey(name: 'add_items')
  final List<AddOrderItemAPIModel>? addItems;
  @JsonKey(name: 'remove_item_ids')
  final List<String>? removeItemIds;

  const UpdateOrderRequest({this.orderStatus, this.deliveryDate, this.specialInstruction, this.orderItems, this.addItems, this.removeItemIds});

  factory UpdateOrderRequest.fromJson(Map<String, dynamic> json) => _$UpdateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateOrderRequestToJson(this);
}

/// Nested model for updating existing order items (suffix APIModel per convention)
@JsonSerializable(includeIfNull: false)
class OrderUpdateItemAPIModel {
  @JsonKey(name: 'order_item_id')
  final String orderItemId;
  final int? quantity;
  @JsonKey(name: 'discount_amount')
  final String? discountAmount;
  @JsonKey(name: 'requires_box')
  final bool? requiresBox;
  @JsonKey(name: 'box_type')
  final String? boxType;
  @JsonKey(name: 'total_box_cost')
  final String? totalBoxCost;
  @JsonKey(name: 'requires_printing')
  final bool? requiresPrinting;
  @JsonKey(name: 'total_printing_cost')
  final String? totalPrintingCost;

  const OrderUpdateItemAPIModel({
    required this.orderItemId,
    this.quantity,
    this.discountAmount,
    this.requiresBox,
    this.boxType,
    this.totalBoxCost,
    this.requiresPrinting,
    this.totalPrintingCost,
  });

  factory OrderUpdateItemAPIModel.fromJson(Map<String, dynamic> json) => _$OrderUpdateItemAPIModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderUpdateItemAPIModelToJson(this);
}

/// Nested model for adding new order items (suffix APIModel per convention)
@JsonSerializable(includeIfNull: false)
class AddOrderItemAPIModel {
  @JsonKey(name: 'card_id')
  final String cardId;
  @JsonKey(name: 'discount_amount')
  final String discountAmount;
  final int quantity;
  @JsonKey(name: 'requires_box')
  final bool requiresBox;
  @JsonKey(name: 'box_type')
  final String? boxType;
  @JsonKey(name: 'total_box_cost')
  final String? totalBoxCost;
  @JsonKey(name: 'requires_printing')
  final bool requiresPrinting;
  @JsonKey(name: 'total_printing_cost')
  final String? totalPrintingCost;

  const AddOrderItemAPIModel({
    required this.cardId,
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    this.boxType,
    this.totalBoxCost,
    required this.requiresPrinting,
    this.totalPrintingCost,
  });

  factory AddOrderItemAPIModel.fromJson(Map<String, dynamic> json) => _$AddOrderItemAPIModelFromJson(json);
  Map<String, dynamic> toJson() => _$AddOrderItemAPIModelToJson(this);
}
