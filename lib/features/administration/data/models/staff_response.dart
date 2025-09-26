import 'package:json_annotation/json_annotation.dart';

part 'staff_response.g.dart';

@JsonSerializable()
class StaffResponse {
  final String id;
  final String phone;
  final String name;
  final String role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'date_joined')
  final String dateJoined;
  final String username;

  const StaffResponse({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.isActive,
    required this.dateJoined,
    required this.username,
  });

  factory StaffResponse.fromJson(Map<String, dynamic> json) => _$StaffResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StaffResponseToJson(this);
}
