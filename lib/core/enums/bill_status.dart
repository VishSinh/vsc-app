import 'package:flutter/material.dart';

enum BillStatus { pending, partial, paid }

extension BillStatusExtension on BillStatus {
  String toApiString() {
    switch (this) {
      case BillStatus.pending:
        return 'PENDING';
      case BillStatus.partial:
        return 'PARTIAL';
      case BillStatus.paid:
        return 'PAID';
    }
  }

  String getDisplayText() {
    switch (this) {
      case BillStatus.pending:
        return 'Pending';
      case BillStatus.partial:
        return 'Partial';
      case BillStatus.paid:
        return 'Paid';
    }
  }

  Color getStatusColor() {
    switch (this) {
      case BillStatus.pending:
        return Colors.red;
      case BillStatus.partial:
        return Colors.orange;
      case BillStatus.paid:
        return Colors.green;
    }
  }

  static BillStatus? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'PENDING':
        return BillStatus.pending;
      case 'PARTIAL':
        return BillStatus.partial;
      case 'PAID':
        return BillStatus.paid;
    }
    return null;
  }

  static Color getColorFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getStatusColor() ?? Colors.grey;
  }

  static String getDisplayTextFromString(String? statusString) {
    final status = fromApiString(statusString);
    return status?.getDisplayText() ?? (statusString?.toUpperCase() ?? 'UNKNOWN');
  }
}
