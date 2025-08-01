import 'validation_result.dart';

/// Base validator interface for type-safe validation
abstract class Validator<T> {
  /// Validates the input and returns a ValidationResult
  ValidationResult validate(T input);

  /// Validates multiple inputs and returns a combined ValidationResult
  ValidationResult validateMultiple(List<T> inputs) {
    ValidationResult combinedResult = ValidationResult.success();

    for (final input in inputs) {
      final result = validate(input);
      combinedResult = combinedResult.combine(result);
    }

    return combinedResult;
  }
}

/// Base validator for nullable inputs
abstract class NullableValidator<T> {
  /// Validates the input and returns a ValidationResult
  ValidationResult validate(T? input);

  /// Validates multiple inputs and returns a combined ValidationResult
  ValidationResult validateMultiple(List<T?> inputs) {
    ValidationResult combinedResult = ValidationResult.success();

    for (final input in inputs) {
      final result = validate(input);
      combinedResult = combinedResult.combine(result);
    }

    return combinedResult;
  }
}
