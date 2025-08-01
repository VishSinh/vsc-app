import '../models/order.dart';
import '../models/order_item.dart';
import '../../data/models/order_api_models.dart';
import '../../data/models/order_responses.dart';
import '../../data/models/order_requests.dart';

/// Service to handle conversions between different model layers
class OrderMapperService {
  /// Convert API response to domain model
  static Order fromApiResponse(OrderResponse response) {
    return Order(
      id: response.id,
      customerId: response.customerId,
      deliveryDate: DateTime.parse(response.deliveryDate),
      orderItems: response.orderItems.map((item) => fromApiModel(item)).toList(),
      status: _parseOrderStatus(response.status),
      totalAmount: double.tryParse(response.totalAmount) ?? 0.0,
      createdAt: DateTime.parse(response.createdAt),
    );
  }

  /// Convert API model to domain model
  static OrderItem fromApiModel(OrderItemApiModel apiModel) {
    return OrderItem(
      cardId: apiModel.cardId,
      discountAmount: double.tryParse(apiModel.discountAmount) ?? 0.0,
      quantity: apiModel.quantity,
      requiresBox: apiModel.requiresBox,
      requiresPrinting: apiModel.requiresPrinting,
      boxType: _mapBoxType(apiModel.boxType),
      boxCost: double.tryParse(apiModel.totalBoxCost ?? '0') ?? 0.0,
      printingCost: double.tryParse(apiModel.totalPrintingCost ?? '0') ?? 0.0,
    );
  }

  /// Convert domain model to API request
  static CreateOrderRequest toApiRequest(Order order) {
    return CreateOrderRequest(
      customerId: order.customerId,
      deliveryDate: order.deliveryDate.toIso8601String(),
      orderItems: order.orderItems.map((item) => toApiModel(item)).toList(),
    );
  }

  /// Convert domain model to API model
  static OrderItemApiModel toApiModel(OrderItem domainModel) {
    return OrderItemApiModel(
      cardId: domainModel.cardId,
      discountAmount: domainModel.discountAmount.toString(),
      quantity: domainModel.quantity,
      requiresBox: domainModel.requiresBox,
      requiresPrinting: domainModel.requiresPrinting,
      boxType: _mapBoxTypeToApi(domainModel.boxType),
      totalBoxCost: domainModel.boxCost.toString(),
      totalPrintingCost: domainModel.printingCost.toString(),
    );
  }

  /// Parse order status from string
  static OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'in_progress':
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Map BoxType from API to domain
  static OrderBoxType? _mapBoxType(BoxType? apiBoxType) {
    if (apiBoxType == null) return null;
    switch (apiBoxType) {
      case BoxType.folding:
        return OrderBoxType.folding;
      case BoxType.complete:
        return OrderBoxType.complete;
    }
  }

  /// Map BoxType from domain to API
  static BoxType? _mapBoxTypeToApi(OrderBoxType? domainBoxType) {
    if (domainBoxType == null) return null;
    switch (domainBoxType) {
      case OrderBoxType.folding:
        return BoxType.folding;
      case OrderBoxType.complete:
        return BoxType.complete;
    }
  }
}
