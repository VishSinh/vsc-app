import 'package:json_annotation/json_annotation.dart';

part 'printing_table_item.g.dart';

@JsonSerializable()
class PrintingTableItem {
  @JsonKey(name: 'printing_job_id')
  final String printingJobId;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'order_name')
  final String orderName;
  final int quantity;
  @JsonKey(name: 'printer_paid')
  final bool printerPaid;
  final int impressions;

  const PrintingTableItem({
    required this.printingJobId,
    required this.orderId,
    required this.orderName,
    required this.quantity,
    required this.printerPaid,
    required this.impressions,
  });

  factory PrintingTableItem.fromJson(Map<String, dynamic> json) => _$PrintingTableItemFromJson(json);

  Map<String, dynamic> toJson() => _$PrintingTableItemToJson(this);

  PrintingTableItem copyWith({
    String? printingJobId,
    String? orderId,
    String? orderName,
    int? quantity,
    bool? printerPaid,
    int? impressions,
  }) {
    return PrintingTableItem(
      printingJobId: printingJobId ?? this.printingJobId,
      orderId: orderId ?? this.orderId,
      orderName: orderName ?? this.orderName,
      quantity: quantity ?? this.quantity,
      printerPaid: printerPaid ?? this.printerPaid,
      impressions: impressions ?? this.impressions,
    );
  }
}
