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

  /// Create a copy with updated order items
  OrderViewModel copyWith({List<OrderItemViewModel>? orderItems}) {
    return OrderViewModel(
      id: id,
      name: name,
      customerId: customerId,
      customerName: customerName,
      staffId: staffId,
      staffName: staffName,
      orderDate: orderDate,
      deliveryDate: deliveryDate,
      orderStatus: orderStatus,
      specialInstruction: specialInstruction,
      orderItems: orderItems ?? this.orderItems,
    );
  }
}

/// View model for displaying card information in order context
class OrderCardViewModel {
  final String id;
  final String vendorId;
  final String barcode;
  final String sellPrice;
  final String costPrice;
  final String maxDiscount;
  final int quantity;
  final String image;
  final String perceptualHash;
  final bool isActive;

  // Computed properties for UI
  final double sellPriceAsDouble;
  final double costPriceAsDouble;
  final double maxDiscountAsDouble;

  const OrderCardViewModel({
    required this.id,
    required this.vendorId,
    required this.barcode,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity,
    required this.image,
    required this.perceptualHash,
    required this.isActive,
    required this.sellPriceAsDouble,
    required this.costPriceAsDouble,
    required this.maxDiscountAsDouble,
  });

  /// Create from API response
  factory OrderCardViewModel.fromApiResponse(dynamic response) {
    final sellPriceAsDouble = (response.sellPriceAsDouble as double?) ?? 0.0;
    final costPriceAsDouble = (response.costPriceAsDouble as double?) ?? 0.0;
    final maxDiscountAsDouble = (response.maxDiscountAsDouble as double?) ?? 0.0;

    return OrderCardViewModel(
      id: (response.id as String?) ?? '',
      vendorId: (response.vendorId as String?) ?? '',
      barcode: (response.barcode as String?) ?? '',
      sellPrice: sellPriceAsDouble.toStringAsFixed(2),
      costPrice: costPriceAsDouble.toStringAsFixed(2),
      maxDiscount: maxDiscountAsDouble.toStringAsFixed(2),
      quantity: (response.quantity as int?) ?? 0,
      image: (response.image as String?) ?? '',
      perceptualHash: (response.perceptualHash as String?) ?? '',
      isActive: (response.isActive as bool?) ?? true,
      sellPriceAsDouble: sellPriceAsDouble,
      costPriceAsDouble: costPriceAsDouble,
      maxDiscountAsDouble: maxDiscountAsDouble,
    );
  }

  // Formatted getters for UI
  String get formattedSellPrice => '₹${sellPriceAsDouble.toStringAsFixed(2)}';
  String get formattedCostPrice => '₹${costPriceAsDouble.toStringAsFixed(2)}';
  String get formattedMaxDiscount => '${maxDiscountAsDouble.toStringAsFixed(2)}%';
  String get formattedQuantity => quantity.toString();
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
  final OrderCardViewModel? card; // Add card information

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
    this.card, // Make card optional
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
      card: null, // Will be populated separately
    );
  }

  /// Create a copy with updated card information
  OrderItemViewModel copyWith({OrderCardViewModel? card}) {
    return OrderItemViewModel(
      id: id,
      orderId: orderId,
      orderName: orderName,
      cardId: cardId,
      quantity: quantity,
      pricePerItem: pricePerItem,
      discountAmount: discountAmount,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxOrders: boxOrders,
      printingJobs: printingJobs,
      card: card ?? this.card,
    );
  }
}
