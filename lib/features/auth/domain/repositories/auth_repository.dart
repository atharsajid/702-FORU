import '../../../../core/error/error_handler.dart';
import '../entities/app_user.dart';

/// Parameters for creating an account.
class SignUpParams {
  const SignUpParams({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.phone = '',
    this.marketingOptIn = false,
    this.businessId,
  });

  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String phone;
  final bool marketingOptIn;
  final String? businessId;
}

abstract class AuthRepository {
  /// The signed-in user, or `null` when nobody is signed in.
  Future<Result<AppUser?>> currentUser();

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUp(SignUpParams params);

  Future<Result<void>> signOut();

  Future<Result<AppUser>> updateProfile(AppUser user);

  /// Whether an email is already registered (used for inline form feedback).
  Future<Result<bool>> emailExists(String email);
}
