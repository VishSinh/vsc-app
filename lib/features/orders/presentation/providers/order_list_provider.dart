import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import '../../data/services/order_service.dart';
import 'package:vsc_app/features/production/data/services/production_service.dart';
import 'package:vsc_app/features/production/presentation/models/box_maker_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_update_form_model.dart';
import 'package:vsc_app/features/production/presentation/models/printer_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/tracing_studio_view_model.dart';

/// Provider for managing order listing, details, and production operations
class OrderListProvider extends BaseProvider {
  final OrderService _orderService = OrderService();
  final ProductionService _productionService = ProductionService();

  // Order listing and management
  final List<OrderViewModel> _orders = [];
  PaginationData? _pagination;
  OrderViewModel? _currentOrder;

  // UI state for orders page
  String _searchQuery = '';
  String _statusFilter = 'all';
  bool _isPageLoading = false;

  // Production service for box order operations
  // State for box makers
  bool _isLoadingBoxMakers = false;
  List<BoxMakerViewModel> _boxMakers = [];
  String? _lastBoxMakersError;

  // State for box orders
  bool _isUpdatingBoxOrder = false;
  String? _lastBoxOrderUpdateError;

  // State for printing jobs
  bool _isLoadingPrinters = false;
  List<PrinterViewModel> _printers = [];
  String? _lastPrintersError;

  // State for tracing studios
  bool _isLoadingTracingStudios = false;
  List<TracingStudioViewModel> _tracingStudios = [];
  String? _lastTracingStudiosError;

  // State for printing job updates
  bool _isUpdatingPrintingJob = false;
  String? _lastPrintingJobUpdateError;

  // Getters for fetched data
  List<OrderViewModel> get orders => List.unmodifiable(_orders);
  PaginationData? get pagination => _pagination;
  OrderViewModel? get currentOrder => _currentOrder;

  // Getters for UI state
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  bool get isPageLoading => _isPageLoading;

  // Getters for production data
  bool get isLoadingBoxMakers => _isLoadingBoxMakers;
  List<BoxMakerViewModel> get boxMakers => List.unmodifiable(_boxMakers);
  bool get isUpdatingBoxOrder => _isUpdatingBoxOrder;
  String? get lastBoxMakersError => _lastBoxMakersError;
  String? get lastBoxOrderUpdateError => _lastBoxOrderUpdateError;
  bool get isLoadingPrinters => _isLoadingPrinters;
  List<PrinterViewModel> get printers => List.unmodifiable(_printers);
  bool get isLoadingTracingStudios => _isLoadingTracingStudios;
  List<TracingStudioViewModel> get tracingStudios => List.unmodifiable(_tracingStudios);
  bool get isUpdatingPrintingJob => _isUpdatingPrintingJob;
  String? get lastPrintersError => _lastPrintersError;
  String? get lastTracingStudiosError => _lastTracingStudiosError;
  String? get lastPrintingJobUpdateError => _lastPrintingJobUpdateError;

  bool get hasMoreOrders {
    return _pagination?.hasNext ?? false;
  }

  // Order fetching methods
  Future<bool> fetchOrders({int page = 1, int pageSize = 10}) async {
    final result = await executeApiOperation(
      apiCall: () => _orderService.getOrders(page: page, pageSize: pageSize),
      onSuccess: (response) {
        _orders.clear();
        // Use the fromApiResponse method to convert OrderResponse to OrderViewModel
        final orderViewModels = (response.data ?? []).map((orderResponse) => OrderViewModel.fromApiResponse(orderResponse)).toList();
        _orders.addAll(orderViewModels);
        _pagination = response.pagination;
        notifyListeners();
        return true;
      },
      showSnackbar: false, // No snackbar for frequent API calls
      errorMessage: 'Failed to fetch orders',
    );
    return result ?? false;
  }

  Future<void> loadNextPage() async {
    if (_pagination?.hasNext == true) {
      await fetchOrders(page: (_pagination?.currentPage ?? 1) + 1);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_pagination?.hasPrevious == true) {
      await fetchOrders(page: (_pagination?.currentPage ?? 1) - 1);
    }
  }

