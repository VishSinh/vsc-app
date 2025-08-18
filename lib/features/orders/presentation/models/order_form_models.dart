import 'package:vsc_app/features/orders/data/models/order_requests.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/orders/presentation/models/order_item_form_model.dart';

/// Form model for order creation
class OrderCreationFormModel {
  String? customerId;
  String? name;
  String? deliveryDate;
  List<OrderItemCreationFormModel>? orderItems;
  String? specialInstruction;

  OrderCreationFormModel({this.customerId, this.name, this.deliveryDate, this.orderItems, this.specialInstruction});

  /// Validates the order creation form
  ValidationResult validate() {
    final errors = <ValidationError>[];

    ValidationResult validateCustomerId() {
      if (customerId == null || customerId!.isEmpty) {
        return ValidationResult.failureSingle('customerId', 'Customer is required');
      }
      return ValidationResult.success();
    }

    ValidationResult validateName() {
      if (name == null || name!.isEmpty) {
        return ValidationResult.failureSingle('name', 'Order name is required');
      }
      return ValidationResult.success();
    }

    ValidationResult validateDeliveryDate() {
      if (deliveryDate == null || deliveryDate!.isEmpty) {
        return ValidationResult.failureSingle('deliveryDate', 'Delivery date is required');
      }

      final deliveryDateTime = DateTime.tryParse(deliveryDate!);
      if (deliveryDateTime == null) {
        return ValidationResult.failureSingle('deliveryDate', 'Invalid delivery date format');
      } else if (deliveryDateTime.isBefore(DateTime.now())) {
        return ValidationResult.failureSingle('deliveryDate', 'Delivery date cannot be in the past');
      }

      return ValidationResult.success();
    }

    ValidationResult validateOrderItems() {
      if (orderItems?.isEmpty ?? true) {
        return ValidationResult.failureSingle('orderItems', 'At least one order item is required');
      }

      final itemErrors = <ValidationError>[];
      for (int i = 0; i < orderItems!.length; i++) {
        final item = orderItems![i];
        final itemValidation = item.validate();
        if (!itemValidation.isValid) {
          itemErrors.add(ValidationError(field: 'orderItem_$i', message: 'Order item ${i + 1}: ${itemValidation.firstMessage}'));
        }
      }

      return itemErrors.isEmpty ? ValidationResult.success() : ValidationResult.failure(itemErrors);
    }

    final customerIdResult = validateCustomerId();
    if (!customerIdResult.isValid) {
      errors.addAll(customerIdResult.errors);
    }

    final nameResult = validateName();
    if (!nameResult.isValid) {
      errors.addAll(nameResult.errors);
    }

    final deliveryDateResult = validateDeliveryDate();
    if (!deliveryDateResult.isValid) {
      errors.addAll(deliveryDateResult.errors);
    }

    final orderItemsResult = validateOrderItems();
    if (!orderItemsResult.isValid) {
      errors.addAll(orderItemsResult.errors);
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  CreateOrderRequest toApiRequest() {
    if (customerId == null || name == null || deliveryDate == null || orderItems == null) {
      throw FormatException('Invalid order form data');
    }

    final orderItemRequests = orderItems!.map((item) => item.toApiRequest()).toList();

    return CreateOrderRequest(customerId: customerId!, name: name!, deliveryDate: deliveryDate!, orderItems: orderItemRequests);
  }

  /// Create a copy with updated values
  OrderCreationFormModel copyWith({
    String? customerId,
    String? name,
    String? deliveryDate,
    List<OrderItemCreationFormModel>? orderItems,
    String? specialInstruction,
  }) {
    return OrderCreationFormModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderItems: orderItems ?? this.orderItems,
      specialInstruction: specialInstruction ?? this.specialInstruction,
    );
  }
}
