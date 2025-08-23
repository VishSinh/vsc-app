import 'package:flutter/material.dart';

/// Printing status enum for production orders
enum PrintingStatus { pending, inTracing, inPrinting, completed }

/// Extension to add conversion methods to PrintingStatus
extension PrintingStatusExtension on PrintingStatus {
  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case PrintingStatus.pending:
        return 'PENDING';
      case PrintingStatus.inTracing:
        return 'IN_TRACING';
      case PrintingStatus.inPrinting:
        return 'IN_PRINTING';
      case PrintingStatus.completed:
        return 'COMPLETED';
    }
  }

  /// Get the display text for the printing status
  String getDisplayText() {
    switch (this) {
      case PrintingStatus.pending:
        return 'PENDING';
      case PrintingStatus.inTracing:
        return 'IN TRACING';
      case PrintingStatus.inPrinting:
        return 'IN PRINTING';
      case PrintingStatus.completed:
        return 'COMPLETED';
    }
  }

  /// Get the color associated with this printing status
  Color getStatusColor() {
    switch (this) {
      case PrintingStatus.pending:
        return Colors.orange;
      case PrintingStatus.inTracing:
      case PrintingStatus.inPrinting:
        return Colors.blue;
      case PrintingStatus.completed:
        return Colors.green;
    }
  }

  /// Convert from API string format
  static PrintingStatus? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'PENDING':
        return PrintingStatus.pending;
      case 'IN_TRACING':
        return PrintingStatus.inTracing;
      case 'IN TRACING': // Alternative format
        return PrintingStatus.inTracing;
      case 'IN_PRINTING':
        return PrintingStatus.inPrinting;
      case 'IN PRINTING': // Alternative format
        return PrintingStatus.inPrinting;
      case 'COMPLETED':
        return PrintingStatus.completed;
      default:
        return null;
    }
  }

  /// Get the color for a printing status string
  static Color getColorFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getStatusColor() ?? Colors.grey;
  }

  /// Get the display text for a printing status string
  static String getDisplayTextFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getDisplayText() ?? (statusString?.toUpperCase() ?? 'UNKNOWN');
  }
}
