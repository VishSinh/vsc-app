import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';

import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/cards/presentation/models/card_form_models.dart';
import 'package:vsc_app/features/cards/presentation/services/card_validators.dart';

/// Provider for managing card state and operations
class CardProvider extends BaseProvider {
  final CardService _cardService = CardService();

  // Card listing and management
  final List<CardViewModel> _cards = [];
  PaginationData? _pagination;
  CardViewModel? _currentCard;

  // Similar cards state
  List<SimilarCardViewModel> _similarCards = [];
  bool _isSearchingSimilar = false;

  // Form state
  CardFormViewModel _formModel = CardFormViewModel.empty();

  // UI state
  String _searchQuery = '';
  bool _isPageLoading = false;
  bool _showCardsList = false;
  int _selectedIndex = 0;

  // Getters for fetched data
  List<CardViewModel> get cards => List.unmodifiable(_cards);
  PaginationData? get pagination => _pagination;
  CardViewModel? get currentCard => _currentCard;
  List<SimilarCardViewModel> get similarCards => List.unmodifiable(_similarCards);

  // Getters for form data
  CardFormViewModel get formModel => _formModel;

  // Getters for UI state
  String get searchQuery => _searchQuery;
  bool get isPageLoading => _isPageLoading;
  bool get isSearchingSimilar => _isSearchingSimilar;
  bool get showCardsList => _showCardsList;
  int get selectedIndex => _selectedIndex;

  // Getters for backward compatibility
  String? get selectedImageUrl => _formModel.image?.path;

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

  /// Get card by ID
  Future<void> getCardById(String id) async {
    await executeApiOperation(
      apiCall: () => _cardService.getCardById(id),
      onSuccess: (response) {
        _currentCard = CardViewModel.fromApiResponse(response.data!);
        return response.data!;
      },
      showSnackbar: false,
      errorMessage: 'Card not found',
    );
  }

  /// Search for similar cards using image upload
  Future<void> searchSimilarCards(XFile imageFile) async {
    _isSearchingSimilar = true;
    _similarCards.clear();
    notifyListeners();

    AppLogger.service('CardProvider', 'Searching for similar cards');

    await executeApiOperation(
      apiCall: () => _cardService.searchSimilarCards(imageFile),
      onSuccess: (response) {
        // Use direct conversion from API response to ViewModel
        // Note: API returns CardResponse but we treat them as similar cards
        _similarCards = (response.data ?? []).map((cardResponse) {
          AppLogger.debug('CardProvider: Processing cardResponse type: ${cardResponse.runtimeType}');
          // Convert CardResponse to SimilarCardViewModel with default similarity
          return SimilarCardViewModel.fromApiResponse(cardResponse);
        }).toList();

        setSuccess('Found ${_similarCards.length} similar cards');
        AppLogger.service('CardProvider', 'Found ${_similarCards.length} similar cards');
      },
      showSnackbar: false,
      errorMessage: 'Failed to search similar cards',
    );

    _isSearchingSimilar = false;
    notifyListeners();
  }

  /// Create a new card
  Future<void> createCard() async {
    AppLogger.service('CardProvider', 'Creating new card');

    // Validate form using the form model's validate method
    final validationResult = _formModel.validate();
    if (!validationResult.isValid) {
      return;
    }

    await executeApiOperation(
      apiCall: () => _cardService.createCard(imageFile: _formModel.image!, request: _formModel.toApiRequest()),
      onSuccess: (response) {
        setSuccess('Card created successfully');
        reset();
        return response.data!;
      },
      errorMessage: 'Failed to create card',
    );
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

  /// Update form model
  void updateFormModel(CardFormViewModel newFormModel) {
    _formModel = newFormModel;
    notifyListeners();
  }

  /// Update form field
  void updateFormField({String? costPrice, String? sellPrice, String? quantity, String? maxDiscount, String? vendorId, XFile? image}) {
    _formModel = _formModel.copyWith(
      costPrice: costPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      maxDiscount: maxDiscount,
      vendorId: vendorId,
      image: image,
    );
    notifyListeners();
  }

  /// Clear selected image (for backward compatibility)
  void clearImage() {
    // Create a new form model without the image
    _formModel = CardFormViewModel.fromFormData(
      costPrice: _formModel.costPrice,
      sellPrice: _formModel.sellPrice,
      quantity: _formModel.quantity,
      maxDiscount: _formModel.maxDiscount,
      vendorId: _formModel.vendorId,
      image: null,
    );
    notifyListeners();
  }

  /// Upload image (for backward compatibility)
  Future<void> uploadImage(XFile imageFile) async {
    _formModel = _formModel.copyWith(image: imageFile);
    notifyListeners();
  }

  /// Select a card from similar results
  void selectCard(CardViewModel card) {
    _currentCard = card;
    notifyListeners();
  }

  /// Select a similar card
  void selectSimilarCard(SimilarCardViewModel card) {
    // Convert SimilarCardViewModel to CardViewModel for selection
    _currentCard = CardViewModel(
      id: card.id,
      vendorId: card.vendorId,
      barcode: card.barcode,
      sellPrice: card.sellPrice,
      costPrice: card.costPrice,
      maxDiscount: card.maxDiscount,
      quantity: card.quantity,
      image: card.image,
      perceptualHash: card.perceptualHash,
      isActive: card.isActive,
      sellPriceAsDouble: card.sellPriceAsDouble,
      costPriceAsDouble: card.costPriceAsDouble,
      maxDiscountAsDouble: card.maxDiscountAsDouble,
      profitMargin: card.profitMargin,
      totalValue: card.totalValue,
    );
    notifyListeners();
  }

  /// Clear selected card
  void clearCurrentCard() {
    _currentCard = null;
    notifyListeners();
  }

  /// Clear similar cards
  void clearSimilarCards() {
    _similarCards.clear();
    notifyListeners();
  }

  /// Clear cards list
  void clearCards() {
    _cards.clear();
    notifyListeners();
  }

  /// Reset form
  void resetForm() {
    _formModel = CardFormViewModel.empty();
    notifyListeners();
  }

  /// Reset the provider state
  @override
  void reset() {
    _cards.clear();
    _pagination = null;
    _currentCard = null;
    _similarCards.clear();
    _isSearchingSimilar = false;
    _formModel = CardFormViewModel.empty();
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

  /// Validate form field
  String? validateField(String fieldName, String value) {
    switch (fieldName) {
      case 'costPrice':
        final result = CardValidators.validateCostPrice(value);
        return result.isValid ? null : result.firstMessage;
      case 'sellPrice':
        final result = CardValidators.validateSellPrice(value);
        return result.isValid ? null : result.firstMessage;
      case 'quantity':
        final result = CardValidators.validateQuantity(value);
        return result.isValid ? null : result.firstMessage;
      case 'maxDiscount':
        final result = CardValidators.validateMaxDiscount(value);
        return result.isValid ? null : result.firstMessage;
      case 'vendorId':
        final result = CardValidators.validateVendorId(value);
        return result.isValid ? null : result.firstMessage;
      default:
        return null;
    }
  }

  /// Validate image
  String? validateImage(File? image) {
    final result = CardValidators.validateImage(image);
    return result.isValid ? null : result.firstMessage;
  }

  /// Check if form is valid
  bool get isFormValid => _formModel.isValid;

  /// Check if any similar cards found
  bool get hasSimilarCards => _similarCards.isNotEmpty;

  /// Check if a card is selected
  bool get hasSelectedCard => _currentCard != null;

  /// Get similar cards (for backward compatibility)
  List<SimilarCardViewModel> getSimilarCards() {
    return _similarCards;
  }
}
