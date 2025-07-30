import 'package:vsc_app/core/models/card_model.dart' as card_model;
import 'package:vsc_app/core/models/customer_model.dart';
import 'package:vsc_app/core/models/order_model.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/card_service.dart';
import 'package:vsc_app/core/services/order_service.dart';

class OrderProvider extends BaseProvider {
  final OrderService _orderService = OrderService();
  final CardService _cardService = CardService();

  Customer? _selectedCustomer;
  final List<OrderItem> _orderItems = [];
  card_model.Card? _currentCard;
  String? _deliveryDate;

  Customer? get selectedCustomer => _selectedCustomer;
  List<OrderItem> get orderItems => _orderItems;
  card_model.Card? get currentCard => _currentCard;
  String? get deliveryDate => _deliveryDate;

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
  Future<card_model.Card?> searchCardByBarcode(String barcode) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _cardService.getCardByBarcode(barcode);

      if (response.success && response.data != null) {
        _currentCard = response.data;
        notifyListeners();
        return response.data;
      } else {
        setError(response.error?.message ?? 'Card not found');
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
    final orderItem = OrderItem(
      cardId: cardId,
      discountAmount: discountAmount,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: boxType,
      totalBoxCost: totalBoxCost,
      totalPrintingCost: totalPrintingCost,
    );

    _orderItems.add(orderItem);
    _currentCard = null;
    notifyListeners();
  }

  /// Remove order item
  void removeOrderItem(int index) {
    if (index >= 0 && index < _orderItems.length) {
      _orderItems.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear current card
  void clearCurrentCard() {
    _currentCard = null;
    notifyListeners();
  }

  /// Create order
  Future<bool> createOrder() async {
    if (_selectedCustomer == null) {
      setError('Please select a customer');
      return false;
    }

    if (_orderItems.isEmpty) {
      setError('Please add at least one item to the order');
      return false;
    }

    if (_deliveryDate == null) {
      setError('Please select a delivery date');
      return false;
    }

    try {
      setLoading(true);
      setError(null);

      final response = await _orderService.createOrder(customerId: _selectedCustomer!.id, deliveryDate: _deliveryDate!, orderItems: _orderItems);

      if (response.success) {
        // Clear the order data after successful creation
        clearOrderData();
        return true;
      } else {
        setError(response.error?.message ?? 'Failed to create order');
        return false;
      }
    } catch (e) {
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
    notifyListeners();
  }

  @override
  void reset() {
    super.reset();
    clearOrderData();
  }
}
