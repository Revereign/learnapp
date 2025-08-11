import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.signUp(email, password);
  }
}
