import 'package:vsc_app/core/enums/service_type.dart';
import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/orders/data/models/order_requests.dart';

/// Form model for service item creation
class ServiceItemCreationFormModel {
  ServiceType? serviceType;
  final int quantity;
  final String totalCost;
  final String totalExpense;
  final String? description;

  ServiceItemCreationFormModel({
    this.serviceType,
    required this.quantity,
    required this.totalCost,
    required this.totalExpense,
    this.description,
  });

  ValidationResult validate() {
    final errors = <ValidationError>[];

    if (serviceType == null) {
      errors.add(ValidationError(field: 'serviceType', message: 'Service type is required'));
    }

    if (quantity <= 0) {
      errors.add(ValidationError(field: 'quantity', message: 'Quantity must be greater than 0'));
    }

    final cost = double.tryParse(totalCost);
    if (cost == null || cost < 0) {
      errors.add(ValidationError(field: 'totalCost', message: 'Valid total cost is required'));
    }

    final expense = double.tryParse(totalExpense);
    if (expense == null || expense < 0) {
      errors.add(ValidationError(field: 'totalExpense', message: 'Valid total expense is required'));
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  ServiceItemRequest toApiRequest() {
    return ServiceItemRequest(
      serviceType: serviceType?.toApiString() ?? '',
      quantity: quantity,
      totalCost: totalCost,
      totalExpense: totalExpense,
      description: description,
    );
  }
}

/// Form model for updating an existing service item
class ServiceItemUpdateFormModel {
  final String serviceOrderItemId;
  final int? quantity; // min 1
  final String? procurementStatus; // raw string mapped to API
  final String? totalCost;
  final String? totalExpense;
  final String? description;

  ServiceItemUpdateFormModel({
    required this.serviceOrderItemId,
    this.quantity,
    this.procurementStatus,
    this.totalCost,
    this.totalExpense,
    this.description,
  });

  ValidationResult validate() {
    final errors = <ValidationError>[];

    if (serviceOrderItemId.trim().isEmpty) {
      errors.add(const ValidationError(field: 'serviceOrderItemId', message: 'serviceOrderItemId is required'));
    }

    if (quantity != null && quantity! < 1) {
      errors.add(const ValidationError(field: 'quantity', message: 'Quantity must be at least 1'));
    }

    if (totalCost != null) {
      final c = double.tryParse(totalCost!);
      if (c == null || c < 0) {
        errors.add(const ValidationError(field: 'totalCost', message: 'Invalid total cost'));
      }
    }

    if (totalExpense != null) {
      final e = double.tryParse(totalExpense!);
      if (e == null || e < 0) {
        errors.add(const ValidationError(field: 'totalExpense', message: 'Invalid total expense'));
      }
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  ServiceItemUpdateAPIModel toApiModel() {
    return ServiceItemUpdateAPIModel(
      serviceOrderItemId: serviceOrderItemId,
      quantity: quantity,
      procurementStatus: procurementStatus,
      totalCost: totalCost,
      totalExpense: totalExpense,
      description: description,
    );
  }

  ServiceItemUpdateFormModel copyWith({
    String? serviceOrderItemId,
    int? quantity,
    String? procurementStatus,
    String? totalCost,
    String? totalExpense,
    String? description,
  }) {
    return ServiceItemUpdateFormModel(
      serviceOrderItemId: serviceOrderItemId ?? this.serviceOrderItemId,
      quantity: quantity ?? this.quantity,
      procurementStatus: procurementStatus ?? this.procurementStatus,
      totalCost: totalCost ?? this.totalCost,
      totalExpense: totalExpense ?? this.totalExpense,
      description: description ?? this.description,
    );
  }
}
