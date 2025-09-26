import 'package:vsc_app/core/models/pagination_data.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/administration/data/models/staff_response.dart';
import 'package:vsc_app/features/administration/data/services/staff_service.dart';

class StaffProvider extends BaseProvider {
  final StaffService _staffService = StaffService();

  final List<StaffResponse> _staff = [];
  PaginationData? _pagination;
  bool _isPageLoading = false;

  List<StaffResponse> get staff => List.unmodifiable(_staff);
  PaginationData? get pagination => _pagination;
  bool get isPageLoading => _isPageLoading;

  Future<void> fetchStaff({int page = 1, int pageSize = 50}) async {
    _isPageLoading = true;
    notifyListeners();

    await executeApiOperation<List<StaffResponse>, void>(
      apiCall: () => _staffService.getStaff(page: page, pageSize: pageSize),
      onSuccess: (response) {
        _staff
          ..clear()
          ..addAll(response.data ?? []);
        _pagination = response.pagination;
        notifyListeners();
      },
      showSnackbar: false,
      errorMessage: 'Failed to fetch staff',
    );

    _isPageLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (_pagination?.hasNext == true) {
      await fetchStaff(page: (_pagination?.currentPage ?? 1) + 1);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_pagination?.hasPrevious == true) {
      await fetchStaff(page: (_pagination?.currentPage ?? 1) - 1);
    }
  }
}
