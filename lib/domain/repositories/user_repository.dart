import '../entities/user.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateUserName({required String uid, required String newName});
  Future<void> deleteUser({required String uid});
}
