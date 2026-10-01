/// Low-level exceptions thrown by data sources (Hive boxes, future APIs).
///
/// Data sources throw these; repositories translate them into the [Failure]
/// types from `failures.dart`.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

/// The local database (Hive) could not be read or written.
class LocalStorageException extends AppException {
  const LocalStorageException([super.message = 'Local storage error.']);
}

/// A record expected to exist was missing.
class RecordNotFoundException extends AppException {
  const RecordNotFoundException([super.message = 'Record not found.']);
}

/// Credentials were invalid or the account already exists.
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Input failed validation before it ever reached storage.
class ValidationException extends AppException {
  const ValidationException(super.message);
}
