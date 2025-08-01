import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/features/orders/data/models/order_api_models.dart';
import 'package:vsc_app/features/orders/data/models/order_requests.dart';
import 'package:vsc_app/features/orders/data/models/order_responses.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class OrderService extends ApiService {
  /// Get orders with pagination
  Future<ApiResponse<List<OrderResponse>>> getOrders({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.ordersEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        return json.map((orderJson) => OrderResponse.fromJson(orderJson as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  /// Create a new order
  Future<ApiResponse<MessageData>> createOrder({
    required String customerId,
    required String deliveryDate,
    required List<OrderItemApiModel> orderItems,
  }) async {
    final request = CreateOrderRequest(customerId: customerId, deliveryDate: deliveryDate, orderItems: orderItems);

    return await executeRequest(
      () => post(AppConstants.ordersEndpoint, data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }
}
