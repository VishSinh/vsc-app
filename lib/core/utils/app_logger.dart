import 'package:logger/logger.dart';
import '../constants/logging_constants.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: true),
    level: Level.debug,
  );

  // Debug logging
  static void debug(String message, {String? category, Object? data}) {
    print('${LoggingConstants.emojiDebug} $message');
  }

  // Info logging
  static void info(String message, {String? category, Object? data}) {
    print('${LoggingConstants.emojiInfo} $message');
  }

  // Warning logging
  static void warning(String message, {String? category, Object? data}) {
    print('${LoggingConstants.emojiWarning} $message');
  }

  // Error logging
  static void error(String message, {String? category, Object? data, Object? error, StackTrace? stackTrace}) {
    print('${LoggingConstants.emojiError} $message');
  }

  // Fatal logging
  static void fatal(String message, {String? category, Object? data, Object? error, StackTrace? stackTrace}) {
    print('${LoggingConstants.emojiError} $message');
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
}
