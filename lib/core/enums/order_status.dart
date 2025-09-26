import 'package:flutter/material.dart';

/// Order status enum for orders
enum OrderStatus { confirmed, inProgress, ready, delivered, fullyPaid }

/// Extension to add conversion methods to OrderStatus
extension OrderStatusExtension on OrderStatus {
  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.inProgress:
        return 'IN_PROGRESS';
      case OrderStatus.ready:
        return 'READY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.fullyPaid:
        return 'FULLY_PAID';
    }
  }

  /// Get the display text for the order status
  String getDisplayText() {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.fullyPaid:
        return 'Fully Paid';
    }
  }

  /// Get the color associated with this order status
  Color getStatusColor() {
    switch (this) {
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.fullyPaid:
        return Colors.green;
    }
  }

  /// Convert from API string format
  static OrderStatus? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'IN_PROGRESS':
        return OrderStatus.inProgress;
      case 'READY':
        return OrderStatus.ready;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'FULLY_PAID':
        return OrderStatus.fullyPaid;
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
