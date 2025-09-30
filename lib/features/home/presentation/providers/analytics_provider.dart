import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/home/data/services/dashboard_service.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_profit_view_model.dart';
import 'package:vsc_app/features/home/presentation/models/yearly_sale_view_model.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';

/// Provider for managing analytics data including yearly profit analysis
class AnalyticsProvider extends BaseProvider {
  final DashboardService _dashboardService;

  // Analytics data
  List<YearlyProfitViewModel>? _yearlyProfitData;
  List<YearlySaleViewModel>? _yearlySaleData;
  List<CardViewModel>? _lowStockCards;
  List<CardViewModel>? _outOfStockCards;
  List<OrderViewModel>? _todaysOrders;

  // Getters
  List<YearlyProfitViewModel>? get yearlyProfitData => _yearlyProfitData;
  List<YearlySaleViewModel>? get yearlySaleData => _yearlySaleData;
  List<CardViewModel>? get lowStockCards => _lowStockCards;
  List<CardViewModel>? get outOfStockCards => _outOfStockCards;
  List<OrderViewModel>? get todaysOrders => _todaysOrders;

  // Constructor
  AnalyticsProvider({DashboardService? dashboardService}) : _dashboardService = dashboardService ?? DashboardService() {
    AppLogger.service('AnalyticsProvider', 'Initialized');
  }

  /// Fetch yearly profit data from the API
  Future<void> fetchYearlyProfitData({bool showSnackbar = false}) async {
    AppLogger.service('AnalyticsProvider', 'Fetching yearly profit data');

    await executeApiOperation(
      apiCall: () => _dashboardService.getYearlyProfitAnalytics(),
      onSuccess: (response) {
        if (response.data != null) {
          _yearlyProfitData = YearlyProfitViewModel.fromAPIModelList(response.data!);
          AppLogger.service('AnalyticsProvider', 'Yearly profit data loaded: ${_yearlyProfitData?.length} months');
          return _yearlyProfitData;
        }
        return null;
      },
      showSnackbar: showSnackbar,
      showLoading: true,
      errorMessage: 'Failed to load profit data',
    );
  }

  /// Fetch yearly sale data from the API
  Future<void> fetchYearlySaleData({bool showSnackbar = false}) async {
    AppLogger.service('AnalyticsProvider', 'Fetching yearly sale data');

    await executeApiOperation(
      apiCall: () => _dashboardService.getYearlySaleAnalytics(),
      onSuccess: (response) {
        if (response.data != null) {
          _yearlySaleData = YearlySaleViewModel.fromAPIModelList(response.data!);
          AppLogger.service('AnalyticsProvider', 'Yearly sale data loaded: ${_yearlySaleData?.length} months');
          return _yearlySaleData;
        }
        return null;
      },
      showSnackbar: showSnackbar,
      showLoading: true,
      errorMessage: 'Failed to load sale data',
    );
  }

  Future<void> getLowStockCards({bool showSnackbar = false}) async {
    AppLogger.service('AnalyticsProvider', 'Fetching low stock cards');

    await executeApiOperation(
      apiCall: () => _dashboardService.getLowStockCards(),
      onSuccess: (response) {
        if (response.data != null) {
          _lowStockCards = response.data!.map((r) => CardViewModel.fromApiResponse(r)).toList();
          AppLogger.service('AnalyticsProvider', 'Low stock cards loaded: ${_lowStockCards?.length}');
          notifyListeners();
          return _lowStockCards;
        }
        return null;
      },
      showSnackbar: showSnackbar,
      showLoading: true,
      errorMessage: 'Failed to load low stock cards',
    );
  }

  Future<void> getOutOfStockCards({bool showSnackbar = false}) async {
    AppLogger.service('AnalyticsProvider', 'Fetching out of stock cards');

    await executeApiOperation(
      apiCall: () => _dashboardService.getOutOfStockCards(),
      onSuccess: (response) {
        if (response.data != null) {
          _outOfStockCards = response.data!.map((r) => CardViewModel.fromApiResponse(r)).toList();
          AppLogger.service('AnalyticsProvider', 'Out of stock cards loaded: ${_outOfStockCards?.length}');
          notifyListeners();
          return _outOfStockCards;
        }
        return null;
      },
      showSnackbar: showSnackbar,
      showLoading: true,
      errorMessage: 'Failed to load out of stock cards',
    );
  }

  /// Fetch today's orders via analytics
  Future<void> getTodaysOrders({bool showSnackbar = false}) async {
    AppLogger.service('AnalyticsProvider', 'Fetching today\'s orders');

    await executeApiOperation(
      apiCall: () => _dashboardService.getTodaysOrders(),
      onSuccess: (response) {
        if (response.data != null) {
          _todaysOrders = response.data!.map((r) => OrderViewModel.fromApiResponse(r)).toList();
          AppLogger.service('AnalyticsProvider', "Today's orders loaded: ${_todaysOrders?.length}");
          notifyListeners();
          return _todaysOrders;
        }
        return null;
      },
      showSnackbar: showSnackbar,
      showLoading: true,
      errorMessage: "Failed to load today's orders",
    );
  }

  /// Get total yearly profit from the loaded data
  double getTotalProfit() {
    if (_yearlyProfitData == null || _yearlyProfitData!.isEmpty) return 0.0;

    return _yearlyProfitData!.fold(0.0, (sum, item) => sum + item.profit);
  }

  /// Get highest profit month from the loaded data
  YearlyProfitViewModel? getHighestProfitMonth() {
    if (_yearlyProfitData == null || _yearlyProfitData!.isEmpty) return null;

    return _yearlyProfitData!.reduce((a, b) => a.profit > b.profit ? a : b);
  }

  /// Get lowest profit month from the loaded data
  YearlyProfitViewModel? getLowestProfitMonth() {
    if (_yearlyProfitData == null || _yearlyProfitData!.isEmpty) return null;

    return _yearlyProfitData!.reduce((a, b) => a.profit < b.profit ? a : b);
  }

  /// Get total yearly sale from the loaded data
  double getTotalSale() {
    if (_yearlySaleData == null || _yearlySaleData!.isEmpty) return 0.0;

    return _yearlySaleData!.fold(0.0, (sum, item) => sum + item.sale);
  }

  /// Get highest sale month from the loaded data
  YearlySaleViewModel? getHighestSaleMonth() {
    if (_yearlySaleData == null || _yearlySaleData!.isEmpty) return null;

    return _yearlySaleData!.reduce((a, b) => a.sale > b.sale ? a : b);
  }

  /// Get lowest sale month from the loaded data
  YearlySaleViewModel? getLowestSaleMonth() {
    if (_yearlySaleData == null || _yearlySaleData!.isEmpty) return null;

    return _yearlySaleData!.reduce((a, b) => a.sale < b.sale ? a : b);
  }

  /// Reset provider state
  @override
  void reset() {
    _yearlyProfitData = null;
    _yearlySaleData = null;
    _lowStockCards = null;
    _outOfStockCards = null;
    _todaysOrders = null;
    super.reset();
    AppLogger.service('AnalyticsProvider', 'Provider state reset');
  }
}
