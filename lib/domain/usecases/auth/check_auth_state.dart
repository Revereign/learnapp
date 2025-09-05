import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';

class CheckAuthState {
  final AuthRepository repository;

  CheckAuthState(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}
