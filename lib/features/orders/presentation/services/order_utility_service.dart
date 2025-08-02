import '../../data/models/order_responses.dart';
import '../models/order_view_models.dart';

/// Utility service for order-related helper functions
class OrderUtilityService {
  /// Calculate total amount from order items (using response models)
  static double calculateTotalAmount(List<OrderItemResponse> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      final pricePerItem = double.tryParse(item.pricePerItem) ?? 0.0;
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      final lineTotal = (pricePerItem * item.quantity) - discountAmount;

      // Add box costs
      final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));

      // Add printing costs
      final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));

      return total + lineTotal + boxCosts + printingCosts;
    });
  }

  /// Calculate total amount from order view models
  static double calculateTotalAmountFromViewModels(List<OrderItemViewModel> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      final pricePerItem = double.tryParse(item.pricePerItem) ?? 0.0;
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      final lineTotal = (pricePerItem * item.quantity) - discountAmount;

      // Add box costs
      final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));

      // Add printing costs
      final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));

      return total + lineTotal + boxCosts + printingCosts;
    });
  }

  /// Calculate total discount from order items (using response models)
  static double calculateTotalDiscount(List<OrderItemResponse> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      return total + (discountAmount * item.quantity);
    });
  }

  /// Calculate total discount from order view models
  static double calculateTotalDiscountFromViewModels(List<OrderItemViewModel> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      final discountAmount = double.tryParse(item.discountAmount) ?? 0.0;
      return total + (discountAmount * item.quantity);
    });
  }

  /// Calculate total additional costs from order items (using response models)
  static double calculateTotalAdditionalCosts(List<OrderItemResponse> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      // Add box costs
      final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));

      // Add printing costs
      final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));

      return total + boxCosts + printingCosts;
    });
  }

  /// Calculate total additional costs from order view models
  static double calculateTotalAdditionalCostsFromViewModels(List<OrderItemViewModel> orderItems) {
    return orderItems.fold(0.0, (total, item) {
      // Add box costs
      final boxCosts = (item.boxOrders ?? []).fold(0.0, (sum, box) => sum + (double.tryParse(box.totalBoxCost) ?? 0.0));

      // Add printing costs
      final printingCosts = (item.printingJobs ?? []).fold(0.0, (sum, job) => sum + (double.tryParse(job.totalPrintingCost) ?? 0.0));

      return total + boxCosts + printingCosts;
    });
  }

  /// Parse order status from string
  static String parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending';
      case 'confirmed':
        return 'confirmed';
      case 'in_progress':
      case 'inprogress':
        return 'in_progress';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  /// Format date for presentation
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  /// Format DateTime for presentation
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
