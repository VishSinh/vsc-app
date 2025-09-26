import 'package:vsc_app/core/models/pagination_data.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/administration/data/models/model_log_response.dart';
import 'package:vsc_app/features/administration/presentation/models/model_log_view_model.dart';
import 'package:vsc_app/features/administration/data/services/audit_service.dart';

class AuditLogsProvider extends BaseProvider with SearchMixin {
  final AuditService _auditService = AuditService();

  final List<ModelLogViewModel> _logs = [];
  PaginationData? _pagination;

  bool _isPageLoading = false;
  // Filters
  String? _selectedStaffId;
  String? _selectedAction; // CREATE, UPDATE, DELETE
  DateTime? _startDate;
  DateTime? _endDate;

  List<ModelLogViewModel> get logs => List.unmodifiable(_logs);
  PaginationData? get pagination => _pagination;
  bool get isPageLoading => _isPageLoading;
  String? get selectedStaffId => _selectedStaffId;
  String? get selectedAction => _selectedAction;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  Future<void> fetchLogs({int page = 1, int pageSize = 50}) async {
    _isPageLoading = true;
    notifyListeners();

    await executeApiOperation<List<ModelLogResponse>, void>(
      apiCall: () => _auditService.getModelLogs(
        page: page,
        pageSize: pageSize,
        staffId: _selectedStaffId,
        action: _selectedAction,
        start: _startDate,
        end: _endDate,
      ),
      onSuccess: (response) {
        _logs
          ..clear()
          ..addAll(ModelLogViewModel.fromResponseList(response.data ?? []));
        _pagination = response.pagination;
        notifyListeners();
      },
      showSnackbar: false,
      errorMessage: 'Failed to fetch model logs',
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

  void setActionFilter(String? action) {
    _selectedAction = action;
    notifyListeners();
  }

  void setDateRange({DateTime? start, DateTime? end}) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }
}
