import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SaveUserToFirestore {
  final AuthRepository repository;

  SaveUserToFirestore(this.repository);

  Future<void> call(UserEntity user, String role) async {
    // Buat nama default dari UID (10 karakter pertama)
    final defaultName = 'user_${user.uid.substring(0, 10)}';

    // Simpan user ke Firestore
    await repository.saveUserToFirestore(
      user.copyWith(
        name: defaultName, 
        role: role,
        gameScore: List.filled(10, 0),
        quizScore: List.filled(10, 0),
        quizTime: List.filled(10, 0),
        achieve: List.filled(6, false),
        todayTime: 0,
        allTime: 0,
        equipBadge: 0,
      ),
    );
  }
}
