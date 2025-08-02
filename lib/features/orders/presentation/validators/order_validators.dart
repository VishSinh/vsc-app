import 'package:vsc_app/core/validation/validation_result.dart';
import 'package:vsc_app/features/orders/presentation/models/order_form_models.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

/// Presentation validators for UI-specific validations
/// These validators handle form field validation and UI state checks
class OrderValidators {
  /// Validates if a customer is selected
  static ValidationResult validateCustomerSelected(dynamic customer) {
    if (customer == null) {
      return ValidationResult.failureSingle('customer', 'Please select a customer');
    }
    return ValidationResult.success();
  }

  /// Validates if order has items
  static ValidationResult validateOrderHasItems(List items) {
    if (items.isEmpty) {
      return ValidationResult.failureSingle('orderItems', 'Please add at least one item to the order');
    }
    return ValidationResult.success();
  }

  /// Validates delivery date
  static ValidationResult validateDeliveryDate(String? deliveryDate) {
    if (deliveryDate == null || deliveryDate.trim().isEmpty) {
      return ValidationResult.failureSingle('deliveryDate', 'Please select a delivery date');
    }
    return ValidationResult.success();
  }

  /// Validates card barcode
  static ValidationResult validateBarcode(String barcode) {
    if (barcode.trim().isEmpty) {
      return ValidationResult.failureSingle('barcode', 'Please enter a barcode');
    }
    return ValidationResult.success();
  }

  /// Validates if order can be created (UI validation)
  static ValidationResult validateOrderCreation({
    required dynamic customer,
    required List<OrderItemCreationFormViewModel> items,
    required String? deliveryDate,
  }) {
    final errors = <ValidationError>[];

    if (customer == null) {
      errors.add(const ValidationError(field: 'customer', message: 'Please select a customer'));
    }

    if (items.isEmpty) {
      errors.add(const ValidationError(field: 'orderItems', message: 'Please add at least one item to the order'));
    }

    if (deliveryDate == null || deliveryDate.trim().isEmpty) {
      errors.add(const ValidationError(field: 'deliveryDate', message: 'Please select a delivery date'));
    }

    return errors.isEmpty ? ValidationResult.success() : ValidationResult.failure(errors);
  }

  /// Validates if current card is selected (UI validation)
  static ValidationResult validateCurrentCardSelected(CardViewModel? currentCard) {
    if (currentCard == null) {
      return ValidationResult.failureSingle('currentCard', 'No card selected');
    }
    return ValidationResult.success();
  }
}
