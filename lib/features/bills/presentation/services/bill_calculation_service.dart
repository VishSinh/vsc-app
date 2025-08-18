import 'package:flutter/material.dart';
import 'package:vsc_app/core/enums/bill_status.dart';

/// Service for bill-related calculations
class BillCalculationService {
  /// Calculate line total for an order item
  static double calculateLineTotal(String pricePerItem, String discountAmount, int quantity) {
    final price = double.tryParse(pricePerItem) ?? 0.0;
    final discount = double.tryParse(discountAmount) ?? 0.0;
    return (price - discount) * quantity;
  }

  /// Calculate total paid amount from payments
  static double calculateTotalPaidAmount(List<dynamic> payments) {
    return payments.fold<double>(0.0, (sum, payment) => sum + (payment.amount as double));
  }

  /// Calculate remaining amount to be paid
  static double calculateRemainingAmount(double totalWithTax, List<dynamic> payments) {
    final totalPaidAmount = calculateTotalPaidAmount(payments);
    return totalWithTax - totalPaidAmount;
  }

  /// Check if a bill is fully paid
  static bool isFullyPaid(double totalWithTax, List<dynamic> payments) {
    return calculateRemainingAmount(totalWithTax, payments) <= 0;
  }

  /// Get status color based on bill status
  static Color getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return Colors.green;
      case BillStatus.partial:
        return Colors.orange;
      case BillStatus.pending:
        return Colors.red;
    }
  }

  /// Get status text based on bill status
  static String getStatusText(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.partial:
        return 'Partial';
      case BillStatus.pending:
        return 'Pending';
    }
  }
}
