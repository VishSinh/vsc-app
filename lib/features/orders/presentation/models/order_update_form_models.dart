import 'package:vsc_app/core/enums/order_status.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/orders/data/models/order_requests.dart';
import 'package:vsc_app/features/orders/presentation/models/order_item_form_model.dart';

/// Form model for updating an order
class OrderUpdateFormModel {
  OrderStatus? orderStatus;
  String? deliveryDate; // ISO-8601 string
  String? specialInstruction;

  // Update existing items
  List<OrderItemUpdateFormModel>? orderItems;

  // Add new items (reuse creation form model)
  List<OrderItemCreationFormModel>? addItems;

  // Remove items by id
  List<String>? removeItemIds;

  OrderUpdateFormModel({this.orderStatus, this.deliveryDate, this.specialInstruction, this.orderItems, this.addItems, this.removeItemIds});

  /// Validates the update form; only validates provided fields
  ValidationResult validate() {
    final errors = <ValidationError>[];

    ValidationResult validateDeliveryDate() {
      if (deliveryDate == null || deliveryDate!.isEmpty) {
        return ValidationResult.success();
      }
      final parsed = DateTime.tryParse(deliveryDate!);
      if (parsed == null) {
        return ValidationResult.failureSingle('deliveryDate', 'Invalid delivery date format');
      }
      return ValidationResult.success();
    }

    ValidationResult validateOrderItems() {
      if (orderItems == null) return ValidationResult.success();
      final itemErrors = <ValidationError>[];
      for (int i = 0; i < orderItems!.length; i++) {
        final result = orderItems![i].validate();
        if (!result.isValid) {
          itemErrors.add(ValidationError(field: 'orderItem_$i', message: result.firstMessage ?? 'Invalid order item update'));
        }
      }
      return itemErrors.isEmpty ? ValidationResult.success() : ValidationResult.failure(itemErrors);
    }

    ValidationResult validateAddItems() {
      if (addItems == null) return ValidationResult.success();
      final itemErrors = <ValidationError>[];
      for (int i = 0; i < addItems!.length; i++) {
        final result = addItems![i].validate();
        if (!result.isValid) {
          itemErrors.add(ValidationError(field: 'addItem_$i', message: result.firstMessage ?? 'Invalid new order item'));
        }
      }
      return itemErrors.isEmpty ? ValidationResult.success() : ValidationResult.failure(itemErrors);
    }

    ValidationResult validateRemoveItemIds() {
      if (removeItemIds == null) return ValidationResult.success();
      final invalidIndex = removeItemIds!.indexWhere((id) => id.trim().isEmpty);
      if (invalidIndex >= 0) {
        return ValidationResult.failureSingle('removeItemIds', 'Remove item id at index $invalidIndex is empty');
      }
      return ValidationResult.success();
    }

    final deliveryDateResult = validateDeliveryDate();
    if (!deliveryDateResult.isValid) errors.addAll(deliveryDateResult.errors);

    final orderItemsResult = validateOrderItems();
    if (!orderItemsResult.isValid) errors.addAll(orderItemsResult.errors);

    final addItemsResult = validateAddItems();
    if (!addItemsResult.isValid) errors.addAll(addItemsResult.errors);

    final removeIdsResult = validateRemoveItemIds();
    if (!removeIdsResult.isValid) errors.addAll(removeIdsResult.errors);

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  /// Convert the form into the API request
  UpdateOrderRequest toApiRequest() {
    final updateItems = orderItems?.map((item) => item.toApiModel()).toList();
    final addItemModels = addItems?.map((item) => _mapCreationToAddApiModel(item)).toList();

    return UpdateOrderRequest(
      orderStatus: orderStatus?.toApiString(),
      deliveryDate: deliveryDate,
      specialInstruction: specialInstruction,
      orderItems: updateItems,
      addItems: addItemModels,
      removeItemIds: removeItemIds,
    );
  }

  AddOrderItemAPIModel _mapCreationToAddApiModel(OrderItemCreationFormModel item) {
    return AddOrderItemAPIModel(
      cardId: item.cardId,
      discountAmount: item.discountAmount,
      quantity: item.quantity,
      requiresBox: item.requiresBox,
      boxType: item.requiresBox ? item.boxType?.toApiString() : null,
      totalBoxCost: item.totalBoxCost,
      requiresPrinting: item.requiresPrinting,
      totalPrintingCost: item.totalPrintingCost,
    );
  }

  /// Create a copy with updated values
  OrderUpdateFormModel copyWith({
    OrderStatus? orderStatus,
    String? deliveryDate,
    String? specialInstruction,
    List<OrderItemUpdateFormModel>? orderItems,
    List<OrderItemCreationFormModel>? addItems,
    List<String>? removeItemIds,
  }) {
    return OrderUpdateFormModel(
      orderStatus: orderStatus ?? this.orderStatus,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      specialInstruction: specialInstruction ?? this.specialInstruction,
      orderItems: orderItems ?? this.orderItems,
      addItems: addItems ?? this.addItems,
      removeItemIds: removeItemIds ?? this.removeItemIds,
    );
  }
}

/// Form model for updating an existing order item
class OrderItemUpdateFormModel {
  final String orderItemId;
  final int? quantity;
  final String? discountAmount;
  final bool? requiresBox;
  final OrderBoxType? boxType;
  final String? totalBoxCost;
  final bool? requiresPrinting;
  final String? totalPrintingCost;

