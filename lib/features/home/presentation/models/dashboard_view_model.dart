import 'package:vsc_app/features/home/data/models/dashboard_response.dart';

/// View model for dashboard statistics to be displayed in the UI
class DashboardViewModel {
  final int lowStockItems;
  final int outOfStockItems;
  final int totalOrdersCurrentMonth;
  final double monthlyOrderChangePercentage;
  final int pendingOrders;
  final int todaysOrders;
  final double monthlyProfit;
  final double totalSaleCurrentMonth;
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
    required this.monthlyProfit,
    required this.totalSaleCurrentMonth,
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
      monthlyProfit: response.monthlyProfitAsDouble,
      totalSaleCurrentMonth: response.totalSaleCurrentMonthAsDouble,
      ordersPendingExpenseLogging: response.ordersPendingExpenseLogging,
      pendingPrintingJobs: response.pendingPrintingJobs,
      pendingBoxJobs: response.pendingBoxJobs,
    );
  }

  /// Format the monthly profit as a currency string
  String get formattedMonthlyProfit => '₹${_formatIndianCurrency(monthlyProfit)}';

  /// Format the monthly sale as a currency string
  String get formattedTotalSaleCurrentMonth => '₹${_formatIndianCurrency(totalSaleCurrentMonth)}';

  /// Formats a number as Indian currency with commas (e.g., 12,34,567.89)
  String _formatIndianCurrency(double amount) {
    // Handle negative numbers
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];

    if (integerPart.length <= 3) {
      return '${isNegative ? '-' : ''}$integerPart.$decimalPart';
    }

    // Split last 3 digits
    final lastThree = integerPart.substring(integerPart.length - 3);
    String rest = integerPart.substring(0, integerPart.length - 3);

    // Group the rest in 2-digit groups from the right
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      groups.insert(0, rest);
    }

    final head = groups.join(',');
    final formattedInteger = head.isEmpty ? lastThree : '$head,$lastThree';
    return '${isNegative ? '-' : ''}$formattedInteger.$decimalPart';
  }

  /// Format the monthly order change percentage
  String get formattedMonthlyOrderChangePercentage =>
      '${monthlyOrderChangePercentage >= 0 ? '+' : ''}${monthlyOrderChangePercentage.toStringAsFixed(1)}%';
}
