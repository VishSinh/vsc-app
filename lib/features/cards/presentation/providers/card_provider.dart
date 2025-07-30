import 'package:vsc_app/core/models/card_model.dart' as card_model;
import 'package:vsc_app/core/services/card_service.dart';
import 'package:vsc_app/core/providers/base_provider.dart';

class CardProvider extends BaseProvider with PaginationMixin {
  final CardService _cardService = CardService();
  final List<card_model.Card> _cards = [];
  String? _errorMessage;
  String? _selectedImageUrl;

  // Getters
  List<card_model.Card> get cards => _cards;
  @override
  String? get errorMessage => _errorMessage;
  String? get selectedImageUrl => _selectedImageUrl;

  /// Load cards with pagination
  Future<void> loadCards({int page = 1, int pageSize = 10}) async {
    try {
      setLoading(true);
      _errorMessage = null;

      print('🔍 CardProvider: Loading cards page $page, pageSize $pageSize');
      print('🔍 CardProvider: Current cards count before loading: ${_cards.length}');

      final response = await _cardService.getCards(page: page, pageSize: pageSize);

      if (response.success && response.data != null) {
        print('🔍 CardProvider: Received ${response.data!.length} cards from API');

        if (page == 1) {
          // First page - replace all cards
          _cards.clear();
          _cards.addAll(response.data!);
          print('🔍 CardProvider: Cleared and added ${response.data!.length} cards (page 1)');
        } else {
          // Subsequent pages - append cards
          _cards.addAll(response.data!);
          print('🔍 CardProvider: Added ${response.data!.length} cards to existing ${_cards.length - response.data!.length} cards (page $page)');
        }

        print('🔍 CardProvider: Total cards after loading: ${_cards.length}');

        // Update pagination data
        if (response.pagination != null) {
          print(
            '🔍 CardProvider: Pagination data - hasNext: ${response.pagination!.hasNext}, currentPage: ${response.pagination!.currentPage}, totalPages: ${response.pagination!.totalPages}',
          );
          setHasMoreData(response.pagination!.hasNext);
          if (page == 1) {
            resetPagination();
          } else {
            incrementPage();
          }
        }

        notifyListeners();
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to load cards';
        // If we get an error on page > 1, it means there are no more pages
        if (page > 1) {
          print('🔍 CardProvider: Error on page $page, setting hasMoreData to false');
          setHasMoreData(false);
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load cards: $e';
      // If we get an error on page > 1, it means there are no more pages
      if (page > 1) {
        print('🔍 CardProvider: Exception on page $page, setting hasMoreData to false');
        setHasMoreData(false);
      }
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  /// Load more cards (for infinite scroll)
  Future<void> loadMoreCards() async {
    if (hasMoreData && !isLoading) {
      print('🔍 CardProvider: loadMoreCards called - hasMoreData: $hasMoreData, isLoading: $isLoading, currentPage: $currentPage');
      await loadCards(page: currentPage + 1);
    } else {
      print('🔍 CardProvider: loadMoreCards skipped - hasMoreData: $hasMoreData, isLoading: $isLoading');
    }
  }

  /// Refresh cards (reload first page)
  Future<void> refreshCards() async {
    await loadCards(page: 1);
  }

  /// Get card by ID
  Future<card_model.Card?> getCardById(String id) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _cardService.getCardById(id);

      if (response.success && response.data != null) {
        notifyListeners();
        return response.data;
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to load card';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load card: $e';
      notifyListeners();
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Upload image (placeholder for future implementation)
  Future<void> uploadImage(dynamic imageFile) async {
    try {
      setLoading(true);
      // TODO: Implement actual image upload
      await Future.delayed(const Duration(seconds: 2)); // Simulate upload
      _selectedImageUrl = 'https://t4.ftcdn.net/jpg/05/08/65/87/360_F_508658796_Np78KNMINjP6CemujX79bJsOWOTRbNCW.jpg';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to upload image: $e';
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  /// Create a new card
  Future<bool> createCard({
    required String image,
    required double costPrice,
    required double sellPrice,
    required int quantity,
    required double maxDiscount,
    required String vendorId,
  }) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _cardService.createCard(
        image: image,
        costPrice: costPrice,
        sellPrice: sellPrice,
        quantity: quantity,
        maxDiscount: maxDiscount,
        vendorId: vendorId,
      );

      if (response.success) {
        // Refresh cards after successful creation
        await refreshCards();
        return true;
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to create card';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create card: $e';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Get filtered cards based on search query
  List<card_model.Card> getFilteredCards(String query) {
    print('🔍 CardProvider: getFilteredCards called with query: "$query"');
    print('🔍 CardProvider: Total cards in _cards: ${_cards.length}');

    if (query.isEmpty) {
      print('🔍 CardProvider: Query is empty, returning all ${_cards.length} cards');
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

    print('🔍 CardProvider: Filtered cards count: ${filteredCards.length}');
    return filteredCards;
  }

  /// Clear all data
  void clearData() {
    _cards.clear();
    _errorMessage = null;
    resetPagination();
    notifyListeners();
  }

  /// Clear image (for form reset)
  void clearImage() {
    _selectedImageUrl = null;
    notifyListeners();
  }

  /// Get similar cards based on image URL
  Future<List<card_model.Card>> getSimilarCards(String imageUrl) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _cardService.getSimilarCards(imageUrl);

      if (response.success && response.data != null) {
        notifyListeners();
        return response.data!;
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to get similar cards';
        notifyListeners();
        return [];
      }
    } catch (e) {
      _errorMessage = 'Failed to get similar cards: $e';
      notifyListeners();
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// Purchase card stock
  Future<bool> purchaseCardStock(String cardId, int quantity) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final response = await _cardService.purchaseCardStock(cardId, quantity);

      if (response.success) {
        // Refresh cards after successful purchase
        await refreshCards();
        return true;
      } else {
        _errorMessage = response.error?.details ?? response.error?.message ?? 'Failed to purchase card stock';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to purchase card stock: $e';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }
}
