import 'package:vsc_app/core/utils/app_logger.dart';

/// Utility functions for service classes
class ServiceUtils {
  /// Safely parse a list from JSON
  ///
  /// This method handles the common pattern of parsing a list of items from JSON
  /// and provides consistent error handling.
  static List<T> parseList<T>(dynamic json, T Function(dynamic item) fromJson) {
    AppLogger.debug('ServiceUtils: parseList called with data type: ${json.runtimeType}');

    if (json is List<dynamic>) {
      AppLogger.debug('ServiceUtils: parseList - data is List, converting items');
      return json.map((item) => fromJson(item)).toList();
    }

    AppLogger.error(
      'ServiceUtils: parseList - Invalid response format',
      error: 'Expected List but got ${json.runtimeType}',
      data: {'jsonType': json.runtimeType.toString()},
    );

    throw Exception('Invalid response format: expected List but got ${json.runtimeType}');
  }

  /// Safely parse a single item from JSON
  ///
  /// This method handles the common pattern of parsing a single item from JSON
  /// and provides consistent error handling.
  static T parseItem<T>(dynamic json, T Function(Map<String, dynamic> item) fromJson) {
    AppLogger.debug('ServiceUtils: parseItem called with data type: ${json.runtimeType}');

    if (json is Map<String, dynamic>) {
      AppLogger.debug('ServiceUtils: parseItem - data is Map, converting item');
      return fromJson(json);
    }

    AppLogger.error(
      'ServiceUtils: parseItem - Invalid response format',
      error: 'Expected Map<String, dynamic> but got ${json.runtimeType}',
      data: {'jsonType': json.runtimeType.toString()},
    );

    throw Exception('Invalid response format: expected Map<String, dynamic> but got ${json.runtimeType}');
  }
}
