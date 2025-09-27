import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/features/orders/data/models/order_responses.dart';

// Follow naming convention of using Response and Request suffixes for API models

part 'bill_get_response.g.dart';

@JsonSerializable()
class BillGetResponse {
  final String id;

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'order_name')
  final String orderName;

  @JsonKey(name: 'tax_percentage')
  final String taxPercentage;

  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  @JsonKey(name: 'order')
  final BillOrderResponse order;

  @JsonKey(name: 'summary')
  final BillSummaryResponse summary;

  const BillGetResponse({
    required this.id,
    required this.orderId,
    required this.orderName,
    required this.taxPercentage,
    required this.paymentStatus,
    required this.order,
    required this.summary,
  });

  factory BillGetResponse.fromJson(Map<String, dynamic> json) => _$BillGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BillGetResponseToJson(this);
}

@JsonSerializable()
class BillOrderResponse extends BaseOrderResponse {
  const BillOrderResponse({
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
    required List<BillOrderItemResponse> orderItems,
    List<ServiceItemResponse> serviceItems = const [],
  }) : super(orderItems: orderItems, serviceItems: serviceItems);

  factory BillOrderResponse.fromJson(Map<String, dynamic> json) {
    final orderItemsJson = json['order_items'] as List<dynamic>?;
    final serviceItemsJson = json['service_items'] as List<dynamic>?;

    final orderItems = orderItemsJson?.map((e) => BillOrderItemResponse.fromJson(e as Map<String, dynamic>)).toList() ?? [];

    final serviceItems = serviceItemsJson?.map((e) => ServiceItemResponse.fromJson(e as Map<String, dynamic>)).toList() ?? [];

    return BillOrderResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      staffId: json['staff_id'] as String,
      staffName: json['staff_name'] as String,
      orderDate: json['order_date'] as String,
      deliveryDate: json['delivery_date'] as String,
      orderStatus: json['order_status'] as String,
      specialInstruction: json['special_instruction'] as String,
      orderItems: orderItems,
      serviceItems: serviceItems,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'customer_id': customerId,
    'customer_name': customerName,
    'staff_id': staffId,
    'staff_name': staffName,
    'order_date': orderDate,
    'delivery_date': deliveryDate,
    'order_status': orderStatus,
    'special_instruction': specialInstruction,
    'order_items': orderItems,
    'service_items': serviceItems,
  };
}

@JsonSerializable()
class BillOrderItemResponse extends OrderItemResponse {
  @JsonKey(name: 'calculated_costs')
  final CalculatedCostsResponse calculatedCosts;

  const BillOrderItemResponse({
    required super.id,
    required super.orderId,
    required super.orderName,
    required super.cardId,
    required super.quantity,
    required super.pricePerItem,
    required super.discountAmount,
    required super.requiresBox,
    required super.requiresPrinting,
    required this.calculatedCosts,
  }) : super(
         boxOrders: null, // Bill items don't have box_orders
         printingJobs: null, // Bill items don't have printing_jobs
       );

  factory BillOrderItemResponse.fromJson(Map<String, dynamic> json) => _$BillOrderItemResponseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BillOrderItemResponseToJson(this);
}

@JsonSerializable()
class BillServiceItemResponse extends ServiceItemResponse {
  const BillServiceItemResponse({
    required super.id,
    required super.orderId,
    required super.orderName,
    required super.serviceType,
    required super.quantity,
    required super.procurementStatus,
    required super.totalCost,
    required super.totalExpense,
    super.description,
  });

  factory BillServiceItemResponse.fromJson(Map<String, dynamic> json) => _$BillServiceItemResponseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BillServiceItemResponseToJson(this);
}

@JsonSerializable()
class CalculatedCostsResponse {
  @JsonKey(name: 'base_cost')
  final String baseCost;

  @JsonKey(name: 'box_cost')
  final String boxCost;

  @JsonKey(name: 'printing_cost')
  final String printingCost;

  @JsonKey(name: 'total_cost')
  final String totalCost;

  const CalculatedCostsResponse({required this.baseCost, required this.boxCost, required this.printingCost, required this.totalCost});

  factory CalculatedCostsResponse.fromJson(Map<String, dynamic> json) => _$CalculatedCostsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CalculatedCostsResponseToJson(this);
}

@JsonSerializable()
class BillSummaryResponse {
  @JsonKey(name: 'order_items_subtotal')
  final String orderItemsSubtotal;

  @JsonKey(name: 'service_items_subtotal')
  final String serviceItemsSubtotal;

  @JsonKey(name: 'items_subtotal')
  final String itemsSubtotal;

  @JsonKey(name: 'total_box_cost')
  final String totalBoxCost;

  @JsonKey(name: 'total_printing_cost')
  final String totalPrintingCost;

  @JsonKey(name: 'grand_total')
  final String grandTotal;

  @JsonKey(name: 'tax_percentage')
  final String taxPercentage;

  @JsonKey(name: 'tax_amount')
  final String taxAmount;

  @JsonKey(name: 'total_with_tax')
  final String totalWithTax;

  @JsonKey(name: 'pending_amount')
  final String? pendingAmount;

  const BillSummaryResponse({
    required this.orderItemsSubtotal,
    required this.serviceItemsSubtotal,
    required this.itemsSubtotal,
    required this.totalBoxCost,
    required this.totalPrintingCost,
    required this.grandTotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalWithTax,
    this.pendingAmount,
  });

  factory BillSummaryResponse.fromJson(Map<String, dynamic> json) => _$BillSummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BillSummaryResponseToJson(this);
}
