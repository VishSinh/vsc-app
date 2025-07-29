import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/order_model.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class OrderService extends BaseService {
  /// Get orders with pagination
  Future<ApiResponse<List<Order>>> getOrders({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.ordersEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        return json.map((orderJson) => Order.fromJson(orderJson as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  /// Create a new order
  Future<ApiResponse<MessageData>> createOrder({
    required String customerId,
    required String deliveryDate,
    required List<OrderItem> orderItems,
  }) async {
    final request = CreateOrderRequest(customerId: customerId, deliveryDate: deliveryDate, orderItems: orderItems);

    return await executeRequest(
      () => post(AppConstants.ordersEndpoint, data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }
}
