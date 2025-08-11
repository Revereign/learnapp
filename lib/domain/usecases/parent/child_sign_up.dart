import '../../repositories/child_auth_repository.dart';
import '../../entities/user.dart';

class ChildSignUp {
  final ChildAuthRepository repository;

  ChildSignUp(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.childSignUp(email, password);
  }
}