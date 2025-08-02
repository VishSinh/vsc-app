// ViewModel classes for Order Response

import 'package:vsc_app/core/enums/order_box_type.dart';

class OrderViewModel {
  final String id;
  final String name;
  final String customerId;
  final String staffId;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String orderStatus;
  final String specialInstruction;
  final List<OrderItemViewModel> orderItems;

  OrderViewModel({
    required this.id,
    required this.name,
    required this.customerId,
    required this.staffId,
    required this.orderDate,
    required this.deliveryDate,
    required this.orderStatus,
    required this.specialInstruction,
    required this.orderItems,
  });
}

class OrderItemViewModel {
  final String id;
  final String orderId;
  final String cardId;
  final int quantity;
  final String pricePerItem;
  final String discountAmount;
  final bool requiresBox;
  final bool requiresPrinting;
  final List<BoxOrderViewModel>? boxOrders;
  final List<PrintingJobViewModel>? printingJobs;

  OrderItemViewModel({
    required this.id,
    required this.orderId,
    required this.cardId,
    required this.quantity,
    required this.pricePerItem,
    required this.discountAmount,
    required this.requiresBox,
    required this.requiresPrinting,
    required this.boxOrders,
    required this.printingJobs,
  });
}

class BoxOrderViewModel {
  final String id;
  final String orderItemId;
  final String? boxMakerId;
  final OrderBoxType boxType;
  final int boxQuantity;
  final String totalBoxCost;
  final String boxStatus;
  final DateTime? estimatedCompletion;

  BoxOrderViewModel({
    required this.id,
    required this.orderItemId,
    this.boxMakerId,
    required this.boxType,
    required this.boxQuantity,
    required this.totalBoxCost,
    required this.boxStatus,
    this.estimatedCompletion,
  });
}

class PrintingJobViewModel {
  final String id;
  final String orderItemId;
  final String? printerId;
  final String? tracingStudioId;
  final int printQuantity;
  final String totalPrintingCost;
  final String printingStatus;
  final DateTime? estimatedCompletion;

  PrintingJobViewModel({
    required this.id,
    required this.orderItemId,
    this.printerId,
    this.tracingStudioId,
    required this.printQuantity,
    required this.totalPrintingCost,
    required this.printingStatus,
    this.estimatedCompletion,
  });
}
