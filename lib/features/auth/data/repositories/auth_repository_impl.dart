import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<Result<AppUser?>> currentUser() async {
    try {
      final id = _local.currentUserId;
      if (id == null) return const Success(null);
      return Success(_local.findById(id));
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.trim();
      if (trimmedEmail.isEmpty || password.isEmpty) {
        return const Error(ValidationFailure('Enter your email and password.'));
      }

      final user = _local.findByEmail(trimmedEmail);
      if (user == null) {
        return const Error(AuthFailure('No account found for that email.'));
      }
      if (!user.matchesPassword(password)) {
        return const Error(AuthFailure('Incorrect email or password.'));
      }

      await _local.saveSession(user.id);
      return Success(user);
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<AppUser>> signUp(SignUpParams params) async {
    try {
      final email = params.email.trim();
      if (params.fullName.trim().length < 2) {
        return const Error(ValidationFailure('Please enter your full name.'));
      }
      if (email.isEmpty || !email.contains('@')) {
        return const Error(ValidationFailure('Please enter a valid email.'));
      }
      if (params.password.length < 6) {
        return const Error(
          ValidationFailure('Password must be at least 6 characters.'),
        );
      }
      if (_local.findByEmail(email) != null) {
        return const Error(
          AuthFailure('That email is already registered. Try signing in.'),
        );
      }

      final user = AppUser(
        id: 'u-${DateTime.now().microsecondsSinceEpoch}',
        fullName: params.fullName.trim(),
        email: email,
        phone: params.phone.trim(),
        role: params.role,
        businessId: params.businessId,
        passwordHash: AppUser.encodePassword(params.password),
        marketingOptIn: params.marketingOptIn,
        createdAt: DateTime.now(),
      );

      await _local.upsertUser(user);
      await _local.saveSession(user.id);
      return Success(user);
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _local.clearSession();
      return const Success(null);
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<AppUser>> updateProfile(AppUser user) async {
    try {
      if (_local.findById(user.id) == null) {
        return const Error(NotFoundFailure('Account not found.'));
      }
      await _local.upsertUser(user);
      return Success(user);
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<bool>> emailExists(String email) async {
    try {
      return Success(_local.findByEmail(email) != null);
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }
}
