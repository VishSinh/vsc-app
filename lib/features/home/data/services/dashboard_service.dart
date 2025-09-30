import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/services/service_utils.dart';
import 'package:vsc_app/features/home/data/models/dashboard_response.dart';
import 'package:vsc_app/features/home/data/models/yearly_profit_response.dart';
import 'package:vsc_app/features/home/data/models/yearly_sale_response.dart';
import 'package:vsc_app/features/cards/data/models/card_responses.dart';
import 'package:vsc_app/features/orders/data/models/order_responses.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class DashboardService extends ApiService {
  Future<ApiResponse<DashboardResponse>> getDashboardData() async {
    return executeRequest(
      () => get(AppConstants.dashboardEndpoint),
      (json) => ServiceUtils.parseItem(json, DashboardResponse.fromJson),
    );
  }

  /// Private generic helper to fetch analytics lists by type with a parser
  Future<ApiResponse<List<T>>> _fetchAnalyticsList<T>(String type, T Function(Map<String, dynamic>) fromJson) async {
    final Map<String, dynamic> params = {'type': type};
    return executeRequest(() => get(AppConstants.detailedAnalyticsEndpoint, queryParameters: params), (json) {
      if (json is List<dynamic>) {
        return json.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
    });
  }

  /// Yearly profit analytics
  Future<ApiResponse<List<MonthlyProfitAPIModel>>> getYearlyProfitAnalytics() {
    return _fetchAnalyticsList('yearly_profit', MonthlyProfitAPIModel.fromJson);
  }

  /// Yearly sale analytics
  Future<ApiResponse<List<MonthlySaleAPIModel>>> getYearlySaleAnalytics() {
    return _fetchAnalyticsList('yearly_sale', MonthlySaleAPIModel.fromJson);
  }

  /// Fetch low stock cards via analytics detail endpoint
  Future<ApiResponse<List<CardResponse>>> getLowStockCards() async {
    return _fetchAnalyticsList('low_stock_cards', (m) => CardResponse.fromJson(m));
  }

  /// Fetch out of stock cards via analytics detail endpoint
  Future<ApiResponse<List<CardResponse>>> getOutOfStockCards() async {
    return _fetchAnalyticsList('out_of_stock_cards', (m) => CardResponse.fromJson(m));
  }

  /// Fetch today's orders via analytics detail endpoint
  Future<ApiResponse<List<OrderResponse>>> getTodaysOrders() async {
    return _fetchAnalyticsList('todays_orders', (m) => OrderResponse.fromJson(m));
  }
}
