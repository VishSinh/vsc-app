import 'package:flutter/material.dart';
import 'package:vsc_app/core/enums/box_status.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';

/// Provider for managing box order edit form state
class BoxOrderEditFormProvider extends ChangeNotifier {
  late BoxOrderUpdateFormModel _formModel;
  final TextEditingController totalBoxCostController = TextEditingController();
  final TextEditingController totalBoxExpenseController = TextEditingController();
  final TextEditingController boxQuantityController = TextEditingController();

  BoxOrderUpdateFormModel get formModel => _formModel;

  void initializeForm({
    required String currentBoxMakerId,
    required String currentTotalBoxCost,
    required String currentTotalBoxExpense,
    required String currentBoxStatus,
    required String currentBoxType,
    required int currentBoxQuantity,
    String? currentEstimatedCompletion,
  }) {
    _formModel = BoxOrderUpdateFormModel.fromCurrentData(
      boxMakerId: currentBoxMakerId.isNotEmpty ? currentBoxMakerId : null,
      totalBoxCost: currentTotalBoxCost,
      totalBoxExpense: currentTotalBoxExpense,
      boxStatus: currentBoxStatus,
      boxType: currentBoxType,
      boxQuantity: currentBoxQuantity,
      estimatedCompletion: currentEstimatedCompletion,
    );

    // Set initial text for text controllers
    totalBoxCostController.text = _formModel.currentTotalBoxCost ?? '';
    totalBoxExpenseController.text = _formModel.currentTotalBoxExpense ?? '';
    boxQuantityController.text = _formModel.currentBoxQuantity?.toString() ?? '';
  }

  void updateBoxMakerId(String? value) {
    _formModel.currentBoxMakerId = value;
    notifyListeners();
  }

  void updateBoxStatus(BoxStatus? value) {
    _formModel.currentBoxStatus = value;
    notifyListeners();
  }

  void updateBoxType(OrderBoxType? value) {
    _formModel.currentBoxType = value;
    notifyListeners();
  }

  void updateTotalBoxCost(String value) {
    _formModel.currentTotalBoxCost = value.isNotEmpty ? value : null;
    notifyListeners();
  }

  void updateTotalBoxExpense(String value) {
    _formModel.currentTotalBoxExpense = value.isNotEmpty ? value : null;
    notifyListeners();
  }

  void updateBoxQuantity(String value) {
    _formModel.currentBoxQuantity = int.tryParse(value);
    notifyListeners();
  }

  void updateEstimatedCompletion(DateTime? date, TimeOfDay? time) {
    if (date != null && time != null) {
      _formModel.currentEstimatedCompletion = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    totalBoxCostController.dispose();
    boxQuantityController.dispose();
    super.dispose();
  }
}
