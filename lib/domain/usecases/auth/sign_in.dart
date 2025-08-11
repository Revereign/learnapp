import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
