import 'package:vsc_app/core/enums/order_box_type.dart';

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

  /// Check if the form is valid
  bool get isValid {
    return cardId.isNotEmpty &&
        quantity > 0 &&
        double.tryParse(discountAmount) != null &&
        double.tryParse(discountAmount)! >= 0 &&
        (!requiresBox || (totalBoxCost != null && double.tryParse(totalBoxCost!) != null && double.tryParse(totalBoxCost!)! >= 0)) &&
        (!requiresPrinting ||
            (totalPrintingCost != null && double.tryParse(totalPrintingCost!) != null && double.tryParse(totalPrintingCost!)! >= 0));
  }

  // Line item total ((basePrice - discountAmount) * formModel.quantity) + boxCost + printingCost;
  double get lineItemTotal {
    return 0.00;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (cardId.isEmpty) errors.add('Card is required');
    if (quantity <= 0) errors.add('Quantity must be greater than 0');

    final discountAmount = double.tryParse(this.discountAmount);
    if (discountAmount == null) {
      errors.add('Invalid discount amount');
    } else if (discountAmount < 0) {
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

    return errors;
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

  // factory OrderCreationFormViewModel.empty() {
  //   return OrderCreationFormViewModel(customerId: '', deliveryDate: '', orderItems: [], specialInstruction: '');
  // }

  /// Check if the form is valid
  bool get isValid {
    return customerId != null &&
        customerId!.isNotEmpty &&
        name != null &&
        name!.isNotEmpty &&
        deliveryDate != null &&
        deliveryDate!.isNotEmpty &&
        orderItems != null &&
        orderItems!.isNotEmpty &&
        orderItems!.every((item) => item.isValid);
  }

  /// Get validation errors
  List<String> get validationErrors {
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
        if (!item.isValid) {
          errors.add('Order item ${i + 1}: ${item.validationErrors.join(', ')}');
        }
      }
    }

    return errors;
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
