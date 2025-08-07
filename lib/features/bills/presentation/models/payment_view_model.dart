import 'package:vsc_app/core/enums/payment_mode.dart';
import 'package:vsc_app/features/bills/data/models/payment_get_response.dart';

class PaymentViewModel {
  final String id;
  final String billId;
  final double amount;
  final PaymentMode paymentMode;
  final String transactionRef;
  final String notes;

  const PaymentViewModel({
    required this.id,
    required this.billId,
    required this.amount,
    required this.paymentMode,
    required this.transactionRef,
    required this.notes,
  });

  factory PaymentViewModel.fromApiResponse(PaymentGetResponse response) {
    return PaymentViewModel(
      id: response.id,
      billId: response.billId,
      amount: response.amount,
      paymentMode: PaymentModeExtension.fromApiString(response.paymentMode) ?? PaymentMode.cash,
      transactionRef: response.transactionRef,
      notes: response.notes,
    );
  }
}
