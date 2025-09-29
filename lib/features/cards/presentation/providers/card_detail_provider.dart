import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/event_bus_service.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
import 'package:vsc_app/features/cards/presentation/models/card_update_form_model.dart';
import 'package:vsc_app/features/cards/presentation/models/card_detail_view_model.dart';
import 'package:vsc_app/core/utils/app_logger.dart';

/// Provider for managing card details, barcode generation, and edit/delete operations
class CardDetailProvider extends BaseProvider {
  final CardService _cardService = CardService();
  final EventBusService _eventBus = EventBusService();

  // Card detail state
  CardViewModel? _currentCard;
  CardDetailViewModel? _cardDetail;

  // Getters for fetched data
  CardViewModel? get currentCard => _currentCard;
  CardDetailViewModel? get cardDetail => _cardDetail;

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

  /// Get card sales/detail analytics by ID
  Future<void> getCardDetail(String id) async {
    await executeApiOperation(
      apiCall: () => _cardService.getCardDetail(id),
      onSuccess: (response) {
        _cardDetail = CardDetailViewModel.fromApiResponse(response.data!);
        return response.data!;
      },
      showSnackbar: false,
      errorMessage: 'Failed to load card details',
    );
  }

  /// Get card by barcode
  Future<void> getCardByBarcode(String barcode) async {
    await executeApiOperation(
      apiCall: () => _cardService.getCardByBarcode(barcode),
      onSuccess: (response) {
        _currentCard = CardViewModel.fromApiResponse(response.data!);
        return response.data!;
      },
      showSnackbar: false,
      errorMessage: 'Card not found',
    );
  }

  /// Purchase card stock
  Future<void> purchaseCardStock(String cardId, int quantity) async {
    await executeApiOperation(
      apiCall: () => _cardService.purchaseCardStock(cardId, quantity),
      onSuccess: (response) {
        setSuccess('Card stock purchased successfully');
        return response.data!;
      },
      errorMessage: 'Failed to purchase card stock',
    );
  }

  /// Select a card
  void selectCard(CardViewModel card) {
    _currentCard = card;
    notifyListeners();
  }

  /// Clear selected card
  void clearCurrentCard() {
    _currentCard = null;
    _cardDetail = null;
    notifyListeners();
  }

  /// Reset the provider state
  @override
  void reset() {
    _currentCard = null;
    _cardDetail = null;
    super.reset();
  }

  /// Check if a card is selected
  bool get hasSelectedCard => _currentCard != null;

  /// Update an existing card
  Future<bool> updateCard(String cardId, CardUpdateFormModel formModel) async {
    AppLogger.service('CardDetailProvider', 'Updating card: $cardId');

    // Validate form using the form model's validate method
    final validationResult = formModel.validate();
    if (!validationResult.isValid) {
      // Show validation errors to user
      final firstError = validationResult.errors.first;
      setError(firstError.message);
      return false;
    }

    final result = await executeApiOperation(
      apiCall: () => _cardService.updateCard(cardId, formModel.image, formModel.toApiRequest()),
      onSuccess: (response) {
        setSuccess('Card updated successfully');
        // Refresh current card data
        getCardById(cardId);

        // Emit event to notify other providers of the update
        _eventBus.emit(CardUpdatedEvent(cardId));

        return true;
      },
      errorMessage: 'Failed to update card',
    );

    return result ?? false;
  }

  /// Delete a card
  Future<bool> deleteCard(String cardId) async {
    AppLogger.service('CardDetailProvider', 'Deleting card: $cardId');

    final result = await executeApiOperation(
      apiCall: () => _cardService.deleteCard(cardId),
      onSuccess: (response) {
        setSuccess('Card deleted successfully');
        clearCurrentCard();

        // Emit event to notify other providers of the deletion
        _eventBus.emit(CardDeletedEvent(cardId));

        return true;
      },
      errorMessage: 'Failed to delete card',
    );

    return result ?? false;
  }
}
