import 'package:intl/intl.dart';
import 'package:vsc_app/features/home/data/models/yearly_profit_response.dart';

/// View model for yearly profit data to be used in UI
class YearlyProfitViewModel {
  final String month;
  final String formattedMonth;
  final double profit;
  final String formattedProfit;

  YearlyProfitViewModel({required this.month, required this.formattedMonth, required this.profit, required this.formattedProfit});

  /// Factory method to create a view model from API model
  factory YearlyProfitViewModel.fromAPIModel(MonthlyProfitAPIModel apiModel) {
    // Parse month format YYYY-MM to create a formatted month name
    final DateTime date = DateTime(int.parse(apiModel.month.substring(0, 4)), int.parse(apiModel.month.substring(5, 7)));

    final double profit = apiModel.profitAsDouble;

    return YearlyProfitViewModel(
      month: apiModel.month,
      formattedMonth: DateFormat('MMM yyyy').format(date),
      profit: profit,
      formattedProfit: NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(profit),
    );
  }

  /// Convert a list of API models to view models
  static List<YearlyProfitViewModel> fromAPIModelList(List<MonthlyProfitAPIModel> apiModels) {
    return apiModels.map((apiModel) => YearlyProfitViewModel.fromAPIModel(apiModel)).toList();
  }
}
