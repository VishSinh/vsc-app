import 'package:vsc_app/features/home/data/models/dashboard_response.dart';

/// View model for dashboard statistics to be displayed in the UI
class DashboardViewModel {
  final int lowStockItems;
  final int outOfStockItems;
  final int totalOrdersCurrentMonth;
  final double monthlyOrderChangePercentage;
  final int pendingOrders;
  final int todaysOrders;
  final int pendingBills;
  final double monthlyProfit;
  final int ordersPendingExpenseLogging;
  final int pendingPrintingJobs;
  final int pendingBoxJobs;

  const DashboardViewModel({
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

  /// Factory method to create a DashboardViewModel from a DashboardResponse
  factory DashboardViewModel.fromResponse(DashboardResponse response) {
    return DashboardViewModel(
      lowStockItems: response.lowStockItems,
      outOfStockItems: response.outOfStockItems,
      totalOrdersCurrentMonth: response.totalOrdersCurrentMonth,
      monthlyOrderChangePercentage: response.monthlyOrderChangePercentage,
      pendingOrders: response.pendingOrders,
      todaysOrders: response.todaysOrders,
      pendingBills: response.pendingBills,
      monthlyProfit: response.monthlyProfitAsDouble,
      ordersPendingExpenseLogging: response.ordersPendingExpenseLogging,
      pendingPrintingJobs: response.pendingPrintingJobs,
      pendingBoxJobs: response.pendingBoxJobs,
    );
  }

  /// Format the monthly profit as a currency string
  String get formattedMonthlyProfit => '₹${monthlyProfit.toStringAsFixed(2)}';

  /// Format the monthly order change percentage
  String get formattedMonthlyOrderChangePercentage =>
      '${monthlyOrderChangePercentage >= 0 ? '+' : ''}${monthlyOrderChangePercentage.toStringAsFixed(1)}%';
}
