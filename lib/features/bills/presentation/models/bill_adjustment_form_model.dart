import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/core/enums/bill_adjustment_type.dart';
import 'package:vsc_app/features/bills/data/models/bill_adjustment_request.dart';

class BillAdjustmentFormModel {
  final String billId;
  final double amount;
  final BillAdjustmentType adjustmentType;
  final String reason;

  const BillAdjustmentFormModel({required this.billId, required this.amount, required this.adjustmentType, this.reason = ''});

  BillAdjustmentRequest toApiRequest() {
    return BillAdjustmentRequest(billId: billId, adjustmentType: adjustmentType.toApiString(), amount: amount, reason: reason);
  }

  ValidationResult validate({double? maxAmount}) {
    final errors = <ValidationError>[];

    if (amount <= 0) {
      errors.add(ValidationError(field: 'amount', message: 'Amount must be greater than 0'));
    }
    if (maxAmount != null && amount > maxAmount) {
      errors.add(ValidationError(field: 'amount', message: 'Amount cannot exceed pending amount (₹${maxAmount.toStringAsFixed(2)})'));
    }
    if (reason.trim().isEmpty) {
      errors.add(ValidationError(field: 'reason', message: 'Reason is required'));
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }
}
