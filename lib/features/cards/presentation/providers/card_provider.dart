import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';

import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/cards/presentation/models/card_form_models.dart';
import 'package:vsc_app/features/cards/presentation/validators/card_validators.dart';
import 'package:vsc_app/features/cards/domain/services/card_mapper_service.dart';
import 'package:vsc_app/features/cards/domain/models/card.dart';

/// Provider for managing card state and operations
class CardProvider extends BaseProvider with AutoSnackBarMixin {
  final CardService _cardService = CardService();

  // State
  List<CardViewModel> _cards = [];
  List<CardViewModel> _similarCards = [];
  CardFormViewModel _formModel = CardFormViewModel.empty();
  CardViewModel? _selectedCard;
  bool _isSearchingSimilar = false;

  // Getters
  List<CardViewModel> get cards => _cards;
  List<CardViewModel> get similarCards => _similarCards;
  CardFormViewModel get formModel => _formModel;
  CardViewModel? get selectedCard => _selectedCard;
  bool get isSearchingSimilar => _isSearchingSimilar;

  /// Get selected image URL (for backward compatibility)
  String? get selectedImageUrl => _formModel.image?.path;

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

  /// Get similar cards (for backward compatibility)
  List<CardViewModel> getSimilarCards() {
    return _similarCards;
  }

  /// Load cards with pagination (for backward compatibility)
  Future<void> loadCards({int page = 1, int pageSize = 10}) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _cardService.getCards(page: page, pageSize: pageSize);

      if (response.success && response.data != null) {
        if (page == 1) {
          _cards.clear();
        }
        _cards.addAll(response.data!.map((apiModel) => CardViewModel.fromDomainModel(CardMapperService.fromApiResponse(apiModel))));
        notifyListeners();
      } else {
        setError(response.error?.message ?? 'Failed to load cards');
      }
    } catch (e) {
      setError('Failed to load cards: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Get card by ID (for backward compatibility)
  Future<CardViewModel?> getCardById(String id) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _cardService.getCardById(id);

      if (response.success && response.data != null) {
        final cardViewModel = CardViewModel.fromDomainModel(CardMapperService.fromApiResponse(response.data!));
        notifyListeners();
        return cardViewModel;
      } else {
        setError(response.error?.message ?? 'Card not found');
        return null;
      }
    } catch (e) {
      setError('Failed to load card: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Get filtered cards (for backward compatibility)
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

  /// Load more cards (for backward compatibility)
  Future<void> loadMoreCards() async {
    // For now, just reload the first page
    await loadCards(page: 1);
  }

  /// Search for similar cards using image upload
  Future<void> searchSimilarCards(XFile imageFile) async {
    try {
      setLoading(true);
      _isSearchingSimilar = true;
      _similarCards.clear();
      notifyListeners();

      AppLogger.service('CardProvider', 'Searching for similar cards');

      final response = await _cardService.searchSimilarCards(imageFile);

      if (response.success && response.data != null) {
        _similarCards = response.data!.map((apiModel) {
          AppLogger.debug('CardProvider: Processing apiModel type: ${apiModel.runtimeType}');
          return CardViewModel.fromDomainModel(CardMapperService.fromApiResponse(apiModel));
        }).toList();

        setSuccess('Found ${_similarCards.length} similar cards');
        AppLogger.service('CardProvider', 'Found ${_similarCards.length} similar cards');
      } else {
        setError(response.error?.message ?? 'Failed to search similar cards');
        AppLogger.error('Similar search failed: ${response.error?.message}', category: 'CardProvider');
      }
    } catch (e) {
      setError('Failed to search similar cards: $e');
      AppLogger.error('Similar search exception: $e', category: 'CardProvider');
    } finally {
      setLoading(false);
      _isSearchingSimilar = false;
      notifyListeners();
    }
  }

  /// Create a new card
  Future<void> createCard() async {
    try {
      setLoading(true);

      AppLogger.service('CardProvider', 'Creating new card');

      // Validate form using presentation validators
      final validationResult = CardValidators.validateCardForm(
        costPrice: _formModel.costPrice,
        sellPrice: _formModel.sellPrice,
        quantity: _formModel.quantity,
        maxDiscount: _formModel.maxDiscount,
        vendorId: _formModel.vendorId,
        image: _formModel.image,
      );
      if (!validationResult.isValid) {
        setError(validationResult.firstMessage ?? 'Invalid form data');
        return;
      }

      if (_formModel.image == null) {
        setError('Image is required');
        return;
      }

      // Convert form model to domain model, then to API request
      final domainModel = CardMapperService.fromFormModel(_formModel);
      final apiRequest = CardMapperService.toCreateCardRequest(domainModel);

      final response = await _cardService.createCard(imageFile: _formModel.image!, request: apiRequest);

      if (response.success) {
        setSuccess('Card created successfully');
        _formModel = CardFormViewModel.empty();
      } else {
        setError(response.error?.message ?? 'Failed to create card');
      }
    } catch (e) {
      setError('Failed to create card: $e');
      AppLogger.error('Card creation exception: $e', category: 'CardProvider');
    } finally {
      setLoading(false);
      notifyListeners();
    }
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

  /// Select a card from similar results
  void selectCard(CardViewModel card) {
    _selectedCard = card;
    notifyListeners();
  }

  /// Select a similar card
  void selectSimilarCard(CardViewModel card) {
    _selectedCard = card;
    notifyListeners();
  }

  /// Clear selected card
  void clearSelectedCard() {
    _selectedCard = null;
    notifyListeners();
  }

  /// Clear similar cards
  void clearSimilarCards() {
    _similarCards.clear();
    notifyListeners();
  }

  /// Reset form
  void resetForm() {
    _formModel = CardFormViewModel.empty();
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

  /// Check if similar search is in progress
  bool get isSearching => _isSearchingSimilar;

  /// Check if any similar cards found
  bool get hasSimilarCards => _similarCards.isNotEmpty;

  /// Check if a card is selected
  bool get hasSelectedCard => _selectedCard != null;

  /// Check if has more data (for backward compatibility)
  bool get hasMoreData => false; // Simplified for now
}
