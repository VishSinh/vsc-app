import 'package:vsc_app/features/production/data/models/box_maker_response.dart';

/// View model for box maker data
class BoxMakerViewModel {
  final String id;
  final String name;
  final String phone;
  final bool isActive;

  const BoxMakerViewModel({required this.id, required this.name, required this.phone, required this.isActive});

  /// Create from API response
  factory BoxMakerViewModel.fromResponse(BoxMakerResponse response) {
    return BoxMakerViewModel(id: response.id, name: response.name, phone: response.phone, isActive: response.isActive);
  }

  /// Create list from API responses
  static List<BoxMakerViewModel> fromResponseList(List<BoxMakerResponse> responses) {
    return responses.map((response) => BoxMakerViewModel.fromResponse(response)).toList();
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoxMakerViewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
