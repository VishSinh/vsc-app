import 'package:vsc_app/core/models/pagination_data.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/administration/data/models/api_log_response.dart';
import 'package:vsc_app/features/administration/data/services/api_logs_service.dart';
import 'package:vsc_app/features/administration/presentation/models/api_log_view_model.dart';

class ApiLogsProvider extends BaseProvider with SearchMixin {
  final ApiLogsService _service = ApiLogsService();

  final List<ApiLogViewModel> _logs = [];
  PaginationData? _pagination;
  bool _isPageLoading = false;

  // Filters
  String? _selectedStaffId;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _endpoint;
  int? _statusCode;

  List<ApiLogViewModel> get logs => List.unmodifiable(_logs);
  PaginationData? get pagination => _pagination;
  bool get isPageLoading => _isPageLoading;
  String? get selectedStaffId => _selectedStaffId;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get endpoint => _endpoint;
  int? get statusCode => _statusCode;

  Future<void> fetchLogs({int page = 1, int pageSize = 50}) async {
    _isPageLoading = true;
    notifyListeners();

    await executeApiOperation<List<ApiLogResponse>, void>(
      apiCall: () => _service.getApiLogs(
        page: page,
        pageSize: pageSize,
        staffId: _selectedStaffId,
        start: _startDate,
        end: _endDate,
        endpoint: _endpoint,
        statusCode: _statusCode,
      ),
      onSuccess: (response) {
        _logs
          ..clear()
          ..addAll(ApiLogViewModel.fromResponseList(response.data ?? []));
        _pagination = response.pagination;
        notifyListeners();
      },
      showSnackbar: false,
      errorMessage: 'Failed to fetch API logs',
    );

    _isPageLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (_pagination?.hasNext == true) {
      await fetchLogs(page: (_pagination?.currentPage ?? 1) + 1);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_pagination?.hasPrevious == true) {
      await fetchLogs(page: (_pagination?.currentPage ?? 1) - 1);
    }
  }

  // Setters for filters
  void setStaffFilter(String? staffId) {
    _selectedStaffId = staffId;
    notifyListeners();
  }

  void setDateRange({DateTime? start, DateTime? end}) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setEndpoint(String? value) {
    _endpoint = value;
    notifyListeners();
  }

  void setStatusCode(int? value) {
    _statusCode = value;
    notifyListeners();
  }
}
