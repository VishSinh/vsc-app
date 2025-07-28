enum TransactionType {
  purchase('PURCHASE'),
  sale('SALE'),
  adjustment('ADJUSTMENT'),
  transfer('TRANSFER'),
  returnItem('RETURN');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere((type) => type.value == value, orElse: () => TransactionType.adjustment);
  }
}
