import '../../repositories/user_repository.dart';

class UpdateUserName {
  final UserRepository repository;

  UpdateUserName(this.repository);

  Future<void> call(String uid, String newName) {
    return repository.updateUserName(uid: uid, newName: newName);
  }
}
