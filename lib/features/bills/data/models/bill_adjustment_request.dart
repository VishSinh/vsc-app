import 'package:json_annotation/json_annotation.dart';

part 'bill_adjustment_request.g.dart';

@JsonSerializable()
class BillAdjustmentRequest {
  @JsonKey(name: 'bill_id')
  final String billId;

  @JsonKey(name: 'adjustment_type')
  final String adjustmentType;

  final double amount;
  final String reason;

  const BillAdjustmentRequest({required this.billId, required this.adjustmentType, required this.amount, required this.reason});

  factory BillAdjustmentRequest.fromJson(Map<String, dynamic> json) => _$BillAdjustmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BillAdjustmentRequestToJson(this);
}
