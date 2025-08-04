// ViewModel classes for Order Response

import 'package:vsc_app/features/orders/data/models/order_responses.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_view_model.dart';

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
