// ViewModel classes for Order Response

import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/orders/data/models/order_responses.dart';

class OrderViewModel {
  final String id;
  final String name;
  final String customerId;
  final String customerName;
  final String staffId;
  final String staffName;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String orderStatus;
  final String specialInstruction;
  final List<OrderItemViewModel> orderItems;

  OrderViewModel({
    required this.id,
    required this.name,
    required this.customerId,
    required this.customerName,
    required this.staffId,
    required this.staffName,
    required this.orderDate,
    required this.deliveryDate,
    required this.orderStatus,
    required this.specialInstruction,
    required this.orderItems,
  });

  factory OrderViewModel.fromApiResponse(OrderResponse response) {
    return OrderViewModel(
      id: response.id,
      name: response.name,
      customerId: response.customerId,
      customerName: response.customerName,
      staffId: response.staffId,
      staffName: response.staffName,
      orderDate: DateTime.parse(response.orderDate),
      deliveryDate: DateTime.parse(response.deliveryDate),
      orderStatus: response.orderStatus,
      specialInstruction: response.specialInstruction,
      orderItems: response.orderItems.map((item) => OrderItemViewModel.fromApiResponse(item)).toList(),
    );
  }
}

class OrderItemViewModel {
  final String id;
  final String orderId;
  final String orderName;
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
    required this.orderName,
    required this.cardId,
    required this.quantity,
    required this.pricePerItem,
    required this.discountAmount,
    required this.requiresBox,
    required this.requiresPrinting,
    required this.boxOrders,
    required this.printingJobs,
  });

  factory OrderItemViewModel.fromApiResponse(OrderItemResponse response) {
    return OrderItemViewModel(
      id: response.id,
      orderId: response.orderId,
      orderName: response.orderName,
      cardId: response.cardId,
      quantity: response.quantity,
      pricePerItem: response.pricePerItem,
      discountAmount: response.discountAmount,
      requiresBox: response.requiresBox,
      requiresPrinting: response.requiresPrinting,
      boxOrders: response.boxOrders?.map((box) => BoxOrderViewModel.fromApiResponse(box)).toList(),
      printingJobs: response.printingJobs?.map((job) => PrintingJobViewModel.fromApiResponse(job)).toList(),
    );
  }
}

class BoxOrderViewModel {
  final String id;
  final String orderItemId;
  final String? boxMakerId;
  final String? boxMakerName;
  final OrderBoxType boxType;
  final int boxQuantity;
  final String totalBoxCost;
  final String boxStatus;
  final DateTime? estimatedCompletion;

  BoxOrderViewModel({
    required this.id,
    required this.orderItemId,
    this.boxMakerId,
    this.boxMakerName,
    required this.boxType,
    required this.boxQuantity,
    required this.totalBoxCost,
    required this.boxStatus,
    this.estimatedCompletion,
  });

  factory BoxOrderViewModel.fromApiResponse(BoxOrderResponse response) {
    return BoxOrderViewModel(
      id: response.id,
      orderItemId: response.orderItemId,
      boxMakerId: response.boxMakerId,
      boxMakerName: response.boxMakerName,
      boxType: OrderBoxTypeExtension.fromApiString(response.boxType) ?? OrderBoxType.folding,
      boxQuantity: response.boxQuantity,
      totalBoxCost: response.totalBoxCost,
      boxStatus: response.boxStatus,
      estimatedCompletion: response.estimatedCompletion != null ? DateTime.parse(response.estimatedCompletion!) : null,
    );
  }
}

class PrintingJobViewModel {
  final String id;
  final String orderItemId;
  final String? printerId;
  final String? printerName;
  final String? tracingStudioId;
  final String? tracingStudioName;
  final int printQuantity;
  final String totalPrintingCost;
  final String printingStatus;
  final DateTime? estimatedCompletion;

  PrintingJobViewModel({
    required this.id,
    required this.orderItemId,
    this.printerId,
    this.printerName,
    this.tracingStudioId,
    this.tracingStudioName,
    required this.printQuantity,
    required this.totalPrintingCost,
    required this.printingStatus,
    this.estimatedCompletion,
  });

  factory PrintingJobViewModel.fromApiResponse(PrintingJobResponse response) {
    return PrintingJobViewModel(
      id: response.id,
      orderItemId: response.orderItemId,
      printerId: response.printerId,
      printerName: response.printerName,
      tracingStudioId: response.tracingStudioId,
      tracingStudioName: response.tracingStudioName,
      printQuantity: response.printQuantity,
      totalPrintingCost: response.totalPrintingCost,
      printingStatus: response.printingStatus,
      estimatedCompletion: response.estimatedCompletion != null ? DateTime.parse(response.estimatedCompletion!) : null,
    );
  }
}
