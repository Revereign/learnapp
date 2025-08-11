import '../entities/user.dart';

abstract class ChildAuthRepository {
  Future<UserEntity> childSignUp(String email, String password);
  Future<void> saveChildToFirestore(UserEntity user);
}