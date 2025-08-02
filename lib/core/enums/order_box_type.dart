/// Box type enum for order items
enum OrderBoxType { folding, complete }

/// Extension to add conversion methods to OrderBoxType
extension OrderBoxTypeExtension on OrderBoxType {
  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case OrderBoxType.folding:
        return 'FOLDING';
      case OrderBoxType.complete:
        return 'COMPLETE';
    }
  }

  /// Convert from API string format
  static OrderBoxType? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'FOLDING':
        return OrderBoxType.folding;
      case 'COMPLETE':
        return OrderBoxType.complete;
      default:
        return null;
    }
  }
}
