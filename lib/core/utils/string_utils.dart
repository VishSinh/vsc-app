/// Utility class for string manipulation and formatting
class StringUtils {
  /// Capitalize the first letter of a string
  static String capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize each word in a string
  static String capitalizeEachWord(String? text) {
    if (text == null || text.isEmpty) return '';

    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate a string to a maximum length with ellipsis
  static String truncate(String? text, int maxLength, {String ellipsis = '...'}) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;

    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Convert camelCase or PascalCase to Title Case
  static String camelToTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';

    final result = text.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');

    return capitalize(result.trim());
  }

  /// Convert snake_case to Title Case
  static String snakeToTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';

    return text.split('_').map((word) => capitalize(word)).join(' ');
  }

  /// Convert kebab-case to Title Case
  static String kebabToTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';

    return text.split('-').map((word) => capitalize(word)).join(' ');
  }

  /// Get initials from a name (e.g., "John Doe" -> "JD")
  static String getInitials(String? fullName, {int maxInitials = 2}) {
    if (fullName == null || fullName.isEmpty) return '';

    final nameParts = fullName.trim().split(' ');
    final initials = nameParts.where((part) => part.isNotEmpty).take(maxInitials).map((part) => part[0].toUpperCase()).join('');

    return initials;
  }

  /// Check if a string is null, empty, or contains only whitespace
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Format a phone number (e.g., "1234567890" -> "+91 12345 67890")
  static String formatPhoneNumber(String? phoneNumber, {String countryCode = '+91'}) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';

    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 5) return digitsOnly;

    // Format based on length
    if (digitsOnly.length <= 10) {
      // Format as local number
      final firstPart = digitsOnly.substring(0, digitsOnly.length > 5 ? 5 : digitsOnly.length);
      final secondPart = digitsOnly.length > 5 ? digitsOnly.substring(5) : '';

      return '$countryCode $firstPart $secondPart'.trim();
    } else {
      // Handle international numbers
      return '+${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 7)} ${digitsOnly.substring(7)}';
    }
  }
}
