import 'package:json_annotation/json_annotation.dart';

part 'printing_job_requests.g.dart';

/// Request model for updating a printing job
@JsonSerializable()
class PrintingJobUpdateRequest {
  @JsonKey(name: 'printer_id')
  final String? printerId;

  @JsonKey(name: 'tracing_studio_id')
  final String? tracingStudioId;

  @JsonKey(name: 'total_printing_cost')
  final String? totalPrintingCost;

  @JsonKey(name: 'printing_status')
  final String? printingStatus;

  @JsonKey(name: 'print_quantity')
  final int? printQuantity;

  @JsonKey(name: 'estimated_completion')
  final String? estimatedCompletion;

  const PrintingJobUpdateRequest({
    this.printerId,
    this.tracingStudioId,
    this.totalPrintingCost,
    this.printingStatus,
    this.printQuantity,
    this.estimatedCompletion,
  });

  factory PrintingJobUpdateRequest.fromJson(Map<String, dynamic> json) => _$PrintingJobUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PrintingJobUpdateRequestToJson(this);
}
