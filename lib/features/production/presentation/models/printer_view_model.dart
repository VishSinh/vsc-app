import 'package:vsc_app/features/production/data/models/printer_response.dart';

/// View model for printer data
class PrinterViewModel {
  final String id;
  final String name;
  final String phone;
  final bool isActive;

  const PrinterViewModel({required this.id, required this.name, required this.phone, required this.isActive});

  /// Create from API response
  factory PrinterViewModel.fromResponse(PrinterResponse response) {
    return PrinterViewModel(id: response.id, name: response.name, phone: response.phone, isActive: response.isActive);
  }

  /// Create list from API responses
  static List<PrinterViewModel> fromResponseList(List<PrinterResponse> responses) {
    return responses.map((response) => PrinterViewModel.fromResponse(response)).toList();
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrinterViewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
