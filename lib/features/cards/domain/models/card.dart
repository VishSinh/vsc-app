/// Pure domain model for Card business entity
class CardEntity {
  final String id;
  final String vendorId;
  final String barcode;
  final double sellPrice;
  final double costPrice;
  final double maxDiscount;
  final int quantity;
  final String image;
  final String perceptualHash;
  final bool isActive;

  const CardEntity({
    required this.id,
    required this.vendorId,
    required this.barcode,
    required this.sellPrice,
    required this.costPrice,
    required this.maxDiscount,
    required this.quantity,
    required this.image,
    required this.perceptualHash,
    required this.isActive,
  });

  /// Create a copy with updated values
  CardEntity copyWith({
    String? id,
    String? vendorId,
    String? barcode,
    double? sellPrice,
    double? costPrice,
    double? maxDiscount,
    int? quantity,
    String? image,
    String? perceptualHash,
    bool? isActive,
  }) {
    return CardEntity(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      barcode: barcode ?? this.barcode,
      sellPrice: sellPrice ?? this.sellPrice,
      costPrice: costPrice ?? this.costPrice,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      perceptualHash: perceptualHash ?? this.perceptualHash,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardEntity &&
        other.id == id &&
        other.vendorId == vendorId &&
        other.barcode == barcode &&
        other.sellPrice == sellPrice &&
        other.costPrice == costPrice &&
        other.maxDiscount == maxDiscount &&
        other.quantity == quantity &&
        other.image == image &&
        other.perceptualHash == perceptualHash &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, vendorId, barcode, sellPrice, costPrice, maxDiscount, quantity, image, perceptualHash, isActive);
  }

  @override
  String toString() {
    return 'CardEntity(id: $id, vendorId: $vendorId, barcode: $barcode, sellPrice: $sellPrice, costPrice: $costPrice, maxDiscount: $maxDiscount, quantity: $quantity, isActive: $isActive)';
  }
}