  // Order detail methods
  Future<bool> fetchOrderById(String orderId) async {
    final result = await executeApiOperation(
      apiCall: () => _orderService.getOrderById(orderId),
      onSuccess: (response) {
        _currentOrder = OrderViewModel.fromApiResponse(response.data!);
        notifyListeners();
        return response.data!; // Return the OrderResponse
      },
      showSnackbar: false, // No snackbar for detail fetching
      errorMessage: 'Failed to fetch order details',
    );
    return result != null; // Convert to boolean
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  // Utility methods
  void clearOrders() {
    _orders.clear();
    _pagination = null;
    notifyListeners();
  }

  // UI state management methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setPageLoading(bool loading) {
    _isPageLoading = loading;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = 'all';
    notifyListeners();
  }

  // Production methods for box orders
  /// Fetch box makers
  Future<void> fetchBoxMakers({int page = 1, int pageSize = 10}) async {
    _isLoadingBoxMakers = true;
    _lastBoxMakersError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _productionService.getBoxMakers(page: page, pageSize: pageSize),
      onSuccess: (response) {
        _boxMakers = BoxMakerViewModel.fromResponseList(response.data!);
        notifyListeners();
        return response.data!;
      },
      showLoading: false, // Use custom loading state
      showSnackbar: false, // No snackbar for data fetching
      errorMessage: 'Failed to fetch box makers',
    );

    _isLoadingBoxMakers = false;
    notifyListeners();
  }

  // Production methods for printing jobs
  /// Fetch printers
  Future<void> fetchPrinters({int page = 1, int pageSize = 10}) async {
    _isLoadingPrinters = true;
    _lastPrintersError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _productionService.getPrinters(page: page, pageSize: pageSize),
      onSuccess: (response) {
        _printers = PrinterViewModel.fromResponseList(response.data!);
        notifyListeners();
        return response.data!;
      },
      showLoading: false, // Use custom loading state
      showSnackbar: false, // No snackbar for data fetching
      errorMessage: 'Failed to fetch printers',
    );

    _isLoadingPrinters = false;
    notifyListeners();
  }

  /// Fetch tracing studios
  Future<void> fetchTracingStudios({int page = 1, int pageSize = 10}) async {
    _isLoadingTracingStudios = true;
    _lastTracingStudiosError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _productionService.getTracingStudios(page: page, pageSize: pageSize),
      onSuccess: (response) {
        _tracingStudios = TracingStudioViewModel.fromResponseList(response.data!);
        notifyListeners();
        return response.data!;
      },
      showLoading: false, // Use custom loading state
      showSnackbar: false, // No snackbar for data fetching
      errorMessage: 'Failed to fetch tracing studios',
    );

    _isLoadingTracingStudios = false;
    notifyListeners();
  }

  /// Update printing job status and details
  Future<void> updatePrintingJob({required String printingJobId, required PrintingJobUpdateFormModel formModel}) async {
    _isUpdatingPrintingJob = true;
    _lastPrintingJobUpdateError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _productionService.updatePrintingJob(printingJobId: printingJobId, request: formModel.toApiRequest()!),
      onSuccess: (response) {
        setSuccess('Printing job updated successfully');
        return response.data!;
      },
      showLoading: false, // Use custom loading state
      errorMessage: 'Failed to update printing job',
    );

    _isUpdatingPrintingJob = false;
    notifyListeners();
  }

  /// Update box order status and details
  Future<void> updateBoxOrder({required String boxOrderId, required BoxOrderUpdateFormModel formModel}) async {
    _isUpdatingBoxOrder = true;
    _lastBoxOrderUpdateError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _productionService.updateBoxOrder(boxOrderId: boxOrderId, request: formModel.toApiRequest()!),
      onSuccess: (response) {
        setSuccess('Box order updated successfully');
        return response.data!;
      },
      showLoading: false, // Use custom loading state
      errorMessage: 'Failed to update box order',
    );

    _isUpdatingBoxOrder = false;
    notifyListeners();
  }
}
