import 'package:json_annotation/json_annotation.dart';

part 'printing_job_response.g.dart';

@JsonSerializable()
class PrintingJobResponse {
  final String id;
  @JsonKey(name: 'order_item_id')
  final String orderItemId;
  @JsonKey(name: 'printer_id')
  final String? printerId;
  @JsonKey(name: 'printer_name')
  final String? printerName;
  @JsonKey(name: 'tracing_studio_id')
  final String? tracingStudioId;
  @JsonKey(name: 'tracing_studio_name')
  final String? tracingStudioName;
  @JsonKey(name: 'print_quantity')
  final int printQuantity;
  @JsonKey(name: 'impressions')
  final int impressions;
  @JsonKey(name: 'total_printing_cost')
  final String totalPrintingCost;
  @JsonKey(name: 'total_printing_expense')
  final String? totalPrintingExpense;
  @JsonKey(name: 'total_tracing_expense')
  final String? totalTracingExpense;
  @JsonKey(name: 'printing_status')
  final String printingStatus;
  @JsonKey(name: 'estimated_completion')
  final String? estimatedCompletion;

  const PrintingJobResponse({
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

  factory PrintingJobResponse.fromJson(Map<String, dynamic> json) => _$PrintingJobResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PrintingJobResponseToJson(this);
}
