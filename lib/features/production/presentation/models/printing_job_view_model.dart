import 'package:vsc_app/features/production/data/models/printing_job_response.dart';

class PrintingJobViewModel {
  final String id;
  final String orderItemId;
  final String? printerId;
  final String? printerName;
  final String? tracingStudioId;
  final String? tracingStudioName;
  final int printQuantity;
  final int impressions;
  final String totalPrintingCost;
  final String? totalPrintingExpense;
  final String? totalTracingExpense;
  final String printingStatus;
  final DateTime? estimatedCompletion;

  PrintingJobViewModel({
    required this.id,
    required this.orderItemId,
    this.printerId,
    this.printerName,
    this.tracingStudioId,
    this.tracingStudioName,
    required this.printQuantity,
    required this.impressions,
    required this.totalPrintingCost,
    this.totalPrintingExpense,
    this.totalTracingExpense,
    required this.printingStatus,
    this.estimatedCompletion,
  });

  factory PrintingJobViewModel.fromApiResponse(PrintingJobResponse response) {
    return PrintingJobViewModel(
      id: response.id,
      orderItemId: response.orderItemId,
      printerId: response.printerId,
      printerName: response.printerName,
      tracingStudioId: response.tracingStudioId,
      tracingStudioName: response.tracingStudioName,
      printQuantity: response.printQuantity,
      impressions: response.impressions,
      totalPrintingCost: response.totalPrintingCost,
      totalPrintingExpense: response.totalPrintingExpense,
      totalTracingExpense: response.totalTracingExpense,
      printingStatus: response.printingStatus,
      estimatedCompletion: response.estimatedCompletion != null ? DateTime.parse(response.estimatedCompletion!) : null,
    );
  }
}
