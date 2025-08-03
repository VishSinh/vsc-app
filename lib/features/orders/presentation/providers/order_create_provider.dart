import 'package:flutter/material.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import '../../data/services/order_service.dart';
import '../models/order_form_models.dart';
import '../services/order_calculation_service.dart';

import 'package:vsc_app/features/cards/data/models/card_responses.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/core/models/customer_model.dart';

/// Provider for managing order creation state and operations
class OrderCreateProvider extends BaseProvider {
  final OrderService _orderService = OrderService();

  final OrderCreationFormViewModel _orderCreationForm = OrderCreationFormViewModel(orderItems: []);

  Customer? _selectedCustomer;
  CardViewModel? _currentCard;

  // Delivery date/time state
  DateTime? _selectedDeliveryDate;
  TimeOfDay? _selectedDeliveryTime;

  final Map<String, CardResponse> _cardDetails = {};

  // Getters for form data
  List<OrderItemCreationFormViewModel> get orderItems => _orderCreationForm.orderItems ?? [];
  String? get selectedCustomerId => _orderCreationForm.customerId;
  String? get orderName => _orderCreationForm.name;
  String? get deliveryDate => _orderCreationForm.deliveryDate;
  String? get specialInstruction => _orderCreationForm.specialInstruction;
  Customer? get selectedCustomer => _selectedCustomer;
  CardViewModel? get currentCardViewModel => _currentCard;

  // Getters for delivery date/time
  DateTime? get selectedDeliveryDate => _selectedDeliveryDate;
  TimeOfDay? get selectedDeliveryTime => _selectedDeliveryTime;

  // Getters for fetched data
  Map<String, CardResponse> get cardDetails => Map.unmodifiable(_cardDetails);

  /// Add order item to the form
  void addOrderItem(OrderItemCreationFormViewModel item) {
    _orderCreationForm.orderItems!.add(item);
    notifyListeners();
  }

  /// Set selected customer data
  void setSelectedCustomerData(Customer customer) {
    _selectedCustomer = customer;
    _orderCreationForm.customerId = customer.id;
    notifyListeners();
  }

  /// Remove order item at specified index
  void removeOrderItem(int index) {
    if (_orderCreationForm.orderItems != null && index >= 0 && index < _orderCreationForm.orderItems!.length) {
      _orderCreationForm.orderItems!.removeAt(index);
      notifyListeners();
    }
  }

  /// Update order item at specified index
  void updateOrderItem(int index, OrderItemCreationFormViewModel item) {
    if (_orderCreationForm.orderItems != null && index >= 0 && index < _orderCreationForm.orderItems!.length) {
      _orderCreationForm.orderItems![index] = item;
      notifyListeners();
    }
  }

  /// Add card details to the cache
  void addCardDetails(String cardId, CardResponse card) {
    _cardDetails[cardId] = card;
    notifyListeners();
  }

  /// Clear current card selection
  void clearCurrentCard() {
    _currentCard = null;
    notifyListeners();
  }

  /// Clear order items only (keep other form data)
  void clearOrderItemsOnly() {
    _orderCreationForm.orderItems?.clear();
    _orderCreationForm.orderItems ??= [];
    notifyListeners();
  }

  /// Search for card by barcode
  Future<void> searchCardByBarcode(String barcode) async {
    await executeApiOperation(
      apiCall: () => CardService().getCardByBarcode(barcode),
      onSuccess: (response) {
        final card = response.data!;
        _currentCard = CardViewModel(
          id: card.id,
          vendorId: card.vendorId,
          barcode: card.barcode,
          sellPrice: card.sellPrice,
          costPrice: card.costPrice,
          maxDiscount: card.maxDiscount,
          quantity: card.quantity,
          image: card.image,
          perceptualHash: card.perceptualHash,
          isActive: card.isActive,
          sellPriceAsDouble: card.sellPriceAsDouble,
          costPriceAsDouble: card.costPriceAsDouble,
          maxDiscountAsDouble: card.maxDiscountAsDouble,
          profitMargin: OrderCalculationService.calculateProfitMargin(card.sellPriceAsDouble, card.costPriceAsDouble),
          totalValue: OrderCalculationService.calculateTotalValue(card.sellPriceAsDouble, card.quantity),
        );
        addCardDetails(card.id, card);
        notifyListeners();
        return card;
      },
      errorMessage: 'Failed to search for card',
    );
  }

