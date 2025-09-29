import 'package:vsc_app/core/enums/bill_adjustment_type.dart';
import 'package:vsc_app/features/bills/data/models/bill_adjustment_get_response.dart';

class BillAdjustmentViewModel {
  final String id;
  final String billId;
  final String staffId;
  final String staffName;
  final BillAdjustmentType adjustmentType;
  final String adjustmentTypeRaw;
  final double amount;
  final String reason;

  const BillAdjustmentViewModel({
    required this.id,
    required this.billId,
    required this.staffId,
    required this.staffName,
    required this.adjustmentType,
    required this.adjustmentTypeRaw,
    required this.amount,
    required this.reason,
  });

  factory BillAdjustmentViewModel.fromApiResponse(BillAdjustmentGetResponse response) {
    return BillAdjustmentViewModel(
      id: response.id,
      billId: response.billId,
      staffId: response.staffId,
      staffName: response.staffName,
      adjustmentType: BillAdjustmentTypeExtension.fromApiString(response.adjustmentType) ?? BillAdjustmentType.negotiation,
      adjustmentTypeRaw: response.adjustmentType,
      amount: response.amount,
      reason: response.reason,
    );
  }
}
