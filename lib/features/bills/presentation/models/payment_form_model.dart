import 'package:vsc_app/core/enums/payment_mode.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/bills/data/models/payment_request.dart';

class PaymentFormModel {
  final String billId;
  final double amount;
  final PaymentMode paymentMode;
  final String transactionRef;
  final String notes;

  const PaymentFormModel({required this.billId, required this.amount, required this.paymentMode, this.transactionRef = '', this.notes = ''});

  PaymentRequest toApiRequest() {
    return PaymentRequest(billId: billId, amount: amount, paymentMode: paymentMode.toApiString(), transactionRef: transactionRef, notes: notes);
  }

  ValidationResult validate() {
    final errors = <String>[];

    if (amount <= 0) {
      errors.add('Amount must be greater than 0');
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors.map((e) => ValidationError(field: 'payment', message: e)).toList());
  }
}
