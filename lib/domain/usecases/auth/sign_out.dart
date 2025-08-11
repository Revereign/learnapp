import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
