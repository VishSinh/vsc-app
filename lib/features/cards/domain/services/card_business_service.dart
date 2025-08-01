/// Business service for card operations - pure business logic only
class CardBusinessService {
  /// Calculate profit margin for a card
  static double calculateProfitMargin(double sellPrice, double costPrice) {
    if (sellPrice <= 0) return 0.0;
    return ((sellPrice - costPrice) / sellPrice) * 100;
  }

  /// Calculate total value for a card
  static double calculateTotalValue(double sellPrice, int quantity) {
    return sellPrice * quantity;
  }

  /// Calculate recommended sell price based on cost price and desired margin
  static double calculateRecommendedSellPrice(double costPrice, double desiredMargin) {
    if (costPrice <= 0 || desiredMargin <= 0) return costPrice;
    return costPrice / (1 - (desiredMargin / 100));
  }

  /// Check if profit margin is good
  static bool hasGoodProfitMargin(double profitMargin, {double threshold = 20.0}) {
    return profitMargin >= threshold;
  }

  /// Check if quantity is low stock
  static bool isLowStock(int quantity, {int threshold = 5}) {
    return quantity <= threshold;
  }

  /// Format similarity score for display
  static String formatSimilarityScore(double similarity) {
    return '${(similarity * 100).toStringAsFixed(1)}%';
  }
}
