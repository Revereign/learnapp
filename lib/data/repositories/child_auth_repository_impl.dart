import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnapp/data/datasources/child_auth_remote_data_source.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/child_auth_repository.dart';

class ChildAuthRepositoryImpl implements ChildAuthRepository {
  final ChildAuthRemoteDataSource childRemoteDataSource;

  ChildAuthRepositoryImpl({required this.childRemoteDataSource});

  @override
  Future<UserEntity> childSignUp(String email, String password) async {
    final userModel = await childRemoteDataSource.childSignUp(email, password);
    return UserEntity(uid: userModel.uid, email: userModel.email);
  }

  @override
  Future<void> saveChildToFirestore(UserEntity user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': user.name,
      'role': user.role,
      'parentUid': user.parentUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
