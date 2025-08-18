import 'package:vsc_app/core/models/pagination_data.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';

import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

/// Provider for managing card listing, pagination, filtering, and search functionality
class CardListProvider extends BaseProvider {
  final CardService _cardService = CardService();

  // Card listing and management
  final List<CardViewModel> _cards = [];
  PaginationData? _pagination;

  // UI state
  String _searchQuery = '';
  bool _isPageLoading = false;
  bool _showCardsList = false;
  int _selectedIndex = 0;

  // Getters for fetched data
  List<CardViewModel> get cards => List.unmodifiable(_cards);
  PaginationData? get pagination => _pagination;

  // Getters for UI state
  String get searchQuery => _searchQuery;
  bool get isPageLoading => _isPageLoading;
  bool get showCardsList => _showCardsList;
  int get selectedIndex => _selectedIndex;

  /// Load cards with pagination
  Future<void> loadCards({int page = 1, int pageSize = 10}) async {
    await executeApiOperation(
      apiCall: () => _cardService.getCards(page: page, pageSize: pageSize),
      onSuccess: (response) {
        if (page == 1) {
          _cards.clear();
        }
        // Use direct conversion from API response to ViewModel
        final cardViewModels = (response.data ?? []).map((cardResponse) => CardViewModel.fromApiResponse(cardResponse)).toList();
        _cards.addAll(cardViewModels);
        _pagination = response.pagination;
        notifyListeners();
      },
      showSnackbar: false,
      errorMessage: 'Failed to load cards',
    );
  }

  Future<void> loadNextPage() async {
    if (_pagination?.hasNext == true) {
      await loadCards(page: (_pagination?.currentPage ?? 1) + 1);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_pagination?.hasPrevious == true) {
      await loadCards(page: (_pagination?.currentPage ?? 1) - 1);
    }
  }

  bool get hasMoreCards {
    return _pagination?.hasNext ?? false;
  }

  /// Get filtered cards
  List<CardViewModel> getFilteredCards(String query) {
    if (query.isEmpty) {
      return _cards;
    }

    final filteredCards = _cards.where((card) {
      final searchLower = query.toLowerCase();
      return card.barcode.toLowerCase().contains(searchLower) ||
          card.vendorId.toLowerCase().contains(searchLower) ||
          card.sellPrice.toLowerCase().contains(searchLower) ||
          card.costPrice.toLowerCase().contains(searchLower) ||
          card.quantity.toString().contains(searchLower) ||
          card.maxDiscount.toLowerCase().contains(searchLower);
    }).toList();

    return filteredCards;
  }

  /// Clear cards list
  void clearCards() {
    _cards.clear();
    notifyListeners();
  }

  /// Reset the provider state
  @override
  void reset() {
    _cards.clear();
    _pagination = null;
    _searchQuery = '';
    _isPageLoading = false;
    _showCardsList = false;
    _selectedIndex = 0;
    super.reset();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set page loading state
  void setPageLoading(bool loading) {
    _isPageLoading = loading;
    notifyListeners();
  }

  /// Set show cards list state
  void setShowCardsList(bool show) {
    _showCardsList = show;
    notifyListeners();
  }

  /// Set selected index
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
