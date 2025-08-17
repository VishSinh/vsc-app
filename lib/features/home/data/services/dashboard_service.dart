import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/features/home/data/models/dashboard_response.dart';

class DashboardService extends ApiService {
  Future<ApiResponse<DashboardResponse>> getDashboardData() async {
    return executeRequest(() => get(AppConstants.dashboardEndpoint), (json) => DashboardResponse.fromJson(json as Map<String, dynamic>));
  }
}
