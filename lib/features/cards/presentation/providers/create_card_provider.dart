import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/utils/app_logger.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/cards/presentation/models/card_form_models.dart';
import 'package:vsc_app/features/cards/presentation/services/card_validators.dart';

/// Provider for managing card creation and similar cards functionality
class CreateCardProvider extends BaseProvider {
  final CardService _cardService = CardService();

  // Similar cards state
  List<SimilarCardViewModel> _similarCards = [];
  bool _isSearchingSimilar = false;

  // Form state
  CardFormViewModel _formModel = CardFormViewModel.empty();

  // Getters for similar cards
  List<SimilarCardViewModel> get similarCards => List.unmodifiable(_similarCards);
  bool get isSearchingSimilar => _isSearchingSimilar;

  // Getters for form data
  CardFormViewModel get formModel => _formModel;

  // Getters for backward compatibility
  String? get selectedImageUrl => _formModel.image?.path;

  /// Search for similar cards using image upload
  Future<void> searchSimilarCards(XFile imageFile) async {
    _isSearchingSimilar = true;
    _similarCards.clear();
    notifyListeners();

    AppLogger.service('CreateCardProvider', 'Searching for similar cards');

    await executeApiOperation(
      apiCall: () => _cardService.searchSimilarCards(imageFile),
      onSuccess: (response) {
        // Use direct conversion from API response to ViewModel
        // Note: API returns CardResponse but we treat them as similar cards
        _similarCards = (response.data ?? []).map((cardResponse) {
          AppLogger.debug('CreateCardProvider: Processing cardResponse type: ${cardResponse.runtimeType}');
          // Convert CardResponse to SimilarCardViewModel with default similarity
          return SimilarCardViewModel.fromApiResponse(cardResponse);
        }).toList();

        setSuccess('Found ${_similarCards.length} similar cards');
        AppLogger.service('CreateCardProvider', 'Found ${_similarCards.length} similar cards');
      },
      showSnackbar: false,
      errorMessage: 'Failed to search similar cards',
    );

    _isSearchingSimilar = false;
    notifyListeners();
  }

  /// Create a new card
  Future<String?> createCard() async {
    AppLogger.service('CreateCardProvider', 'Creating new card');

    // Validate form using the form model's validate method
    final validationResult = _formModel.validate();
    if (!validationResult.isValid) {
      return null;
    }

    return await executeApiOperation(
      apiCall: () => _cardService.createCard(imageFile: _formModel.image!, request: _formModel.toApiRequest()),
      onSuccess: (response) {
        final createCardResponse = response.data!;
        setSuccess('Card created successfully');

        // Return the barcode for navigation
        return createCardResponse.barcode;
      },
      errorMessage: 'Failed to create card',
    );
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
    _formModel = _formModel.copyWith(image: null);
    notifyListeners();
  }

  /// Upload image (for backward compatibility)
  Future<void> uploadImage(XFile imageFile) async {
    _formModel = _formModel.copyWith(image: imageFile);
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

  /// Reset the provider state
  @override
  void reset() {
    _similarCards.clear();
    _isSearchingSimilar = false;
    _formModel = CardFormViewModel.empty();
    super.reset();
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
  bool get isFormValid => _formModel.validate().isValid;

  /// Check if any similar cards found
  bool get hasSimilarCards => _similarCards.isNotEmpty;

  /// Get similar cards (for backward compatibility)
  List<SimilarCardViewModel> getSimilarCards() {
    return _similarCards;
  }
}
