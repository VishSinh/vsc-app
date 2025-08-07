// class PaymentMode(models.TextChoices):
//         CASH = "CASH", "Cash"
//         CARD = "CARD", "Card"
//         UPI = "UPI", "UPI"

enum PaymentMode { cash, card, upi }

extension PaymentModeExtension on PaymentMode {
  String toApiString() {
    switch (this) {
      case PaymentMode.cash:
        return 'CASH';
      case PaymentMode.card:
        return 'CARD';
      case PaymentMode.upi:
        return 'UPI';
    }
  }

  static PaymentMode? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'CASH':
        return PaymentMode.cash;
      case 'CARD':
        return PaymentMode.card;
      case 'UPI':
        return PaymentMode.upi;
    }
    return null;
  }
}
