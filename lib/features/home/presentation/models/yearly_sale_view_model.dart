import 'package:intl/intl.dart';
import 'package:vsc_app/features/home/data/models/yearly_sale_response.dart';

/// View model for yearly sale data to be used in UI
class YearlySaleViewModel {
  final String month;
  final String formattedMonth;
  final double sale;
  final String formattedSale;

  YearlySaleViewModel({required this.month, required this.formattedMonth, required this.sale, required this.formattedSale});

  /// Factory method to create a view model from API model
  factory YearlySaleViewModel.fromAPIModel(MonthlySaleAPIModel apiModel) {
    // Parse month format YYYY-MM to create a formatted month name
    final DateTime date = DateTime(int.parse(apiModel.month.substring(0, 4)), int.parse(apiModel.month.substring(5, 7)));

    final double sale = apiModel.saleAsDouble;

    return YearlySaleViewModel(
      month: apiModel.month,
      formattedMonth: DateFormat('MMM yyyy').format(date),
      sale: sale,
      formattedSale: NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(sale),
    );
  }

  /// Convert a list of API models to view models
  static List<YearlySaleViewModel> fromAPIModelList(List<MonthlySaleAPIModel> apiModels) {
    return apiModels.map((apiModel) => YearlySaleViewModel.fromAPIModel(apiModel)).toList();
  }
}
