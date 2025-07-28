import 'package:json_annotation/json_annotation.dart';
import 'package:vsc_app/core/models/api_response.dart';

part 'permission_model.g.dart';

@JsonSerializable()
class Permission {
  final String name;
  final String value;
  final String description;

  const Permission({
    required this.name,
    required this.value,
    required this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionToJson(this);
}

@JsonSerializable()
class AllPermissionsData {
  final List<Permission> permissions;
  final int totalCount;

  const AllPermissionsData({
    required this.permissions,
    required this.totalCount,
  });

  factory AllPermissionsData.fromJson(Map<String, dynamic> json) => _$AllPermissionsDataFromJson(json);
  Map<String, dynamic> toJson() => _$AllPermissionsDataToJson(this);
}

@JsonSerializable()
class StaffPermissionsData {
  @JsonKey(name: 'staff_id')
  final String staffId;
  @JsonKey(name: 'staff_role')
  final String staffRole;
  final List<String> permissions;
  @JsonKey(name: 'total_count')
  final int totalCount;

  const StaffPermissionsData({
    required this.staffId,
    required this.staffRole,
    required this.permissions,
    required this.totalCount,
  });

  factory StaffPermissionsData.fromJson(Map<String, dynamic> json) => _$StaffPermissionsDataFromJson(json);
  Map<String, dynamic> toJson() => _$StaffPermissionsDataToJson(this);
}

// Type aliases for better readability
typedef AllPermissionsResponse = ApiResponse<AllPermissionsData>;
typedef StaffPermissionsResponse = ApiResponse<StaffPermissionsData>; 