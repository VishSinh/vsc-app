import 'package:json_annotation/json_annotation.dart';

part 'tracing_table_item.g.dart';

@JsonSerializable()
class TracingTableItem {
  @JsonKey(name: 'printing_job_id')
  final String printingJobId;
  @JsonKey(name: 'order_name')
  final String orderName;
  final int quantity;
  @JsonKey(name: 'tracing_studio_paid')
  final bool tracingStudioPaid;

  const TracingTableItem({
    required this.printingJobId,
    required this.orderName,
    required this.quantity,
    required this.tracingStudioPaid,
  });

  factory TracingTableItem.fromJson(Map<String, dynamic> json) => _$TracingTableItemFromJson(json);

  Map<String, dynamic> toJson() => _$TracingTableItemToJson(this);

  TracingTableItem copyWith({String? printingJobId, String? orderName, int? quantity, bool? tracingStudioPaid}) {
    return TracingTableItem(
      printingJobId: printingJobId ?? this.printingJobId,
      orderName: orderName ?? this.orderName,
      quantity: quantity ?? this.quantity,
      tracingStudioPaid: tracingStudioPaid ?? this.tracingStudioPaid,
    );
  }
}
