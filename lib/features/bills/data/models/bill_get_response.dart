// {
//     "success": true,
//     "data": {
//         "id": "93d3146b-7a67-4c4e-bdcc-74a11ecfc6d6",
//         "order_id": "e9506222-db6b-409b-a65d-2bca0c2fc7da",
//         "order_name": "Y wedds X",
//         "tax_percentage": "0.00",
//         "payment_status": "PENDING",
//         "order": {
//             "id": "e9506222-db6b-409b-a65d-2bca0c2fc7da",
//             "name": "Y wedds X",
//             "customer_id": "77a5345e-3f8a-484d-b786-a3ce5fdbccd6",
//             "customer_name": "Monte",
//             "staff_id": "3bd1de7d-c4c5-4ddc-a2e7-f35ea3badfb8",
//             "staff_name": "Vijay Sinha",
//             "order_date": "2025-08-03T07:21:40.541Z",
//             "delivery_date": "2025-11-15T10:00:00Z",
//             "order_status": "CONFIRMED",
//             "special_instruction": "",
//             "order_items": [
//                 {
//                     "id": "2203a8c0-1b2d-4e3e-aa2f-b371ff82c584",
//                     "order_id": "e9506222-db6b-409b-a65d-2bca0c2fc7da",
//                     "order_name": "Y wedds X",
//                     "card_id": "295ff0d8-2919-4643-992e-67fa48e9bd3f",
//                     "quantity": 2,
//                     "price_per_item": "150.00",
//                     "discount_amount": "5.00",
//                     "requires_box": true,
//                     "requires_printing": false,
//                     "calculated_costs": {
//                         "base_cost": "290.00",
//                         "box_cost": "500.00",
//                         "printing_cost": "0.00",
//                         "total_cost": "790.00"
//                     }
//                 },
//                 {
//                     "id": "cc085e56-844b-4773-b193-ba3cd7429be2",
//                     "order_id": "e9506222-db6b-409b-a65d-2bca0c2fc7da",
//                     "order_name": "Y wedds X",
//                     "card_id": "fcff2b14-1882-47aa-bb2d-0178234cdbe4",
//                     "quantity": 1,
//                     "price_per_item": "150.00",
//                     "discount_amount": "0.00",
//                     "requires_box": false,
//                     "requires_printing": true,
//                     "calculated_costs": {
//                         "base_cost": "150.00",
//                         "box_cost": "0.00",
//                         "printing_cost": "400.00",
//                         "total_cost": "550.00"
//                     }
//                 }
//             ]
//         },
//         "summary": {
//             "items_subtotal": "440.00",
//             "total_box_cost": "500.00",
//             "total_printing_cost": "400.00",
//             "grand_total": "1340.00",
//             "tax_percentage": "0.00",
//             "tax_amount": "0.00",
//             "total_with_tax": "1340.00"
//         }
//     }
// }
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
class BillOrderResponse extends OrderResponse {
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
  }) : super(orderItems: orderItems);

  @override
  List<BillOrderItemResponse> get orderItems => super.orderItems as List<BillOrderItemResponse>;

  factory BillOrderResponse.fromJson(Map<String, dynamic> json) => _$BillOrderResponseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BillOrderResponseToJson(this);
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

  const BillSummaryResponse({
    required this.itemsSubtotal,
    required this.totalBoxCost,
    required this.totalPrintingCost,
    required this.grandTotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalWithTax,
  });

  factory BillSummaryResponse.fromJson(Map<String, dynamic> json) => _$BillSummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BillSummaryResponseToJson(this);
}
