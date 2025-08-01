import '../../data/models/order_api_models.dart';
import '../../data/models/order_requests.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_item.dart';

/// Enhanced form data model for order item entry
class OrderItemFormViewModel {
  final int quantity;
  final String discountAmount;
  final bool requiresBox;
  final bool requiresPrinting;
  final String? totalBoxCost;
  final String? totalPrintingCost;
  final BoxType? boxType;

  // Validation helpers
  final bool isValid;
  final String? quantityError;
  final String? discountError;
  final String? boxCostError;
  final String? printingCostError;

  const OrderItemFormViewModel({
    required this.quantity,
    required this.discountAmount,
    required this.requiresBox,
    required this.requiresPrinting,
    this.totalBoxCost,
    this.totalPrintingCost,
    this.boxType,
    required this.isValid,
    this.quantityError,
    this.discountError,
    this.boxCostError,
    this.printingCostError,
  });

  /// Create from form data with validation
  factory OrderItemFormViewModel.fromFormData({
    required int quantity,
    required String discountAmount,
    required bool requiresBox,
    required bool requiresPrinting,
    String? totalBoxCost,
    String? totalPrintingCost,
    BoxType? boxType,
    double? maxDiscount,
  }) {
    String? quantityError;
    String? discountError;
    String? boxCostError;
    String? printingCostError;

    // Validate quantity
    if (quantity <= 0) {
      quantityError = 'Quantity must be greater than 0';
    }

    // Validate discount amount
    final discountAmountAsDouble = double.tryParse(discountAmount);
    if (discountAmountAsDouble == null || discountAmountAsDouble < 0) {
      discountError = 'Invalid discount amount';
    } else if (maxDiscount != null && discountAmountAsDouble > maxDiscount) {
      discountError = 'Discount cannot exceed ₹${maxDiscount.toStringAsFixed(2)}';
    }

    // Validate box cost if required
    if (requiresBox) {
      final boxCostAsDouble = double.tryParse(totalBoxCost ?? '');
      if (boxCostAsDouble == null || boxCostAsDouble < 0) {
        boxCostError = 'Invalid box cost';
      }
    }

    // Validate printing cost if required
    if (requiresPrinting) {
      final printingCostAsDouble = double.tryParse(totalPrintingCost ?? '');
      if (printingCostAsDouble == null || printingCostAsDouble < 0) {
        printingCostError = 'Invalid printing cost';
      }
    }

    final isValid = quantityError == null && discountError == null && boxCostError == null && printingCostError == null;

    return OrderItemFormViewModel(
      quantity: quantity,
      discountAmount: discountAmount,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      totalBoxCost: totalBoxCost,
      totalPrintingCost: totalPrintingCost,
      boxType: boxType,
      isValid: isValid,
      quantityError: quantityError,
      discountError: discountError,
      boxCostError: boxCostError,
      printingCostError: printingCostError,
    );
  }

  /// Convert to API model
  OrderItemApiModel toApiModel(String cardId) {
    return OrderItemApiModel(
      cardId: cardId,
      discountAmount: discountAmount,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: boxType,
      totalBoxCost: totalBoxCost,
      totalPrintingCost: totalPrintingCost,
    );
  }

  /// Convert to domain model
  OrderItem toDomainModel() {
    return OrderItem(
      cardId: '', // Will be set by provider
      discountAmount: double.tryParse(discountAmount) ?? 0.0,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: boxType == BoxType.folding
          ? OrderBoxType.folding
          : boxType == BoxType.complete
          ? OrderBoxType.complete
          : null,
      boxCost: double.tryParse(totalBoxCost ?? '0') ?? 0.0,
      printingCost: double.tryParse(totalPrintingCost ?? '0') ?? 0.0,
    );
  }

