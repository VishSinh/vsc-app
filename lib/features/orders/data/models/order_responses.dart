import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/features/production/data/models/box_order_response.dart';
import 'package:vsc_app/features/production/data/models/printing_job_response.dart';

part 'order_responses.g.dart';

/// Base order response without billId - used by both OrderResponse and BillOrderResponse
@JsonSerializable()
class BaseOrderResponse {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
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

  @JsonKey(name: 'order_items', defaultValue: [])
  final List<OrderItemResponse> orderItems;

  @JsonKey(name: 'service_items', defaultValue: [])
  final List<ServiceItemResponse> serviceItems;

  const BaseOrderResponse({
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
    this.serviceItems = const [],
  });

  factory BaseOrderResponse.fromJson(Map<String, dynamic> json) => _$BaseOrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BaseOrderResponseToJson(this);
}

@JsonSerializable()
class OrderResponse extends BaseOrderResponse {
  @JsonKey(name: 'bill_id')
  final String billId;

  const OrderResponse({
    required super.id,
    required super.name,
    required super.customerId,
    required super.customerName,
    required super.staffId,
    required super.staffName,
    required super.orderDate,
    required super.deliveryDate,
    required super.orderStatus,
    required super.specialInstruction,
    required super.orderItems,
    super.serviceItems = const [],
    required this.billId,
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

@JsonSerializable()
class ServiceItemResponse {
  final String id;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'order_name')
  final String orderName;
  @JsonKey(name: 'service_type')
  final String serviceType;
  final int quantity;
  @JsonKey(name: 'procurement_status')
  final String procurementStatus;
  @JsonKey(name: 'total_cost')
  final String totalCost;
  @JsonKey(name: 'total_expense')
  final String? totalExpense;
  final String? description;

  const ServiceItemResponse({
    required this.id,
    required this.orderId,
    required this.orderName,
    required this.serviceType,
    required this.quantity,
    required this.procurementStatus,
    required this.totalCost,
    this.totalExpense,
    this.description,
  });

  factory ServiceItemResponse.fromJson(Map<String, dynamic> json) => _$ServiceItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceItemResponseToJson(this);
}

// @JsonSerializable()
// class OrderCreateResponse extends OrderResponse {
//   @JsonKey(name: 'bill_id')
//   final String billId;

//   const OrderCreateResponse({
//     required super.id,
//     required super.name,
//     required super.customerId,
//     required super.customerName,
//     required super.staffId,
//     required super.staffName,
//     required super.orderDate,
//     required super.deliveryDate,
//     required super.orderStatus,
//     required super.specialInstruction,
//     required super.orderItems,
//     required this.billId,
//   });

//   factory OrderCreateResponse.fromJson(Map<String, dynamic> json) => _$OrderCreateResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$OrderCreateResponseToJson(this);
// }
