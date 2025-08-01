import 'package:vsc_app/core/models/customer_model.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import 'package:vsc_app/features/orders/data/services/order_service.dart';
import 'package:vsc_app/features/orders/domain/services/order_price_calculator_service.dart';
import 'package:vsc_app/features/orders/domain/services/order_mapper_service.dart';
import 'package:vsc_app/features/orders/domain/models/order_item.dart';
import 'package:vsc_app/features/orders/data/models/order_api_models.dart';
import 'package:vsc_app/features/orders/presentation/validators/order_validators.dart' as presentation;
import 'package:vsc_app/features/orders/domain/validators/order_validators.dart' as domain;
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/cards/domain/models/card.dart';
import 'package:vsc_app/features/cards/domain/services/card_mapper_service.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

class OrderProvider extends BaseProvider with AutoSnackBarMixin {
  final OrderService _orderService = OrderService();
  final CardService _cardService = CardService();
  final OrderPriceCalculatorService _priceCalculator = OrderPriceCalculatorService();

  Customer? _selectedCustomer;
  final List<OrderItemViewModel> _orderItems = [];
  CardEntity? _currentCard;
  String? _deliveryDate;

  // Store card details for each order item
  final Map<String, CardEntity> _cardDetails = {};

  Customer? get selectedCustomer => _selectedCustomer;
  List<OrderItemViewModel> get orderItems => _orderItems;
  CardEntity? get currentCard => _currentCard;
  CardViewModel? get currentCardViewModel => _currentCard != null ? CardViewModel.fromDomainModel(_currentCard!) : null;
  String? get deliveryDate => _deliveryDate;

  /// Get cached domain models for calculations
  List<OrderItem> get _domainOrderItems => _orderItems.map((item) => item.toDomainModel()).toList();

  /// Get order total using business logic
  double get orderTotal => _priceCalculator.calculateOrderTotal(_domainOrderItems, _cardDetails);

  /// Get total discount for the order
  double get totalDiscount => _priceCalculator.calculateTotalDiscount(_domainOrderItems);

  /// Get total additional costs (box + printing)
  double get totalAdditionalCosts => _priceCalculator.calculateTotalAdditionalCosts(_domainOrderItems);

  /// Check if order is ready for submission
  bool get isOrderReady {
    return _selectedCustomer != null && _orderItems.isNotEmpty && _deliveryDate != null;
  }

