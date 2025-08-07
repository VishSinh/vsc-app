import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/features/bills/data/models/bill_get_response.dart';
import 'package:vsc_app/features/bills/data/models/payment_get_response.dart';
import 'package:vsc_app/features/bills/data/models/payment_request.dart';

class BillService extends ApiService {
  Future<ApiResponse<BillGetResponse>> getBillByBillId({required String billId}) async =>
      await executeRequest(() => get('${AppConstants.billsEndpoint}$billId/'), (json) => BillGetResponse.fromJson(json));

  Future<ApiResponse<List<BillGetResponse>>> getBillByOrderId({required String orderId}) async =>
      await executeRequest(() => get('${AppConstants.billsEndpoint}?order_id=$orderId'), (json) {
        if (json is List<dynamic>) {
          return json.map((bill) => BillGetResponse.fromJson(bill)).toList();
        }
        throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
      });

  Future<ApiResponse<List<BillGetResponse>>> getBillByPhone({required String phone}) async =>
      await executeRequest(() => get('${AppConstants.billsEndpoint}?phone=$phone'), (json) {
        if (json is List<dynamic>) {
          return json.map((bill) => BillGetResponse.fromJson(bill)).toList();
        }
        throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
      });

  Future<ApiResponse<List<PaymentGetResponse>>> getPaymentsByBillId({required String billId}) async =>
      await executeRequest(() => get('${AppConstants.paymentsEndpoint}?bill_id=$billId'), (json) {
        if (json is List<dynamic>) {
          return json.map((payment) => PaymentGetResponse.fromJson(payment)).toList();
        }
        throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
      });

  Future<ApiResponse<PaymentGetResponse>> createPayment({required PaymentRequest payment}) async =>
      await executeRequest(() => post(AppConstants.paymentsEndpoint, data: payment.toJson()), (json) => PaymentGetResponse.fromJson(json));
}
