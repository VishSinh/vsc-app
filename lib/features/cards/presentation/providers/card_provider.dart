import 'package:flutter/material.dart';
import 'package:vsc_app/core/models/card_model.dart';
import 'package:vsc_app/core/providers/base_provider.dart';
import 'package:vsc_app/core/services/card_service.dart';
import 'package:vsc_app/core/utils/snackbar_utils.dart';

class CardProvider extends BaseProvider {
  final CardService _cardService;
  String? _selectedImageUrl;

  CardProvider({CardService? cardService}) : _cardService = cardService ?? CardService();

  String? get selectedImageUrl => _selectedImageUrl;

  Future<void> uploadImage(dynamic imageFile) async {
    await executeAsync(() async {
      _selectedImageUrl = await _cardService.uploadImage(imageFile);
      notifyListeners();
    }, showLoading: true);
  }

  Future<void> createCard({
    required double costPrice,
    required double sellPrice,
    required int quantity,
    required double maxDiscount,
    required String vendorId,
    BuildContext? context,
  }) async {
    if (_selectedImageUrl == null) {
      final errorMessage = 'Please select an image first';
      setError(errorMessage);
      if (context != null) {
        SnackbarUtils.showError(context, errorMessage);
      }
      return;
    }

    final request = CreateCardRequest(
      image: _selectedImageUrl!,
      costPrice: costPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      maxDiscount: maxDiscount,
      vendorId: vendorId,
    );

    await executeApiCall(
      () => _cardService.createCard(request),
      onSuccess: (data) {
        setSuccess('Card created successfully!');
        // Reset form or navigate away
        _selectedImageUrl = null;
        notifyListeners();
        if (context != null) {
          SnackbarUtils.showSuccess(context, 'Card created successfully!');
        }
      },
      onError: (error) {
        if (context != null) {
          SnackbarUtils.showApiError(context, error);
        }
      },
      context: context,
    );
  }

  void clearImage() {
    _selectedImageUrl = null;
    notifyListeners();
  }
}
