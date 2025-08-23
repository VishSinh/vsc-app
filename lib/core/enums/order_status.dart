import 'package:flutter/material.dart';

/// Order status enum for orders
enum OrderStatus { pending, confirmed, inProgress, completed, cancelled }

/// Extension to add conversion methods to OrderStatus
extension OrderStatusExtension on OrderStatus {
  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.inProgress:
        return 'IN_PROGRESS';
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Get the display text for the order status
  String getDisplayText() {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.inProgress:
        return 'IN PROGRESS';
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Get the color associated with this order status
  Color getStatusColor() {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// Convert from API string format
  static OrderStatus? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'IN_PROGRESS':
        return OrderStatus.inProgress;
      case 'COMPLETED':
        return OrderStatus.completed;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return null;
    }
  }

  /// Get the color for an order status string
  static Color getColorFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getStatusColor() ?? Colors.grey;
  }

  /// Get the display text for an order status string
  static String getDisplayTextFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getDisplayText() ?? (statusString?.toUpperCase() ?? 'UNKNOWN');
  }
}
