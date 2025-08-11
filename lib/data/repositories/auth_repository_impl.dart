import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final userModel = await remoteDataSource.signIn(email, password);

    // 🔥 Ambil data dari Firestore
    final doc = await FirebaseFirestore.instance.collection('users').doc(userModel.uid).get();

    if (!doc.exists) {
      throw Exception("User data not found in Firestore");
    }

    final data = doc.data()!;
    return UserEntity(
      uid: userModel.uid,
      email: userModel.email,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
    );
  }

  @override
  Future<UserEntity> signUp(String email, String password) async {
    final userModel = await remoteDataSource.signUp(email, password);
    return UserEntity(uid: userModel.uid, email: userModel.email);
  }

  @override
  Future<void> saveUserToFirestore(UserEntity user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': user.name,
      'role': user.role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
