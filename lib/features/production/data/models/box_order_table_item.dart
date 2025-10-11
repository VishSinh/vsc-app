import 'package:json_annotation/json_annotation.dart';

part 'box_order_table_item.g.dart';

@JsonSerializable()
class BoxOrderTableItem {
  @JsonKey(name: 'box_order_id')
  final String boxOrderId;
  @JsonKey(name: 'order_name')
  final String orderName;
  final int quantity;
  @JsonKey(name: 'box_maker_paid')
  final bool boxMakerPaid;

  const BoxOrderTableItem({required this.boxOrderId, required this.orderName, required this.quantity, required this.boxMakerPaid});

  factory BoxOrderTableItem.fromJson(Map<String, dynamic> json) => _$BoxOrderTableItemFromJson(json);

  Map<String, dynamic> toJson() => _$BoxOrderTableItemToJson(this);

  BoxOrderTableItem copyWith({String? boxOrderId, String? orderName, int? quantity, bool? boxMakerPaid}) {
    return BoxOrderTableItem(
      boxOrderId: boxOrderId ?? this.boxOrderId,
      orderName: orderName ?? this.orderName,
      quantity: quantity ?? this.quantity,
      boxMakerPaid: boxMakerPaid ?? this.boxMakerPaid,
    );
  }
}
