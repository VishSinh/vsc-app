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
}
