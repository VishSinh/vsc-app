import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/features/production/data/models/box_order_response.dart';
import 'package:vsc_app/features/production/data/models/printing_job_response.dart';

part 'order_responses.g.dart';

@JsonSerializable()
class OrderResponse {
  final String id;
  final String name;
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'staff_id')
  final String staffId;
  @JsonKey(name: 'staff_name')
  final String staffName;
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
    required this.customerName,
    required this.staffId,
    required this.staffName,
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
  @JsonKey(name: 'order_name')
  final String orderName;
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
    required this.orderName,
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
