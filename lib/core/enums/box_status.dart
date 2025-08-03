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

  /// Convert from API string format
  static BoxStatus? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'PENDING':
        return BoxStatus.pending;
      case 'IN_PROGRESS':
        return BoxStatus.inProgress;
      case 'COMPLETED':
        return BoxStatus.completed;
      default:
        return null;
    }
  }
}
