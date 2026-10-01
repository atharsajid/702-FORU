import 'package:flutter/material.dart';

import '../utils/context_extensions.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Central place that converts "anything thrown" into a user-facing message.
///
/// Repositories translate exceptions into [Failure]s; this handler is the
/// safety net for errors that escape that path (e.g. inside a provider).
class AppErrorHandler {
  const AppErrorHandler._();

  /// Converts any error into a [Failure].
  static Failure toFailure(Object error) {
    if (error is Failure) return error;
    if (error is ValidationException) return ValidationFailure(error.message);
    if (error is LocalStorageException) return StorageFailure(error.message);
    if (error is RecordNotFoundException) return NotFoundFailure(error.message);
    if (error is AuthException) return AuthFailure(error.message);
    if (error is AppException) return UnexpectedFailure(error.message);
    return const UnexpectedFailure();
  }

  /// Short, human message for any error.
  static String message(Object error) => toFailure(error).message;

  /// Shows the error to the user via a themed snackbar.
  static void show(BuildContext context, Object error) {
    context.showSnack(message(error), isError: true);
  }

  /// Runs [action], converting any thrown error into a [Failure].
  ///
  /// ```dart
  /// final result = await AppErrorHandler.guard(() => repo.signIn(...));
  /// result.fold(onSuccess: …, onFailure: …);
  /// ```
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (error) {
      return Result.failure(toFailure(error));
    }
  }
}

/// Minimal success/failure wrapper used by repositories and providers.
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;
  Failure? get failureOrNull => this is Error<T> ? (this as Error<T>).failure : null;

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.value);
    return failure((self as Error<T>).failure);
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}
