enum PrintingStatus {
  pending('PENDING'),
  inTracing('IN_TRACING'),
  inPrinting('IN_PRINTING'),
  completed('COMPLETED');

  const PrintingStatus(this.value);
  final String value;

  String toApiString() => value;

  static PrintingStatus? fromApiString(String? value) {
    if (value == null) return null;
    return PrintingStatus.values.firstWhere((status) => status.value == value, orElse: () => PrintingStatus.pending);
  }
}

/// Extension for PrintingStatus enum
class PrintingStatusExtension {
  static PrintingStatus? fromApiString(String? value) {
    if (value == null) return null;
    return PrintingStatus.values.firstWhere((status) => status.value == value, orElse: () => PrintingStatus.pending);
  }
}