  /// Set selected customer
  void setSelectedCustomer(Customer customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  /// Set delivery date
  void setDeliveryDate(String date) {
    _deliveryDate = date;
    notifyListeners();
  }

  /// Search card by barcode
  Future<CardEntity?> searchCardByBarcode(String barcode) async {
    try {
      setLoading(true);
      setError(null);

      // Validate barcode (UI validation)
      final barcodeResult = presentation.OrderValidators.validateBarcode(barcode);
      if (!barcodeResult.isValid) {
        setError(barcodeResult.firstMessage ?? 'Invalid barcode'); // ✅ Auto SnackBar via mixin
        return null;
      }

      // Check if card is already in order items (business rule)
      final cardNotInOrderResult = domain.OrderDomainValidators.validateCardNotInOrder(barcode, _domainOrderItems);
      if (!cardNotInOrderResult.isValid) {
        setError(cardNotInOrderResult.firstMessage ?? 'Card already in order'); // ✅ Auto SnackBar via mixin
        return null;
      }

      final response = await _cardService.getCardByBarcode(barcode);

      if (response.success && response.data != null) {
        // Convert API response to domain model
        _currentCard = CardMapperService.fromApiResponse(response.data!);
        notifyListeners();
        return _currentCard;
      } else {
        setError(response.error?.details ?? response.error?.message ?? 'Card not found');
        return null;
      }
    } catch (e) {
      setError('Failed to search card: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Add order item
  void addOrderItem({
    required String cardId,
    required String discountAmount,
    required int quantity,
    required bool requiresBox,
    required bool requiresPrinting,
    BoxType? boxType,
    String? totalBoxCost,
    String? totalPrintingCost,
  }) {
    // Validate item addition using business logic
    final validationResult = domain.OrderDomainValidators.validateItemAddition(
      cardId: cardId,
      existingItems: _domainOrderItems,
      quantity: quantity,
      availableStock: _currentCard?.quantity ?? 0,
    );

    if (!validationResult.isValid) {
      setError(validationResult.firstMessage ?? 'Invalid item addition');
      return;
    }

    // Validate discount amount (business rule)
    final discountAmountDouble = double.tryParse(discountAmount) ?? 0.0;
    final discountResult = domain.OrderDomainValidators.validateDiscountAmount(discountAmountDouble, _currentCard?.maxDiscount ?? 0.0);
    if (!discountResult.isValid) {
      setError(discountResult.firstMessage ?? 'Invalid discount amount');
      return;
    }

    // Validate additional costs if required (business rules)
    if (requiresBox) {
      final boxCost = double.tryParse(totalBoxCost ?? '0') ?? 0.0;
      final boxCostResult = domain.OrderDomainValidators.validateBoxCost(boxCost, requiresBox);
      if (!boxCostResult.isValid) {
        setError(boxCostResult.firstMessage ?? 'Invalid box cost');
        return;
      }
    }

    if (requiresPrinting) {
      final printingCost = double.tryParse(totalPrintingCost ?? '0') ?? 0.0;
      final printingCostResult = domain.OrderDomainValidators.validatePrintingCost(printingCost, requiresPrinting);
      if (!printingCostResult.isValid) {
        setError(printingCostResult.firstMessage ?? 'Invalid printing cost');
        return;
      }
    }

    // Create view model from API model
    final apiModel = OrderItemApiModel(
      cardId: cardId,
      discountAmount: discountAmount,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: boxType,
      totalBoxCost: totalBoxCost,
      totalPrintingCost: totalPrintingCost,
    );

    final orderItem = OrderItemViewModel.fromApiModel(apiModel, CardMapperService.toApiResponse(_currentCard!));

    _orderItems.add(orderItem);
    // Store card details for display
    _cardDetails[cardId] = _currentCard!;
    _currentCard = null;
    notifyListeners();
  }

  /// Remove order item
  void removeOrderItem(int index) {
    if (index >= 0 && index < _orderItems.length) {
      final item = _orderItems[index];
      _orderItems.removeAt(index);
      // Remove card details as well
      _cardDetails.remove(item.cardId);
      notifyListeners();
    }
  }

  /// Clear current card
  void clearCurrentCard() {
    _currentCard = null;
    notifyListeners();
  }

  /// Get card by ID from stored card details
  CardEntity? getCardById(String cardId) {
    // First check if it's the current card
    if (_currentCard?.id == cardId) {
      return _currentCard;
    }

    // Check stored card details
    return _cardDetails[cardId];
  }

  /// Get card ViewModel by ID from stored card details (for UI)
  CardViewModel? getCardViewModelById(String cardId) {
    final card = getCardById(cardId);
    return card != null ? CardViewModel.fromDomainModel(card) : null;
  }

  /// Create order
  Future<bool> createOrder() async {
    // Validate order creation using UI validation
    final validationResult = presentation.OrderValidators.validateOrderCreation(
      customer: _selectedCustomer,
      items: _domainOrderItems,
      deliveryDate: _deliveryDate,
    );

    if (!validationResult.isValid) {
      setError(validationResult.firstMessage ?? 'Invalid order data');
      return false;
    }

    try {
      setLoading(true);
      setError(null);

      final response = await _orderService.createOrder(
        customerId: _selectedCustomer!.id,
        deliveryDate: _deliveryDate!,
        orderItems: _domainOrderItems.map((item) => OrderMapperService.toApiModel(item)).toList(),
      );

      if (response.success) {
        // Clear the order data after successful creation
        clearOrderData();
        return true;
      } else {
        setError(response.error?.details ?? response.error?.message ?? 'Failed to create order');
        return false;
      }
    } catch (e) {
      AppLogger.errorCaught('OrderProvider.createOrder', e.toString(), errorObject: e);
      setError('Failed to create order: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Clear order data
  void clearOrderData() {
    _selectedCustomer = null;
    _orderItems.clear();
    _currentCard = null;
    _deliveryDate = null;
    _cardDetails.clear(); // Clear stored card details as well
    notifyListeners();
  }

  /// Clear only order items (preserve customer and delivery date)
  void clearOrderItemsOnly() {
    _orderItems.clear();
    _currentCard = null;
    _cardDetails.clear(); // Clear stored card details as well
    notifyListeners();
  }

  @override
  void reset() {
    super.reset();
    clearOrderData();
  }
}
