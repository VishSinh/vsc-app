import 'package:vsc_app/core/enums/printing_status.dart';
import 'package:vsc_app/features/production/data/models/printing_job_requests.dart';

class PrintingJobUpdateFormModel {
  // Original values
  String? printerId;
  String? tracingStudioId;
  String? totalPrintingCost;
  String? totalPrintingExpense;
  String? totalTracingExpense;
  PrintingStatus? printingStatus;
  int? printQuantity;
  int? impressions;
  DateTime? estimatedCompletion;

  // Current values
  String? currentPrinterId;
  String? currentTracingStudioId;
  String? currentTotalPrintingCost;
  String? currentTotalPrintingExpense;
  String? currentTotalTracingExpense;
  PrintingStatus? currentPrintingStatus;
  int? currentPrintQuantity;
  int? currentImpressions;
  DateTime? currentEstimatedCompletion;

  factory PrintingJobUpdateFormModel.fromCurrentData({
    String? printerId,
    String? tracingStudioId,
    String? totalPrintingCost,
    String? totalPrintingExpense,
    String? totalTracingExpense,
    String? printingStatus,
    int? printQuantity,
    int? impressions,
    String? estimatedCompletion,
  }) {
    final model = PrintingJobUpdateFormModel._();
    model.printerId = printerId;
    model.tracingStudioId = tracingStudioId;
    model.totalPrintingCost = totalPrintingCost;
    model.totalPrintingExpense = totalPrintingExpense;
    model.totalTracingExpense = totalTracingExpense;
    model.printingStatus = PrintingStatusExtension.fromApiString(printingStatus);
    model.printQuantity = printQuantity;
    model.impressions = impressions;
    model.estimatedCompletion = estimatedCompletion != null ? DateTime.tryParse(estimatedCompletion) : null;

    // Initialize current values with original values
    model.currentPrinterId = model.printerId;
    model.currentTracingStudioId = model.tracingStudioId;
    model.currentTotalPrintingCost = model.totalPrintingCost;
    model.currentTotalPrintingExpense = model.totalPrintingExpense;
    model.currentTotalTracingExpense = model.totalTracingExpense;
    model.currentPrintingStatus = model.printingStatus;
    model.currentPrintQuantity = model.printQuantity;
    model.currentImpressions = model.impressions;
    model.currentEstimatedCompletion = model.estimatedCompletion;

    return model;
  }

  PrintingJobUpdateFormModel._();

  bool get hasChanges {
    return _isValueChanged(printerId, currentPrinterId) ||
        _isValueChanged(tracingStudioId, currentTracingStudioId) ||
        _isValueChanged(totalPrintingCost, currentTotalPrintingCost) ||
        _isValueChanged(totalPrintingExpense, currentTotalPrintingExpense) ||
        _isValueChanged(totalTracingExpense, currentTotalTracingExpense) ||
        _isValueChanged(printingStatus, currentPrintingStatus) ||
        _isValueChanged(printQuantity, currentPrintQuantity) ||
        _isValueChanged(impressions, currentImpressions) ||
        _isValueChanged(estimatedCompletion, currentEstimatedCompletion);
  }

  PrintingJobUpdateRequest? toApiRequest() {
    final request = <String, dynamic>{};
    bool hasAnyChanges = false;

    if (_isValueChanged(printerId, currentPrinterId)) {
      request['printer_id'] = currentPrinterId;
      hasAnyChanges = true;
    }

    if (_isValueChanged(tracingStudioId, currentTracingStudioId)) {
      request['tracing_studio_id'] = currentTracingStudioId;
      hasAnyChanges = true;
    }

    if (_isValueChanged(totalPrintingCost, currentTotalPrintingCost)) {
      request['total_printing_cost'] = currentTotalPrintingCost;
      hasAnyChanges = true;
    }

    if (_isValueChanged(totalPrintingExpense, currentTotalPrintingExpense)) {
      request['total_printing_expense'] = currentTotalPrintingExpense;
      hasAnyChanges = true;
    }

    if (_isValueChanged(totalTracingExpense, currentTotalTracingExpense)) {
      request['total_tracing_expense'] = currentTotalTracingExpense;
      hasAnyChanges = true;
    }

    if (_isValueChanged(printingStatus, currentPrintingStatus)) {
      request['printing_status'] = currentPrintingStatus?.toApiString();
      hasAnyChanges = true;
    }

    if (_isValueChanged(printQuantity, currentPrintQuantity)) {
      request['print_quantity'] = currentPrintQuantity;
      hasAnyChanges = true;
    }

    if (_isValueChanged(impressions, currentImpressions)) {
      request['impressions'] = currentImpressions;
      hasAnyChanges = true;
    }

    if (_isValueChanged(estimatedCompletion, currentEstimatedCompletion)) {
      request['estimated_completion'] = currentEstimatedCompletion?.toIso8601String();
      hasAnyChanges = true;
    }

    return hasAnyChanges ? PrintingJobUpdateRequest.fromJson(request) : null;
  }

  bool _isValueChanged(dynamic original, dynamic current) {
    if (original == null && current == null) return false;
    if (original == null && current != null && current.toString().isEmpty) return false;
    if (current == null && original != null && original.toString().isEmpty) return false;
    if (original == null && current != null && current.toString().isNotEmpty) return true;
    if (current == null && original != null && original.toString().isNotEmpty) return true;
    return original != current;
  }
}
