import 'dart:convert';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/permission_model.dart';
import 'package:vsc_app/core/services/base_service.dart';

class PermissionService extends BaseService {
  PermissionService({super.dio, super.secureStorage});

  Future<AllPermissionsResponse> getAllPermissions() async {
    return await executeRequest(() => get(AppConstants.allPermissionsEndpoint), (json) => AllPermissionsData.fromJson(json as Map<String, dynamic>));
  }

  Future<StaffPermissionsResponse> getStaffPermissions() async {
    return await executeRequest(() => get(AppConstants.permissionsEndpoint), (json) => StaffPermissionsData.fromJson(json as Map<String, dynamic>));
  }

  Future<void> cacheStaffPermissions(List<String> permissions) async {
    await secureStorage.write(key: AppConstants.staffPermissionsKey, value: jsonEncode(permissions));
  }

  Future<List<String>> getCachedStaffPermissions() async {
    final permissionsJson = await secureStorage.read(key: AppConstants.staffPermissionsKey);
    if (permissionsJson != null) {
      final List<dynamic> permissions = jsonDecode(permissionsJson) as List<dynamic>;
      return permissions.cast<String>();
    }
    return [];
  }

  Future<void> clearCachedPermissions() async {
    await secureStorage.delete(key: AppConstants.staffPermissionsKey);
  }
}