  CardViewModel? getCardViewModelById(String cardId) {
    final cardResponse = _cardDetails[cardId];
    if (cardResponse == null) return null;

    return CardViewModel(
      id: cardResponse.id,
      vendorId: cardResponse.vendorId,
      barcode: cardResponse.barcode,
      sellPrice: cardResponse.sellPrice,
      costPrice: cardResponse.costPrice,
      maxDiscount: cardResponse.maxDiscount,
      quantity: cardResponse.quantity,
      image: cardResponse.image,
      perceptualHash: cardResponse.perceptualHash,
      isActive: cardResponse.isActive,
      sellPriceAsDouble: cardResponse.sellPriceAsDouble,
      costPriceAsDouble: cardResponse.costPriceAsDouble,
      maxDiscountAsDouble: cardResponse.maxDiscountAsDouble,
      profitMargin: OrderCalculationService.calculateProfitMargin(cardResponse.sellPriceAsDouble, cardResponse.costPriceAsDouble),
      totalValue: OrderCalculationService.calculateTotalValue(cardResponse.sellPriceAsDouble, cardResponse.quantity),
    );
  }

  /// Create order with current form data
  Future<bool> createOrder() async {
    // Validate order creation
    final validationResult = _orderCreationForm.validate();
    if (!validationResult.isValid) {
      setError(validationResult.firstMessage ?? 'Please check your input');
      return false;
    }

    final result = await executeApiOperation(
      apiCall: () => _orderService.createOrder(request: _orderCreationForm.toApiRequest()),
      onSuccess: (response) {
        reset();
        return response.data!; // Return the MessageData
      },
      successMessage: 'Order created successfully',
      errorMessage: 'Failed to create order',
    );
    return result != null; // Convert to boolean
  }

  /// Reset the provider state
  @override
  void reset() {
    _orderCreationForm.orderItems?.clear();
    _orderCreationForm.orderItems ??= [];
    _orderCreationForm.customerId = null;
    _orderCreationForm.name = null;
    _orderCreationForm.deliveryDate = null;
    _orderCreationForm.specialInstruction = null;
    _selectedCustomer = null;
    _currentCard = null;
    _selectedDeliveryDate = null;
    _selectedDeliveryTime = null;
    super.reset();
  }

  /// Set order name
  void setOrderName(String orderName) {
    _orderCreationForm.name = orderName;
    notifyListeners();
  }

  /// Set delivery date
  void setDeliveryDate(DateTime? date) {
    _selectedDeliveryDate = date;
    if (date != null && _selectedDeliveryTime != null) {
      final deliveryDateTime = DateTime(date.year, date.month, date.day, _selectedDeliveryTime!.hour, _selectedDeliveryTime!.minute);
      _orderCreationForm.deliveryDate = deliveryDateTime.toIso8601String();
    }
    notifyListeners();
  }

  /// Set delivery time
  void setDeliveryTime(TimeOfDay? time) {
    _selectedDeliveryTime = time;
    if (_selectedDeliveryDate != null && time != null) {
      final deliveryDateTime = DateTime(
        _selectedDeliveryDate!.year,
        _selectedDeliveryDate!.month,
        _selectedDeliveryDate!.day,
        time.hour,
        time.minute,
      );
      _orderCreationForm.deliveryDate = deliveryDateTime.toIso8601String();
    }
    notifyListeners();
  }

  /// Set default delivery date and time (tomorrow at 10:00 AM)
  void setDefaultDeliveryDateTime() {
    _selectedDeliveryDate = DateTime.now().add(const Duration(days: 1));
    _selectedDeliveryTime = const TimeOfDay(hour: 10, minute: 0);
    if (_selectedDeliveryDate != null && _selectedDeliveryTime != null) {
      final deliveryDateTime = DateTime(
        _selectedDeliveryDate!.year,
        _selectedDeliveryDate!.month,
        _selectedDeliveryDate!.day,
        _selectedDeliveryTime!.hour,
        _selectedDeliveryTime!.minute,
      );
      _orderCreationForm.deliveryDate = deliveryDateTime.toIso8601String();
    }
    notifyListeners();
  }

  /// Check if order can be created (has required data)
  bool get canCreateOrder {
    return _orderCreationForm.customerId != null &&
        _orderCreationForm.name != null &&
        _orderCreationForm.deliveryDate != null &&
        (_orderCreationForm.orderItems?.isNotEmpty ?? false);
  }

  /// Get order items count
  int get orderItemsCount => _orderCreationForm.orderItems?.length ?? 0;

  /// Check if form has any data
  bool get hasFormData {
    return _orderCreationForm.customerId != null ||
        _orderCreationForm.name != null ||
        _orderCreationForm.deliveryDate != null ||
        (_orderCreationForm.orderItems?.isNotEmpty ?? false);
  }
}
