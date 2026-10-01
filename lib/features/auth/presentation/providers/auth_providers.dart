import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

// ── Use cases ────────────────────────────────────────────────────────────
final getCurrentUserProvider = Provider<GetCurrentUser>(
  (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)),
);

final signInWithEmailProvider = Provider<SignInWithEmail>(
  (ref) => SignInWithEmail(ref.watch(authRepositoryProvider)),
);

final signUpAccountProvider = Provider<SignUpAccount>(
  (ref) => SignUpAccount(ref.watch(authRepositoryProvider)),
);

final signOutAccountProvider = Provider<SignOutAccount>(
  (ref) => SignOutAccount(ref.watch(authRepositoryProvider)),
);

final updateProfileProvider = Provider<UpdateProfile>(
  (ref) => UpdateProfile(ref.watch(authRepositoryProvider)),
);

final checkEmailExistsProvider = Provider<CheckEmailExists>(
  (ref) => CheckEmailExists(ref.watch(authRepositoryProvider)),
);

// ── State ────────────────────────────────────────────────────────────────
class AuthState {
  const AuthState({this.user, this.isBusy = false, this.error});

  final AppUser? user;
  final bool isBusy;
  final Failure? error;

  bool get isAuthenticated => user != null;
  bool get isProvider => user?.role.isProvider ?? false;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? isBusy,
    Failure? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Owns the session. Reads Hive synchronously in [build] so the app knows
/// whether someone is signed in on the very first frame (no splash flicker).
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final dataSource = ref.watch(authLocalDataSourceProvider);
    final id = dataSource.currentUserId;
    if (id == null) return const AuthState();
    return AuthState(user: dataSource.findById(id));
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isBusy: true, clearError: true);
    final result = await ref.read(signInWithEmailProvider)(
      email: email,
      password: password,
    );
    return result.when(
      success: (user) {
        state = AuthState(user: user);
        return true;
      },
      failure: (failure) {
        state = AuthState(user: state.user, error: failure);
        return false;
      },
    );
  }

  Future<bool> signUp(SignUpParams params) async {
    state = state.copyWith(isBusy: true, clearError: true);
    final result = await ref.read(signUpAccountProvider)(params);
    return result.when(
      success: (user) {
        state = AuthState(user: user);
        return true;
      },
      failure: (failure) {
        state = AuthState(user: state.user, error: failure);
        return false;
      },
    );
  }

  /// Called after a provider registration succeeds so the session reflects the
  /// newly linked business id.
  void setUser(AppUser user) => state = AuthState(user: user);

  Future<void> signOut() async {
    state = state.copyWith(isBusy: true, clearError: true);
    await ref.read(signOutAccountProvider)();
    state = const AuthState();
  }

  Future<bool> updateProfile(AppUser user) async {
    state = state.copyWith(isBusy: true, clearError: true);
    final result = await ref.read(updateProfileProvider)(user);
    return result.when(
      success: (updated) {
        state = AuthState(user: updated);
        return true;
      },
      failure: (failure) {
        state = state.copyWith(isBusy: false, error: failure);
        return false;
      },
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Just the signed-in user (or null) – rebuilds only when that changes.
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authControllerProvider.select((state) => state.user)),
);

final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(currentUserProvider)?.id,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider) != null,
);

final isProviderProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider)?.role.isProvider ?? false,
);
