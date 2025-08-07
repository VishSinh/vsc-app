// {
//             "id": "36c9f927-cc7f-438d-93da-c9197a51e6fb",
//             "bill_id": "93d3146b-7a67-4c4e-bdcc-74a11ecfc6d6",
//             "amount": "15.50",
//             "payment_mode": "CASH",
//             "transaction_ref": "TXN_12345_CASH_01",
//             "notes": "Full payment received for order #XYZ."
//         }

import 'package:json_annotation/json_annotation.dart';

part 'payment_get_response.g.dart';

@JsonSerializable()
class PaymentGetResponse {
  final String id;

  @JsonKey(name: 'bill_id')
  final String billId;

  @JsonKey(fromJson: _amountFromJson)
  final double amount;

  @JsonKey(name: 'payment_mode')
  final String paymentMode;

  @JsonKey(name: 'transaction_ref')
  final String transactionRef;

  final String notes;

  const PaymentGetResponse({
    required this.id,
    required this.billId,
    required this.amount,
    required this.paymentMode,
    required this.transactionRef,
    required this.notes,
  });

  factory PaymentGetResponse.fromJson(Map<String, dynamic> json) => _$PaymentGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentGetResponseToJson(this);
}

double _amountFromJson(dynamic value) {
  if (value is num) {
    return value.toDouble();
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}
