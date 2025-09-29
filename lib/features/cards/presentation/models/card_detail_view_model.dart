import 'package:vsc_app/core/utils/currency_formatter.dart';
import 'package:vsc_app/core/utils/date_formatter.dart';
import 'package:vsc_app/features/cards/data/models/card_detail_response.dart';

class CardDetailOrderViewModel {
  final String orderId;
  final String name;
  final int quantity;

  const CardDetailOrderViewModel({required this.orderId, required this.name, required this.quantity});

  factory CardDetailOrderViewModel.fromApi(CardDetailOrder response) {
    return CardDetailOrderViewModel(orderId: response.orderId, name: response.name, quantity: response.quantity);
  }
}

class CardDetailViewModel {
  final int ordersCount;
  final int unitsSold;
  final double grossRevenue;
  final double grossCost;
  final double grossProfit;
  final double avgSellingPrice;
  final double avgDiscountPerUnit;
  final double avgDiscountRate; // 0-1 rate
  final DateTime? firstSoldAt;
  final DateTime? lastSoldAt;
  final int distinctCustomers;
  final int returnsTransactions;
  final int returnsUnitsReturned;
  final Map<String, int> orderStatusBreakdown;
  final List<CardDetailOrderViewModel> orders;

  const CardDetailViewModel({
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
    required this.returnsTransactions,
    required this.returnsUnitsReturned,
    required this.orderStatusBreakdown,
    required this.orders,
  });

  factory CardDetailViewModel.fromApiResponse(CardDetailResponse response) {
    double _toDouble(String? s) => s == null ? 0.0 : (double.tryParse(s) ?? 0.0);

    return CardDetailViewModel(
      ordersCount: response.ordersCount,
      unitsSold: response.unitsSold,
      grossRevenue: _toDouble(response.grossRevenue),
      grossCost: _toDouble(response.grossCost),
      grossProfit: _toDouble(response.grossProfit),
      avgSellingPrice: _toDouble(response.avgSellingPrice),
      avgDiscountPerUnit: _toDouble(response.avgDiscountPerUnit),
      avgDiscountRate: _toDouble(response.avgDiscountRate),
      firstSoldAt: DateFormatter.parseDateTime(response.firstSoldAt),
      lastSoldAt: DateFormatter.parseDateTime(response.lastSoldAt),
      distinctCustomers: response.distinctCustomers,
      returnsTransactions: response.returns.transactions,
      returnsUnitsReturned: response.returns.unitsReturned,
      orderStatusBreakdown: response.orderStatusBreakdown,
      orders: response.orders.map(CardDetailOrderViewModel.fromApi).toList(),
    );
  }

  // Formatted getters
  String get formattedGrossRevenue => CurrencyFormatter.format(grossRevenue);
  String get formattedGrossCost => CurrencyFormatter.format(grossCost);
  String get formattedGrossProfit => CurrencyFormatter.format(grossProfit);
  String get formattedAvgSellingPrice => CurrencyFormatter.format(avgSellingPrice);
  String get formattedAvgDiscountPerUnit => CurrencyFormatter.format(avgDiscountPerUnit);
  String get formattedAvgDiscountRate => '${(avgDiscountRate * 100).toStringAsFixed(2)}%';
  String get formattedFirstSoldAt => DateFormatter.formatDateTime(firstSoldAt);
  String get formattedLastSoldAt => DateFormatter.formatDateTime(lastSoldAt);
}
