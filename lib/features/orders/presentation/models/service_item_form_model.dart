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

  ServiceItemCreationFormModel({this.serviceType, required this.quantity, required this.totalCost, required this.totalExpense, this.description});

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
