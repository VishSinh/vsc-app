import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/models/pagination_data.dart';
import 'package:vsc_app/features/production/data/models/box_order_table_item.dart';
import 'package:vsc_app/features/production/data/models/printing_table_item.dart';
import 'package:vsc_app/features/production/data/models/tracing_table_item.dart';
import 'package:vsc_app/features/production/data/services/production_service.dart';
import 'package:vsc_app/features/production/presentation/models/box_maker_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/printer_view_model.dart';
import 'package:vsc_app/features/production/presentation/models/tracing_studio_view_model.dart';

class ProductionProvider extends BaseProvider {
  final ProductionService _service = ProductionService();

  // Printers state
  bool _isLoadingPrinters = false;
  String? _lastPrintersError;
  final List<PrinterViewModel> _printers = [];
  PrinterViewModel? _selectedPrinter;
  bool _isLoadingPrinterItems = false;
  String? _lastPrinterItemsError;
  final List<PrintingTableItem> _printerItems = [];
  PaginationData? _printerItemsPagination;

  // Tracing studios state
  bool _isLoadingTracingStudios = false;
  String? _lastTracingStudiosError;
  final List<TracingStudioViewModel> _tracingStudios = [];
  TracingStudioViewModel? _selectedTracingStudio;
  bool _isLoadingTracingItems = false;
  String? _lastTracingItemsError;
  final List<TracingTableItem> _tracingItems = [];
  PaginationData? _tracingItemsPagination;

  // Box makers state
  bool _isLoadingBoxMakers = false;
  String? _lastBoxMakersError;
  final List<BoxMakerViewModel> _boxMakers = [];
  BoxMakerViewModel? _selectedBoxMaker;
  bool _isLoadingBoxOrderItems = false;
  String? _lastBoxOrderItemsError;
  final List<BoxOrderTableItem> _boxOrderItems = [];
  PaginationData? _boxOrderItemsPagination;

  // Getters
  bool get isLoadingPrinters => _isLoadingPrinters;
  String? get lastPrintersError => _lastPrintersError;
  List<PrinterViewModel> get printers => List.unmodifiable(_printers);
  PrinterViewModel? get selectedPrinter => _selectedPrinter;
  bool get isLoadingPrinterItems => _isLoadingPrinterItems;
  String? get lastPrinterItemsError => _lastPrinterItemsError;
  List<PrintingTableItem> get printerItems => List.unmodifiable(_printerItems);
  PaginationData? get printerItemsPagination => _printerItemsPagination;

  bool get isLoadingTracingStudios => _isLoadingTracingStudios;
  String? get lastTracingStudiosError => _lastTracingStudiosError;
  List<TracingStudioViewModel> get tracingStudios => List.unmodifiable(_tracingStudios);
  TracingStudioViewModel? get selectedTracingStudio => _selectedTracingStudio;
  bool get isLoadingTracingItems => _isLoadingTracingItems;
  String? get lastTracingItemsError => _lastTracingItemsError;
  List<TracingTableItem> get tracingItems => List.unmodifiable(_tracingItems);
  PaginationData? get tracingItemsPagination => _tracingItemsPagination;

  bool get isLoadingBoxMakers => _isLoadingBoxMakers;
  String? get lastBoxMakersError => _lastBoxMakersError;
  List<BoxMakerViewModel> get boxMakers => List.unmodifiable(_boxMakers);
  BoxMakerViewModel? get selectedBoxMaker => _selectedBoxMaker;
  bool get isLoadingBoxOrderItems => _isLoadingBoxOrderItems;
  String? get lastBoxOrderItemsError => _lastBoxOrderItemsError;
  List<BoxOrderTableItem> get boxOrderItems => List.unmodifiable(_boxOrderItems);
  PaginationData? get boxOrderItemsPagination => _boxOrderItemsPagination;

  // Actions
  Future<void> fetchPrinters({int page = 1, int pageSize = 50}) async {
    _isLoadingPrinters = true;
    _lastPrintersError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _service.getPrinters(page: page, pageSize: pageSize),
      onSuccess: (response) {
        final list = PrinterViewModel.fromResponseList(response.data ?? []);
        _printers
          ..clear()
          ..addAll({for (final p in list) p.id: p}.values); // de-duplicate by id
        notifyListeners();
        return response.data;
      },
      showLoading: false,
      showSnackbar: false,
      errorMessage: 'Failed to load printers',
    );

