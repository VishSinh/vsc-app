import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/bills/data/services/bill_service.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_form_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_view_model.dart';

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
      showLoading: true,
      errorMessage: 'Failed to fetch bill',
    );
  }

  // Add getters for bill data
  BillViewModel? get currentBill => _bill;
  List<BillViewModel> get bills => List.unmodifiable(_bills);
  List<PaymentViewModel> get payments => List.unmodifiable(_payments);

  // Payments Get
  List<PaymentViewModel> _payments = [];
  PaymentFormModel? _paymentFormModel;

  Future<void> getPaymentsByBillId({required String billId}) async {
    await executeApiOperation(
      apiCall: () => _billService.getPaymentsByBillId(billId: billId),
      onSuccess: (response) {
        setSuccess('Payments fetched successfully');
        _payments = response.data?.map((payment) => PaymentViewModel.fromApiResponse(payment)).toList() ?? [];
      },
      showLoading: false,
      showSnackbar: false,
      errorMessage: 'Failed to fetch payments',
    );
  }

  Future<void> createPayment({required PaymentFormModel paymentFormModel}) async {
    await executeApiOperation(
      apiCall: () => _billService.createPayment(payment: paymentFormModel.toApiRequest()),
      onSuccess: (response) {
        setSuccess('Payment created successfully');
        _paymentFormModel = null;
        getPaymentsByBillId(billId: paymentFormModel.billId);
      },
      errorMessage: 'Failed to create payment',
    );
  }

  /// Clear bill data when navigating back
  void clearBillData() {
    _bill = null;
    _payments = [];
    clearMessages();
    notifyListeners();
  }
}
