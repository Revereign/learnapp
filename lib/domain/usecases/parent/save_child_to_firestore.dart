import '../../repositories/child_auth_repository.dart';
import '../../entities/user.dart';

class SaveChildToFirestore {
  final ChildAuthRepository repository;

  SaveChildToFirestore(this.repository);

  Future<void> call(UserEntity user, String role, String parentUid) async {
    // Buat nama default dari UID (10 karakter pertama)
    final defaultName = 'user_${user.uid.substring(0, 10)}';

    // Buat user dengan field baru yang sudah diinisialisasi
    final userWithDefaults = user.copyWith(
      name: defaultName, 
      role: role, 
      parentUid: parentUid,
      gameScore: List.filled(10, 0),
      quizScore: List.filled(10, 0),
      quizTime: List.filled(10, 0),
      achieve: List.filled(6, false),
      todayTime: 0,
      allTime: 0,
    );

    // Simpan user ke Firestore
    await repository.saveChildToFirestore(userWithDefaults);
  }
}