  /// Create a copy with updated values
  OrderItemFormViewModel copyWith({
    int? quantity,
    String? discountAmount,
    bool? requiresBox,
    bool? requiresPrinting,
    String? totalBoxCost,
    String? totalPrintingCost,
    BoxType? boxType,
    double? maxDiscount,
  }) {
    return OrderItemFormViewModel.fromFormData(
      quantity: quantity ?? this.quantity,
      discountAmount: discountAmount ?? this.discountAmount,
      requiresBox: requiresBox ?? this.requiresBox,
      requiresPrinting: requiresPrinting ?? this.requiresPrinting,
      totalBoxCost: totalBoxCost ?? this.totalBoxCost,
      totalPrintingCost: totalPrintingCost ?? this.totalPrintingCost,
      boxType: boxType ?? this.boxType,
      maxDiscount: maxDiscount,
    );
  }
}

/// Form data model for order creation
class OrderFormViewModel {
  final String? customerId;
  final String? deliveryDate;
  final List<OrderItemFormViewModel> orderItems;

  // Validation helpers
  final bool isValid;
  final String? customerError;
  final String? deliveryDateError;
  final String? orderItemsError;

  const OrderFormViewModel({
    this.customerId,
    this.deliveryDate,
    required this.orderItems,
    required this.isValid,
    this.customerError,
    this.deliveryDateError,
    this.orderItemsError,
  });

  /// Create with validation
  factory OrderFormViewModel.create({String? customerId, String? deliveryDate, List<OrderItemFormViewModel> orderItems = const []}) {
    String? customerError;
    String? deliveryDateError;
    String? orderItemsError;

    // Validate customer
    if (customerId == null || customerId.isEmpty) {
      customerError = 'Please select a customer';
    }

    // Validate delivery date
    if (deliveryDate == null || deliveryDate.isEmpty) {
      deliveryDateError = 'Please select delivery date';
    } else {
      try {
        final date = DateTime.parse(deliveryDate);
        final now = DateTime.now();
        if (date.isBefore(now)) {
          deliveryDateError = 'Delivery date cannot be in the past';
        }
      } catch (e) {
        deliveryDateError = 'Invalid delivery date format';
      }
    }

    // Validate order items
    if (orderItems.isEmpty) {
      orderItemsError = 'Please add at least one item to the order';
    } else {
      final invalidItems = orderItems.where((item) => !item.isValid).toList();
      if (invalidItems.isNotEmpty) {
        orderItemsError = 'Please fix errors in order items';
      }
    }

    final isValid = customerError == null && deliveryDateError == null && orderItemsError == null;

    return OrderFormViewModel(
      customerId: customerId,
      deliveryDate: deliveryDate,
      orderItems: orderItems,
      isValid: isValid,
      customerError: customerError,
      deliveryDateError: deliveryDateError,
      orderItemsError: orderItemsError,
    );
  }

  /// Convert to API request
  CreateOrderRequest toApiRequest() {
    return CreateOrderRequest(
      customerId: customerId!,
      deliveryDate: deliveryDate!,
      orderItems: orderItems.map((item) => item.toApiModel('')).toList(), // cardId will be set by provider
    );
  }

  /// Convert to domain model
  Order toDomainModel() {
    return Order(
      id: '', // Will be set by backend
      customerId: customerId ?? '',
      deliveryDate: DateTime.tryParse(deliveryDate ?? '') ?? DateTime.now(),
      orderItems: orderItems.map((item) => item.toDomainModel()).toList(),
      status: OrderStatus.pending,
      totalAmount: 0.0, // Will be calculated by business logic
      createdAt: DateTime.now(),
    );
  }

  /// Get total order value
  double get totalOrderValue {
    return orderItems.fold(0.0, (sum, item) {
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      final boxCost = item.requiresBox ? (double.tryParse(item.totalBoxCost ?? '0') ?? 0.0) : 0.0;
      final printingCost = item.requiresPrinting ? (double.tryParse(item.totalPrintingCost ?? '0') ?? 0.0) : 0.0;
      return sum + ((item.quantity * 0) - discountAmount) + boxCost + printingCost; // Base price will be added by provider
    });
  }
}
