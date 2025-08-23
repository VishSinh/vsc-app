import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/features/cards/data/services/card_service.dart';

import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';

/// Provider for managing card details, barcode generation, and edit/delete operations
class CardDetailProvider extends BaseProvider {
  final CardService _cardService = CardService();

  // Card detail state
  CardViewModel? _currentCard;

  // Getters for fetched data
  CardViewModel? get currentCard => _currentCard;

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
    notifyListeners();
  }

  /// Reset the provider state
  @override
  void reset() {
    _currentCard = null;
    super.reset();
  }

  /// Check if a card is selected
  bool get hasSelectedCard => _currentCard != null;
}
