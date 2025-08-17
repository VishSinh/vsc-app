import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/bills/data/services/bill_service.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_card_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_form_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_view_model.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';

class BillProvider extends BaseProvider {
  final BillService _billService = BillService();
  final CardService _cardService = CardService();

  BillViewModel? _bill;
  List<BillViewModel> _bills = [];
  Map<String, BillCardViewModel> _cardImages = {};

  Future<void> getBillByBillId({required String billId}) async {
    await executeApiOperation(
      apiCall: () => _billService.getBillByBillId(billId: billId),
      onSuccess: (response) {
        setSuccess('Bill fetched successfully');
        _bill = BillViewModel.fromApiResponse(response.data!);
        return _bill!;
      },
      showLoading: false,
      showSnackbar: false,
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
      showSnackbar: false,
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
      showSnackbar: false,
      errorMessage: 'Failed to fetch bill',
    );
  }

  // Add getters for bill data
  BillViewModel? get currentBill => _bill;
  List<BillViewModel> get bills => List.unmodifiable(_bills);
  List<PaymentViewModel> get payments => List.unmodifiable(_payments);
  Map<String, BillCardViewModel> get cardImages => Map.unmodifiable(_cardImages);

  // Get card image by ID
  BillCardViewModel? getCardImageById(String cardId) {
    return _cardImages[cardId];
  }

  // Payments Get
  List<PaymentViewModel> _payments = [];

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
        getPaymentsByBillId(billId: paymentFormModel.billId);
      },
      errorMessage: 'Failed to create payment',
    );
  }

  /// Clear bill data when navigating back
  void clearBillData() {
    _bill = null;
    _payments = [];
    _cardImages = {};
    clearMessages();
    notifyListeners();
  }

  /// Fetch card image for a bill item
  Future<BillCardViewModel?> fetchCardImage(String cardId) async {
    // If we already have this card image, return it
    if (_cardImages.containsKey(cardId)) {
      return _cardImages[cardId];
    }

    try {
      final response = await _cardService.getCardById(cardId);
      if (response.success && response.data != null) {
        final cardViewModel = BillCardViewModel.fromCardResponse(response.data!);
        _cardImages[cardId] = cardViewModel;
        notifyListeners();
        return cardViewModel;
      }
    } catch (e) {
      setError('Failed to fetch card image');
    }

    return null;
  }
}
