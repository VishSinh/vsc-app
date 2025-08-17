import 'package:vsc_app/features/cards/data/models/card_responses.dart';

/// UI model for displaying card information in bill pages
class BillCardViewModel {
  final String id;
  final String barcode;
  final String image;
  final double price;
  final String formattedPrice;

  const BillCardViewModel({required this.id, required this.barcode, required this.image, required this.price, required this.formattedPrice});

  /// Create from API response
  factory BillCardViewModel.fromCardResponse(CardResponse response) {
    final price = double.tryParse(response.sellPrice) ?? 0.0;

    return BillCardViewModel(
      id: response.id,
      barcode: response.barcode,
      image: response.image,
      price: price,
      formattedPrice: '₹${price.toStringAsFixed(2)}',
    );
  }
}
