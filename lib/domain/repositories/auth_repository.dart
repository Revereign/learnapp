import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(String email, String password);
  Future<void> saveUserToFirestore(UserEntity user);
  Future<void> signOut();
}
