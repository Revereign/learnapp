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
      'gameScore': List.filled(10, 0), // Default 0 untuk 10 level
      'quizScore': List.filled(10, 0), // Default 0 untuk 10 level
      'quizTime': List.filled(10, 0), // Default 0 untuk 10 level
      'achieve': List.filled(6, false), // Default false untuk 6 achievement
      'todayTime': 0, // Default 0
      'allTime': 0, // Default 0
    });
  }
}
