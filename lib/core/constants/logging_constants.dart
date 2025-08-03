class LoggingConstants {
  // Log Levels
  static const String levelDebug = 'DEBUG';
  static const String levelInfo = 'INFO';
  static const String levelWarning = 'WARNING';
  static const String levelError = 'ERROR';
  static const String levelFatal = 'FATAL';

  // Log Categories
  static const String categoryApi = 'API';
  static const String categoryUi = 'UI';
  static const String categoryAuth = 'AUTH';
  static const String categoryProvider = 'PROVIDER';
  static const String categoryService = 'SERVICE';
  static const String categoryNavigation = 'NAVIGATION';
  static const String categoryValidation = 'VALIDATION';
  static const String categoryError = 'ERROR';
  static const String categoryPerformance = 'PERFORMANCE';

  // Log Messages
  static const String msgApiRequest = 'API Request';
  static const String msgApiResponse = 'API Response';
  static const String msgApiError = 'API Error';
  static const String msgUiAction = 'UI Action';
  static const String msgNavigation = 'Navigation';
  static const String msgStateChange = 'State Change';
  static const String msgErrorCaught = 'Error Caught';
  static const String msgNullCheck = 'Null Check';
  static const String msgValidation = 'Validation';
  static const String msgPerformance = 'Performance';

  // Log Emojis for Visual Identification
  static const String emojiDebug = '🔍';
  static const String emojiInfo = '📦';
  static const String emojiWarning = '⚠️';
  static const String emojiError = '❌';
  static const String emojiSuccess = '✅';
  static const String emojiApi = '🌐';
  static const String emojiUi = '🖱️';
  static const String emojiAuth = '🔐';
  static const String emojiNavigation = '🧭';
  static const String emojiPerformance = '⚡';

  // Log Templates
  static String apiRequest(String endpoint, {String? method, Map<String, dynamic>? params}) {
    return '$emojiApi $msgApiRequest: ${method ?? 'GET'} $endpoint${params != null ? ' with params: $params' : ''}';
  }

  static String apiResponse(String endpoint, {bool success = true, String? data}) {
    return '$emojiApi $msgApiResponse: ${success ? 'Success' : 'Error'} for $endpoint${data != null ? ' - $data' : ''}';
  }

  static String apiError(String endpoint, String error) {
    return '$emojiError $msgApiError: $endpoint - $error';
  }

  static String uiAction(String action, {String? details}) {
    return '$emojiUi $msgUiAction: $action${details != null ? ' - $details' : ''}';
  }

  static String navigation(String from, String to) {
    return '$emojiNavigation $msgNavigation: $from → $to';
  }

  static String stateChange(String provider, String state) {
    return '$emojiInfo $msgStateChange: $provider - $state';
  }

  static String errorCaught(String context, String error) {
    return '$emojiError $msgErrorCaught: $context - $error';
  }

  static String nullCheck(String context, String variable) {
    return '$emojiWarning $msgNullCheck: $context - $variable is null';
  }

  static String validation(String context, String result) {
    return '$emojiInfo $msgValidation: $context - $result';
  }

  static String performance(String operation, String duration) {
    return '$emojiPerformance $msgPerformance: $operation took $duration';
  }
}
