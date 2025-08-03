import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import '../../data/services/order_service.dart';
import '../services/order_mapper_service.dart';
import 'package:vsc_app/features/production/data/services/production_service.dart';
import 'package:vsc_app/features/production/presentation/models/box_maker_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';
import 'package:vsc_app/features/production/presentation/services/production_mapper_service.dart';
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
    try {
      setLoading(true);
      clearMessages();

      final response = await _orderService.getOrders(page: page, pageSize: pageSize);

      if (response.success) {
        _orders.clear();
        // Use the mapper to convert OrderResponse to OrderViewModel
        final orderViewModels = (response.data ?? []).map((orderResponse) => OrderMapperService.orderResponseToViewModel(orderResponse)).toList();
        _orders.addAll(orderViewModels);
        _pagination = response.pagination;
        notifyListeners();
        return true;
      } else {
        setError(response.error?.message ?? 'Failed to fetch orders');
        return false;
      }
    } catch (e) {
      setError('Error fetching orders: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> loadNextPage() async {
    if (_pagination?.hasNext == true) {
      return await fetchOrders(page: (_pagination?.currentPage ?? 1) + 1);
    }
    return false;
  }

  Future<bool> refreshOrders() async {
    return await fetchOrders();
  }

  // Order detail methods
  Future<bool> fetchOrderById(String orderId) async {
    try {
      setLoading(true);
      clearMessages();

      final response = await _orderService.getOrderById(orderId);

      if (response.success) {
        _currentOrder = OrderMapperService.orderResponseToViewModel(response.data!);
        notifyListeners();
        return true;
      } else {
        setError(response.error?.message ?? 'Failed to fetch order details');
        return false;
      }
    } catch (e) {
      setError('Error fetching order details: $e');
      return false;
    } finally {
      setLoading(false);
    }
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

  // Production methods for box orders
  /// Fetch box makers
  Future<void> fetchBoxMakers({int page = 1, int pageSize = 10}) async {
    try {
      setLoading(true);
      _isLoadingBoxMakers = true;
      _lastBoxMakersError = null;
      clearMessages();
      notifyListeners();

      final response = await _productionService.getBoxMakers(page: page, pageSize: pageSize);

      if (response.success) {
        _boxMakers = BoxMakerViewModel.fromResponseList(response.data!);
      } else {
        _lastBoxMakersError = response.error?.message ?? 'Failed to fetch box makers';
        setError(_lastBoxMakersError!);
      }
    } catch (e) {
      _lastBoxMakersError = e.toString();
      setError('Error fetching box makers: $e');
    } finally {
      setLoading(false);
      _isLoadingBoxMakers = false;
      notifyListeners();
    }
  }

  // Production methods for printing jobs
  /// Fetch printers
  Future<void> fetchPrinters({int page = 1, int pageSize = 10}) async {
    try {
      setLoading(true);
      _isLoadingPrinters = true;
      _lastPrintersError = null;
      clearMessages();
      notifyListeners();

      final response = await _productionService.getPrinters(page: page, pageSize: pageSize);

      if (response.success) {
        _printers = PrinterViewModel.fromResponseList(response.data!);
      } else {
        _lastPrintersError = response.error?.message ?? 'Failed to fetch printers';
        setError(_lastPrintersError!);
      }
    } catch (e) {
      _lastPrintersError = e.toString();
      setError('Error fetching printers: $e');
    } finally {
      setLoading(false);
      _isLoadingPrinters = false;
      notifyListeners();
    }
  }

  /// Fetch tracing studios
  Future<void> fetchTracingStudios({int page = 1, int pageSize = 10}) async {
    try {
      setLoading(true);
      _isLoadingTracingStudios = true;
      _lastTracingStudiosError = null;
      clearMessages();
      notifyListeners();

      final response = await _productionService.getTracingStudios(page: page, pageSize: pageSize);

      if (response.success) {
        _tracingStudios = TracingStudioViewModel.fromResponseList(response.data!);
      } else {
        _lastTracingStudiosError = response.error?.message ?? 'Failed to fetch tracing studios';
        setError(_lastTracingStudiosError!);
      }
    } catch (e) {
      _lastTracingStudiosError = e.toString();
      setError('Error fetching tracing studios: $e');
    } finally {
      setLoading(false);
      _isLoadingTracingStudios = false;
      notifyListeners();
    }
  }

  /// Update printing job status and details
  Future<void> updatePrintingJob({required String printingJobId, required PrintingJobUpdateFormModel formModel}) async {
    try {
      setLoading(true);
      _isUpdatingPrintingJob = true;
      _lastPrintingJobUpdateError = null;
      clearMessages();
      notifyListeners();

      // Use mapper service to convert form model to request
      final request = ProductionMapperService.printingJobUpdateFormModelToRequest(formModel);

      // If no changes detected, show warning and return
      if (request == null) {
        setError('No changes detected');
        return;
      }

      // Debug: Log what fields are being sent
      print('Printing Job Update - Request data: ${request.toJson()}');

      final response = await _productionService.updatePrintingJob(printingJobId: printingJobId, request: request);

      if (response.success) {
        setSuccess('Printing job updated successfully');
      } else {
        _lastPrintingJobUpdateError = response.error?.message ?? 'Failed to update printing job';
        setError(_lastPrintingJobUpdateError!);
      }
    } catch (e) {
      _lastPrintingJobUpdateError = e.toString();
      setError('Error updating printing job: $e');
    } finally {
      setLoading(false);
      _isUpdatingPrintingJob = false;
      notifyListeners();
    }
  }

  /// Update box order status and details
  Future<void> updateBoxOrder({required String boxOrderId, required BoxOrderUpdateFormModel formModel}) async {
    try {
      setLoading(true);
      _isUpdatingBoxOrder = true;
      _lastBoxOrderUpdateError = null;
      clearMessages();
      notifyListeners();

      // Use mapper service to convert form model to request
      final request = ProductionMapperService.formModelToRequest(formModel);

      // If no changes detected, show warning and return
      if (request == null) {
        setError('No changes detected');
        return;
      }

      // Debug: Log what fields are being sent
      print('Box Order Update - Request data: ${request.toJson()}');

      final response = await _productionService.updateBoxOrder(boxOrderId: boxOrderId, request: request);

      if (response.success) {
        setSuccess('Box order updated successfully');
      } else {
        _lastBoxOrderUpdateError = response.error?.message ?? 'Failed to update box order';
        setError(_lastBoxOrderUpdateError!);
      }
    } catch (e) {
      _lastBoxOrderUpdateError = e.toString();
      setError('Error updating box order: $e');
    } finally {
      setLoading(false);
      _isUpdatingBoxOrder = false;
      notifyListeners();
    }
  }
}
