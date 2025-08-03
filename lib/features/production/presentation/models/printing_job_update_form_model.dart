import 'package:vsc_app/core/enums/printing_status.dart';

/// Form model for updating printing jobs
class PrintingJobUpdateFormModel {
  // Original values (populated from current printing job data)
  String? printerId;
  String? tracingStudioId;
  String? totalPrintingCost;
  PrintingStatus? printingStatus;
  int? printQuantity;
  DateTime? estimatedCompletion;

  // Current values (user input)
  String? currentPrinterId;
  String? currentTracingStudioId;
  String? currentTotalPrintingCost;
  PrintingStatus? currentPrintingStatus;
  int? currentPrintQuantity;
  DateTime? currentEstimatedCompletion;

  PrintingJobUpdateFormModel({
    this.printerId,
    this.tracingStudioId,
    this.totalPrintingCost,
    this.printingStatus,
    this.printQuantity,
    this.estimatedCompletion,
  });

  /// Create from current printing job data
  factory PrintingJobUpdateFormModel.fromCurrentData({
    String? printerId,
    String? tracingStudioId,
    String? totalPrintingCost,
    String? printingStatus,
    int? printQuantity,
    String? estimatedCompletion,
  }) {
    return PrintingJobUpdateFormModel(
      printerId: printerId,
      tracingStudioId: tracingStudioId,
      totalPrintingCost: totalPrintingCost,
      printingStatus: PrintingStatusExtension.fromApiString(printingStatus),
      printQuantity: printQuantity,
      estimatedCompletion: estimatedCompletion != null ? DateTime.tryParse(estimatedCompletion) : null,
    );
  }

  /// Check if form has any changes
  bool get hasChanges {
    return _isValueChanged(printerId, currentPrinterId) ||
        _isValueChanged(tracingStudioId, currentTracingStudioId) ||
        _isValueChanged(totalPrintingCost, currentTotalPrintingCost) ||
        _isValueChanged(printingStatus, currentPrintingStatus) ||
        _isValueChanged(printQuantity, currentPrintQuantity) ||
        _isValueChanged(estimatedCompletion, currentEstimatedCompletion);
  }

  /// Compare two values, treating null and empty string as same
  bool _isValueChanged(dynamic original, dynamic current) {
    if (original == null && current == null) return false;
    if (original == null && current != null && current.toString().isEmpty) return false;
    if (current == null && original != null && original.toString().isEmpty) return false;
    if (original == null && current != null && current.toString().isNotEmpty) return true;
    if (current == null && original != null && original.toString().isNotEmpty) return true;
    return original != current;
  }

  /// Clear all form data
  void clear() {
    printerId = null;
    tracingStudioId = null;
    totalPrintingCost = null;
    printingStatus = null;
    printQuantity = null;
    estimatedCompletion = null;

    // Reset current values
    currentPrinterId = null;
    currentTracingStudioId = null;
    currentTotalPrintingCost = null;
    currentPrintingStatus = null;
    currentPrintQuantity = null;
    currentEstimatedCompletion = null;
  }
}
