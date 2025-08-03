import '../../data/models/order_responses.dart';
import '../models/order_form_models.dart';
import 'package:vsc_app/features/cards/data/models/card_responses.dart';

/// Service for calculating order prices and totals
class OrderPriceCalculatorService {
  // CREATION FLOW CALCULATIONS (Form Models)

  /// Calculate line item total for creation flow
  static double calculateLineItemTotalForCreation(OrderItemCreationFormViewModel item, CardResponse card) {
    final basePrice = card.sellPriceAsDouble;
    final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
    final boxCost = double.tryParse(item.totalBoxCost ?? '0') ?? 0.0;
    final printingCost = double.tryParse(item.totalPrintingCost ?? '0') ?? 0.0;

    return ((basePrice - discountAmount) * item.quantity) + boxCost + printingCost;
  }

  /// Calculate order total for creation flow
  static double calculateOrderTotalForCreation(List<OrderItemCreationFormViewModel> items, Map<String, CardResponse> cardDetails) {
    return items.fold(0.0, (total, item) {
      final card = cardDetails[item.cardId];
      if (card == null) return total;
      return total + calculateLineItemTotalForCreation(item, card);
    });
  }

  /// Calculate total discount for creation flow
  static double calculateTotalDiscountForCreation(List<OrderItemCreationFormViewModel> items) {
    return items.fold(0.0, (total, item) {
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      return total + (discountAmount * item.quantity);
    });
  }

  /// Calculate total additional costs for creation flow
  static double calculateTotalAdditionalCostsForCreation(List<OrderItemCreationFormViewModel> items) {
    return items.fold(0.0, (total, item) {
      final boxCost = double.tryParse(item.totalBoxCost ?? '0') ?? 0.0;
      final printingCost = double.tryParse(item.totalPrintingCost ?? '0') ?? 0.0;
      return total + boxCost + printingCost;
    });
  }

  // FETCHING FLOW CALCULATIONS (Response Models)

  /// Calculate line item total for fetched data
  static double calculateLineItemTotalForFetched(OrderItemResponse item, CardResponse card) {
    final pricePerItem = double.tryParse(item.pricePerItem) ?? 0.0;
    final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
    final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));
    final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));

    return ((pricePerItem - discountAmount) * item.quantity) + boxCosts + printingCosts;
  }

  /// Calculate order total for fetched data
  static double calculateOrderTotalForFetched(List<OrderItemResponse> items, Map<String, CardResponse> cardDetails) {
    return items.fold(0.0, (total, item) {
      final card = cardDetails[item.cardId];
      if (card == null) return total;
      return total + calculateLineItemTotalForFetched(item, card);
    });
  }

  /// Calculate total discount for fetched data
  static double calculateTotalDiscountForFetched(List<OrderItemResponse> items) {
    return items.fold(0.0, (total, item) {
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      return total + (discountAmount * item.quantity);
    });
  }

  /// Calculate total additional costs for fetched data
  static double calculateTotalAdditionalCostsForFetched(List<OrderItemResponse> items) {
    return items.fold(0.0, (total, item) {
      final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));
      final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));
      return total + boxCosts + printingCosts;
    });
  }

  /// Get order item count
  static int getOrderItemCount(List<OrderItemCreationFormViewModel> items) {
    return items.fold(0, (total, item) => total + item.quantity);
  }
}
