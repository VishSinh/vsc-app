import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/features/administration/data/models/staff_response.dart';

class StaffService extends ApiService {
  Future<ApiResponse<List<StaffResponse>>> getStaff({int page = 1, int pageSize = 50}) async {
    return await executeRequest(() => get('${AppConstants.staffEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        return json.map((e) => StaffResponse.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format for staff');
    });
  }
}
