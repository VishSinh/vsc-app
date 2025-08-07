import 'package:json_annotation/json_annotation.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'bill_id')
  final String billId;
  final double amount;

  @JsonKey(name: 'payment_mode')
  final String paymentMode;

  @JsonKey(name: 'transaction_ref')
  final String transactionRef;

  @JsonKey(name: 'notes')
  final String notes;

  const PaymentRequest({required this.billId, required this.amount, required this.paymentMode, required this.transactionRef, required this.notes});

  factory PaymentRequest.fromJson(Map<String, dynamic> json) => _$PaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}
