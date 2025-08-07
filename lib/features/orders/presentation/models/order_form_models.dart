import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/orders/data/models/order_requests.dart';
import 'package:vsc_app/core/validation/validation_result.dart';

/// Alias for backward compatibility
typedef BoxType = OrderBoxType;

/// Form model for order item creation
class OrderItemCreationFormViewModel {
  String cardId;
  final String discountAmount;
  final int quantity;
  final bool requiresBox;
  final bool requiresPrinting;
  final OrderBoxType? boxType;
  final String? totalBoxCost;
  final String? totalPrintingCost;

  OrderItemCreationFormViewModel({
    this.cardId = '',
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    required this.requiresPrinting,
    this.boxType,
    this.totalBoxCost,
    this.totalPrintingCost,
  });

  /// Validates the order item form
  ValidationResult validate() {
    final errors = <String>[];

    if (cardId.isEmpty) {
      errors.add('Card is required');
    }

    if (quantity <= 0) {
      errors.add('Quantity must be greater than 0');
    }

    final discountAmountValue = double.tryParse(discountAmount);
    if (discountAmountValue == null) {
      errors.add('Invalid discount amount');
    } else if (discountAmountValue < 0) {
      errors.add('Discount amount cannot be negative');
    }

    if (requiresBox) {
      final boxCost = double.tryParse(totalBoxCost ?? '');
      if (boxCost == null || boxCost < 0) {
        errors.add('Valid box cost is required');
      }
    }

    if (requiresPrinting) {
      final printingCost = double.tryParse(totalPrintingCost ?? '');
      if (printingCost == null || printingCost < 0) {
        errors.add('Valid printing cost is required');
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors.map((e) => ValidationError(field: 'orderItem', message: e)).toList());
  }

  OrderItemRequest toApiRequest() {
    return OrderItemRequest(
      cardId: cardId,
      discountAmount: discountAmount,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: requiresBox ? boxType?.toApiString() : null,
      totalBoxCost: totalBoxCost ?? '0.00',
      totalPrintingCost: totalPrintingCost ?? '0.00',
    );
  }

  /// Create a copy with updated values
  OrderItemCreationFormViewModel copyWith({
    String? cardId,
    String? discountAmount,
    int? quantity,
    bool? requiresBox,
    bool? requiresPrinting,
    OrderBoxType? boxType,
    String? totalBoxCost,
    String? totalPrintingCost,
  }) {
    return OrderItemCreationFormViewModel(
      cardId: cardId ?? this.cardId,
      discountAmount: discountAmount ?? this.discountAmount,
      quantity: quantity ?? this.quantity,
      requiresBox: requiresBox ?? this.requiresBox,
      requiresPrinting: requiresPrinting ?? this.requiresPrinting,
      boxType: boxType ?? this.boxType,
      totalBoxCost: totalBoxCost ?? this.totalBoxCost,
      totalPrintingCost: totalPrintingCost ?? this.totalPrintingCost,
    );
  }
}

/// Form model for order creation
class OrderCreationFormViewModel {
  String? customerId;
  String? name;
  String? deliveryDate;
  List<OrderItemCreationFormViewModel>? orderItems;
  String? specialInstruction;

  OrderCreationFormViewModel({this.customerId, this.name, this.deliveryDate, this.orderItems, this.specialInstruction});

  /// Validates the order creation form
  ValidationResult validate() {
    final errors = <String>[];

    if (customerId == null || customerId!.isEmpty) {
      errors.add('Customer is required');
    }

    if (name == null || name!.isEmpty) {
      errors.add('Order name is required');
    }

    if (deliveryDate == null || deliveryDate!.isEmpty) {
      errors.add('Delivery date is required');
    } else {
      final deliveryDateTime = DateTime.tryParse(deliveryDate!);
      if (deliveryDateTime == null) {
        errors.add('Invalid delivery date format');
      } else if (deliveryDateTime.isBefore(DateTime.now())) {
        errors.add('Delivery date cannot be in the past');
      }
    }

    if (orderItems?.isEmpty ?? true) {
      errors.add('At least one order item is required');
    } else {
      for (int i = 0; i < orderItems!.length; i++) {
        final item = orderItems![i];
        final itemValidation = item.validate();
        if (!itemValidation.isValid) {
          errors.add('Order item ${i + 1}: ${itemValidation.firstMessage}');
        }
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors.map((e) => ValidationError(field: 'order', message: e)).toList());
  }

  CreateOrderRequest toApiRequest() {
    final orderItems = this.orderItems?.map((item) => item.toApiRequest()).toList() ?? [];

    return CreateOrderRequest(customerId: customerId!, name: name!, deliveryDate: deliveryDate!, orderItems: orderItems);
  }

  /// Create a copy with updated values
  OrderCreationFormViewModel copyWith({
    String? customerId,
    String? name,
    String? deliveryDate,
    List<OrderItemCreationFormViewModel>? orderItems,
    String? specialInstruction,
  }) {
    return OrderCreationFormViewModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderItems: orderItems ?? this.orderItems,
      specialInstruction: specialInstruction ?? this.specialInstruction,
    );
  }
}
