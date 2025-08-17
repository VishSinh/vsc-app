import 'package:json_annotation/json_annotation.dart';

part 'dashboard_response.g.dart';

/// API response model for dashboard data
@JsonSerializable()
class DashboardResponse {
  @JsonKey(name: 'low_stock_items')
  final int lowStockItems;
  
  @JsonKey(name: 'out_of_stock_items')
  final int outOfStockItems;
  
  @JsonKey(name: 'total_orders_current_month')
  final int totalOrdersCurrentMonth;
  
  @JsonKey(name: 'monthly_order_change_percentage')
  final double monthlyOrderChangePercentage;
  
  @JsonKey(name: 'pending_orders')
  final int pendingOrders;
  
  @JsonKey(name: 'todays_orders')
  final int todaysOrders;
  
  @JsonKey(name: 'pending_bills')
  final int pendingBills;
  
  @JsonKey(name: 'monthly_profit')
  final String monthlyProfit;
  
  @JsonKey(name: 'orders_pending_expense_logging')
  final int ordersPendingExpenseLogging;
  
  @JsonKey(name: 'pending_printing_jobs')
  final int pendingPrintingJobs;
  
  @JsonKey(name: 'pending_box_jobs')
  final int pendingBoxJobs;

  const DashboardResponse({
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.totalOrdersCurrentMonth,
    required this.monthlyOrderChangePercentage,
    required this.pendingOrders,
    required this.todaysOrders,
    required this.pendingBills,
    required this.monthlyProfit,
    required this.ordersPendingExpenseLogging,
    required this.pendingPrintingJobs,
    required this.pendingBoxJobs,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) => _$DashboardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);
  
  // Helper method to convert string price to double
  double get monthlyProfitAsDouble => double.tryParse(monthlyProfit) ?? 0.0;
}
