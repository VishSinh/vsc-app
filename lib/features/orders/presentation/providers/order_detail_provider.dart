import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/orders/data/services/order_service.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/features/production/data/services/production_service.dart';
import 'package:vsc_app/features/production/presentation/models/box_maker_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_update_form_model.dart';
import 'package:vsc_app/features/production/presentation/models/printer_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/tracing_studio_view_model.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import 'package:vsc_app/features/orders/presentation/models/order_update_form_models.dart';

/// Provider for managing order details and production operations
class OrderDetailProvider extends BaseProvider {
  final OrderService _orderService = OrderService();
  final ProductionService _productionService = ProductionService();
  final CardService _cardService = CardService();

  // Order detail state
  OrderViewModel? _currentOrder;

  // Card cache for order items
  final Map<String, OrderCardViewModel> _cardCache = {};

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
  OrderViewModel? get currentOrder => _currentOrder;
  Map<String, OrderCardViewModel> get cardCache => Map.unmodifiable(_cardCache);

  // Scanned/selected card for adding new items in Edit flow
  OrderCardViewModel? _currentScannedCard;
  OrderCardViewModel? get currentScannedCard => _currentScannedCard;

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

  /// Get order by ID
  Future<void> getOrderById(String id) async {
    await executeApiOperation(
      apiCall: () => _orderService.getOrderById(id),
      onSuccess: (response) async {
        _currentOrder = OrderViewModel.fromApiResponse(response.data!);

        // Fetch card information for each order item
        await _fetchCardDetailsForOrderItems();

        return response.data!;
      },
      showSnackbar: false,
      errorMessage: 'Order not found',
    );
  }

  /// Select an order
  void selectOrder(OrderViewModel order) {
    _currentOrder = order;
    notifyListeners();
  }

  /// Clear selected order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// Reset the provider state
  @override
  void reset() {
    _currentOrder = null;
    _cardCache.clear();
    _boxMakers.clear();
    _printers.clear();
    _tracingStudios.clear();
    _isLoadingBoxMakers = false;
    _isUpdatingBoxOrder = false;
    _isLoadingPrinters = false;
    _isLoadingTracingStudios = false;
    _isUpdatingPrintingJob = false;
    _lastBoxMakersError = null;
    _lastBoxOrderUpdateError = null;
    _lastPrintersError = null;
    _lastTracingStudiosError = null;
    _lastPrintingJobUpdateError = null;
    super.reset();
  }

  /// Check if an order is selected
  bool get hasSelectedOrder => _currentOrder != null;

  /// Fetch card details for all order items
  Future<void> _fetchCardDetailsForOrderItems() async {
    if (_currentOrder == null) return;

    final cardIds = _currentOrder!.orderItems.map((item) => item.cardId).toSet();

    for (final cardId in cardIds) {
      if (!_cardCache.containsKey(cardId)) {
        await _fetchCardById(cardId);
      }
    }

    // Update order items with card information
    _updateOrderItemsWithCardInfo();
  }

  /// Fetch card by ID and cache it
  Future<void> _fetchCardById(String cardId) async {
    try {
      final response = await _cardService.getCardById(cardId);
      if (response.success && response.data != null) {
        final cardViewModel = OrderCardViewModel.fromApiResponse(response.data!);
        _cardCache[cardId] = cardViewModel;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Failed to fetch card $cardId: $e');
    }
  }

  /// Update order items with card information
  void _updateOrderItemsWithCardInfo() {
    if (_currentOrder == null) return;

    final updatedItems = _currentOrder!.orderItems.map((item) {
      final card = _cardCache[item.cardId];
      return item.copyWith(card: card);
    }).toList();

    _currentOrder = _currentOrder!.copyWith(orderItems: updatedItems);
    notifyListeners();
  }

  /// Get card for a specific order item
  OrderCardViewModel? getCardForOrderItem(String cardId) {
    return _cardCache[cardId];
  }

  /// Search card by barcode and cache it for add-item flow
  Future<void> searchCardByBarcode(String barcode) async {
    await executeApiOperation(
      apiCall: () => _cardService.getCardByBarcode(barcode),
      onSuccess: (response) {
        final cardVm = OrderCardViewModel.fromApiResponse(response.data!);
        _currentScannedCard = cardVm;
        _cardCache[cardVm.id] = cardVm; // cache for display reuse
        notifyListeners();
        return response.data!;
      },
      errorMessage: 'Failed to search for card',
    );
  }

  void clearCurrentScannedCard() {
    _currentScannedCard = null;
    notifyListeners();
  }

  /// Update order via API and refresh details
  Future<void> updateOrder({required String orderId, required OrderUpdateFormModel formModel}) async {
    await executeApiOperation(
      apiCall: () => _orderService.updateOrder(orderId: orderId, request: formModel.toApiRequest()),
      onSuccess: (response) async {
        setSuccess('Order updated successfully');
        await getOrderById(orderId);
        return response.data!;
      },
      showLoading: true,
      errorMessage: 'Failed to update order',
    );
  }

  /// Delete order by ID
  Future<bool> deleteOrder(String orderId) async {
    final result = await executeApiOperation(
      apiCall: () => _orderService.deleteOrder(orderId),
      onSuccess: (response) {
        clearCurrentOrder();
        return true;
      },
      showLoading: true,
      successMessage: 'Order deleted successfully',
      errorMessage: 'Failed to delete order',
    );
    return result ?? false;
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
