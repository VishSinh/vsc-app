import 'package:intl/intl.dart';

/// Utility class for formatting date values
class DateFormatter {
  /// Format a DateTime as a readable date string (e.g., "Jan 15, 2023")
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat.yMMMd().format(dateTime);
  }

  /// Format a DateTime as a readable date and time string (e.g., "Jan 15, 2023 14:30")
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat.yMMMd().add_Hm().format(dateTime);
  }

  /// Format a DateTime as a readable time string (e.g., "14:30")
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat.Hm().format(dateTime);
  }

  /// Parse a string to DateTime
  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Get a relative time string (e.g., "2 days ago", "Just now")
  static String getRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format a DateTime to yyyy-MM-dd for API query parameters
  static String formatDateForApi(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Format a date range (e.g., "Jan 15 - Jan 20, 2023")
  static String formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return 'N/A';
    if (startDate == null) return 'Until ${formatDate(endDate)}';
    if (endDate == null) return 'From ${formatDate(startDate)}';

    final isSameYear = startDate.year == endDate.year;
    final isSameMonth = startDate.month == endDate.month && isSameYear;

    if (isSameMonth) {
      return '${DateFormat.d().format(startDate)} - ${DateFormat.d().format(endDate)} ${DateFormat.yMMM().format(endDate)}';
    } else if (isSameYear) {
      return '${DateFormat.MMMd().format(startDate)} - ${DateFormat.MMMd().format(endDate)}, ${DateFormat.y().format(endDate)}';
    } else {
      return '${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMd().format(endDate)}';
    }
  }
}
