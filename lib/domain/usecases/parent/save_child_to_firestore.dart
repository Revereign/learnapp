import '../../repositories/child_auth_repository.dart';
import '../../entities/user.dart';

class SaveChildToFirestore {
  final ChildAuthRepository repository;

  SaveChildToFirestore(this.repository);

  Future<void> call(UserEntity user, String role, String parentUid) async {
    // Buat nama default dari UID (10 karakter pertama)
    final defaultName = 'user_${user.uid.substring(0, 10)}';

    // Simpan user ke Firestore
    await repository.saveChildToFirestore(
      user.copyWith(name: defaultName, role: role, parentUid: parentUid),
    );
  }
}