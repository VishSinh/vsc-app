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
    final errors = <ValidationError>[];

    ValidationResult validateAmount() {
      final amountStr = amount.toString();

      if (amountStr.trim().isEmpty) {
        return ValidationResult.failureSingle('amount', 'Amount is required');
      }

      final amountValue = double.tryParse(amountStr);
      if (amountValue == null) {
        return ValidationResult.failureSingle('amount', 'Please enter a valid number');
      }

      if (amountValue <= 0) {
        return ValidationResult.failureSingle('amount', 'Amount must be greater than 0');
      }

      return ValidationResult.success();
    }

    final amountResult = validateAmount();
    if (!amountResult.isValid) {
      errors.addAll(amountResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
