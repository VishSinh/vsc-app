import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/bills/data/services/bill_service.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';

class BillProvider extends BaseProvider {
  final BillService _billService = BillService();

  BillViewModel? _bill;
  List<BillViewModel> _bills = [];

  Future<void> getBillByBillId({required String billId}) async {
    await executeApiOperation(
      apiCall: () => _billService.getBillByBillId(billId: billId),
      onSuccess: (response) {
        setSuccess('Bill fetched successfully');
        _bill = BillViewModel.fromApiResponse(response.data!);
        return _bill!;
      },
      showLoading: false,
      errorMessage: 'Failed to fetch bill',
    );
  }

  Future<void> getBillByOrderId({required String orderId}) async {
    await executeApiOperation(
      apiCall: () => _billService.getBillByOrderId(orderId: orderId),
      onSuccess: (response) {
        setSuccess('Bill fetched successfully');
        _bills = response.data?.map((bill) => BillViewModel.fromApiResponse(bill)).toList() ?? [];
        return _bills;
      },
      showLoading: false,
      errorMessage: 'Failed to fetch bill',
    );
  }

  Future<void> getBillByPhone({required String phone}) async {
    await executeApiOperation(
      apiCall: () => _billService.getBillByPhone(phone: phone),
      onSuccess: (response) {
        setSuccess('Bill fetched successfully');
        _bills = response.data?.map((bill) => BillViewModel.fromApiResponse(bill)).toList() ?? [];
        return _bills;
      },
      showLoading: false,
      errorMessage: 'Failed to fetch bill',
    );
  }

  // Add getters for bill data
  BillViewModel? get currentBill => _bill;
  List<BillViewModel> get bills => List.unmodifiable(_bills);
}
