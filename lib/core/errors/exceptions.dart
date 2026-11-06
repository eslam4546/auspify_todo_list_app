class DatabaseException implements Exception {
  final String message;

  DatabaseException([this.message = 'A local database exception occurred.']);

  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException implements Exception {
  final String message;

  ValidationException([this.message = 'Validation failed.']);

  @override
  String toString() => 'ValidationException: $message';
}
