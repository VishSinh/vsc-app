import 'package:json_annotation/json_annotation.dart';

part 'order_responses.g.dart';

@JsonSerializable()
class OrderResponse {
  final String id;
  final String name;
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'staff_id')
  final String staffId;
  @JsonKey(name: 'order_date')
  final String orderDate;
  @JsonKey(name: 'delivery_date')
  final String deliveryDate;
  @JsonKey(name: 'order_status')
  final String orderStatus;
  @JsonKey(name: 'special_instruction')
  final String specialInstruction;
  @JsonKey(name: 'order_items')
  final List<OrderItemResponse> orderItems;

  const OrderResponse({
    required this.id,
    required this.name,
    required this.customerId,
    required this.staffId,
    required this.orderDate,
    required this.deliveryDate,
    required this.orderStatus,
    required this.specialInstruction,
    required this.orderItems,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}

@JsonSerializable()
class OrderItemResponse {
  final String id;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'card_id')
  final String cardId;
  final int quantity;
  @JsonKey(name: 'price_per_item')
  final String pricePerItem;
  @JsonKey(name: 'discount_amount')
  final String discountAmount;
  @JsonKey(name: 'requires_box')
  final bool requiresBox;
  @JsonKey(name: 'requires_printing')
  final bool requiresPrinting;
  @JsonKey(name: 'box_orders')
  final List<BoxOrderResponse>? boxOrders;
  @JsonKey(name: 'printing_jobs')
  final List<PrintingJobResponse>? printingJobs;

  const OrderItemResponse({
    required this.id,
    required this.orderId,
    required this.cardId,
    required this.quantity,
    required this.pricePerItem,
    required this.discountAmount,
    required this.requiresBox,
    required this.requiresPrinting,
    required this.boxOrders,
    required this.printingJobs,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) => _$OrderItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemResponseToJson(this);
}

@JsonSerializable()
class BoxOrderResponse {
  final String id;
  @JsonKey(name: 'order_item_id')
  final String orderItemId;
  @JsonKey(name: 'box_maker_id')
  final String? boxMakerId;
  @JsonKey(name: 'box_type')
  final String boxType;
  @JsonKey(name: 'box_quantity')
  final int boxQuantity;
  @JsonKey(name: 'total_box_cost')
  final String totalBoxCost;
  @JsonKey(name: 'box_status')
  final String boxStatus;
  @JsonKey(name: 'estimated_completion')
  final String? estimatedCompletion;

  const BoxOrderResponse({
    required this.id,
    required this.orderItemId,
    this.boxMakerId,
    required this.boxType,
    required this.boxQuantity,
    required this.totalBoxCost,
    required this.boxStatus,
    this.estimatedCompletion,
  });

  factory BoxOrderResponse.fromJson(Map<String, dynamic> json) => _$BoxOrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BoxOrderResponseToJson(this);
}

@JsonSerializable()
class PrintingJobResponse {
  final String id;
  @JsonKey(name: 'order_item_id')
  final String orderItemId;
  @JsonKey(name: 'printer_id')
  final String? printerId;
  @JsonKey(name: 'tracing_studio_id')
  final String? tracingStudioId;
  @JsonKey(name: 'print_quantity')
  final int printQuantity;
  @JsonKey(name: 'total_printing_cost')
  final String totalPrintingCost;
  @JsonKey(name: 'printing_status')
  final String printingStatus;
  @JsonKey(name: 'estimated_completion')
  final String? estimatedCompletion;

  const PrintingJobResponse({
    required this.id,
    required this.orderItemId,
    this.printerId,
    this.tracingStudioId,
    required this.printQuantity,
    required this.totalPrintingCost,
    required this.printingStatus,
    this.estimatedCompletion,
  });

  factory PrintingJobResponse.fromJson(Map<String, dynamic> json) => _$PrintingJobResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PrintingJobResponseToJson(this);
}
