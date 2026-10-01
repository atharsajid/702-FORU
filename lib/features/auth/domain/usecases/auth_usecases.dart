import '../../../../core/error/error_handler.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser?>> call() => _repository.currentUser();
}

class SignInWithEmail {
  const SignInWithEmail(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) =>
      _repository.signIn(email: email, password: password);
}

class SignUpAccount {
  const SignUpAccount(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser>> call(SignUpParams params) => _repository.signUp(params);
}

class SignOutAccount {
  const SignOutAccount(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}

class UpdateProfile {
  const UpdateProfile(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser>> call(AppUser user) => _repository.updateProfile(user);
}

class CheckEmailExists {
  const CheckEmailExists(this._repository);
  final AuthRepository _repository;

  Future<Result<bool>> call(String email) => _repository.emailExists(email);
}