  OrderItemUpdateFormModel({
    required this.orderItemId,
    this.quantity,
    this.discountAmount,
    this.requiresBox,
    this.boxType,
    this.totalBoxCost,
    this.requiresPrinting,
    this.totalPrintingCost,
  });

  ValidationResult validate() {
    final errors = <ValidationError>[];

    if (orderItemId.trim().isEmpty) {
      errors.add(const ValidationError(field: 'orderItemId', message: 'orderItemId is required'));
    }

    if (quantity != null && quantity! < 0) {
      errors.add(const ValidationError(field: 'quantity', message: 'Quantity cannot be negative'));
    }

    if (discountAmount != null) {
      final discount = double.tryParse(discountAmount!);
      if (discount == null || discount < 0) {
        errors.add(const ValidationError(field: 'discountAmount', message: 'Invalid discount amount'));
      }
    }

    if (requiresBox == true) {
      if (boxType == null) {
        errors.add(const ValidationError(field: 'boxType', message: 'Box type is required when requiresBox is true'));
      }
      final boxCost = double.tryParse(totalBoxCost ?? '');
      if (boxCost == null) {
        errors.add(const ValidationError(field: 'totalBoxCost', message: 'totalBoxCost is required when requiresBox is true'));
      }
    }

    if (requiresPrinting == true) {
      final printingCost = double.tryParse(totalPrintingCost ?? '');
      if (printingCost == null) {
        errors.add(const ValidationError(field: 'totalPrintingCost', message: 'totalPrintingCost is required when requiresPrinting is true'));
      }
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  OrderUpdateItemAPIModel toApiModel() {
    return OrderUpdateItemAPIModel(
      orderItemId: orderItemId,
      quantity: quantity,
      discountAmount: discountAmount,
      requiresBox: requiresBox,
      boxType: requiresBox == true ? boxType?.toApiString() : null,
      totalBoxCost: totalBoxCost,
      requiresPrinting: requiresPrinting,
      totalPrintingCost: totalPrintingCost,
    );
  }

  OrderItemUpdateFormModel copyWith({
    String? orderItemId,
    int? quantity,
    String? discountAmount,
    bool? requiresBox,
    OrderBoxType? boxType,
    String? totalBoxCost,
    bool? requiresPrinting,
    String? totalPrintingCost,
  }) {
    return OrderItemUpdateFormModel(
      orderItemId: orderItemId ?? this.orderItemId,
      quantity: quantity ?? this.quantity,
      discountAmount: discountAmount ?? this.discountAmount,
      requiresBox: requiresBox ?? this.requiresBox,
      boxType: boxType ?? this.boxType,
      totalBoxCost: totalBoxCost ?? this.totalBoxCost,
      requiresPrinting: requiresPrinting ?? this.requiresPrinting,
      totalPrintingCost: totalPrintingCost ?? this.totalPrintingCost,
    );
  }
}
