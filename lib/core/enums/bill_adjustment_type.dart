/// Bill Adjustment Type enum and helpers
enum BillAdjustmentType { negotiation, complaint, goodwill, other }

extension BillAdjustmentTypeExtension on BillAdjustmentType {
  String toApiString() {
    switch (this) {
      case BillAdjustmentType.negotiation:
        return 'NEGOTIATION';
      case BillAdjustmentType.complaint:
        return 'COMPLAINT';
      case BillAdjustmentType.goodwill:
        return 'GOODWILL';
      case BillAdjustmentType.other:
        return 'OTHER';
    }
  }

  String get displayText {
    switch (this) {
      case BillAdjustmentType.negotiation:
        return 'Negotiation';
      case BillAdjustmentType.complaint:
        return 'Complaint';
      case BillAdjustmentType.goodwill:
        return 'Goodwill';
      case BillAdjustmentType.other:
        return 'Other';
    }
  }

  static BillAdjustmentType? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'NEGOTIATION':
        return BillAdjustmentType.negotiation;
      case 'COMPLAINT':
        return BillAdjustmentType.complaint;
      case 'GOODWILL':
        return BillAdjustmentType.goodwill;
      case 'OTHER':
        return BillAdjustmentType.other;
    }
    return null;
  }
}
