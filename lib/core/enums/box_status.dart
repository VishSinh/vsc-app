import 'package:flutter/material.dart';

/// Box status enum for production orders
enum BoxStatus { pending, inProgress, completed }

/// Extension to add conversion methods to BoxStatus
extension BoxStatusExtension on BoxStatus {
  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case BoxStatus.pending:
        return 'PENDING';
      case BoxStatus.inProgress:
        return 'IN_PROGRESS';
      case BoxStatus.completed:
        return 'COMPLETED';
    }
  }

  /// Get the display text for the box status
  String getDisplayText() {
    switch (this) {
      case BoxStatus.pending:
        return 'PENDING';
      case BoxStatus.inProgress:
        return 'IN PROGRESS';
      case BoxStatus.completed:
        return 'COMPLETED';
    }
  }

  /// Get the color associated with this box status
  Color getStatusColor() {
    switch (this) {
      case BoxStatus.pending:
        return Colors.orange;
      case BoxStatus.inProgress:
        return Colors.blue;
      case BoxStatus.completed:
        return Colors.green;
    }
  }

  /// Convert from API string format
  static BoxStatus? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'PENDING':
        return BoxStatus.pending;
      case 'IN PROGRESS':
        return BoxStatus.inProgress;
      case 'COMPLETED':
        return BoxStatus.completed;
      default:
        return null;
    }
  }

  /// Get the color for a box status string
  static Color getColorFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getStatusColor() ?? Colors.grey;
  }

  /// Get the display text for a box status string
  static String getDisplayTextFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getDisplayText() ?? (statusString?.toUpperCase() ?? 'UNKNOWN');
  }
}
