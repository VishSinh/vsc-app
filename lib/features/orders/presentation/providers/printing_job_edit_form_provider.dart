import 'package:flutter/material.dart';
import 'package:vsc_app/core/enums/printing_status.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_update_form_model.dart';

/// Provider for managing printing job edit form state
class PrintingJobEditFormProvider extends ChangeNotifier {
  late PrintingJobUpdateFormModel _formModel;
  final TextEditingController totalPrintingCostController = TextEditingController();
  final TextEditingController printQuantityController = TextEditingController();
  final TextEditingController totalPrintingExpenseController = TextEditingController();
  final TextEditingController totalTracingExpenseController = TextEditingController();

  PrintingJobUpdateFormModel get formModel => _formModel;

  void initializeForm({
    required String currentPrinterId,
    required String currentTracingStudioId,
    required String currentTotalPrintingCost,
    required String currentTotalPrintingExpense,
    required String currentTotalTracingExpense,
    required String currentPrintingStatus,
    required int currentPrintQuantity,
    String? currentEstimatedCompletion,
  }) {
    _formModel = PrintingJobUpdateFormModel.fromCurrentData(
      printerId: currentPrinterId.isNotEmpty ? currentPrinterId : null,
      tracingStudioId: currentTracingStudioId.isNotEmpty ? currentTracingStudioId : null,
      totalPrintingCost: currentTotalPrintingCost,
      totalPrintingExpense: currentTotalPrintingExpense,
      totalTracingExpense: currentTotalTracingExpense,
      printingStatus: currentPrintingStatus,
      printQuantity: currentPrintQuantity,
      estimatedCompletion: currentEstimatedCompletion,
    );

    // Set initial text for text controllers
    totalPrintingCostController.text = _formModel.currentTotalPrintingCost ?? '';
    printQuantityController.text = _formModel.currentPrintQuantity?.toString() ?? '';
    totalPrintingExpenseController.text = _formModel.currentTotalPrintingExpense ?? '';
    totalTracingExpenseController.text = _formModel.currentTotalTracingExpense ?? '';
  }

  void updatePrinterId(String? value) {
    _formModel.currentPrinterId = value;
    notifyListeners();
  }

  void updateTracingStudioId(String? value) {
    _formModel.currentTracingStudioId = value;
    notifyListeners();
  }

  void updatePrintingStatus(PrintingStatus? value) {
    _formModel.currentPrintingStatus = value;
    notifyListeners();
  }

  void updateTotalPrintingCost(String value) {
    _formModel.currentTotalPrintingCost = value.isNotEmpty ? value : null;
    notifyListeners();
  }

  void updateTotalPrintingExpense(String value) {
    _formModel.currentTotalPrintingExpense = value.isNotEmpty ? value : null;
    notifyListeners();
  }

  void updateTotalTracingExpense(String value) {
    _formModel.currentTotalTracingExpense = value.isNotEmpty ? value : null;
    notifyListeners();
  }

  void updatePrintQuantity(String value) {
    _formModel.currentPrintQuantity = int.tryParse(value);
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
    totalPrintingCostController.dispose();
    printQuantityController.dispose();
    super.dispose();
  }
}
