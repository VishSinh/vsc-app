import 'package:flutter/material.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import 'package:vsc_app/features/cards/data/models/card_responses.dart';
import 'package:vsc_app/features/orders/presentation/models/order_item_form_model.dart';
import '../../data/services/order_service.dart';
import '../models/order_form_models.dart';

import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/core/models/customer_model.dart';

/// Provider for managing order creation state and operations
class OrderCreateProvider extends BaseProvider {
  final OrderService _orderService = OrderService();

  final OrderCreationFormModel _orderCreationForm = OrderCreationFormModel(orderItems: []);

  Customer? _selectedCustomer;
  CardViewModel? _currentCard;

  // Delivery date/time state
  DateTime? _selectedDeliveryDate;
  TimeOfDay? _selectedDeliveryTime;

  // Change _cardDetails to store CardViewModel
  final Map<String, CardViewModel> _cardDetails = {};

  // Getters for form data
  List<OrderItemCreationFormModel> get orderItems => _orderCreationForm.orderItems ?? [];
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
  void addOrderItem(OrderItemCreationFormModel item) {
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
  void updateOrderItem(int index, OrderItemCreationFormModel item) {
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
      onSuccess: (response) {
        final cardResponse = response.data!;

        _currentCard = CardViewModel.fromApiResponse(cardResponse);

        addCardDetails(cardResponse.id, _currentCard!);
      },
      errorMessage: 'Failed to search for card',
    );
  }

  // Simplify getCardViewModelById since we now store ViewModels
  CardViewModel? getCardViewModelById(String cardId) {
    return _cardDetails[cardId];
  }

  /// Create order with current form data
  Future<String> createOrder() async {
    // Validate order creation
    final validationResult = _orderCreationForm.validate();
    if (!validationResult.isValid) {
      setErrorWithSnackBar(validationResult.firstMessage ?? 'Please check your input', context!);
      return '';
    }

    final result = await executeApiOperation(
      apiCall: () => _orderService.createOrder(request: _orderCreationForm.toApiRequest()),
      onSuccess: (response) {
        reset();
        String billId = response.data!.billId;

        return billId;
      },
      successMessage: 'Order created successfully',
      errorMessage: 'Failed to create order',
    );
    return result ?? '';
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

  void setOrderName(String orderName) {
    _orderCreationForm.name = orderName;
    notifyListeners();
  }

  void setDeliveryDate(DateTime? date) {
    _selectedDeliveryDate = date;
    if (date != null && _selectedDeliveryTime != null) {
      final deliveryDateTime = DateTime(date.year, date.month, date.day, _selectedDeliveryTime!.hour, _selectedDeliveryTime!.minute);
      _orderCreationForm.deliveryDate = deliveryDateTime.toIso8601String();
    }
    notifyListeners();
  }

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

  /// Set default delivery date and time (4 days from now at 6:00 PM)
  void setDefaultDeliveryDateTime() {
    _selectedDeliveryDate = DateTime.now().add(const Duration(days: 4));
    _selectedDeliveryTime = const TimeOfDay(hour: 18, minute: 0);
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

  // bool get canCreateOrder {
  //   return _orderCreationForm.customerId != null &&
  //       _orderCreationForm.name != null &&
  //       _orderCreationForm.deliveryDate != null &&
  //       (_orderCreationForm.orderItems?.isNotEmpty ?? false);
  // }

  // int get orderItemsCount => _orderCreationForm.orderItems?.length ?? 0;

  // bool get hasFormData {
  //   return _orderCreationForm.customerId != null ||
  //       _orderCreationForm.name != null ||
  //       _orderCreationForm.deliveryDate != null ||
  //       (_orderCreationForm.orderItems?.isNotEmpty ?? false);
  // }
}
