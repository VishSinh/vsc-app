import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/message_data.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/services/service_utils.dart';
import 'package:vsc_app/features/bills/data/models/bill_get_response.dart';
import 'package:vsc_app/features/bills/data/models/payment_get_response.dart';
import 'package:vsc_app/features/bills/data/models/payment_request.dart';
import 'package:vsc_app/features/bills/data/models/bill_adjustment_get_response.dart';
import 'package:vsc_app/features/bills/data/models/bill_adjustment_request.dart';

class BillService extends ApiService {
  Future<ApiResponse<List<BillGetResponse>>> getBills({int page = 1, int pageSize = AppConstants.defaultPageSize}) async =>
      await executeRequest(
        () => get('${AppConstants.billsEndpoint}?page=$page&page_size=$pageSize'),
        (json) => ServiceUtils.parseList(json, (item) => BillGetResponse.fromJson(item)),
      );

  Future<ApiResponse<BillGetResponse>> getBillByBillId({required String billId}) async => await executeRequest(
    () => get('${AppConstants.billsEndpoint}$billId/'),
    (json) => ServiceUtils.parseItem(json, BillGetResponse.fromJson),
  );

  Future<ApiResponse<List<BillGetResponse>>> getBillByOrderId({required String orderId}) async => await executeRequest(
    () => get('${AppConstants.billsEndpoint}?order_id=$orderId'),
    (json) => ServiceUtils.parseList(json, (item) => BillGetResponse.fromJson(item)),
  );

  Future<ApiResponse<List<BillGetResponse>>> getBillByPhone({
    required String phone,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async => await executeRequest(
    () => get('${AppConstants.billsEndpoint}?phone=$phone&page=$page&page_size=$pageSize'),
    (json) => ServiceUtils.parseList(json, (item) => BillGetResponse.fromJson(item)),
  );

  Future<ApiResponse<List<PaymentGetResponse>>> getPaymentsByBillId({required String billId}) async => await executeRequest(
    () => get('${AppConstants.paymentsEndpoint}?bill_id=$billId'),
    (json) => ServiceUtils.parseList(json, (item) => PaymentGetResponse.fromJson(item)),
  );

  Future<ApiResponse<MessageData>> createPayment({required PaymentRequest payment}) async => await executeRequest(
    () => post(AppConstants.paymentsEndpoint, data: payment),
    (json) => MessageData.fromJson(json as Map<String, dynamic>),
  );

  // ========================= BILL ADJUSTMENTS =========================
  Future<ApiResponse<List<BillAdjustmentGetResponse>>> getBillAdjustmentsByBillId({required String billId}) async =>
      await executeRequest(
        () => get('${AppConstants.billAdjustmentsEndpoint}?bill_id=$billId'),
        (json) => ServiceUtils.parseList(json, (item) => BillAdjustmentGetResponse.fromJson(item)),
      );

  Future<ApiResponse<MessageData>> createBillAdjustment({required BillAdjustmentRequest request}) async => await executeRequest(
    () => post(AppConstants.billAdjustmentsEndpoint, data: request),
    (json) => MessageData.fromJson(json as Map<String, dynamic>),
  );
}
