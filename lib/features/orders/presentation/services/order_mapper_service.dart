import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';

import '../../data/models/order_responses.dart';
import '../../data/models/order_requests.dart';
import '../models/order_form_models.dart';

import 'package:vsc_app/core/enums/order_box_type.dart';

/// Mapper service for converting between different model layers
class OrderMapperService {
  // PRESENTATION → DATA CONVERSIONS (CREATION FLOW)

  /// Convert order creation form to request DTO
  static CreateOrderRequest orderCreationFormToRequest(OrderCreationFormViewModel formModel) {
    final orderItems = formModel.orderItems?.map((item) => orderItemCreationFormToRequest(item)).toList() ?? [];

    return CreateOrderRequest(
      customerId: formModel.customerId!,
      name: formModel.name!,
      deliveryDate: formModel.deliveryDate!,
      orderItems: orderItems,
    );
  }

  /// Convert order item creation form to request DTO
  static OrderItemRequest orderItemCreationFormToRequest(OrderItemCreationFormViewModel formModel) {
    return OrderItemRequest(
      cardId: formModel.cardId,
      discountAmount: formModel.discountAmount,
      quantity: formModel.quantity,
      requiresBox: formModel.requiresBox,
      requiresPrinting: formModel.requiresPrinting,
      boxType: formModel.boxType?.toApiString(),
      totalBoxCost: formModel.totalBoxCost ?? '0.00',
      totalPrintingCost: formModel.totalPrintingCost ?? '0.00',
    );
  }

  // DATA → PRESENTATION CONVERSIONS (FETCHING FLOW)
  static OrderViewModel orderResponseToViewModel(OrderResponse responseModel) {
    return OrderViewModel(
      id: responseModel.id,
      name: responseModel.name,
      customerId: responseModel.customerId,
      staffId: responseModel.staffId,
      orderDate: DateTime.parse(responseModel.orderDate),
      deliveryDate: DateTime.parse(responseModel.deliveryDate),
      orderStatus: responseModel.orderStatus,
      specialInstruction: responseModel.specialInstruction,
      orderItems: responseModel.orderItems.map((item) => orderItemResponseToViewModel(item)).toList(),
    );
  }

  static OrderItemViewModel orderItemResponseToViewModel(OrderItemResponse responseModel) {
    return OrderItemViewModel(
      id: responseModel.id,
      orderId: responseModel.orderId,
      cardId: responseModel.cardId,
      quantity: responseModel.quantity,
      pricePerItem: responseModel.pricePerItem,
      discountAmount: responseModel.discountAmount,
      requiresBox: responseModel.requiresBox,
      requiresPrinting: responseModel.requiresPrinting,
      boxOrders: responseModel.boxOrders?.map((box) => boxOrderResponseToViewModel(box)).toList(),
      printingJobs: responseModel.printingJobs?.map((job) => printingJobResponseToViewModel(job)).toList(),
    );
  }

  static BoxOrderViewModel boxOrderResponseToViewModel(BoxOrderResponse responseModel) {
    return BoxOrderViewModel(
      id: responseModel.id,
      orderItemId: responseModel.orderItemId,
      boxMakerId: responseModel.boxMakerId,
      boxType: OrderBoxTypeExtension.fromApiString(responseModel.boxType) ?? OrderBoxType.folding,
      boxQuantity: responseModel.boxQuantity,
      totalBoxCost: responseModel.totalBoxCost,
      boxStatus: responseModel.boxStatus,
      estimatedCompletion: responseModel.estimatedCompletion != null ? DateTime.parse(responseModel.estimatedCompletion!) : null,
    );
  }

  static PrintingJobViewModel printingJobResponseToViewModel(PrintingJobResponse responseModel) {
    return PrintingJobViewModel(
      id: responseModel.id,
      orderItemId: responseModel.orderItemId,
      printerId: responseModel.printerId,
      tracingStudioId: responseModel.tracingStudioId,
      printQuantity: responseModel.printQuantity,
      totalPrintingCost: responseModel.totalPrintingCost,
      printingStatus: responseModel.printingStatus,
      estimatedCompletion: responseModel.estimatedCompletion != null ? DateTime.parse(responseModel.estimatedCompletion!) : null,
    );
  }
}
