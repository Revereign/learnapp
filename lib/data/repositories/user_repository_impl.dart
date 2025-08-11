import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore firestore;

  UserRepositoryImpl({required this.firestore});

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final snapshot = await firestore.collection("users").get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc).toEntity())
        .where((user) =>
    user.role != "admin" &&
        user.deletedAt == null) // filter admin dan soft deleted
        .toList();
  }

  @override
  Future<void> updateUserName({required String uid, required String newName}) async {
    await firestore.collection("users").doc(uid).update({"name": newName});
  }

  @override
  Future<void> deleteUser({required String uid}) async {
    await firestore.collection("users").doc(uid).update({
      "deletedAt": FieldValue.serverTimestamp(), // soft delete
    });
  }
}
