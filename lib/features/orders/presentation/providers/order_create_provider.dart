import 'package:flutter/material.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import '../../data/services/order_service.dart';
import '../models/order_form_models.dart';
import '../services/order_calculation_service.dart';

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

  // Change _cardDetails to store CardViewModel
  final Map<String, CardViewModel> _cardDetails = {};

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
  Map<String, CardViewModel> get cardDetails => Map.unmodifiable(_cardDetails);

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
  void addCardDetails(String cardId, CardViewModel card) {
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
      onSuccess: (dynamic response) {
        final cardData = response.data as dynamic;
        final double sellPriceNum = (cardData.sellPriceAsDouble as double?) ?? 0.0;
        final double costPriceNum = (cardData.costPriceAsDouble as double?) ?? 0.0;
        final double maxDiscountNum = (cardData.maxDiscountAsDouble as double?) ?? 0.0;
        final int quantityNum = (cardData.quantity as int?) ?? 0;
        _currentCard = CardViewModel(
          id: (cardData.id as String?) ?? '',
          vendorId: (cardData.vendorId as String?) ?? '',
          barcode: (cardData.barcode as String?) ?? '',
          sellPrice: sellPriceNum.toStringAsFixed(2),
          costPrice: costPriceNum.toStringAsFixed(2),
          maxDiscount: maxDiscountNum.toStringAsFixed(2),
          quantity: quantityNum,
          image: cardData.image as String,
          perceptualHash: cardData.perceptualHash as String,
          isActive: (cardData.isActive as bool?) ?? true,
          sellPriceAsDouble: sellPriceNum,
          costPriceAsDouble: costPriceNum,
          maxDiscountAsDouble: maxDiscountNum,
          profitMargin: OrderCalculationService.calculateProfitMargin(sellPriceNum, costPriceNum),
          totalValue: OrderCalculationService.calculateTotalValue(sellPriceNum, quantityNum),
        );
        addCardDetails(cardData.id as String, _currentCard!);
      },
      errorMessage: 'Failed to search for card',
    );
  }

  // Simplify getCardViewModelById since we now store ViewModels
  CardViewModel? getCardViewModelById(String cardId) {
    return _cardDetails[cardId];
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
