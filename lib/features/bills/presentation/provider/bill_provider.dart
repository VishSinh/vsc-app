import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/models/pagination_data.dart';
import 'package:vsc_app/features/bills/data/services/bill_service.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_card_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/bill_view_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_form_model.dart';
import 'package:vsc_app/features/bills/presentation/models/payment_view_model.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import 'package:vsc_app/features/customers/data/services/customer_service.dart';

class BillProvider extends BaseProvider {
  final BillService _billService = BillService();
  final CardService _cardService = CardService();
  final CustomerService _customerService = CustomerService();

  BillViewModel? _bill;
  List<BillViewModel> _bills = [];
  Map<String, BillCardViewModel> _cardImages = {};
  PaginationData? _pagination;
  String _lastPhoneQuery = '';

  // Customer phone cache
  final Map<String, String> _customerPhoneCache = {};

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

  Future<void> getBillByPhone({required String phone, int page = 1, int pageSize = 10}) async {
    _lastPhoneQuery = phone;
    await executeApiOperation(
      apiCall: () => _billService.getBillByPhone(phone: phone, page: page, pageSize: pageSize),
      onSuccess: (response) {
        setSuccess('Bill fetched successfully');
        _bills = response.data?.map((bill) => BillViewModel.fromApiResponse(bill)).toList() ?? [];
        _pagination = response.pagination;
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
  PaginationData? get pagination => _pagination;
  bool get hasMoreBills => _pagination?.hasNext ?? false;
  String? getCustomerPhone(String customerId) => _customerPhoneCache[customerId];

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

  /// Fetch and cache customer phone by customer ID
  Future<void> fetchCustomerPhone(String customerId) async {
    if (_customerPhoneCache.containsKey(customerId)) return;
    final response = await _customerService.getCustomerById(customerId);
    if (response.success && response.data != null) {
      _customerPhoneCache[customerId] = response.data!.phone;
      notifyListeners();
    }
  }

  Future<void> getBills({int page = 1, int pageSize = 10}) async {
    _lastPhoneQuery = '';
    await executeApiOperation(
      apiCall: () => _billService.getBills(page: page, pageSize: pageSize),
      onSuccess: (response) {
        setSuccess('Bills fetched successfully');
        _bills = response.data?.map((bill) => BillViewModel.fromApiResponse(bill)).toList() ?? [];
        _pagination = response.pagination;
        return _bills;
      },
      showLoading: true,
      showSnackbar: false,
      errorMessage: 'Failed to fetch bills',
    );
  }

  Future<void> loadNextPage() async {
    if (_pagination?.hasNext == true) {
      final nextPage = (_pagination?.currentPage ?? 1) + 1;
      if (_lastPhoneQuery.isNotEmpty) {
        await getBillByPhone(phone: _lastPhoneQuery, page: nextPage);
      } else {
        await getBills(page: nextPage);
      }
    }
  }

  Future<void> loadPreviousPage() async {
    if (_pagination?.hasPrevious == true) {
      final prevPage = (_pagination?.currentPage ?? 1) - 1;
      if (_lastPhoneQuery.isNotEmpty) {
        await getBillByPhone(phone: _lastPhoneQuery, page: prevPage);
      } else {
        await getBills(page: prevPage);
      }
    }
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
