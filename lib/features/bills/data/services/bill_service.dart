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
import 'package:vsc_app/core/utils/query_params.dart';

class BillService extends ApiService {
  Future<ApiResponse<List<BillGetResponse>>> getBills({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? orderId,
    String? phone,
    bool? paid,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final params = QueryParamsBuilder()
        .withPagination(page: page, pageSize: pageSize)
        .withString('order_id', orderId)
        .withString('phone', phone)
        .withBoolAsString('paid', paid)
        .withSort(sortBy: sortBy, sortOrder: sortOrder)
        .build();

    return await executeRequest(
      () => get(AppConstants.billsEndpoint, queryParameters: params),
      (json) => ServiceUtils.parseList(json, (item) => BillGetResponse.fromJson(item)),
    );
  }

  Future<ApiResponse<BillGetResponse>> getBillByBillId({required String billId}) async => await executeRequest(
    () => get('${AppConstants.billsEndpoint}$billId/'),
    (json) => ServiceUtils.parseItem(json, BillGetResponse.fromJson),
  );

  Future<ApiResponse<List<BillGetResponse>>> getBillByOrderId({required String orderId}) async {
    return await getBills(orderId: orderId);
  }

  Future<ApiResponse<List<BillGetResponse>>> getBillByPhone({
    required String phone,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    return await getBills(page: page, pageSize: pageSize, phone: phone);
  }

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
