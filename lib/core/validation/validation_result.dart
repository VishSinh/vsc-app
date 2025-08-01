/// Represents a single validation error for a specific field
class ValidationError {
  final String field;
  final String message;
  final String? code;

  const ValidationError({required this.field, required this.message, this.code});

  @override
  String toString() => 'ValidationError(field: $field, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError && runtimeType == other.runtimeType && field == other.field && message == other.message && code == other.code;

  @override
  int get hashCode => field.hashCode ^ message.hashCode ^ code.hashCode;
}

/// Represents the result of a validation operation
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;

  const ValidationResult._({required this.isValid, required this.errors});

  /// Creates a successful validation result
  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true, errors: []);
  }

  /// Creates a failed validation result with errors
  factory ValidationResult.failure(List<ValidationError> errors) {
    return ValidationResult._(isValid: false, errors: errors);
  }

  /// Creates a failed validation result with a single error
  factory ValidationResult.failureSingle(String field, String message, {String? code}) {
    return ValidationResult.failure([ValidationError(field: field, message: message, code: code)]);
  }

  /// Gets the error message for a specific field
  String? getMessage(String field) {
    final error = errors.firstWhere(
      (error) => error.field == field,
      orElse: () => const ValidationError(field: '', message: ''),
    );
    return error.field.isNotEmpty ? error.message : null;
  }

  /// Checks if a specific field has an error
  bool hasError(String field) {
    return errors.any((error) => error.field == field);
  }

  /// Gets all error messages as a single string
  String get combinedMessage {
    return errors.map((error) => error.message).join(', ');
  }

  /// Gets the first error message
  String? get firstMessage {
    return errors.isNotEmpty ? errors.first.message : null;
  }

  /// Combines this validation result with another
  ValidationResult combine(ValidationResult other) {
    if (isValid && other.isValid) {
      return ValidationResult.success();
    }

    final allErrors = [...errors, ...other.errors];
    return ValidationResult.failure(allErrors);
  }

  @override
  String toString() => 'ValidationResult(isValid: $isValid, errors: $errors)';
}