    _isLoadingPrinters = false;
    notifyListeners();
  }

  // Reset all production state to initial (used when entering the page)
  void resetProduction() {
    _isLoadingPrinters = false;
    _lastPrintersError = null;
    _printers.clear();
    _selectedPrinter = null;
    _isLoadingPrinterItems = false;
    _lastPrinterItemsError = null;
    _printerItems.clear();
    _printerItemsPagination = null;

    _isLoadingTracingStudios = false;
    _lastTracingStudiosError = null;
    _tracingStudios.clear();
    _selectedTracingStudio = null;
    _isLoadingTracingItems = false;
    _lastTracingItemsError = null;
    _tracingItems.clear();
    _tracingItemsPagination = null;

    _isLoadingBoxMakers = false;
    _lastBoxMakersError = null;
    _boxMakers.clear();
    _selectedBoxMaker = null;
    _isLoadingBoxOrderItems = false;
    _lastBoxOrderItemsError = null;
    _boxOrderItems.clear();
    _boxOrderItemsPagination = null;

    notifyListeners();
  }

  // Refresh helpers for pull-to-refresh on tabs
  Future<void> refreshPrintersTab() async {
    await fetchPrinters(page: 1, pageSize: 50);
    if (_selectedPrinter != null) {
      await fetchPrinterItems(page: 1);
    }
  }

  Future<void> refreshTracingTab() async {
    await fetchTracingStudios(page: 1, pageSize: 50);
    if (_selectedTracingStudio != null) {
      await fetchTracingItems(page: 1);
    }
  }

  Future<void> refreshBoxMakersTab() async {
    await fetchBoxMakers(page: 1, pageSize: 50);
    if (_selectedBoxMaker != null) {
      await fetchBoxOrderItems(page: 1);
    }
  }

  void setSelectedPrinter(PrinterViewModel? printer) {
    _selectedPrinter = printer;
    _printerItems.clear();
    _lastPrinterItemsError = null;
    notifyListeners();
  }

  Future<void> fetchPrinterItems({int page = 1, int pageSize = 10}) async {
    if (_selectedPrinter == null) return;
    _isLoadingPrinterItems = true;
    _lastPrinterItemsError = null;
    _printerItems.clear();
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _service.getPrintingItemsByPrinter(printerId: _selectedPrinter!.id, page: page, pageSize: pageSize),
      onSuccess: (response) {
        _printerItems
          ..clear()
          ..addAll(response.data ?? []);
        _printerItemsPagination = response.pagination;
        notifyListeners();
        return response.data;
      },
      showLoading: false,
      showSnackbar: false,
      errorMessage: 'Failed to load printer items',
    );

    _isLoadingPrinterItems = false;
    notifyListeners();
  }

  Future<void> fetchTracingStudios({int page = 1, int pageSize = 50}) async {
    _isLoadingTracingStudios = true;
    _lastTracingStudiosError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _service.getTracingStudios(page: page, pageSize: pageSize),
      onSuccess: (response) {
        final list = TracingStudioViewModel.fromResponseList(response.data ?? []);
        _tracingStudios
          ..clear()
          ..addAll({for (final t in list) t.id: t}.values);
        notifyListeners();
        return response.data;
      },
      showLoading: false,
      showSnackbar: false,
      errorMessage: 'Failed to load tracing studios',
    );

    _isLoadingTracingStudios = false;
    notifyListeners();
  }

  void setSelectedTracingStudio(TracingStudioViewModel? studio) {
    _selectedTracingStudio = studio;
    _tracingItems.clear();
    _lastTracingItemsError = null;
    notifyListeners();
  }

  Future<void> fetchTracingItems({int page = 1, int pageSize = 10}) async {
    if (_selectedTracingStudio == null) return;
    _isLoadingTracingItems = true;
    _lastTracingItemsError = null;
    _tracingItems.clear();
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _service.getTracingItemsByStudio(tracingStudioId: _selectedTracingStudio!.id, page: page, pageSize: pageSize),
      onSuccess: (response) {
        _tracingItems
          ..clear()
          ..addAll(response.data ?? []);
        _tracingItemsPagination = response.pagination;
        notifyListeners();
        return response.data;
      },
      showLoading: false,
      showSnackbar: false,
      errorMessage: 'Failed to load tracing items',
    );

    _isLoadingTracingItems = false;
    notifyListeners();
  }

  Future<void> fetchBoxMakers({int page = 1, int pageSize = 50}) async {
    _isLoadingBoxMakers = true;
    _lastBoxMakersError = null;
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _service.getBoxMakers(page: page, pageSize: pageSize),
      onSuccess: (response) {
        final list = BoxMakerViewModel.fromResponseList(response.data ?? []);
        _boxMakers
          ..clear()
          ..addAll({for (final b in list) b.id: b}.values);
        notifyListeners();
        return response.data;
      },
      showLoading: false,
      showSnackbar: false,
      errorMessage: 'Failed to load box makers',
    );

    _isLoadingBoxMakers = false;
    notifyListeners();
  }

  void setSelectedBoxMaker(BoxMakerViewModel? maker) {
    _selectedBoxMaker = maker;
    _boxOrderItems.clear();
    _lastBoxOrderItemsError = null;
    notifyListeners();
  }

  Future<void> fetchBoxOrderItems({int page = 1, int pageSize = 10}) async {
    if (_selectedBoxMaker == null) return;
    _isLoadingBoxOrderItems = true;
    _lastBoxOrderItemsError = null;
    _boxOrderItems.clear();
    notifyListeners();

    await executeApiOperation(
      apiCall: () => _service.getBoxOrdersByBoxMaker(boxMakerId: _selectedBoxMaker!.id, page: page, pageSize: pageSize),
      onSuccess: (response) {
        _boxOrderItems
          ..clear()
          ..addAll(response.data ?? []);
        _boxOrderItemsPagination = response.pagination;
        notifyListeners();
        return response.data;
      },
      showLoading: false,
      showSnackbar: false,
      errorMessage: 'Failed to load box orders',
    );

    _isLoadingBoxOrderItems = false;
    notifyListeners();
  }

  // Pagination helpers
  Future<void> loadNextPrinterItemsPage() async {
    if (_printerItemsPagination?.hasNext == true) {
      await fetchPrinterItems(page: (_printerItemsPagination?.currentPage ?? 1) + 1);
    }
  }

  Future<void> loadPrevPrinterItemsPage() async {
    if (_printerItemsPagination?.hasPrevious == true) {
      await fetchPrinterItems(page: (_printerItemsPagination?.currentPage ?? 1) - 1);
    }
  }

  Future<void> loadNextTracingItemsPage() async {
    if (_tracingItemsPagination?.hasNext == true) {
      await fetchTracingItems(page: (_tracingItemsPagination?.currentPage ?? 1) + 1);
    }
  }

  Future<void> loadPrevTracingItemsPage() async {
    if (_tracingItemsPagination?.hasPrevious == true) {
      await fetchTracingItems(page: (_tracingItemsPagination?.currentPage ?? 1) - 1);
    }
  }

  Future<void> loadNextBoxOrderItemsPage() async {
    if (_boxOrderItemsPagination?.hasNext == true) {
      await fetchBoxOrderItems(page: (_boxOrderItemsPagination?.currentPage ?? 1) + 1);
    }
  }

  Future<void> loadPrevBoxOrderItemsPage() async {
    if (_boxOrderItemsPagination?.hasPrevious == true) {
      await fetchBoxOrderItems(page: (_boxOrderItemsPagination?.currentPage ?? 1) - 1);
    }
  }

  // Toggle actions
  Future<void> togglePrinterPaid(String printingJobId, bool newValue) async {
    await executeApiOperation(
      apiCall: () => _service.togglePrinterPaid(printingJobId: printingJobId, paid: newValue),
      onSuccess: (response) {
        final index = _printerItems.indexWhere((e) => e.printingJobId == printingJobId);
        if (index != -1) {
          _printerItems[index] = _printerItems[index].copyWith(printerPaid: newValue);
          notifyListeners();
        }
        return response.data;
      },
      showLoading: false,
      showSnackbar: true,
      successMessage: 'Printer paid status updated',
      errorMessage: 'Failed to update printer paid status',
    );
  }

  Future<void> toggleTracingPaid(String printingJobId, bool newValue) async {
    await executeApiOperation(
      apiCall: () => _service.toggleTracingPaid(printingJobId: printingJobId, paid: newValue),
      onSuccess: (response) {
        final index = _tracingItems.indexWhere((e) => e.printingJobId == printingJobId);
        if (index != -1) {
          _tracingItems[index] = _tracingItems[index].copyWith(tracingStudioPaid: newValue);
          notifyListeners();
        }
        return response.data;
      },
      showLoading: false,
      showSnackbar: true,
      successMessage: 'Tracing paid status updated',
      errorMessage: 'Failed to update tracing paid status',
    );
  }

  Future<void> toggleBoxMakerPaid(String boxOrderId, bool newValue) async {
    await executeApiOperation(
      apiCall: () => _service.toggleBoxMakerPaid(boxOrderId: boxOrderId, paid: newValue),
      onSuccess: (response) {
        final index = _boxOrderItems.indexWhere((e) => e.boxOrderId == boxOrderId);
        if (index != -1) {
          _boxOrderItems[index] = _boxOrderItems[index].copyWith(boxMakerPaid: newValue);
          notifyListeners();
        }
        return response.data;
      },
      showLoading: false,
      showSnackbar: true,
      successMessage: 'Box order paid status updated',
      errorMessage: 'Failed to update box order paid status',
    );
  }
}
