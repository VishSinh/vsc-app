/// Represents a validation failure for domain-side use
/// This is used with Either types and domain layer validation
class ValidationFailure {
  final String message;
  final String? field;
  final String? code;

  const ValidationFailure(this.message, {this.field, this.code});

  /// Creates a validation failure for a specific field
  const ValidationFailure.field(this.message, this.field, {this.code});

  /// Creates a general validation failure
  const ValidationFailure.general(this.message, {this.code}) : field = null;

  @override
  String toString() => 'ValidationFailure(message: $message, field: $field, code: $code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationFailure && runtimeType == other.runtimeType && message == other.message && field == other.field && code == other.code;

  @override
  int get hashCode => message.hashCode ^ field.hashCode ^ code.hashCode;
}
