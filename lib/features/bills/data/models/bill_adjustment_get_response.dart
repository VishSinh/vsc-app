// API sample item:
// {
//   "id": "b0fe5bb5-b0d9-4aa2-a09f-a0de4a584446",
//   "bill_id": "e76140a8-728f-4b85-a7fa-b3e8bd9690a7",
//   "staff_id": "cefb9fb8-d353-4da7-aecd-054c1dddcef0",
//   "staff_name": "Vijay Sinha",
//   "adjustment_type": "NEGOTIATION",
//   "amount": "900.00",
//   "reason": "Meow"
// }

import 'package:json_annotation/json_annotation.dart';

part 'bill_adjustment_get_response.g.dart';

@JsonSerializable()
class BillAdjustmentGetResponse {
  final String id;

  @JsonKey(name: 'bill_id')
  final String billId;

  @JsonKey(name: 'staff_id')
  final String staffId;

  @JsonKey(name: 'staff_name')
  final String staffName;

  @JsonKey(name: 'adjustment_type')
  final String adjustmentType;

  @JsonKey(fromJson: _amountFromJson)
  final double amount;

  final String reason;

  const BillAdjustmentGetResponse({
    required this.id,
    required this.billId,
    required this.staffId,
    required this.staffName,
    required this.adjustmentType,
    required this.amount,
    required this.reason,
  });

  factory BillAdjustmentGetResponse.fromJson(Map<String, dynamic> json) => _$BillAdjustmentGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BillAdjustmentGetResponseToJson(this);
}

double _amountFromJson(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
