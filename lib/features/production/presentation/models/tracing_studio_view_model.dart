import 'package:vsc_app/features/production/data/models/tracing_studio_response.dart';

/// View model for tracing studio data
class TracingStudioViewModel {
  final String id;
  final String name;
  final String phone;
  final bool isActive;

  const TracingStudioViewModel({required this.id, required this.name, required this.phone, required this.isActive});

  /// Create from API response
  factory TracingStudioViewModel.fromResponse(TracingStudioResponse response) {
    return TracingStudioViewModel(id: response.id, name: response.name, phone: response.phone, isActive: response.isActive);
  }

  /// Create list from API responses
  static List<TracingStudioViewModel> fromResponseList(List<TracingStudioResponse> responses) {
    return responses.map((response) => TracingStudioViewModel.fromResponse(response)).toList();
  }

  @override
  String toString() {
    return name;
  }
}
