import '../../repositories/user_repository.dart';

class DeleteUser {
  final UserRepository repository;

  DeleteUser(this.repository);

  Future<void> call(String uid) {
    return repository.deleteUser(uid: uid);
  }
}
