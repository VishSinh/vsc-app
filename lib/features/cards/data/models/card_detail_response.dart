import 'package:json_annotation/json_annotation.dart';

part 'card_detail_response.g.dart';

@JsonSerializable()
class CardDetailResponse {
  @JsonKey(name: 'orders_count')
  final int ordersCount;
  @JsonKey(name: 'units_sold')
  final int unitsSold;
  @JsonKey(name: 'gross_revenue')
  final String grossRevenue;
  @JsonKey(name: 'gross_cost')
  final String grossCost;
  @JsonKey(name: 'gross_profit')
  final String grossProfit;
  @JsonKey(name: 'avg_selling_price')
  final String? avgSellingPrice;
  @JsonKey(name: 'avg_discount_per_unit')
  final String avgDiscountPerUnit;
  @JsonKey(name: 'avg_discount_rate')
  final String avgDiscountRate;
  @JsonKey(name: 'first_sold_at')
  final String? firstSoldAt;
  @JsonKey(name: 'last_sold_at')
  final String? lastSoldAt;
  @JsonKey(name: 'distinct_customers')
  final int distinctCustomers;
  final ReturnsSummary returns;
  @JsonKey(name: 'order_status_breakdown')
  final Map<String, int> orderStatusBreakdown;
  final List<CardDetailOrder> orders;

  const CardDetailResponse({
    required this.ordersCount,
    required this.unitsSold,
    required this.grossRevenue,
    required this.grossCost,
    required this.grossProfit,
    required this.avgSellingPrice,
    required this.avgDiscountPerUnit,
    required this.avgDiscountRate,
    required this.firstSoldAt,
    required this.lastSoldAt,
    required this.distinctCustomers,
    required this.returns,
    required this.orderStatusBreakdown,
    required this.orders,
  });

  factory CardDetailResponse.fromJson(Map<String, dynamic> json) => _$CardDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CardDetailResponseToJson(this);
}

@JsonSerializable()
class ReturnsSummary {
  final int transactions;
  @JsonKey(name: 'units_returned')
  final int unitsReturned;

  const ReturnsSummary({required this.transactions, required this.unitsReturned});

  factory ReturnsSummary.fromJson(Map<String, dynamic> json) => _$ReturnsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnsSummaryToJson(this);
}

@JsonSerializable()
class CardDetailOrder {
  @JsonKey(name: 'order_id')
  final String orderId;
  final String name;
  final int quantity;

  const CardDetailOrder({required this.orderId, required this.name, required this.quantity});

  factory CardDetailOrder.fromJson(Map<String, dynamic> json) => _$CardDetailOrderFromJson(json);
  Map<String, dynamic> toJson() => _$CardDetailOrderToJson(this);
}
