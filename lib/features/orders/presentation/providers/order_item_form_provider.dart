import 'package:flutter/material.dart';
import 'package:vsc_app/features/orders/presentation/models/order_form_models.dart';

/// Provider for managing order item form state
class OrderItemFormProvider extends ChangeNotifier {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController boxCostController = TextEditingController();
  final TextEditingController printingCostController = TextEditingController();

  bool _requiresBox = false;
  bool _requiresPrinting = false;
  BoxType _selectedBoxType = BoxType.folding;

  bool get requiresBox => _requiresBox;
  bool get requiresPrinting => _requiresPrinting;
  BoxType get selectedBoxType => _selectedBoxType;

  OrderItemFormProvider() {
    quantityController.text = '1';
    discountController.text = '0.00';
    boxCostController.text = '0.00';
    printingCostController.text = '0.00';
  }

  void setRequiresBox(bool value) {
    _requiresBox = value;
    notifyListeners();
  }

  void setRequiresPrinting(bool value) {
    _requiresPrinting = value;
    notifyListeners();
  }

  void setSelectedBoxType(BoxType value) {
    _selectedBoxType = value;
    notifyListeners();
  }

  void reset() {
    quantityController.text = '1';
    discountController.text = '0.00';
    boxCostController.text = '0.00';
    printingCostController.text = '0.00';
    _requiresBox = false;
    _requiresPrinting = false;
    _selectedBoxType = BoxType.folding;
    notifyListeners();
  }

  @override
  void dispose() {
    quantityController.dispose();
    discountController.dispose();
    boxCostController.dispose();
    printingCostController.dispose();
    super.dispose();
  }
}
