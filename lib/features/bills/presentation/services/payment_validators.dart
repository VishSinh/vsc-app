import 'package:vsc_app/core/validation/validation_result.dart';

/// Validators for payment-related form fields
class PaymentValidators {
  /// Validate payment amount
  static ValidationResult validateAmount(String amount, {double? maxAmount}) {
    if (amount.trim().isEmpty) {
      return ValidationResult.failureSingle('amount', 'Amount is required');
    }

    final amountValue = double.tryParse(amount);
    if (amountValue == null) {
      return ValidationResult.failureSingle('amount', 'Please enter a valid number');
    }

    if (amountValue <= 0) {
      return ValidationResult.failureSingle('amount', 'Amount must be greater than 0');
    }

    if (maxAmount != null && amountValue > maxAmount) {
      return ValidationResult.failureSingle('amount', 'Amount cannot exceed remaining balance (₹${maxAmount.toStringAsFixed(2)})');
    }

    return ValidationResult.success();
  }

  /// Validate payment form
  static ValidationResult validatePaymentForm({required String amount, double? maxAmount}) {
    return validateAmount(amount, maxAmount: maxAmount);
  }
}
