/// Domain-level failure types.
///
/// Repositories always surface a [Failure] (never a raw exception) so the
/// presentation layer can show a meaningful message without knowing where the
/// error came from (Hive, network, validation, …).
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Something went wrong while reading or writing local storage.
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'We could not save your data. Please try again.']);
}

/// Credentials were rejected / user does not exist.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Incorrect email or password.']);
}

/// Input did not pass validation.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// A requested record could not be found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find what you were looking for.']);
}

/// Anything we have not categorised yet.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong. Please try again.']);
}
