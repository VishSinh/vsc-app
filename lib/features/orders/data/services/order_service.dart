import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/features/orders/data/models/order_requests.dart';
import 'package:vsc_app/features/orders/data/models/order_responses.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class OrderService extends ApiService {
  /// Get orders with pagination
  Future<ApiResponse<List<OrderResponse>>> getOrders({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.ordersEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        try {
          return json.map((orderJson) {
            if (orderJson is Map<String, dynamic>) {
              return OrderResponse.fromJson(orderJson);
            } else {
              throw Exception('Invalid order format: expected Map but got ${orderJson.runtimeType}');
            }
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse orders: $e');
        }
      }
      throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
    });
  }

  /// Create a new order
  Future<ApiResponse<MessageData>> createOrder({required CreateOrderRequest request}) async {
    return await executeRequest(() => post(AppConstants.ordersEndpoint, data: request), (json) => MessageData.fromJson(json as Map<String, dynamic>));
  }

  /// Get order by ID
  Future<ApiResponse<OrderResponse>> getOrderById(String orderId) async {
    return await executeRequest(() => get('${AppConstants.ordersEndpoint}$orderId/'), (json) => OrderResponse.fromJson(json as Map<String, dynamic>));
  }
}
