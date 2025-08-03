import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import '../../data/services/order_service.dart';
import '../services/order_mapper_service.dart';
import '../models/order_form_models.dart';

import 'package:vsc_app/features/cards/data/models/card_responses.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/core/models/customer_model.dart';

/// Provider for managing order creation state and operations
class OrderProvider extends BaseProvider {
  final OrderService _orderService = OrderService();

  final OrderCreationFormViewModel _orderCreationForm = OrderCreationFormViewModel(orderItems: []);

  Customer? _selectedCustomer;
  CardViewModel? _currentCard;

  final Map<String, CardResponse> _cardDetails = {};

  // Getters for form data
  List<OrderItemCreationFormViewModel> get orderItems => _orderCreationForm.orderItems ?? [];
  String? get selectedCustomerId => _orderCreationForm.customerId;
  String? get orderName => _orderCreationForm.name;
  String? get deliveryDate => _orderCreationForm.deliveryDate;
  String? get specialInstruction => _orderCreationForm.specialInstruction;
  Customer? get selectedCustomer => _selectedCustomer;
  CardViewModel? get currentCardViewModel => _currentCard;

  // Getters for fetched data
  Map<String, CardResponse> get cardDetails => Map.unmodifiable(_cardDetails);

  // Order creation methods
  void addOrderItem(OrderItemCreationFormViewModel item) {
    _orderCreationForm.orderItems!.add(item);
    notifyListeners();
  }

  void setSelectedCustomerData(Customer customer) {
    _selectedCustomer = customer;
    _orderCreationForm.customerId = customer.id;
    notifyListeners();
  }

  void removeOrderItem(int index) {
    if (_orderCreationForm.orderItems != null && index >= 0 && index < _orderCreationForm.orderItems!.length) {
      _orderCreationForm.orderItems!.removeAt(index);
      notifyListeners();
    }
  }

  void updateOrderItem(int index, OrderItemCreationFormViewModel item) {
    if (_orderCreationForm.orderItems != null && index >= 0 && index < _orderCreationForm.orderItems!.length) {
      _orderCreationForm.orderItems![index] = item;
      notifyListeners();
    }
  }

  void addCardDetails(String cardId, CardResponse card) {
    _cardDetails[cardId] = card;
    notifyListeners();
  }

  void clearCurrentCard() {
    _currentCard = null;
    notifyListeners();
  }

  void clearOrderItemsOnly() {
    _orderCreationForm.orderItems?.clear();
    _orderCreationForm.orderItems ??= [];
    notifyListeners();
  }

  // Card search method
  Future<void> searchCardByBarcode(String barcode) async {
    try {
      setLoading(true);
      clearMessages();

      final response = await CardService().getCardByBarcode(barcode);

      if (response.success) {
        CardResponse card = response.data!;
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
          profitMargin: _calculateProfitMargin(card.sellPriceAsDouble, card.costPriceAsDouble),
          totalValue: _calculateTotalValue(card.sellPriceAsDouble, card.quantity),
        );
        addCardDetails(card.id, card);
        notifyListeners();
        setSuccess('Card found: ${response.data!.barcode}');
      } else {
        setError(response.error?.message ?? 'Failed to search for card');
      }
    } catch (e) {
      setError('Error searching for card: $e');
    } finally {
      setLoading(false);
    }
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
      profitMargin: _calculateProfitMargin(cardResponse.sellPriceAsDouble, cardResponse.costPriceAsDouble),
      totalValue: _calculateTotalValue(cardResponse.sellPriceAsDouble, cardResponse.quantity),
    );
  }

  // Simple business calculations
  static double _calculateProfitMargin(double sellPrice, double costPrice) {
    if (costPrice == 0) return 0;
    return ((sellPrice - costPrice) / costPrice) * 100;
  }

  static double _calculateTotalValue(double sellPrice, int quantity) {
    return sellPrice * quantity;
  }

  Future<bool> createOrder() async {
    try {
      setLoading(true);
      clearMessages();

      final response = await _orderService.createOrder(request: OrderMapperService.orderCreationFormToRequest(_orderCreationForm));

      if (response.success) {
        setSuccess('Order created successfully');
        reset();
        return true;
      } else {
        setError(response.error?.message ?? 'Failed to create order');
        return false;
      }
    } catch (e) {
      setError('Error creating order: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Utility methods
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
    super.reset();
  }

  void setDeliveryDate(String deliveryDate) {
    _orderCreationForm.deliveryDate = deliveryDate;
    notifyListeners();
  }

  void setOrderName(String orderName) {
    _orderCreationForm.name = orderName;
    notifyListeners();
  }
}
