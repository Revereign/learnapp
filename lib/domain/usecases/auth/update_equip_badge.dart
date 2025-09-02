import '../../repositories/auth_repository.dart';

class UpdateEquipBadge {
  final AuthRepository repository;

  UpdateEquipBadge(this.repository);

  Future<void> call(String uid, int equipBadge) {
    return repository.updateUserEquipBadge(uid, equipBadge);
  }
}
