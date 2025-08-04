import 'package:logging/logging.dart';
import 'dart:developer' as developer;
import '../constants/logging_constants.dart';

class AppLogger {
  static final Logger _logger = Logger('AppLogger');
  static bool _initialized = false;

  /// Initialize the logger with custom configuration
  static void initialize({Level level = Level.ALL}) {
    if (_initialized) return;

    // Configure the logging package
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      // Custom formatter that includes emojis and categories
      final emoji = _getEmojiForLevel(record.level);
      final category = record.loggerName != 'AppLogger' ? '[${record.loggerName}]' : '';
      final timestamp = record.time.toIso8601String();

      developer.log('$emoji $timestamp$category ${record.message}');

      // Log stack trace for errors
      if (record.error != null) {
        developer.log('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        developer.log('Stack trace: ${record.stackTrace}');
      }
    });

    _initialized = true;
  }

  /// Get emoji for log level
  static String _getEmojiForLevel(Level level) {
    switch (level) {
      case Level.FINE:
      case Level.FINER:
      case Level.FINEST:
        return LoggingConstants.emojiDebug;
      case Level.INFO:
        return LoggingConstants.emojiInfo;
      case Level.WARNING:
        return LoggingConstants.emojiWarning;
      case Level.SEVERE:
        return LoggingConstants.emojiError;
      default:
        return LoggingConstants.emojiInfo;
    }
  }

  /// Create a logger for a specific category
  static Logger _getLogger(String category) => Logger('AppLogger.$category');

  // Debug logging
  static void debug(String message, {String? category, Object? data}) {
    final logger = category != null ? _getLogger(category) : _logger;
    final fullMessage = data != null ? '$message | Data: $data' : message;
    logger.fine(fullMessage);
  }

  // Info logging
  static void info(String message, {String? category, Object? data}) {
    final logger = category != null ? _getLogger(category) : _logger;
    final fullMessage = data != null ? '$message | Data: $data' : message;
    logger.info(fullMessage);
  }

  // Warning logging
  static void warning(String message, {String? category, Object? data}) {
    final logger = category != null ? _getLogger(category) : _logger;
    final fullMessage = data != null ? '$message | Data: $data' : message;
    logger.warning(fullMessage);
  }

  // Error logging
  static void error(String message, {String? category, Object? data, Object? error, StackTrace? stackTrace}) {
    final logger = category != null ? _getLogger(category) : _logger;
    final fullMessage = data != null ? '$message | Data: $data' : message;
    logger.severe(fullMessage, error, stackTrace);
  }

  // Fatal logging
  static void fatal(String message, {String? category, Object? data, Object? error, StackTrace? stackTrace}) {
    final logger = category != null ? _getLogger(category) : _logger;
    final fullMessage = data != null ? '$message | Data: $data' : message;
    logger.severe('FATAL: $fullMessage', error, stackTrace);
  }

  static void apiError(String endpoint, String error) {
    AppLogger.error(LoggingConstants.apiError(endpoint, error), category: LoggingConstants.categoryApi);
  }

  // UI specific logging
  static void uiAction(String action, {String? details}) {
    info(LoggingConstants.uiAction(action, details: details), category: LoggingConstants.categoryUi);
  }

  static void navigation(String from, String to) {
    info(LoggingConstants.navigation(from, to), category: LoggingConstants.categoryNavigation);
  }

  // Provider/State logging
  static void stateChange(String provider, String state) {
    debug(LoggingConstants.stateChange(provider, state), category: LoggingConstants.categoryProvider);
  }

  // Error handling logging
  static void errorCaught(String context, String error, {Object? errorObject, StackTrace? stackTrace}) {
    AppLogger.error(
      LoggingConstants.errorCaught(context, error),
      category: LoggingConstants.categoryError,
      error: errorObject,
      stackTrace: stackTrace,
    );
  }

  // Null check logging
  static void nullCheck(String context, String variable) {
    warning(LoggingConstants.nullCheck(context, variable), category: LoggingConstants.categoryError);
  }

  // Validation logging
  static void validation(String context, String result) {
    info(LoggingConstants.validation(context, result), category: LoggingConstants.categoryValidation);
  }

  // Performance logging
  static void performance(String operation, String duration) {
    info(LoggingConstants.performance(operation, duration), category: LoggingConstants.categoryPerformance);
  }

  // Service specific logging
  static void service(String service, String action, {String? details}) {
    debug('${LoggingConstants.emojiApi} $service: $action${details != null ? ' - $details' : ''}', category: LoggingConstants.categoryService);
  }

  // Auth specific logging
  static void auth(String action, {String? details}) {
    info('${LoggingConstants.emojiAuth} Auth: $action${details != null ? ' - $details' : ''}', category: LoggingConstants.categoryAuth);
  }

  // Success logging
  static void success(String context, String message) {
    info('${LoggingConstants.emojiSuccess} $context: $message');
  }

  // Generic logging with custom emoji
  static void log(String emoji, String message, {String? category, Object? data}) {
    info('$emoji $message', category: category, data: data);
  }

  /// Log API request with timing
  static void apiRequest(String endpoint, {String? method, Map<String, dynamic>? params}) {
    info(
      LoggingConstants.apiRequest(endpoint, method: method, params: params),
      category: LoggingConstants.categoryApi,
    );
  }

  /// Log API response with timing
  static void apiResponse(String endpoint, {bool success = true, String? data, Duration? duration}) {
    final message = LoggingConstants.apiResponse(endpoint, success: success, data: data);
    final fullMessage = duration != null ? '$message | Duration: ${duration.inMilliseconds}ms' : message;
    info(fullMessage, category: LoggingConstants.categoryApi);
  }

  /// Log method entry and exit for debugging
  static void methodEntry(String methodName, {String? className, Map<String, dynamic>? parameters}) {
    final context = className != null ? '$className.$methodName' : methodName;
    final params = parameters != null ? ' | Params: $parameters' : '';
    debug('Entering $context$params', category: 'METHOD');
  }

  static void methodExit(String methodName, {String? className, Object? result}) {
    final context = className != null ? '$className.$methodName' : methodName;
    final resultStr = result != null ? ' | Result: $result' : '';
    debug('Exiting $context$resultStr', category: 'METHOD');
  }

  /// Log database operations
  static void database(String operation, {String? table, String? query, Object? data}) {
    final message = 'Database: $operation${table != null ? ' on $table' : ''}';
    final fullMessage = query != null ? '$message | Query: $query' : message;
    debug(fullMessage, category: 'DATABASE', data: data);
  }

  /// Log cache operations
  static void cache(String operation, {String? key, Object? data}) {
    final message = 'Cache: $operation${key != null ? ' for key: $key' : ''}';
    debug(message, category: 'CACHE', data: data);
  }

  /// Log network connectivity
  static void network(String status, {String? endpoint, Duration? latency}) {
    final message = 'Network: $status${endpoint != null ? ' - $endpoint' : ''}';
    final fullMessage = latency != null ? '$message | Latency: ${latency.inMilliseconds}ms' : message;
    info(fullMessage, category: 'NETWORK');
  }

  /// Log user interactions
  static void userInteraction(String action, {String? screen, Map<String, dynamic>? details}) {
    final message = 'User Interaction: $action${screen != null ? ' on $screen' : ''}';
    info(message, category: 'USER_INTERACTION', data: details);
  }

  /// Log app lifecycle events
  static void lifecycle(String event, {String? details}) {
    info('App Lifecycle: $event${details != null ? ' - $details' : ''}', category: 'LIFECYCLE');
  }

  /// Log memory usage
  static void memory(String operation, {int? bytes, String? context}) {
    final message = 'Memory: $operation${context != null ? ' - $context' : ''}';
    final fullMessage = bytes != null ? '$message | ${(bytes / 1024 / 1024).toStringAsFixed(2)}MB' : message;
    debug(fullMessage, category: 'MEMORY');
  }
}
