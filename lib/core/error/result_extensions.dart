import 'error_handler.dart';

/// Lets `FutureProvider`s turn a [Result] into a value (or a thrown [Failure]),
/// which `AsyncValue` then surfaces as `.error`.
///
/// ```dart
/// final categories = FutureProvider((ref) async {
///   final result = await ref.watch(getCategoriesProvider)();
///   return result.orThrow();
/// });
/// ```
extension ResultX<T> on Result<T> {
  T orThrow() => when(
        success: (value) => value,
        failure: (failure) => throw failure,
      );
}
