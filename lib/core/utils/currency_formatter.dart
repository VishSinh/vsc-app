import 'package:intl/intl.dart';

/// Utility class for formatting currency values
class CurrencyFormatter {
  /// Format a double value as currency with the given currency symbol
  /// Default currency symbol is ₹ (Indian Rupee)
  static String format(dynamic value, {String symbol = '₹', int decimalPlaces = 2}) {
    if (value == null) return symbol + '0.00';

    // Convert string to double if needed
    double numericValue;
    if (value is String) {
      numericValue = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      numericValue = value.toDouble();
    } else {
      return symbol + '0.00';
    }

    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: decimalPlaces, locale: 'en_IN');

    return formatter.format(numericValue);
  }

  /// Format a double value as currency without the currency symbol
  static String formatWithoutSymbol(dynamic value, {int decimalPlaces = 2}) {
    if (value == null) return '0.00';

    // Convert string to double if needed
    double numericValue;
    if (value is String) {
      numericValue = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      numericValue = value.toDouble();
    } else {
      return '0.00';
    }

    final formatter = NumberFormat.decimalPattern('en_IN')
      ..minimumFractionDigits = decimalPlaces
      ..maximumFractionDigits = decimalPlaces;

    return formatter.format(numericValue);
  }

  /// Format a percentage value
  static String formatPercentage(dynamic value, {int decimalPlaces = 1}) {
    if (value == null) return '0%';

    // Convert string to double if needed
    double numericValue;
    if (value is String) {
      numericValue = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      numericValue = value.toDouble();
    } else {
      return '0%';
    }

    final formatter = NumberFormat.percentPattern('en_US')
      ..minimumFractionDigits = decimalPlaces
      ..maximumFractionDigits = decimalPlaces;

    return formatter.format(numericValue / 100);
  }
}
