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
      parentUid: data['parentUid'],
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      gameScore: data['gameScore'] != null
          ? List<int>.from(data['gameScore'])
          : null,
      quizScore: data['quizScore'] != null
          ? List<int>.from(data['quizScore'])
          : null,
      quizTime: data['quizTime'] != null
          ? List<int>.from(data['quizTime'])
          : null,
      achieve: data['achieve'] != null
          ? List<bool>.from(data['achieve'])
          : null,
      todayTime: data['todayTime'],
      allTime: data['allTime'],
      equipBadge: data['equipBadge'],
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
      'parentUid': user.parentUid,
      'deletedAt': user.deletedAt,
      'gameScore': user.gameScore ?? List.filled(10, 0),
      'quizScore': user.quizScore ?? List.filled(10, 0),
      'quizTime': user.quizTime ?? List.filled(10, 0),
      'achieve': user.achieve ?? List.filled(6, false),
      'todayTime': user.todayTime ?? 0,
      'allTime': user.allTime ?? 0,
      'equipBadge': user.equipBadge ?? 0,
    });
  }


  @override
  Future<void> updateUserEquipBadge(String uid, int equipBadge) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'equipBadge': equipBadge,
    });
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel == null) return null;

      // Ambil data dari Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(userModel.uid).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return UserEntity(
        uid: userModel.uid,
        email: userModel.email,
        name: data['name'] ?? '',
        role: data['role'] ?? '',
        parentUid: data['parentUid'],
        deletedAt: data['deletedAt'] != null
            ? (data['deletedAt'] as Timestamp).toDate()
            : null,
        gameScore: data['gameScore'] != null
            ? List<int>.from(data['gameScore'])
            : null,
        quizScore: data['quizScore'] != null
            ? List<int>.from(data['quizScore'])
            : null,
        quizTime: data['quizTime'] != null
            ? List<int>.from(data['quizTime'])
            : null,
        achieve: data['achieve'] != null
            ? List<bool>.from(data['achieve'])
            : null,
        todayTime: data['todayTime'],
        allTime: data['allTime'],
        equipBadge: data['equipBadge'],
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
